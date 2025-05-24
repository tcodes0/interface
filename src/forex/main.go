// Copyright 2024 Raphael Thomazella. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file and online
// at https://opensource.org/license/BSD-3-clause.

package main

import (
	"context"
	_ "embed"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/tcodes0/go/clock"
	"github.com/tcodes0/go/jsonutil"
	"github.com/tcodes0/go/logging"
	"github.com/tcodes0/go/misc"
)

var (
	flagset  = flag.NewFlagSet(os.Args[0], flag.ContinueOnError)
	logger   = &logging.Logger{}
	errUsage = errors.New("see usage")
	errFinal error

	envColorVal    = "T0_COLOR"
	envLogLevelVal = "T0_LOGLEVEL"
	envAPIKeyVal   = "OPEN_EXCHANGE_RATES_API_KEY"

	apiBaseURL = "https://openexchangerates.org/api"
	redisAddr  = "localhost:6379"
	version    = "0.0.1"
)

func main() {
	defer func() {
		// the first deferred function will run last.
		if msg := recover(); msg != nil {
			logger.Stacktrace(logging.LError, true)
			logger.Fatalf("%v", msg)
		}

		passAway(errFinal)
	}()

	misc.DotEnv(".env", false /* noisy */)

	fColor := misc.LookupEnv(envColorVal, false)
	fLogLevel := misc.LookupEnv(envLogLevelVal, int(logging.LInfo))

	//nolint:gosec // log level does not overflow here
	opts := []logging.CreateOptions{logging.OptFlags(log.Lshortfile), logging.OptLevel(logging.Level(fLogLevel))}
	if fColor {
		opts = append(opts, logging.OptColor())
	}

	logger = logging.Create(opts...)
	fCurrency := flagset.String("currency", "", "currency to fetch rate for, e.g. USD, EUR, BRL. Required")
	fDBNumber := flagset.Int("db", 0, "database number to use, e.g. 0, 1. Optional")
	fBaseName := flagset.String("basename", "t0forex", "name used to save values in redis, e.g. myForex. Optional")
	fVerShort := flagset.Bool("v", false, "print version and exit")
	fVerLong := flagset.Bool("version", false, "print version and exit")

	err := flagset.Parse(os.Args[1:])
	if err != nil {
		errFinal = errors.Join(err, errUsage)

		return
	}

	if *fVerShort || *fVerLong {
		fmt.Println(version)

		return
	}

	envAPIKey := misc.LookupEnv(envAPIKeyVal, "")
	clk := &clock.Time{}

	errFinal = forex(*fCurrency, *fBaseName, envAPIKey, *fDBNumber, clk)
}

func passAway(fatal error) {
	if fatal != nil {
		if errors.Is(fatal, errUsage) {
			usage()
		}

		logger.Stacktrace(logging.LDebug, true)
		logger.Fatalf("%s", fatal.Error())
	}
}

func usage() {
	fmt.Printf(`
forex fetch script
use -h | --help for flag documentation

fetches a currency rate and stores it in a local database.
uses a currency API to fetch the rate. Skips fetching based on time and day of the week.

environment variables:
- %s toggle logger colored output (default: false)
- %s 1 - 5, 1 is debug. The higher the less logs (default: 2)
- %s api key
`, envColorVal, envLogLevelVal, envAPIKeyVal)
}

func forex(currency, setBasename, apiKey string, DBNumber int, clk clock.Nower) error {
	err := validate(currency, apiKey)
	if err != nil {
		return err
	}

	if !marketsOpen(clk) {
		logger.Info("markets closed, skipping fetch")

		return nil
	}

	rate, timestamp, err := fetchRateFromUSD(context.Background(), currency, apiKey)
	if err != nil {
		return err
	}

	logger.Debugf("currency: %s, rate: %f", currency, rate)

	err = save(context.Background(), rate, timestamp, DBNumber, setBasename, currency)

	return nil
}

