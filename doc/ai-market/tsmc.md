# Indicator 4 — TSMC / Advanced Manufacturing

Methodology: [doc/ideas/investing/4.md](../ideas/investing/4.md).
Two related indicators: TSMC HPC revenue (quarterly, whenever TSMC reports) and CoWoS /
advanced-packaging utilization (monthly/quarterly depending on data availability — realistically
quarterly is sufficient). Append-only, oldest first.

## 1. TSMC HPC revenue (primary)

| Quarter | HPC Revenue | HPC YoY Growth | HPC % of Revenue | Notes | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- |

Most important field: HPC YoY growth. No need to isolate AI revenue from HPC — the category is
exposed enough to AI accelerators to be a useful upstream proxy. Total TSMC revenue growth can be
kept as context but isn't a core field.

Signal: HPC growth accelerating → bullish; decelerating → warning; declining → bearish.

Source: TSMC quarterly earnings releases, investor presentations / financial reports.

## 2. CoWoS — capacity / utilization (qualitative)

| Period | Demand (Tight/Normal/Weak) | Utilization | Capacity / Expansion | Source | Notes |
| --- | --- | --- | --- | --- | --- |

TSMC doesn't publish a clean utilization number — don't manufacture precision that doesn't exist.
Focus on three things: demand/orders, utilization, capacity. **Capacity expansion ≠ bearish** —
only concerning when capacity expansion and weakening orders/utilization occur together.

Sources: TSMC earnings calls / investor commentary / announcements; credible semiconductor
research (particularly TrendForce); Reuters/Bloomberg for customer/order developments when
primary data isn't available. Give TSMC's own commentary priority, use industry sources to fill
gaps.

## What we're looking for

Key bearish combination: TSMC HPC growth decelerating + CoWoS demand/utilization weakening. The
strongest signal is this happening *after* Big Tech capex and GPU/HBM indicators have already
started deteriorating — confirmation moving upstream through the supply chain.
