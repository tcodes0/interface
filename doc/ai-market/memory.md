# Indicator 3 — HBM / Memory

Methodology: [doc/ideas/investing/3.md](../ideas/investing/3.md).
Purpose: detect whether AI-memory demand stays tight or supply catches up. Cadence: HBM
observations and server DRAM monthly; memory-maker inventory quarterly. Append-only, oldest
first.

## 1. Memory-maker inventory days (primary quantitative signal, quarterly)

| Quarter | SK Hynix Inventory Days | Samsung Inventory Days | Micron Inventory Days | Notes | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- |

Sources: company quarterly earnings releases, 10-Q/10-K/annual reports, investor presentations.
Signal: low/stable → tight supply/strong demand; rising → potential normalization; rapidly
rising → potentially bearish. Capture company commentary when it materially explains a move.

## 2. HBM pricing (qualitative primary signal, monthly)

| Month | HBM Price Trend (Rising/Stable/Falling) | Generation (HBM3E/HBM4) | Source | Notes | Last Updated |
| --- | --- | --- | --- | --- | --- |

Sources: TrendForce, other credible semiconductor research, memory-company commentary as
supporting evidence. Don't manufacture a numerical price when the source only gives direction —
consistency across multiple credible reports is the key.

## 3. Server DRAM (bonus confirmation, monthly)

| Month | Server DRAM Price Trend (Rising/Stable/Falling) | Source | Last Updated |
| --- | --- | --- | --- |

Primary source: TrendForce DRAM pricing. Supporting evidence only — conventional DRAM has
applications far beyond AI.

## What we're looking for

- Strong AI-memory demand: HBM prices ↑ + inventory days low/stable + server DRAM prices ↑
- Potential deterioration: HBM prices ↓ + inventory days ↑ + server DRAM prices ↓

The combination matters far more than any single observation.

## Source hierarchy

1. SK Hynix / Samsung / Micron earnings and filings
2. TrendForce
3. Other reputable semiconductor research
4. Company/investor commentary