func validate(currency, apiKey string) error {
	if currency == "" {
		return fmt.Errorf("currency code is required, e.g BRL")
	}

	if apiKey == "" {
		return fmt.Errorf("API key is required, see help")
	}

	if _, err := exec.LookPath("redis-cli"); err != nil {
		return fmt.Errorf("redis is not installed")
	}

	if err := exec.Command("redis-cli", "ping").Run(); err != nil {
		return fmt.Errorf("redis is not running")
	}

	return nil
}

func marketsOpen(clk clock.Nower) bool {
	dayOfWeek, hour := clk.Now().Weekday(), clk.Now().Hour()

	// Markets not open yet on Sunday
	if dayOfWeek == time.Sunday && hour < 22 {
		return false
	}
	// Markets closed for the weekend: Friday after 22:00 UTC
	if dayOfWeek == time.Friday && hour >= 22 {
		return false
	}
	// Saturday is always closed
	if dayOfWeek == time.Saturday {
		return false
	}

	// Market volume too low between 23–10 UTC (~18–7 EST)
	if hour > 22 || hour < 11 {
		return false
	}

	return true
}

type openExchangeRatesLatest struct {
	Timestamp float64            `json:"timestamp"`
	Rates     map[string]float64 `json:"rates"`
}

func fetchRateFromUSD(ctx context.Context, currency, apiKey string) (float64, float64, error) {
	query := url.Values{}
	query.Set("app_id", apiKey)

	res, err := get(ctx, nil, "latest.json", nil, query)
	if err != nil {
		return 0, 0, misc.Wrapfl(err)
	}

	if res.StatusCode != http.StatusOK {
		return 0, 0, fmt.Errorf("failed to fetch rate: %s", res.Status)
	}

	latest, err := jsonutil.UnmarshalReader[openExchangeRatesLatest](res.Body)
	res.Body.Close()

	if err != nil {
		return 0, 0, misc.Wrapfl(err)
	}

	rate, ok := latest.Rates[currency]
	if !ok {
		return 0, 0, fmt.Errorf("currency %s not found in response", currency)
	}

	if rate == 0 {
		return 0, 0, fmt.Errorf("currency %s has invalid rate", currency)
	}

	if latest.Timestamp == 0 {
		return 0, 0, fmt.Errorf("invalid timestamp")
	}

	return rate, latest.Timestamp, nil
}

func get(ctx context.Context, client *http.Client, path string, header http.Header, query url.Values) (*http.Response, error) {
	return doRequest(ctx, client, http.MethodGet, path, http.NoBody, header, query)
}

func doRequest(ctx context.Context, client *http.Client, method, path string, body io.Reader, header http.Header, query url.Values) (*http.Response, error) {
	url := apiBaseURL + "/" + path + "?" + query.Encode()

	req, err := http.NewRequestWithContext(ctx, method, url, body)
	if err != nil {
		return nil, misc.Wrapfl(err)
	}

	req.Header = header

	if client == nil {
		client = &http.Client{}
	}

	logger.DebugData(map[string]any{"method": method, "url": url, "headers": header}, "request")

	resp, err := client.Do(req)
	if err != nil {
		return nil, misc.Wrapfl(err)
	}

	logger.DebugData(map[string]any{"status": resp.StatusCode}, "response")

	return resp, nil
}

func save(ctx context.Context, rate float64, timestamp float64, DBNumber int, setBasename, currency string) error {
	db := redis.NewClient(&redis.Options{
		Addr: redisAddr,
		DB:   DBNumber,
	})

	op := db.ZAdd(ctx, setBasename+"_"+currency, redis.Z{
		Score:  timestamp,
		Member: rate,
	})
	if op.Err() != nil {
		return misc.Wrapfl(op.Err())
	}

	if op.Val() == 0 {
		return fmt.Errorf("failed to save rate")
	}

	return nil
}
