# Indicator 4 — TSMC / Advanced Manufacturing

Two related indicators (see [dashboard.md](./dashboard.md)):

1. TSMC HPC revenue
2. CoWoS / advanced packaging utilization and capacity

Cadence: HPC quarterly, whenever TSMC reports. CoWoS monthly/quarterly depending on data
availability, but realistically quarterly is sufficient for the dashboard — no need to chase
every capacity announcement. Append-only, oldest first — never edit or delete a historical row.

## 1. TSMC HPC revenue — primary

TSMC reports revenue by platform, including HPC, but only ever states it as a **% of total
revenue plus a QoQ % change** on the earnings call (never an absolute HPC dollar figure, and
never a HPC-specific YoY figure except once a year, as a full-year number, in the Q4 call).
Absolute HPC USD revenue below is therefore **derived**, not directly reported: `total quarterly
revenue (USD) × HPC % of revenue`. Quarterly HPC YoY growth is similarly derived by comparing
that derived figure to the same quarter a year earlier — this compounds rounding error from two
source numbers (TSMC rounds both total revenue and platform % to the nearest whole/tenth), so
treat quarterly HPC YoY as directionally reliable but not to the same precision as capex.md's
XBRL-sourced figures. The one number TSMC does state as verbatim YoY is **full-year HPC growth**,
given once a year on the Q4/full-year call (e.g. "HPC increased 48% year-over-year" in 2025) —
prefer that figure over the derived quarterly ones whenever comparing full years.

