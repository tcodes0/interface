# Updating the AI Market Dashboard

How to keep the indicator sheets current. Spec/rationale:
[doc/ideas/investing/ai-market.md](../ideas/investing/ai-market.md).

## Cadence

### Monthly (every month, regardless of earnings)

- **GPU scarcity** ([gpu-scarcity.md](./gpu-scarcity.md)): Compute Exchange H100 resale range,
  Vast.ai H100/B200 rental snapshot, lead-time/availability chatter from independent sources.
- **HBM pricing** ([memory.md](./memory.md), section 2): TrendForce / credible semiconductor
  research directional read (Rising/Stable/Falling).
- **Server DRAM** ([memory.md](./memory.md), section 3): TrendForce DRAM contract price trend.
- **Compute market** ([compute-market.md](./compute-market.md)): ComputeTape H100 spot price,
  Vast.ai H100 rental price + availability.

### Quarterly (gated on earnings releases)

- **Big Tech capex** ([capex.md](./capex.md)): Microsoft, Amazon, Alphabet, Meta cluster in late
  Jan / Apr / Jul / Oct; Oracle runs on an offset fiscal calendar — check separately.
- **Memory-maker inventory days** ([memory.md](./memory.md), section 1): SK Hynix, Samsung,
  Micron earnings/filings. Micron's fiscal calendar is offset from the others.
- **TSMC HPC + CoWoS** ([tsmc.md](./tsmc.md)): TSMC reports monthly revenue but HPC breakdown and
  CoWoS commentary come with the quarterly earnings call, typically mid-month following quarter
  close.

> Rough earnings windows only — confirm exact dates each cycle, companies shift by a week or two.

## Update steps

1. Pull the relevant primary sources for whatever is due this cycle (see cadence above and the
   source hierarchy in each sheet).
2. Append new row(s) to the relevant sheet(s) — **never edit or delete a historical row.** If a
   number needs correcting, append a new row and note the correction; keeps the sheet
   git-diffable and honest.
3. Recompute YoY / TTM where the sheet defines a formulaic field (capex, HPC growth). No scoring
   or composite indices — that's an explicit non-goal across all five sheets.
4. Refresh [dashboard.md](./dashboard.md): update each row's "Current Read" and "Last Updated",
   and revise the narrative paragraph if the overall picture has shifted.
5. Commit directly to `dev` (small, recurring, well-defined — no PR needed per the github skill's
   dev-branch convention): `data(ai-market): <month> <year> update`.

## Reminders

- Don't manufacture precision a source doesn't provide (lead times, CoWoS utilization, HBM
  pricing are all qualitative/directional by design — see each sheet's methodology link).
- The signal we care about is convergence across layers, not any single indicator flipping. Keep
  the dashboard narrative honest about how many layers are actually confirming.
