# Updating the AI Market Dashboard

How to keep the indicator sheets current. For the rationale and full indicator dashboard, see
[dashboard.md](./dashboard.md).

## Cadence

### Monthly (every month, regardless of earnings)

- **GPU scarcity** ([gpu-scarcity.md](./gpu-scarcity.md)): Compute Exchange H100 resale range,
  Vast.ai H100/B200 rental snapshot, lead-time/availability chatter from independent sources.
- **HBM pricing** ([memory.md](./memory.md), section 2): TrendForce / credible semiconductor
  research directional read (Rising/Stable/Falling).
- **Server DRAM** ([memory.md](./memory.md), section 3): TrendForce DRAM contract price trend.
- **Compute market** ([compute-market.md](./compute-market.md)): ComputeTape H100 spot price,
  Vast.ai H100 rental price + availability.

### Quarterly (gated on earnings releases)

- **Big Tech capex** ([capex.md](./capex.md)): Microsoft, Amazon, Alphabet, Meta cluster in late
  Jan / Apr / Jul / Oct; Oracle runs on an offset fiscal calendar — check separately.
- **Memory-maker inventory days** ([memory.md](./memory.md), section 1): SK Hynix, Samsung,
  Micron earnings/filings. Micron's fiscal calendar is offset from the others.
- **TSMC HPC + CoWoS** ([tsmc.md](./tsmc.md)): TSMC reports monthly revenue but HPC breakdown and
  CoWoS commentary come with the quarterly earnings call, typically mid-month following quarter
  close.

> Rough earnings windows only — confirm exact dates each cycle, companies shift by a week or two.

## Update steps

1. Pull the relevant primary sources for whatever is due this cycle (see cadence above and the
   source hierarchy in each sheet).
2. Append new row(s) to the relevant sheet(s) — **never edit or delete a historical row.** If a
   number needs correcting, append a new row and note the correction; keeps the sheet
   git-diffable and honest.
3. Recompute YoY / TTM where the sheet defines a formulaic field (capex, HPC growth). No scoring
   or composite indices — that's an explicit non-goal across all five sheets.
4. Refresh [dashboard.md](./dashboard.md): update each row's "Current Read" and "Last Updated",
   and revise the narrative paragraph if the overall picture has shifted.
5. Commit directly to `dev` (small, recurring, well-defined — no PR needed per the github skill's
   dev-branch convention): `data(ai-market): <month> <year> update`.

## Updating Indicator 1 — Big Tech Capex

First full pass done 2026-08-16 (Q2 2026 calendar quarter / most-recent fiscal quarter per company).
Notes for next time:

**Best source found: SEC EDGAR's XBRL company-concept API, not press releases or HTML pages.**
Company IR pages and press-release HTML are inconsistently structured (some render financial
tables via JS-injected React 'flight' payloads that don't show up in a raw HTML fetch, some serve
CloudFront pages that return near-empty bodies to a plain `curl`). The reliable path is:

```
https://data.sec.gov/api/xbrl/companyconcept/CIK<10-digit-cik>/us-gaap/PaymentsToAcquirePropertyPlantAndEquipment.json
```

(Amazon's own filings tag this line `PaymentsToAcquireProductiveAssets` instead — same cash-flow
line, different XBRL tag; check `companyfacts` for the full tag list if a `companyconcept` call
comes back empty or stale.) Send a descriptive `User-Agent` header (SEC blocks/deprioritizes
requests without one, per their fair-access policy) — e.g. `-A 'Merlin research
merlin@golang.dev.br'`.

This endpoint returns every historical XBRL fact tagged under that concept, across every filing
that reported it (so the same quarter often appears 2-3 times, once per filing that included it as
a comparative period — dedupe by `(start, end)` keeping the row with the latest `filed` date).

**The API gives cumulative fiscal-year-to-date figures, not clean quarterly numbers.** A 10-Q for
Q3 reports capex for the full 9 months, not just Q3. To get a quarterly figure, group facts by
their `start` date (which resets each fiscal year) and diff consecutive cumulative values within
that group. Wrote a small script to do this (`derive_quarterly` — group by `start`, sort by `end`,
subtract). This also naturally handles Oracle and Amazon's non-calendar or shifted fiscal quarters.

**CIKs used, for reference:** Microsoft 0000789019, Amazon 0001018724, Alphabet 0001652044, Meta
0001326801, Oracle 0001341439.

