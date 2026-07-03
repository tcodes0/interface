### Architectural Design: MCP Server Resource Management

**Problem Statement & Design Direction**
The server executes external commands as child processes which, if left unconstrained, risk exhausting the container's available memory and triggering a systemic crash. Relying entirely on a Go-based polling loop to monitor process trees is computationally expensive and vulnerable to missing sudden memory allocation bursts. The architectural direction shifts process-level enforcement directly to the Linux kernel via Cgroups v2, allowing the OS to handle precise constraints and CPU throttling natively. The Go server acts strictly as an orchestrator, handling admission control, global container health, and communicating state back to the client.

**Summary of Decisions**
Limits are dynamically assigned based on total container memory and a priority tier system rather than hardcoded bytes. To handle high load, the server uses a fast-rejection admission strategy, returning memory snapshots to prompt the LLM agent to free resources manually via a newly exposed `shell_kill` tool. The Go-based global monitor is reduced to a low-overhead 5-second polling interval, relying on kernel-level `memory.high` throttling to absorb allocation spikes between ticks. Because the system operates as a synchronous MCP server, out-of-band terminations by the global monitor are buffered in an ephemeral, in-memory queue and delivered as a system message during the client's next tool invocation.

---

### 1. Configuration & Priority

Limits are dynamically calculated as a percentage of **Total Container Memory**.

* `OOM_USAGE_MAX_PCT`: Global container threshold (Default: `90`).
* `JOB_PATH_CHAR_LIMIT`: Cgroup string truncation limit (Default: `40`).
* `PRIORITY_PCT_LOW`: 10%, `PRIORITY_PCT_MED`: 25%, `PRIORITY_PCT_HIGH`: 50%.

### 2. Internal Job Manager & MCP Tooling

* **Encapsulation:** All `/proc` and cgroup manipulation is hidden behind a thread-safe, mockable internal API to prevent state leaks and handle PID wrap-around verification.
* **User Control (`shell_kill`):** An MCP tool explicitly exposed to the LLM agent, accepting a PID to forcefully terminate an active process and free resources.

### 3. Admission Control (Fast Rejection)

If `Container Free Memory < Required Bytes` for a new job, the server acts as a circuit breaker. It rejects the request and returns a detailed text snapshot to the MCP client, prompting it to use the `shell_kill` tool.

```text
Error: Insufficient memory to spawn job (Requires: 500MB).
Action Required: Use the `shell_kill` tool to terminate active jobs and free resources.

Container Memory Snapshot:
Total: 2048 MB
Current: 1800 MB (87%)

Active Jobs:
1. PID 1024 - node_jest_test_foo/bar/baz - 800 MB (39.0%)
2. PID 1045 - python3_data_processor - 600 MB (29.2%)

```

### 4. Job Execution (The Runner)

1. Fork child and suspend via `ptrace`.
2. Generate path: `/sys/fs/cgroup/server/jobs/$pid-$processName-$args` (truncated).
3. Write `memory.max` (hard boundary) and `memory.high` (throttling boundary, 10% lower).
4. Write to `cgroup.procs`.
* *Fallback:* If any filesystem write fails, detach `ptrace`, log internally, and return a text warning to the MCP client that the job is running unconstrained, along with its ID.


5. Resume execution.

### 5. Global Monitor (Low Overhead)

* **Polling:** Runs every 5 seconds. The 5-second interval keeps CPU overhead minimal, safely relying on the `memory.high` cgroup throttling to absorb sudden allocation bursts between ticks.
* **Mitigation:** If the container breaches the `OOM_USAGE_MAX_PCT` threshold, it identifies the highest memory consumer in the `/jobs` directory and commands the internal API to terminate it.

### 6. Ephemeral Asynchronous Notifications

Because MCP operates synchronously, the server uses an in-memory queue to buffer OOM kill events.

When the Global Monitor kills a job, it pushes a formatted string to this queue. On the very next MCP tool invocation by the client (regardless of the tool used), the server pops the queue and prepends the notification to the tool's standard output.

**Format:**

```text
[mcp system] A process was killed in the background due to high global memory usage.
Terminated: PID 1024 - node_jest_test_foo/bar/baz (800 MB)
Container Snapshot: Current 1850 MB / Total 2048 MB (90%)
Note: This async message is not related to the current tool call.

<... standard tool output follows ...>
```

## next steps

review this plan, refine and criticize.