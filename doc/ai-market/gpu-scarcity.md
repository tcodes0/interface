# Indicator 2 — GPU Scarcity

Purpose: track whether GPU supply is becoming easier to obtain and whether the scarcity premium
is disappearing (see [dashboard.md](./dashboard.md)). Updated monthly. Two generations tracked:
H100 (mature / last-generation) and B200 (current generation). Append-only, oldest first — never
edit or delete a historical row.

## Quantitative — resale and rental prices

| Month | GPU | Used/Resale Price | Cloud Rental Price | Source | Last Updated |
| --- | --- | --- | --- | --- | --- |

- **H100 resale**: Compute Exchange, monthly, record a price range not a point estimate, keep
  GPU configuration consistent month to month.
- **Cloud rental**: Vast.ai, monthly snapshot, H100 and B200, record a representative
  price/range, keep methodology consistent between months.
- **B200 resale is not tracked** — the secondary market is too immature for now.

## Qualitative — availability / lead time

| Month | GPU | Availability / Lead-Time Observation | Source | Date |
| --- | --- | --- | --- | --- |

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
