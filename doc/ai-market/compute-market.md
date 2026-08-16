# Indicator 5 — Compute Market

Methodology: [doc/ideas/investing/5.md](../ideas/investing/5.md).
Purpose: detect whether the market is absorbing newly available compute, or whether supply is
beginning to exceed workload demand, observed directly through rental prices and availability
rather than by estimating efficiency and workload separately. Monthly. Append-only, oldest first.

Scope: H100 only for now. B200 can be added later if secondary-market data matures.

## Observed compute market

| Month | H100 Spot Price | H100 Availability | Vast.ai H100 Price | Vast.ai Availability | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- |

- ComputeTape: primary standardized H100/H100e spot-price series, clean downloadable history,
  monthly observations.
- Vast.ai: existing API access, monthly snapshots, H100 rental price + available capacity/GPU
  availability. Add other reliable supply/utilization fields if useful.

## What we're looking for

- Strong evidence of weakening compute demand: H100 spot price ↓ + Vast.ai rental price ↓ +
  available compute ↑. The more persistent the move, the more meaningful.
- Strong demand: prices stable/high + availability constrained.

No scoring or composite formula.

## Notes

- AI efficiency (indicator 5.1 in the spec) is deliberately **not tracked** — its effect should
  manifest here anyway; see the spec for the full rationale (efficiency gains can increase, not
  decrease, hardware demand if they unlock enough workload growth).
- Vast.ai is only a subset of the global compute market — treat it as a thermometer, not a claim
  about global utilization. ComputeTape as an independent series is what makes the signal useful.
