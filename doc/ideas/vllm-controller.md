# context

The project is to build a small control plane for managing manually created Vast.ai instances running vLLM. The main goal is to automatically shut down GPU instances when they have been idle for a configurable period, while also allowing an AI agent to start an existing instance when it needs a worker.

Each Vast instance runs a lightweight worker agent alongside vLLM. When the container boots, the agent generates a unique worker ID and registers itself with the control server, providing basic information such as its hostname, Vast instance, model, GPU, and other available metadata. The control server responds with configuration such as the heartbeat interval and idle timeout.

The worker sends a heartbeat periodically regardless of whether it is receiving requests. Separately, it monitors the existing vLLM log and reports the timestamp of the most recent request. This keeps worker liveness and request activity independent. The control server uses those signals to determine whether a worker is starting, active, idle, terminating, or in an unknown state.

The control plane will use SQLite to track both Vast instances and the workers associated with them. A Vast instance represents the underlying infrastructure, while a worker represents a particular boot of that instance. The controller can cross-check its own records against the Vast API when something is unclear, such as when a worker stops sending heartbeats.

The control plane will also expose a very small MCP interface over standard input and output. The initial interface will provide high-level operations to start a worker, stop a worker, and check status. Starting a worker will accept a general string query that can be matched against the metadata associated with manually provisioned instances. The agent will not be responsible for creating new Vast instances; if no suitable existing instance is available, the control plane simply reports an error.

The control server and MCP server will use the same Go binary in different modes and can run together in Docker Compose. The MCP layer will remain a thin interface over the control plane. A small Python wrapper can later expose the stdio MCP interface over SSE if needed. The design is intentionally focused on lifecycle management rather than full infrastructure orchestration, leaving automatic provisioning and more sophisticated worker management for a future phase.

Here’s the implementation plan I’d use for v1. It keeps the system intentionally small while leaving the right seams for future orchestration.

## 1. Components

Build one Go binary with two modes:

```text
control --mode=server
control --mode=mcp
```

The server process owns:

- SQLite
- Vast API integration
- worker registration
- heartbeats
- worker state
- Vast instance state
- idle detection
- termination
- reconciliation

The MCP process owns only:

- stdio MCP transport
- three high-level tools
- forwarding commands to the control server

No Vast logic should live in the MCP layer.

```text
MCP client
    │
    │ stdio
    ▼
control --mode=mcp
    │
    │ HTTP
    ▼
control --mode=server
    ├── SQLite
    └── Vast API
```

## 2. SQLite data model

Two primary entities:

```text
vast_instances
----------------
id
vast_instance_id
name
status
metadata
created_at
updated_at
```

and:

```text
workers
----------------
id
worker_id
vast_instance_id
state
hostname
metadata
registered_at
last_heartbeat_at
last_request_at
terminated_at
```

plus a join table:

```text
worker_information
----------------
id
worker_id
...extra heartbeat fields (maybe jsonb?)
```

The important relationship:

```text
Vast instance
    │
    └── 0..1 current worker
```

A worker represents a particular boot/session, while the Vast instance persists across boots.

Don't delete old worker records. They provide useful history.

For example:

```text
instance: qwen-primary

worker abc123 → TERMINATED
worker def456 → ACTIVE
```

## 3. Worker registration

When the container starts, the entrypoint launches the worker agent.

The agent generates a fresh unique ID for that boot:

```text
worker_id = UUID/ULID
```

It gathers whatever information is readily available:

```text
worker_id
Vast instance ID (VAST_CONTAINERLABEL)
model (VLLM_MODEL_NAME)
image version (VERSION)
vLLM version/configuration (VLLM_CMD_LINE)
GPU_INFO $(nvidia-smi --query-gpu=index,name,memory.total --format=csv,noheader)
```

Then:

```http
POST /workers/register
```

with something along the lines of:

```json
{
  "worker_id": "...",
  "vast_instance_id": "...",
  "hostname": "...",
  "metadata": {
    "model": "Qwen/...",
    "gpu": "...",
    "vllm_version": "..."
  }
}
```

The server creates the worker record and associates it with the existing Vast instance.

The registration response provides configuration:

```json
{
  "heartbeat_interval": 30,
  "idle_timeout": 1800
}
```

The worker doesn't decide its own state. It reports facts; the control plane derives state.

## 4. Heartbeat agent

The worker sends a heartbeat continuously, regardless of request activity.

For example, every 30 seconds:

```http
POST /workers/{worker_id}/heartbeat
```

Payload:

```json
{
  "last_request_at": "2026-08-29T01:17:32Z"
}
```

The server records the actual heartbeat receipt time itself:

```text
last_heartbeat_at = now()
```

rather than trusting the worker's clock.

`last_request_at` is obtained from the vLLM log.

This gives us two completely separate signals:

```text
last_heartbeat_at
    = Is the worker alive?

last_request_at
    = When did this worker last receive a request?
```

### 4.1 Extra heartbeat fields

For booting workers the extra fields are valuable to monitor boot, where most failures happen.
.hugginface size
.cache size
each gpu: SM % and memory %
see repo interface bin/vllm-monitor for how to get these metrics

For running workers the following is useful to measure worker performance

"Generation throughput"
"KV cache usage"
"Prefix hit rate"
"Mean acceptance length"
"Accepted throughput"
"Drafted throughput"
"Accepted tokens"
"Drafted tokens"
"Position acceptance"
"Draft acceptance"

see repo interface bin/vllm-monitor for how to get these metrics from the vllm log, only available after instance is running

For running workers could be useful to grep the log for "error" of similar patterns that appear in stack traces

error: boolean
stack_trace: slice of the vllm log around the error

