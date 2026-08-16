# Indicator 3 — HBM / Memory

Purpose: detect whether AI-memory demand remains tight or whether memory supply is beginning to
catch up (see [dashboard.md](./dashboard.md)). Cadence: HBM market observations and server DRAM
prices monthly; memory-maker inventory data quarterly. Append-only, oldest first — never edit or
delete a historical row.

The sheet stays deliberately small: hard inventory data + qualitative HBM pricing + broader DRAM
pricing.

## 1. Memory-maker inventory days — primary quantitative signal (quarterly)

Companies: SK Hynix, Samsung, Micron.

| Quarter | SK Hynix Inventory Days | Samsung Inventory Days | Micron Inventory Days | Notes | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- |

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

| Month | HBM Price Trend (Rising/Stable/Falling) | Generation (HBM3E/HBM4) | Source | Notes | Last Updated |
| --- | --- | --- | --- | --- | --- |

Sources: TrendForce; other credible semiconductor research/industry sources when necessary;
memory-company commentary as supporting evidence. Don't manufacture a numerical price when the
source only provides directional information — the key is consistency: if multiple credible
reports indicate HBM contract prices are rising or falling, record that direction and the
evidence.

## 3. Server DRAM — bonus confirmation (monthly)

| Month | Server DRAM Price Trend (Rising/Stable/Falling) | Source | Last Updated |
| --- | --- | --- | --- |

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
