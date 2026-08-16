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

## Reminders

- Don't manufacture precision a source doesn't provide (lead times, CoWoS utilization, HBM
  pricing are all qualitative/directional by design — see each sheet's methodology link).
- The signal we care about is convergence across layers, not any single indicator flipping. Keep
  the dashboard narrative honest about how many layers are actually confirming.
