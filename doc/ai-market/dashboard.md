# AI Market Indicator Dashboard

An AI hardware cycle / market-retraction indicator, built from the physical AI supply chain
rather than trying to predict a top from stock prices alone.

> **Watch the physical AI supply chain for signs that demand is weakening and supply is catching
> up.**

## The indicators

1. **Big Tech capex growth** ([capex.md](./capex.md)) — track Microsoft, Amazon, Google, Meta,
   Oracle. Absolute spending matters less than the growth trend and forward guidance.
   Decelerating capex growth, delayed data centers, or reduced guidance = bearish. The primary
   **demand-side indicator**.

2. **GPU lead times + resale prices** ([gpu-scarcity.md](./gpu-scarcity.md)) — long lead times =
   GPUs remain scarce = bullish; shortening lead times = supply catching up = bearish; falling
   used/resale GPU prices = scarcity premium disappearing = bearish. Strongest signal: lead times
   falling + resale prices falling simultaneously. The **GPU scarcity indicator**.

3. **HBM / memory** ([memory.md](./memory.md)) — HBM (High Bandwidth Memory) is the specialized
   DRAM used alongside AI accelerators, made by Micron, SK Hynix, Samsung. Rising HBM
   prices/tight supply = strong AI accelerator demand; falling = potentially bearish. Track
   inventories and capacity expansion. Server DRAM is supporting evidence only — it competes with
   HBM for manufacturing capacity, so falling DRAM prices don't necessarily mean AI demand is
   falling.

4. **TSMC HPC** ([tsmc.md](./tsmc.md)) — TSMC manufactures chips for NVIDIA, AMD, Apple, etc. HPC
   (High Performance Computing) is a revenue category that includes a large amount of
   AI-related chip demand, though not exclusively AI. HPC revenue growth is a useful upstream
   proxy for high-performance compute demand; decelerating growth would be bearish.

5. **Advanced packaging / CoWoS** ([tsmc.md](./tsmc.md)) — CoWoS is TSMC's advanced packaging
   tech used to integrate GPUs/accelerators with HBM, and has been a bottleneck in AI accelerator
   production. High/rising utilization and orders = strong demand; falling = bearish. Capacity
   expansion itself isn't bearish — only concerning when capacity expands while
   utilization/orders weaken.

**AI efficiency** was considered as a sixth indicator and deliberately excluded from the core
dashboard. It's extremely difficult to interpret without knowing how AI usage is changing:

> **Hardware demand ≈ AI workload × compute required per unit of workload**

An efficiency improvement can *increase* hardware demand if it causes AI usage to explode — e.g.
5× efficiency with 10× workload growth still requires roughly 2× the compute. So efficiency is
treated as a qualitative wildcard, not a quantitative market-timing signal. Instead its effect is
observed indirectly through indicator 5.2, the compute market (see
[compute-market.md](./compute-market.md)).

## Core dashboard

| Indicator | Bullish | Bearish |
| --- | --- | --- |
| Big Tech capex growth | Accelerating | Decelerating |
| GPU lead times | Long/increasing | Short/decreasing |
| GPU resale prices | High/increasing | Falling |
| HBM prices/orders | Tight/rising | Falling |
| Memory inventories | Low | Rising |
| TSMC HPC growth | Accelerating | Decelerating |
| Advanced packaging utilization | High/rising | Falling |

**Hierarchy:**

- **Primary signals**: Big Tech capex, GPU scarcity, HBM
- **Confirmation signals**: TSMC HPC, memory inventories, advanced packaging utilization

The ideal bearish setup isn't one indicator turning negative — it's multiple layers of the
physical supply chain deteriorating together:

> Big Tech capex growth ↓ → GPU lead times ↓ → GPU resale prices ↓ → HBM prices/orders ↓ → TSMC
> HPC growth ↓ → packaging utilization ↓

That cascade would suggest the transition from "customers desperately want hardware and can't get
enough" to "supply is catching up and customers are becoming less aggressive" — the thing we're
ultimately trying to identify, because by the time semiconductor revenue itself is declining, the
market may already have priced in the downturn.

## Snapshot

| Indicator | Sheet | Current Read | Last Updated |
| --- | --- | --- | --- |
| Big Tech capex growth | [capex.md](./capex.md) | Bullish/accelerating: aggregate Big Tech capex (MSFT+GOOGL+META+AMZN+ORCL) YoY growth reaccelerated to +86.5% in Q2 2026 (from +71-75% through most of 2025), and every company raised or reaffirmed elevated forward guidance for the rest of 2026/FY27 (Alphabet raised to $195-205B, Amazon to ~$220B, Meta's floor to $130-145B, Oracle guiding ~$70B net cash outlay for FY27, Microsoft ~$175B FY27). No deceleration signal yet — the opposite. | 2026-08-16 |
| GPU scarcity (lead times + resale) | [gpu-scarcity.md](./gpu-scarcity.md) | _not yet populated_ | — |
| HBM / memory | [memory.md](./memory.md) | _not yet populated_ | — |
| TSMC HPC + CoWoS | [tsmc.md](./tsmc.md) | _not yet populated_ | — |
| Compute market (H100 spot/rental) | [compute-market.md](./compute-market.md) | _not yet populated_ | — |

## Current read (narrative)

**Indicator 1 (Big Tech capex) populated as of 2026-08-16; indicators 2-5 not yet populated.**

Capex growth is accelerating, not decelerating — aggregate hyperscaler capex YoY hit +86.5% in Q2
2026, and forward guidance across all five companies points to more spend, not less, through the
rest of 2026 and into FY27. On its own this is a **bullish** read for the primary demand-side
indicator, i.e. the opposite of the setup this dashboard is watching for. It says nothing yet
about GPU scarcity, HBM, or TSMC/CoWoS — those still need to be gathered before drawing any
conclusion about convergence (or lack of it) across the supply chain layers.

See [updating.md](./updating.md) for the monthly/quarterly refresh process.
