# Indicator 1 — U.S. Hyperscaler Capex

Scope: Microsoft, Amazon, Alphabet, Meta, Oracle. Tracks quarterly capex and the direction of
spending growth. This is explicitly a **U.S. hyperscaler capex proxy**, not global AI capex — the
primary **demand-side indicator** in the dashboard (see [dashboard.md](./dashboard.md)).

Updated manually on a quarterly cadence, on each company's earnings release. Append-only, oldest
first — never edit or delete a historical row.

## Per-company

| Company | Quarter | Capex | Capex YoY | TTM Capex | TTM Capex YoY | Fwd Guidance | Next Update | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

- **Next Update** = when new data should become available (i.e. next earnings date).
- **Last Updated** = when we actually refreshed the sheet.

## Aggregate

| Quarter | Big Tech Capex | Capex YoY | TTM Capex | TTM Capex YoY |
| --- | --- | --- | --- | --- |

Big Tech Capex = Microsoft + Amazon + Alphabet + Meta + Oracle.

## Sources

Company earnings releases, investor-relations materials, SEC filings where applicable.

## Notes

- Forward guidance isn't consistently given by every company every quarter — record when
  available, don't manufacture an estimate.
- No scoring or trend formulas beyond the basic YoY / TTM / aggregate calculations, no automatic
  conclusions.
- Future: a separate China AI Capex sheet, kept out of this aggregate, for independent US/China
  comparison.
