# Indicator 4 — TSMC / Advanced Manufacturing

Two related indicators (see [dashboard.md](./dashboard.md)):

1. TSMC HPC revenue
2. CoWoS / advanced packaging utilization and capacity

Cadence: HPC quarterly, whenever TSMC reports. CoWoS monthly/quarterly depending on data
availability, but realistically quarterly is sufficient for the dashboard — no need to chase
every capacity announcement. Append-only, oldest first — never edit or delete a historical row.

## 1. TSMC HPC revenue — primary

TSMC reports revenue by platform, including HPC.

| Quarter | HPC Revenue | HPC YoY Growth | HPC % of Revenue | Notes | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- |

The most important field is HPC YoY growth. No need to attempt to isolate AI revenue from HPC —
HPC includes other applications, but the category is sufficiently exposed to AI accelerators to
provide a useful upstream proxy. Total TSMC revenue growth can be kept as context but doesn't
need to be a core field.

Source: TSMC quarterly earnings releases; TSMC investor presentations / financial reports.

Signal: HPC growth accelerating → bullish; decelerating → warning; declining → bearish.

## 2. CoWoS — capacity / utilization

Trickier because TSMC doesn't give a nice monthly "CoWoS utilization = 94%" number — like HBM
pricing, don't manufacture precision that doesn't exist.

| Period | Demand (Tight/Normal/Weak) | Capacity / Expansion | Utilization | Source | Notes |
| --- | --- | --- | --- | --- | --- |

Focus on three things:

- **Demand / orders**: strong customer demand, capacity fully booked, orders increasing/decreasing.
- **Utilization**: high/tight, normalizing, falling.
- **Capacity**: new CoWoS capacity coming online, expansion plans, geographic/fab expansion.

Important distinction: **capacity expansion ≠ bearish**. We only care when capacity expansion and
weakening orders/utilization occur together.

## Sources

**HPC revenue**: TSMC earnings releases; TSMC investor presentations.

**CoWoS**: TSMC earnings calls / investor commentary; TSMC announcements; credible semiconductor
research, particularly TrendForce; potentially Reuters/Bloomberg for customer/order developments
when primary data isn't available. Give TSMC's own commentary priority, use industry sources to
fill in the gaps.

## What we're looking for

Key bearish combination: TSMC HPC growth decelerating + CoWoS demand/utilization weakening. The
strongest signal would be if that happens *after* Big Tech capex and GPU/HBM indicators have
already started deteriorating — confirmation moving upstream through the physical supply chain.
