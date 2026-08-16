# Indicator 2 — GPU Scarcity

Methodology: [doc/ideas/investing/2.md](../ideas/investing/2.md).
Purpose: track whether GPU supply is loosening and the scarcity premium is disappearing.
Updated monthly. Two generations tracked: H100 (mature) and B200 (current). Append-only, oldest
first.

## Quantitative — resale and rental prices

| Month | GPU | Used/Resale Price | Cloud Rental Price | Source | Last Updated |
| --- | --- | --- | --- | --- | --- |

- H100 resale: Compute Exchange, monthly, record a range not a point estimate, keep GPU config
  consistent month to month.
- Cloud rental: Vast.ai, monthly snapshot, H100 and B200, keep methodology consistent.
- B200 resale is **not tracked** — secondary market too immature.

## Qualitative — availability / lead time

| Month | GPU | Availability / Lead-Time Observation | Source | Date |
| --- | --- | --- | --- | --- |

- Not a quantitative index — no standardized market-wide lead-time dataset exists and single
  supplier quotes can mislead. Look for multiple independent reports pointing the same direction.

## What we're looking for

Strongest bearish combination: H100 resale ↓ + H100 cloud rental ↓ + B200 cloud rental ↓ +
independent availability reports improving — scarcity premium disappearing across both
generations.

Weaker/ambiguous signal: H100 loosening while B200 stays expensive/constrained — could just be
normal generational turnover, not a demand slowdown.

No scoring or automated conclusions — interpret convergence manually.
