# Indicator 3 — HBM / Memory

Purpose: detect whether AI-memory demand remains tight or whether memory supply is beginning to
catch up (see [dashboard.md](./dashboard.md)). Cadence: HBM market observations and server DRAM
prices monthly; memory-maker inventory data quarterly. Append-only, oldest first — never edit or
delete a historical row.

The sheet stays deliberately small: hard inventory data + qualitative HBM pricing + broader DRAM
pricing.

## 1. Memory-maker inventory days — primary quantitative signal (quarterly)

Companies: SK Hynix, Samsung, Micron.

**Days-inventory formula (fixed convention, apply consistently to every row/company/period):**
`ending Inventory ÷ that quarter's COGS × actual calendar days in the quarter` — actual days
(90/91/92), not an averaged 91.25, since exact period-start/period-end dates are available for
all three companies. Ending inventory (not average of beginning+ending) is used, matching what's
directly reported without extra derivation.

**Per-company sourcing:**

- **Micron** — SEC EDGAR XBRL company-concept API (CIK 0000723125), same method as capex.md:
  `InventoryNet` for the balance-sheet figure, `CostOfGoodsAndServicesSold` for COGS (derived to
  quarterly by grouping cumulative fiscal-year-to-date facts by `start` and diffing consecutive
  `end` values, same technique capex.md documents for capex). Micron's fiscal year ends ~Aug
  28/29, offsetting its fiscal quarters about one quarter _behind_ calendar quarters — same
  pattern as Oracle in capex.md. Each Micron cell/row notes its fiscal-quarter label; the
  "Quarter" column below aligns rows to the nearest calendar quarter for cross-company
  comparison, so Micron rows are an approximation of that calendar quarter, not exact.
- **SK Hynix / Samsung** — both KRX-listed, no SEC filings, so sourced from
  stockanalysis.com's balance-sheet and income-statement pages (`quote/krx/<ticker>/financials/...`),
  cross-checked against each company's own quarterly press release for revenue (both matched
  closely). Neither company's scraped income-statement page exposed a direct "Cost of Revenue"
  line, so COGS is derived as `Revenue − Gross Profit` for both.
- **Samsung caveat, applies to every Samsung figure in this table:** the Inventory, Revenue, and
  Gross Profit figures are Samsung Electronics' **whole-company** consolidated numbers (Galaxy
  phones, TVs, appliances, foundry, display, Harman, etc.), not the DS (Device Solutions /
  semiconductor) segment specifically. Confirmed unavailable at segment level, not just
  unchecked: Samsung's own interim consolidated financial statements (segment-information note)
  state explicitly that "Total assets and liabilities of each operating segment are excluded from
  the disclosure as these have not been provided regularly to the Management Committee." Treat
  the Samsung column as a noisy proxy, weighted less than Micron/SK Hynix in the narrative — it's
  flagged inline as "(whole-co.)" on every value.

| Quarter | SK Hynix Inventory Days | Samsung Inventory Days     | Micron Inventory Days                            | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | Source                                                      | Last Updated |
| ------- | ----------------------- | -------------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- | ------------ |
| Q4 2024 | —                       | —                          | 146.1 (FY25 Q1, end 2024-11-28)                  | Micron-only quarter; SK Hynix/Samsung backfill starts Q1/Q2 2025 (earliest quarters pulled from stockanalysis.com this pass).                                                                                                                                                                                                                                                                                                                                                    | Micron: SEC EDGAR XBRL                                      | 2026-08-16   |
| Q1 2025 | 173.8 (Q1 2025)         | —                          | 159.3 (FY25 Q2, end 2025-02-27)                  | Samsung not yet backfilled to this quarter. SK Hynix's high reading here (173.8) is the highest in the series so far, falling sharply from here through 2H2025.                                                                                                                                                                                                                                                                                                                  | Micron: SEC EDGAR XBRL; SK Hynix: stockanalysis.com         | 2026-08-16   |
| Q2 2025 | 119.1 (Q2 2025)         | 94.6 (whole-co., Q2 2025)  | 135.6 (FY25 Q3, end 2025-05-29)                  | All three falling or low relative to Q1 2025.                                                                                                                                                                                                                                                                                                                                                                                                                                    | Micron: SEC EDGAR XBRL; SK Hynix/Samsung: stockanalysis.com | 2026-08-16   |
| Q3 2025 | 116.2 (Q3 2025)         | 88.1 (whole-co., Q3 2025)  | 121.4 (FY25 Q4 / FY25 full-year, end 2025-08-28) | Lowest Samsung whole-co. reading in the series.                                                                                                                                                                                                                                                                                                                                                                                                                                  | Micron: SEC EDGAR XBRL; SK Hynix/Samsung: stockanalysis.com | 2026-08-16   |
| Q4 2025 | 128.3 (Q4 2025)         | 97.8 (whole-co., Q4 2025)  | 123.1 (FY26 Q1, end 2025-11-27)                  | SK Hynix ticks back up; Micron continues gradual decline.                                                                                                                                                                                                                                                                                                                                                                                                                        | Micron: SEC EDGAR XBRL; SK Hynix/Samsung: stockanalysis.com | 2026-08-16   |
| Q1 2026 | 131.9 (Q1 2026)         | 100.9 (whole-co., Q1 2026) | 121.9 (FY26 Q2, end 2026-02-26)                  | SK Hynix continues rising; Samsung whole-co. also rising off its Q3 2025 low.                                                                                                                                                                                                                                                                                                                                                                                                    | Micron: SEC EDGAR XBRL; SK Hynix/Samsung: stockanalysis.com | 2026-08-16   |
| Q2 2026 | 122.8 (Q2 2026)         | 124.5 (whole-co., Q2 2026) | 120.5 (FY26 Q3, end 2026-05-28)                  | Micron at series low (120.5, down from 146.1 seven quarters earlier) — the cleanest tightening signal of the three, since it's a pure-play memory maker. Samsung whole-co. jumped to its highest reading in the series this quarter; given the whole-company caveat above, don't read this as a memory-specific inventory build without corroboration — could reflect non-memory segments (e.g. device inventory ahead of a product cycle). SK Hynix roughly flat/slightly down. | Micron: SEC EDGAR XBRL; SK Hynix/Samsung: stockanalysis.com | 2026-08-16   |