**Two different "capex" figures coexist and must not be blended.** The cash-flow-statement line
(`PaymentsToAcquirePropertyPlantAndEquipment` — cash actually paid for PP&E) is what these SEC
facts represent, and is what the sheet's quantitative columns use for consistency across
companies and time. But company guidance and earnings-call commentary very often use a broader
"capital expenditures" figure that **includes finance-lease principal payments** — e.g. Microsoft
reported "$41 billion" in capex on its Q4 FY26 call while cash paid for PP&E per the 10-K was
$35.8B, a ~$5B gap from finance leases. Record which figure a guidance quote refers to (most
companies now say so explicitly, e.g. Meta's "including principal payments on finance leases").
Don't silently reconcile them into one number.

**Forward guidance quotes come from earnings call transcripts, not press releases.** Press
releases report actuals; guidance for the upcoming quarter/year is almost always spoken on the
call. Motley Fool's `fool.com/earnings/call-transcripts/...` and Investing.com's
`investing.com/news/transcripts/...` both publish full transcripts within days of the call and are
reliably scrapable with a plain `curl -A 'Mozilla/5.0'`; search for the company name + quarter +
"earnings call transcript" via the `lga-websearch` skill's SearXNG instance to find the URL, then
grep the fetched HTML for "capital expenditure"/"capex" to jump straight to the relevant
paragraphs. Quote close to verbatim and attribute to the speaker (usually the CFO).

**Oracle's fiscal year runs ~3 months ahead of calendar** (FY ends May 31, quarters end
Feb/May/Aug/Nov). When aggregating into the Big Tech Capex total, its quarter is time-shifted by
about a month relative to the other four companies' calendar quarters — the aggregate is therefore
a close approximation for any row that includes Oracle, not an exact calendar-quarter sum. Keep
Oracle's own fiscal-quarter label alongside the calendar-quarter alignment in the per-company
table so this is auditable later.

**PDF earnings releases work fine with `pdfminer.six`** (`pip install pdfminer.six`,
`extract_text()`) when a company's investor-relations HTML page doesn't render financials
statically — this is how Alphabet's numbers were double-checked against SEC data (both matched
exactly, good cross-validation signal that the pipeline is sound).

## Updating Indicator 2 — GPU Scarcity

First full pass done 2026-08-16. Notes for next time:

**No single source covers both resale price and lead time reliably — expect to combine 3-4 sources
per update.** Unlike indicator 1 (one XBRL endpoint covers all companies), GPU scarcity data is
scattered across a marketplace site (resale), a rental marketplace's live API (cloud rental), and
a handful of industry blogs/newsletters (lead times). Budget more search time for this sheet than
for capex.

**Compute Exchange's own blog/article pages return an empty body to a plain `curl`** (Next.js
react-server-component streaming, similar to what capex.md's notes describe for some IR pages) —
but its **product/category pages** (e.g. `compute.exchange/hardware-market/used-gpus`) render the
price data server-side and work fine with a plain `curl -A 'Mozilla/5.0' ...`. If a Compute
Exchange URL comes back as 0 bytes, look for the equivalent hardware-market/pricing page instead
of the blog post.

**Vast.ai has a public, unauthenticated marketplace API that's a much better source than scraping
their pricing pages.** The pricing pages themselves (`vast.ai/pricing/gpu/<model>`) are Next.js
pages that render price into a client-side JS bundle, not in the static HTML — `curl` gets a
skeleton page with a loading-shimmer placeholder where the price should be, no amount of
User-Agent spoofing fixes this since it's a code-splitting issue, not a bot-blocking one. Instead
hit the marketplace API directly, which returns live, granular per-listing offers:

```bash
curl -s -G 'https://cloud.vast.ai/api/v0/bundles/' \
  --data-urlencode 'q={"gpu_name":{"in":["H100 SXM"]},"num_gpus":{"eq":1},"rentable":{"eq":true},"order":[["dph_total","asc"]]}'
```

`gpu_name` must match Vast's internal naming exactly (`"H100 SXM"`, `"B200"`, etc. — hit the
endpoint with no `q` filter first and inspect `set(o['gpu_name'] for o in offers)` if unsure of
the exact string). `dph_total` is dollars-per-hour total (GPU + host overhead) for that listing;
sort ascending and read off the low end of the distribution as the "representative" on-demand
price, but eyeball the whole list first — a single outlier listing (e.g. one host at 3x everyone
else) can badly skew a naive min/max range if quoted uncritically. This endpoint has no auth and
no documented rate limit encountered so far; it's technically undocumented (found by inspecting
network behavior of `cloud.vast.ai`, not from a published API doc), so verify it's still live and
hasn't moved before relying on it again.

