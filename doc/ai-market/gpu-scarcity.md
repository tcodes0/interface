# Indicator 2 — GPU Scarcity

Purpose: track whether GPU supply is becoming easier to obtain and whether the scarcity premium
is disappearing (see [dashboard.md](./dashboard.md)). Updated monthly. Two generations tracked:
H100 (mature / last-generation) and B200 (current generation). Append-only, oldest first — never
edit or delete a historical row.

## Quantitative — resale and rental prices

| Month | GPU | Used/Resale Price | Cloud Rental Price | Source | Last Updated |
| --- | --- | --- | --- | --- | --- |
| 2026-08 | H100 SXM5 | $22,000–$27,000 | $1.60–$2.52/hr (on-demand; a handful of outlier listings ran up to $7.09/hr) | Compute Exchange (resale) + Vast.ai live marketplace API (rental) | 2026-08-16 |
| 2026-08 | B200 | not tracked | $4.13–$5.88/hr (on-demand; one outlier listing at $9.31/hr) | Vast.ai live marketplace API (rental) | 2026-08-16 |

- **H100 resale**: Compute Exchange, monthly, record a price range not a point estimate, keep
  GPU configuration consistent month to month.
- **Cloud rental**: Vast.ai, monthly snapshot, H100 and B200, record a representative
  price/range, keep methodology consistent between months.
- **B200 resale is not tracked** — the secondary market is too immature for now.

## Qualitative — availability / lead time

| Month | GPU | Availability / Lead-Time Observation | Source | Date |
| --- | --- | --- | --- | --- |
| 2026-08 | H100 (SXM/PCIe) | Cloud/rental capacity: multiple independent reports describe on-demand H100 as effectively sold out at scale during Jan-Mar 2026 ("impossible to find any H100s, H200s or B200 rental capacity for any term" by March), with 1-year contract pricing up ~40% from a $1.70/hr low (Oct 2025) to $2.35/hr (Mar 2026). More recent (Jul 2026) secondary sources describe on-demand *spot* rental prices falling sharply from the 2024 peak (~$8-10/hr) to $1.80-3.50/hr in Q2 2026 — a big divergence from the contract-price story, likely reflecting >300 new neocloud entrants fragmenting the on-demand rental pool even as committed/contract capacity stays tight. Direct purchase lead times still commonly cited at 6-18+ months depending on channel. | SemiAnalysis GPU Rental Price Index (Apr 2026 newsletter); Value Add VC (Jul 2026, secondary/aggregator); GPUSmith aggregator (Jul 2026) | 2026-08-16 |
| 2026-08 | H200 / B200 | Multiple independent sources (SemiAnalysis, GPUaaS.com, Lyceum Technology, Value Add VC) converge on **36-52 week lead times** for H200/B200 through standard hyperscaler/OEM channels as of Q2 2026, driven by HBM3e memory constraints and TSMC CoWoS packaging capacity allocated through at least mid-2027 — not GPU die supply itself. One source (GPUaaS.com, Apr/Jun 2026) reports *priority* enterprise/OEM lead times improved from 12-24 weeks (Q4 2025) to 8-16 weeks, but non-priority buyers still face 30+ weeks. Backlog estimated at ~3.6M B200 units as of April 2026. | GPUaaS.com (Apr/Jun 2026); Value Add VC (Jul 2026); Lyceum Technology (Apr 2026) | 2026-08-16 |

Example observations: "6–8 weeks", "in stock", etc. Not treated as a quantitative index — there
is no reliable standardized market-wide lead-time dataset, and individual supplier quotes can be
misleading. Instead look for multiple independent reports pointing in the same direction.

## What we're looking for

Strongest bearish development:

> H100 resale prices ↓ + H100 cloud rental prices ↓ + B200 cloud rental prices ↓ + independent
> availability reports improving

That would indicate the scarcity premium is disappearing across both the mature and current GPU
generations.

A weaker signal: H100 loosening while B200 remains expensive/constrained. That could simply
represent normal generational turnover rather than an AI demand slowdown.

No scoring or automated conclusions — keep observations raw and interpret convergence manually.
