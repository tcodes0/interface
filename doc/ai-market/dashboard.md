# AI Market Indicator Dashboard

Current-state snapshot of the AI hardware cycle indicators. Rationale and full methodology:
[doc/ideas/investing/ai-market.md](../ideas/investing/ai-market.md).
Underlying data sheets, one per indicator, live alongside this file. Historical rows in those
sheets are never edited or deleted — corrections are appended as new rows with a note.

See [updating.md](./updating.md) for the monthly/quarterly refresh process.

## Snapshot

| Indicator | Sheet | Current Read | Last Updated |
| --- | --- | --- | --- |
| Big Tech capex growth | [capex.md](./capex.md) | _not yet populated_ | — |
| GPU scarcity (lead times + resale) | [gpu-scarcity.md](./gpu-scarcity.md) | _not yet populated_ | — |
| HBM / memory | [memory.md](./memory.md) | _not yet populated_ | — |
| TSMC HPC + CoWoS | [tsmc.md](./tsmc.md) | _not yet populated_ | — |
| Compute market (H100 spot/rental) | [compute-market.md](./compute-market.md) | _not yet populated_ | — |

## Current read (narrative)

_Not yet populated — fill in once the first round of data is gathered._

Hierarchy reminder (from the spec):

- **Primary signals**: Big Tech capex, GPU scarcity, HBM
- **Confirmation signals**: TSMC HPC, memory inventories, advanced packaging utilization

The bearish setup we're watching for is multiple layers deteriorating together, upstream through
the supply chain: capex ↓ → GPU lead times/resale ↓ → HBM ↓ → TSMC HPC ↓ → packaging utilization ↓.
No single indicator flipping is the signal — convergence is.