**There's now a dedicated `api_keys-vast_ai_mcp_litellm` tool (authenticated, base URL
`https://console.vast.ai/api/v0`) — confirmed working 2026-08-16, prefer it over the raw
unauthenticated `curl` above.** It hits vast.ai's real (authenticated) REST API, not the
undocumented public marketplace endpoint, so it's less likely to get rate-limited or silently
changed out from under this workflow. Verified request shape (differs from the unauthenticated
`cloud.vast.ai` endpoint above in two ways: no `q=` JSON-string query-param wrapper, and it needs
a trailing slash or you'll get a 301):

```
method: POST
path: /bundles/
headers: {"Content-Type": "application/json"}
body: {"gpu_name": {"in": ["H100 SXM"]}, "num_gpus": {"eq": 1}, "rentable": {"eq": true}, "order": [["dph_total", "asc"]], "limit": 20}
```

The filter fields go directly at the top level of the JSON body — no `q` wrapper needed here
(that's a quirk of the public `cloud.vast.ai/api/v0/bundles/` endpoint, not this one). A bare
`POST /bundles/` with an empty or minimal body (e.g. `{"limit": 3}`) also works and is a good way
to sanity-check the tool/key are alive before building a full filter. Response shape (`{"offers":
[...]}`, same `dph_total`/`gpu_name`/`rentable` fields) matches the unauthenticated endpoint, so
the rest of this section's guidance on reading `dph_total`, watching for outliers, etc. still
applies unchanged. Fall back to the plain `curl` only if the authenticated tool is unavailable or
errors.

**Lead-time claims across GPU-industry blogs vary by 2-4x depending on channel and buyer
priority — don't average them, report the range and attribute each figure.** For the same month
(Q2 2026), sources reported H200/B200 lead times anywhere from "8-16 weeks for priority OEM
buyers" to "36-52 weeks through standard hyperscaler channels" to "30+ weeks for non-priority
enterprise buyers." These aren't contradictory once you notice they're describing different
buyer tiers/channels, not different points in time. Read the fine print on *who* the lead time
applies to before treating two numbers as comparable.

**Distinguish "on-demand spot rental price" from "1-year contract/committed rental price" — they
can move in opposite directions at the same time and both are relevant to different halves of
the indicator.** SemiAnalysis (a paid research firm's public newsletter) reported 1-year H100
contract pricing *rising* ~40% Oct 2025 → Mar 2026 due to committed-capacity scarcity, while
other secondary sources reported on-demand *spot* pricing *falling* sharply from the 2024 peak
over a similar window — attributed to a wave of new neocloud entrants fragmenting spot supply.
Both can be true simultaneously and the divergence itself is informative (see dashboard.md's
current-read narrative) — don't collapse them into one "the rental price is $X" figure.

**Treat single-outlet "industry newsletter" and SEO-content-farm sources (GPUaaS.com, GPUSmith,
Value Add VC, Silicon Analysts, Lyceum Technology, etc.) as directionally useful but not
authoritative on their own — look for the same figure corroborated across 2-3 independently
operated sites before trusting it.** Several of these clearly aggregate from each other (nearly
identical "36-52 weeks" and "3.6 million unit backlog" phrasing recurs verbatim across multiple
sites), which means they may share a single upstream source rather than being truly independent
confirmations — treat convergent phrasing with a bit of suspicion, not as N independent data
points. SemiAnalysis is the one outlet in this space with a named research methodology (survey +
transaction data across neoclouds) and is worth weighting more heavily than the unattributed
aggregator sites.

**Publish dates matter more here than for capex** — GPU market conditions in this cycle are
moving fast enough that a "2026" article without a specific month can be stale by the time it's
found via search. Check `datePublished`/`dateModified` in the page's JSON-LD (`grep -o
'datePublished[^,]*' page.html`) before citing a figure, and prefer the search engine's own
`publishedDate` field on the result (via the `lga-websearch` skill's JSON output) as a first-pass
filter before fetching.

## Updating Indicator 3 — HBM / Memory

First full pass done 2026-08-16 (HBM pricing/server DRAM as of Aug 2026; inventory days backfilled
Q4 2024 - Q2 2026). Notes for next time:

**TrendForce press-center and news pages are directly curl-able**, same as noted for the GPU
scarcity indicator's earlier research — `curl -A 'Mozilla/5.0' <url>` renders server-side fine, no
JS-rendering problem. Good, reliable source for HBM/DRAM qualitative pricing direction. JSON-LD
`datePublished` is present in the page head (`grep -o 'datePublished[^,]*' page.html`), useful for
freshness-checking the same way indicator 2's notes recommend for GPU lead-time articles.
**TrendForce doesn't publish a clean numeric HBM contract price series** — everything found is
directional ("~20% hike", "13-18% QoQ") or about deltas, not absolute price levels. Stick with
Rising/Stable/Falling + quoted percentage deltas, don't try to build a price index. Treat articles
repeated near-verbatim across secondary outlets (TechTimes, BigGo Finance, Reddit, KuCoin news,
etc.) as one underlying TrendForce source, not independent confirmations — same caution as
indicator 2's notes on convergent-phrasing sources.

**Memory-maker inventory days must be derived, not sourced directly** — nobody publishes it
cleanly for all three companies. Fixed formula (documented in memory.md itself, keep both docs in
sync if it ever changes): `ending Inventory ÷ that quarter's COGS × actual calendar days in the
quarter` (actual day-count, not an averaged 91.25 — exact period dates are available for all
three). Ending inventory, not average of beginning+ending.

- **Micron**: SEC EDGAR XBRL company-concept API (CIK 0000723125), `InventoryNet` +
  `CostOfGoodsAndServicesSold`, derived to quarterly the same way capex.md documents for capex
  (group cumulative FYTD facts by `start`, sort by `end`, diff consecutive values). Fiscal year
  ends ~Aug 28/29, offsetting fiscal quarters ~1 quarter behind calendar quarters — same pattern
  as Oracle in capex.md, keep both labels.
- **SK Hynix / Samsung**: no SEC filings (KRX-listed) — use stockanalysis.com's
  `quote/krx/<ticker>/financials/balance-sheet/?p=quarterly` and `financials/?p=quarterly` pages,
  both plain-curlable, no blocking encountered. Cross-check the scraped revenue figure against
  each company's own press release before trusting the rest of the page (done this pass for both
  — matched closely). Neither ticker's income-statement page exposes a direct "Cost of Revenue"
  line in what's rendered server-side; COGS is derived as `Revenue − Gross Profit` instead — worth
  re-checking whether a cleaner line item exists deeper in the page before continuing to rely on
  the derived version. **Don't use stockanalysis.com's `ratios/?p=quarterly` "Inventory Turnover"
  row** — its quarterly-vs-annualized convention was never verified; derive from raw
  Inventory/COGS instead, as above.
- **Samsung's inventory (and revenue/COGS) is whole-company, not DS-segment-specific, and this is
  now confirmed structural, not just unavailable-this-pass**: Samsung's own interim consolidated
  financial statements' segment-information note states plainly that segment-level assets and
  liabilities (which includes inventory) are excluded from disclosure because they aren't
  regularly provided to the Management Committee. Checked the full quarterly financial statements
  PDF (`images.samsung.com/.../<year>_con_quarter<NN>_all.pdf`, extracted via `pdfminer.six`), not
  just the press release — the caveat holds at that level of detail too, no need to re-check DART
  or the annual/semiannual report specifically, this is Samsung's stated disclosure policy.
  Keep reporting the whole-company figure (flagged "(whole-co.)" inline per memory.md's
  convention) rather than dropping Samsung from the table — it's the best available proxy — but
  don't read a whole-company inventory move as a memory-specific signal without corroboration from
  Micron/SK Hynix or DS-segment revenue/profit commentary in the earnings release.
- Samsung's newsroom (`news.samsung.com`) was flaky again this pass (timeouts on a plain curl);
  `news.samsungsemiconductor.com` mirrors the same press releases and was reliably reachable —
  try that host first before falling back to secondary sources (pulse2, techtimes, bubblear,
  investing.com's earnings-slide coverage all covered the same Q2 2026 release in enough detail to
  cross-check).

**SEC EDGAR Archives HTML pages block automated requests even with a descriptive User-Agent
string — use the XBRL companyconcept API only**, same finding as capex.md's SEC EDGAR notes for
indicator 1 (not re-litigated here, see that section). Confirmed again this pass for Micron.

## Reminders

- Don't manufacture precision a source doesn't provide (lead times, CoWoS utilization, HBM
  pricing are all qualitative/directional by design — see each sheet's methodology link).
- The signal we care about is convergence across layers, not any single indicator flipping. Keep
  the dashboard narrative honest about how many layers are actually confirming.
