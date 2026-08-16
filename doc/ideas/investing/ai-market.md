We discussed building an **AI hardware cycle / market-retraction indicator** rather than trying to predict a top from stock prices alone.

The central idea is:

> **Watch the physical AI supply chain for signs that demand is weakening and supply is catching up.**

The most useful indicators ended up being:

1. **Big Tech capex growth**

   * Track Microsoft, Amazon, Google, Meta, Oracle.
   * Absolute spending matters less than the **growth trend and forward guidance**.
   * Decelerating capex growth, delayed data centers, or reduced guidance = bearish.
   * This is the primary **demand-side indicator**.

2. **GPU lead times + resale prices**

   * Long lead times = GPUs remain scarce → bullish.
   * Shortening lead times = supply catching up → bearish.
   * Falling used/resale GPU prices = scarcity premium disappearing and potentially weaker marginal demand → bearish.
   * The strongest signal is **lead times falling + resale prices falling simultaneously**.
   * This is the **GPU scarcity indicator**.

3. **HBM / memory**

   * HBM = High Bandwidth Memory, the specialized DRAM used alongside AI accelerators.
   * HBM is manufactured by companies such as Micron, SK Hynix and Samsung.
   * Rising HBM prices/tight supply = strong AI accelerator demand.
   * Falling HBM prices/orders = potentially bearish.
   * Track memory manufacturers' **inventories and capacity expansion**.
   * Server DRAM is useful but more ambiguous because HBM and conventional DRAM compete for manufacturing capacity. Falling DRAM prices don't necessarily mean AI demand is falling.
   * Therefore HBM is the better direct AI signal; DRAM is supporting evidence.

4. **TSMC HPC**

   * TSMC manufactures chips for NVIDIA, AMD, Apple, etc.
   * HPC = High Performance Computing, a category that includes a large amount of AI-related chip demand, although it isn't exclusively AI.
   * **TSMC HPC revenue growth** is therefore a useful upstream proxy for high-performance compute demand.
   * Decelerating HPC growth would be bearish.

5. **Advanced packaging / CoWoS**

   * CoWoS is TSMC's advanced packaging technology used to integrate GPUs/accelerators with HBM.
   * It's important because advanced packaging has been a bottleneck in AI accelerator production.
   * High/rising utilization and orders = strong demand.
   * Falling utilization/orders = bearish.
   * Capacity expansion itself isn't bearish; it becomes concerning when **capacity is expanding while utilization/orders weaken**.

We initially considered **AI efficiency** as another indicator, but decided to exclude it from the core dashboard.

The reason is that efficiency is extremely difficult to interpret without knowing how AI usage is changing. The relevant relationship is approximately:

> **Hardware demand ≈ AI workload × compute required per unit of workload**

An efficiency improvement can actually increase hardware demand if it causes AI usage to explode. For example, 5× efficiency with 10× workload growth still requires roughly 2× the compute.

So AI efficiency is better treated as a **qualitative wildcard**, not a quantitative market-timing signal.

The resulting core dashboard is therefore:

| Indicator                          | Bullish         | Bearish          |
| ---------------------------------- | --------------- | ---------------- |
| **Big Tech capex growth**          | Accelerating    | Decelerating     |
| **GPU lead times**                 | Long/increasing | Short/decreasing |
| **GPU resale prices**              | High/increasing | Falling          |
| **HBM prices/orders**              | Tight/rising    | Falling          |
| **Memory inventories**             | Low             | Rising           |
| **TSMC HPC growth**                | Accelerating    | Decelerating     |
| **Advanced packaging utilization** | High/rising     | Falling          |

I'd think of the hierarchy as:

**Primary signals**

* Big Tech capex
* GPU scarcity
* HBM

**Confirmation signals**

* TSMC HPC
* Memory inventories
* Advanced packaging utilization

The ideal bearish setup isn't one indicator turning negative. It's **multiple layers of the physical supply chain deteriorating together**:

> Big Tech capex growth ↓
> → GPU lead times ↓
> → GPU resale prices ↓
> → HBM prices/orders ↓
> → TSMC HPC growth ↓
> → packaging utilization ↓

That would suggest the transition from **"customers desperately want hardware and can't get enough"** to **"supply is catching up and customers are becoming less aggressive."**

That transition is the thing we're ultimately trying to identify, because by the time semiconductor revenue itself is declining, the market may already have priced in the downturn.
