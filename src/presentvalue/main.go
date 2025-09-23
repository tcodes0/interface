package main

import (
	"fmt"
	"math"
	"os"
	"strings"
)

func presentValue(total float64, installments int, annualInterest float64) float64 {
	fmt.Printf("%d monthly installments\nannual interest of %.2f%%\nvalue of %.2f\n", installments, annualInterest*100, total)

	monthlyInterest := math.Pow(1+annualInterest, 1.0/12.0) - 1 // formula for compound interest
	installmentValue := total / float64(installments)

	fmt.Printf("monthly interest: %.2f%% (compound)\ninstallment value %.2f\n", monthlyInterest*100, installmentValue)

	pv := 0.0
	for installmentN := range installments {
		pv += installmentValue / math.Pow(1+monthlyInterest, float64(installmentN))

		fmt.Printf("payment %d, total present value: %.2f\n", installmentN+1, pv)
	}

	return pv
}

func main() {
	if len(os.Args) != 4 {
		usageFatal(fmt.Errorf("invalid number of arguments"))
	}

	value, installments, interestYear := 0.0, 0, 0.0

	_, err := fmt.Sscanf(strings.Join(os.Args[1:], " "), "%f%d%f", &value, &installments, &interestYear)
	if err != nil {
		usageFatal(err)
	}

	vp := presentValue(value, installments, interestYear)
	percentSaved := (1 - vp/value) * 100

	fmt.Printf("present value in installments: R$ %.2f\n", vp)
	fmt.Printf("save: R$ %.2f (%.2f%%)", value-vp, percentSaved)
}

func usageFatal(err error) {
	fmt.Println("Error: ", err.Error())
	fmt.Println("usage: presentvalue <value> <installments> <interest-year>")
	fmt.Println("example: presentvalue 1000 10 0.15")

	os.Exit(1)
}
