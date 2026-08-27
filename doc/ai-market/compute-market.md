# Indicator 5 — Compute Market

Purpose: detect whether the market is absorbing newly available compute, or whether compute
supply is beginning to exceed workload demand.

Underlying hypothesis:

> Efficiency gains > workload growth → required compute falls → excess compute appears → compute
> prices fall.

Rather than trying to separately estimate efficiency and workload, we observe the final market
effect directly. Monthly. Append-only, oldest first — never edit or delete a historical row.

## 5.1 — AI efficiency (future enhancement, not tracked)

Definition: the amount of useful AI capability or workload produced per unit of
compute/hardware/cost — e.g. inference performance per GPU, tokens/sec per GPU, AI performance
per hardware dollar, model capability per unit of compute, inference cost per unit of useful
output.

Not tracked initially: measuring it cleanly across different models, hardware generations and
workloads is difficult, while its effect should ultimately appear in the compute market below.
See also [dashboard.md](./dashboard.md) for the broader rationale on excluding AI efficiency from
the core dashboard.

Potential future sources: MLPerf, Artificial Analysis, Epoch AI, NVIDIA/AMD benchmarks.

## 5.2 — Observed compute market (core, tracked)

Definition: the market-clearing demand for actual GPU compute, observed through compute rental
prices and available capacity — the practical proxy for the effect we're interested in.

Scope: H100 only for now. B200 can be added later if the market data becomes sufficiently mature.

| Month   | H100 Spot Price                                                                                                                                                                                                                                                                                                    | H100 Availability                                                                                                                                                                                                                                                         | Vast.ai H100 Price                                                                                                                                               | Vast.ai Availability                                                                      | Source                                                                                                                                                              | Last Updated |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| 2026-08 | ComputeTape CT-H100 on-demand median $5.22/hr across 6 sourced providers (Hyperstack $3.20, Crusoe $3.90, Lambda $4.29, CoreWeave $6.16, AWS $6.88, Azure $12.29); spot-median sub-metric $2.46/hr; blended H100e-normalized $5.41/hr. Weekly move: flat (0.0% same-provider change, 6 providers in both periods). | Per-provider tags from ComputeTape: Lambda "Available"; Hyperstack, Crusoe, CoreWeave "Available Limited"; AWS, Azure "Quota Gated" — i.e. neoclouds report limited-but-open capacity while both hyperscalers are quota-gated. No aggregate availability index published. | $1.60–$7.08/hr across 11 rentable single-GPU listings, median $2.52/hr (low end: Ohio/Japan/Netherlands hosts; high end: a few unspecified-location US listings) | 83 total H100 SXM GPUs rentable across 31 listings (including multi-GPU bundles up to 8x) | ComputeTape CT-H100 Index (computetape.com/indexes/h100, current.json + history.csv) + Vast.ai authenticated REST API (`api_keys-vast_ai_mcp_litellm`, `/bundles/`) | 2026-08-16   |

- **ComputeTape**: primary standardized H100/H100e spot-price series, clean downloadable
  historical data, monthly observations.
- **Vast.ai**: use existing API access, monthly snapshots, H100 rental price, available
  capacity/GPU availability. Add other reliable supply/utilization fields if useful.

## What we're looking for

Strong evidence of weakening compute demand:

> H100 spot price ↓ + Vast.ai rental price ↓ + available compute ↑

The more persistent the move, the more meaningful it is.

Strong demand: prices stable/high + availability constrained.

No scoring or composite formula.

## Rationale

Compute marketplaces provide a revealed-demand proxy that does not depend on knowing the workload
or compute consumption of proprietary AI models. If increasingly capable/efficient open-source
models continue generating sufficient demand, that demand should still manifest through GPU
rental markets. Falling compute prices and rising available capacity can therefore provide
evidence of weakening aggregate demand even when proprietary model usage is opaque.

Caveat: Vast.ai represents only a subset of the global compute market — it's a market
thermometer, not a claim that it measures global utilization. Having ComputeTape as an
independent H100 price series makes the signal more useful.