## 5. Log monitoring

The worker agent tails the existing vLLM log.

It doesn't need to understand the entire log. Its only responsibility initially is:

```text
find most recent request timestamp
```

It can maintain the latest observed timestamp in memory and include that value in the next heartbeat.

So we don't need a separate request API.

Conceptually:

```text
vLLM
  │
  ▼
log file
  │
  ▼
worker agent
  │
  ├── parse latest request timestamp
  │
  └── heartbeat every N seconds
          │
          ▼
       control
```

This also means if no requests happen for an hour, the worker continues sending heartbeats while `last_request_at` remains unchanged.

## 6. Worker states

Keep the state machine deliberately small:

```text
STARTING
ACTIVE
IDLE
TERMINATING
UNKNOWN
```

Transitions:

```text
register
   ↓
STARTING
   ↓ heartbeat
ACTIVE
   │
   │ no requests for idle_timeout
   ▼
IDLE
   │
   │ idle timeout reached
   ▼
TERMINATING
   │
   │ Vast confirms termination
   ▼
terminated
```

`UNKNOWN` is used when the controller can't reconcile the worker's actual state.

For example:

```text
heartbeat becomes stale
        ↓
query Vast
        ↓
Vast says RUNNING
        ↓
UNKNOWN
```

Whereas:

```text
heartbeat becomes stale
        ↓
query Vast
        ↓
Vast says TERMINATED
        ↓
worker = terminated
```

No `DEAD` or `DRAINING` state for v1.

## 7. Idle detection

The controller periodically evaluates workers.

Conceptually:

```text
heartbeat fresh?
    │
    ├── no → reconcile with Vast
    │
    └── yes
          │
          ├── request recent → ACTIVE
          │
          └── request old → IDLE
```

Then:

```text
IDLE
  + idle_timeout exceeded
  ↓
TERMINATING
  ↓
Vast terminate API
```

The initial timeout can comfortably be something like 30 minutes.

We intentionally aren't solving long-running generation tracking in v1.

## 8. Vast reconciliation

The control plane should periodically reconcile its database against Vast.

This is important because the controller can restart, the container can disappear, or Vast can change state independently.

For each known instance:

```text
SQLite says RUNNING
        ↓
query Vast
        ↓
actual Vast state
```

Vast is authoritative for the actual infrastructure state.

SQLite is authoritative for our additional information:

```text
worker_id
last heartbeat
last request
metadata
history
```

## 9. MCP interface

Keep this extremely small.

### `stop_worker`

Same query mechanism:

```text
stop_worker("qwen")
```

The control plane resolves the worker and requests termination/stop through Vast.

### `status`

Could take an optional query:

```text
status()
status("qwen")
status("primary")
```

Without a query, return the fleet:

```text
qwen-primary    IDLE       Vast RUNNING
qwen-secondary  ACTIVE     Vast RUNNING
gemma           STOPPED    Vast STOPPED
```

With a query, return the matching worker/instance details.

## 9.1 future tools (out of scope for now)

### `list_templates`

Input: none

returns a list of vast.ai templates.

### `start_worker`

Input:

```text
template: string
```

The query is matched against vast.ai templates

For example:

```text
start_worker("qwen38-fp8-5090-next")
```

The MCP layer doesn't need to know how matching works. It simply passes the template to the control plane.

The control plane:

```text
templates
  ↓
find suitable template by name
  ↓
chooses hardware based on decision algo (tbd)
  ↓
creates instance
```

If no exact name match:

```text
ERROR:
No available template matching "qwen38-fp8-5090-next". Try list templates
```

## 11. Control-plane HTTP API

Keep this internal API small too:

```text
POST /workers/register
POST /workers/:id/heartbeat

GET  /workers
GET  /workers/:id

POST /workers/stop
```

The MCP adapter calls these APIs.

The HTTP API also gives you a useful CLI/debugging interface later.

Get workers by id should return detailed worker information (format tbd)

## 12. CLI

Since the same binary has modes, I'd add a third useful mode eventually:

```text
control --mode=cli status
control --mode=cli instances
control --mode=cli workers
control --mode=cli reconcile
```

Not required for the first implementation, but it would make development and debugging substantially easier.

## 13. Docker Compose

Two instances of the same image:

```yaml
services:
  control:
    image: control
    command: ["control", "--mode=server"]
    volumes:
      - ./data:/data

  mcp:
    image: control
    command: ["control", "--mode=mcp"]
```

The MCP process talks to the server over the Compose network.

The external Python SSE wrapper can then translate:

```text
SSE
 ↓
stdio
 ↓
control --mode=mcp
```

without polluting the Go control plane with SSE concerns.

## 14. Implementation order

I'd implement it in this order:

```text
1. Go project + configuration
2. SQLite schema/repository
3. Vast API client
4. Vast instance discovery/reconciliation
5. Worker registration endpoint
6. Worker heartbeat endpoint
7. Worker agent
8. vLLM log parser
9. State evaluation
10. Idle termination
11. MCP stdio server
12. start_worker / stop_worker / status
13. Query matching
14. Docker Compose
15. Python SSE wrapper
```

The first useful milestone would actually be before MCP:

```text
Vast instance
    ↓
container boots
    ↓
worker registers
    ↓
heartbeat
    ↓
log activity
    ↓
SQLite shows ACTIVE/IDLE
```

Then add:

```text
IDLE
 ↓
timeout
 ↓
Vast termination
```

Once that works reliably, the MCP layer is almost just plumbing.

The key design principle I'd preserve throughout is: **workers report observations; the control plane owns state and decisions; Vast owns infrastructure reality; MCP exposes only high-level intent.**