| Quarter | Total Revenue (USD) | HPC % of Revenue | HPC QoQ Growth (reported verbatim) | Est. HPC Revenue (derived) | HPC YoY Growth (derived, same-quarter) | Notes | Source | Last Updated |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Q1 2025 | $25.53B | 59% | +7% | $15.06B | — | Baseline quarter for this sheet; no prior-year HPC % pulled yet to derive YoY. | SEC 6-K press release (revenue/%) + earnings call transcript (HPC %/QoQ) | 2026-08-16 |
| Q2 2025 | $30.07B | 60% | +14% | $18.04B | — | | SEC 6-K press release + earnings call transcript | 2026-08-16 |
| Q3 2025 | $33.10B | 57% | 0% (flat) | $18.87B | — | HPC % dipped from Q2 as smartphone/IoT/automotive all grew faster that quarter (seasonal), not a demand pullback per se — TSMC's own commentary this quarter reaffirmed CoWoS/AI demand still exceeding supply (see section 2). | SEC 6-K press release + earnings call transcript | 2026-08-16 |
| Q4 2025 | $33.73B | 55% | +4% | $18.55B | — | Full-year 2025: HPC = 58% of full-year revenue, **+48% YoY** (both figures stated verbatim by TSMC on this call — the one directly-reported HPC YoY figure in this sheet, prefer it over any derived quarterly YoY for full-year comparisons). | SEC 6-K press release + earnings call transcript | 2026-08-16 |
| Q1 2026 | $35.90B | 61% | +20% | $21.90B | +45.4% (derived vs. Q1 2025's $15.06B) | | SEC 6-K press release + earnings call transcript | 2026-08-16 |
| Q2 2026 | $40.20B | 66% | +20% | $26.53B | +47.1% (derived vs. Q2 2025's $18.04B) | HPC % of revenue (66%) and est. HPC YoY (+47.1%) are both the highest in this series — accelerating, not decelerating. Motley Fool's own headline for this transcript: "Revenue surged 33.7% as AI demand drives HPC platform growth to 66% of sales." | SEC 6-K press release + earnings call transcript | 2026-08-16 |

Source: TSMC's quarterly earnings-release press release (SEC 6-K exhibit 99.1 — gives total
consolidated revenue, EPS, margins, wafer revenue by node) for total-revenue figures; TSMC's
earnings call transcript ("Moving on to revenue contribution by platform...", spoken by the CFO
in prepared remarks each quarter) for HPC %/QoQ. See [updating.md](./updating.md) for exact
sourcing mechanics and gotchas.

Signal: HPC growth accelerating → bullish; decelerating → warning; declining → bearish. As of
Q2 2026 this is unambiguously accelerating on every field tracked (% of revenue, QoQ, derived
YoY) — the strongest of the dashboard's primary/confirmation signals gathered so far.

## 2. CoWoS — capacity / utilization

Trickier because TSMC doesn't give a nice monthly "CoWoS utilization = 94%" number — like HBM
pricing, don't manufacture precision that doesn't exist.

| Period | Demand (Tight/Normal/Weak) | Capacity / Expansion | Utilization | Source | Notes |
| --- | --- | --- | --- | --- | --- |
| Q1 2025 | Tight | Plans to **double CoWoS capacity in 2025** to meet demand (C.C. Wei, Q1 2025 call). Analyst asked directly about "CoWoS order adjustment" rumors circulating that quarter; TSMC's answer reaffirmed demand still above supply despite the noise. | Not disclosed as a numeric %; qualitatively "demand still well above supply" | Q1 2025 earnings call transcript | Same quarter DeepSeek's release triggered market worry about AI efficiency reducing hardware demand — TSMC's own read (C.C. Wei) was that efficiency gains would *widen* AI adoption and use, not shrink chip demand — worth remembering as a real-time example of the "efficiency wildcard" dashboard.md's intro discusses. |
| Q2 2025 | Tight | Analyst directly asked whether "CoWoS capacity will probably come into balance by 2026" (a forward view TSMC had given previously) still held. CFO's answer: AI/data-center demand "still even stronger," implying the supply-demand gap was not yet narrowing on the timeline previously suggested. | Not disclosed numerically | Q2 2025 earnings call transcript | |
| Q3 2025 | Tight | Analyst noted 2025's already-announced 2x CoWoS capacity build "clearly feels like even that is not enough," asked for a read on 2026 capacity plans. TSMC declined to give the 2026 number on this call ("we probably update you next year"), but confirmed continued capacity expansion work in 2026. | Not disclosed numerically | Q3 2025 earnings call transcript | TSMC also declined a direct number on what % of 2025 revenue was "AI accelerator" specifically (narrower than HPC) on this call — consistent with the dashboard's own methodology note not to try to isolate pure AI revenue from HPC. |
| Q1 2026 | Tight | TSMC confirmed **two new advanced-packaging fabs in Arizona**, and is also partnering with an outside OSAT (assembly/test) firm building its own Arizona packaging fab *faster* than TSMC's own two, specifically to help close the front-end/back-end capacity gap sooner. C.C. Wei, when asked directly whether the crunch was AI accelerators, CPUs, or memory: "talking about the CoWoS capacity, all I can say is... we are still working to increase the capacity in 2026... today, all I want to say about the AI everything related like front-end and back-end capacity is very tight." | Not disclosed numerically; explicitly described as "very tight" front-end **and** back-end | Q1 2026 earnings call transcript | Notable escalation from Q3 2025's answer: TSMC is now willing to let an external OSAT partner absorb overflow packaging demand rather than wait for its own fabs — read as tightness severe enough to accept a competitive/margin cost to relieve it faster. |
| Q2 2026 | Tight, verging on a stated bottleneck | TSMC raised its **2026 capital budget from $52-56B (guided Jan 2026) → "towards the high end" of that same range, i.e. ~$56B (reaffirmed Apr 2026) → $60-64B (raised Jul 2026)** — a ~$8-12B raise concentrated in the most recent revision, with CFO citing (in order, per C.C. Wei's own framing when pressed by an analyst) demand strength as "the most important reason," plus a secondary inflation/tooling-cost factor. 10-20% of that capital budget is allocated to advanced packaging/testing/mask-making (a range TSMC declined to narrow further when an analyst pushed for a packaging-only breakout). C.C. Wei, verbatim: **"our packaging capacity is so tight that now it's limiting my customers' growth."** | Not disclosed numerically; the "limiting my customers' growth" quote is the most direct capacity-constraint statement TSMC has made across the 6 quarters reviewed | Q2 2026 earnings call transcript | This is a qualitatively stronger/more explicit tightness statement than any prior quarter in this series — CoWoS/packaging described as an active constraint on customer growth, not just "demand exceeds supply." Corroborates indicator 3's (HBM/memory) same-quarter read of tight upstream supply. |

Focus on three things:

- **Demand / orders**: strong customer demand, capacity fully booked, orders increasing/decreasing.
- **Utilization**: high/tight, normalizing, falling.
- **Capacity**: new CoWoS capacity coming online, expansion plans, geographic/fab expansion.

Important distinction: **capacity expansion ≠ bearish**. We only care when capacity expansion and
weakening orders/utilization occur together.

## Sources

**HPC revenue**: TSMC's quarterly earnings-release press release, filed as SEC 6-K exhibit 99.1
(`sec.gov/Archives/edgar/data/1046179/...`), for total consolidated revenue; TSMC's own quarterly
earnings call transcript for the HPC platform %/QoQ figures (TSMC doesn't publish a standalone
HPC-revenue investor document). See [updating.md](./updating.md) for exact sourcing mechanics.

**CoWoS**: TSMC earnings call Q&A (analysts ask about CoWoS/packaging capacity nearly every
quarter, and TSMC management responds with qualitative color even when declining to give a
number) is the highest-value source found so far — richer than any secondary/industry source
reviewed to date. TrendForce and other credible semiconductor research remain useful for
cross-checking or filling gaps between TSMC's own quarters, but weren't needed for the first pass
since TSMC's own commentary was sufficiently rich. Give TSMC's own commentary priority, use
industry sources to fill in the gaps.

## What we're looking for

Key bearish combination: TSMC HPC growth decelerating + CoWoS demand/utilization weakening. The
strongest signal would be if that happens *after* Big Tech capex and GPU/HBM indicators have
already started deteriorating — confirmation moving upstream through the physical supply chain.