Inventory days is the primary metric. Absolute inventory can be retained as supporting data but
isn't necessary for the core dashboard.

Primary sources: company quarterly earnings releases; 10-Q / 10-K / annual and quarterly
reports; investor presentations.

Signal: low/stable inventory days → tight supply / strong demand; rising → potential
normalization; rapidly rising → potentially bearish. Capture company commentary when it
materially explains the inventory movement.

## 2. HBM pricing — qualitative primary signal (monthly)

There doesn't appear to be a sufficiently transparent, standardized public HBM price series to
justify pretending we have precise monthly prices.

| Month   | HBM Price Trend (Rising/Stable/Falling) | Generation (HBM3E/HBM4) | Source                                          | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Last Updated |
| ------- | --------------------------------------- | ----------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| 2026-08 | Rising                                  | HBM3E→HBM4 transition   | TrendForce (2025-12-24, 2026-06-02, 2026-08-04) | ~20% HBM3E price hike planned for 2026 (Samsung/SK Hynix, per Chosun Biz). HBM's annual contract-pricing mechanism means contract prices lagged the broader DRAM price surge since 2H2025 — per TrendForce's per-wafer revenue analysis, HBM wafer revenue was actually overtaken by DDR5 64GB RDIMM in 1Q26 (HBM profitability temporarily below conventional DRAM), which is exactly why suppliers are pushing hard for a 2027 HBM4 contract-price surge ("multiples higher"). NVIDIA is evaluating _lower_ HBM configurations (8-Hi HBM4e/HBM4 vs. original 12-Hi HBM4e) for Rubin Ultra specifically because DRAM/HBM supply is too tight and HBM4e validation timelines are uncertain — a demand-outstripping-design-capacity signal, not demand weakening. TrendForce: HBM bit shipments projected +50-60% YoY in 2027, "still insufficient to keep pace with demand growth"; HBM to reach ~18%/22%/30% of total DRAM wafer input by end of 2025/2026/2027. | 2026-08-16   |

Sources: TrendForce; other credible semiconductor research/industry sources when necessary;
memory-company commentary as supporting evidence. Don't manufacture a numerical price when the
source only provides directional information — the key is consistency: if multiple credible
reports indicate HBM contract prices are rising or falling, record that direction and the
evidence.

## 3. Server DRAM — bonus confirmation (monthly)

| Month   | Server DRAM Price Trend (Rising/Stable/Falling) | Source                              | Last Updated |
| ------- | ----------------------------------------------- | ----------------------------------- | ------------ |
| 2026-08 | Rising                                          | TrendForce (2026-07-03, 2026-07-09) | 2026-08-16   |

Notes (2026-08 row): conventional DRAM contract prices forecast +13-18% QoQ in 3Q26, NAND +10-15%
QoQ. Server DRAM shortage already anticipated for 2027 — RDIMM bit supply projected to grow only
15-20% YoY in 2027, "significantly lagging" projected server CPU shipment growth. Server CPU
shortages (not DRAM itself) slowed system assembly in Q2 2026, causing DRAM inventory to build up
at US CSPs — a supply-chain-bottleneck nuance, not evidence of soft DRAM demand. From Q3 2026 on,
price increases expected to shift toward customers without long-term agreements (LTAs).
Moderation in the broader (+13-18%) forecast is attributed specifically to _consumer_
(PC/smartphone) demand hitting affordability limits, not server/AI demand, which TrendForce still
describes as tight/undersupplied.

Primary source: TrendForce DRAM pricing. Supporting evidence rather than a direct AI-demand
indicator, because conventional DRAM has applications far beyond AI.

## What we're looking for

- Strong AI-memory demand: HBM prices ↑ + inventory days low/stable + server DRAM prices ↑
- Potential deterioration: HBM prices ↓ + inventory days ↑ + server DRAM prices ↓

The combination matters much more than any individual observation.

## Source hierarchy

**Highest priority**

1. SK Hynix / Samsung / Micron earnings and filings
2. TrendForce

**Secondary**

3. Other reputable semiconductor research
4. Company/investor commentary
