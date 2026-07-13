---
name: eleanor-litellm
description: Use when querying the LiteLLM proxy database, investigating LLM call logs, spend, latency, or memory entries stored in LiteLLM for the LGA stack.
---

# Eleanor LiteLLM

## What LiteLLM Is Here

LiteLLM is the LLM proxy sitting in front of model providers for the LGA stack (see the `lga`
project state memory). It serves two purposes relevant to querying:

1. **Proxy logs** — every completion/tool call routed through it is recorded in Postgres.
2. **Memory API** — the `/v1/memory` HTTP endpoint backs the `chatui-memory` skill; those entries
   also live in this same Postgres database, just accessed via HTTP instead of SQL.

Compose service names (see `lga` project state): `litellm` (proxy, port 4000) and `litellm-db`
(Postgres, port 5432).

## Access

### Direct DB access (bench shell)

`psql` is not installed in the bench container — use Python + `psycopg2-binary` instead:

```bash
pip3 install --break-system-packages psycopg2-binary
```

```python
import psycopg2
conn = psycopg2.connect('postgresql://litellm@litellm-db:5432/litellm')
cur = conn.cursor()
cur.execute('SELECT ...')
for row in cur.fetchall():
    print(row)
```

No password required — trust auth (`POSTGRES_HOST_AUTH_METHOD: trust`, per `lga` project state).
One schema, `public`. List tables:

```sql
SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;
```

Table names are `LiteLLM_*` (PascalCase, quote them: `"LiteLLM_SpendLogs"`) plus a handful of
plain-named aggregate views (`MonthlyGlobalSpend`, `DailyTagSpend`, `Last30dModelsBySpend`, etc.)

### Memory API (HTTP)

For memory entries specifically, prefer the `/v1/memory` HTTP API over raw SQL against
`LiteLLM_MemoryTable` — see the `chatui-memory` skill for the full read/write/delete pattern and
auth header. Querying the table directly is fine for one-off inspection but the API enforces the
key-prefix namespacing convention and scoping the memory skill relies on.

## Where To Find Useful Information

| Table                     | Contains                                                              |
| -------------------------- | ---------------------------------------------------------------------- |
| `LiteLLM_SpendLogs`        | Per-call log: every completion/tool call, cost, tokens, timing — see Logs section below |
| `LiteLLM_MemoryTable`      | Backs `/v1/memory` — prefer the HTTP API (see `chatui-memory`) over querying this directly |
| `LiteLLM_VerificationToken`| API keys (virtual keys), budgets, rate limits, scoping to team/user   |
| `LiteLLM_UserTable`        | Proxy user records                                                     |
| `LiteLLM_TeamTable`        | Team records, budget/spend rollups                                     |
| `LiteLLM_ErrorLogs`        | Failed calls — check here first when a call silently fails             |
| `LiteLLM_ModelTable`       | Configured models / deployments                                        |
| `LiteLLM_AgentsTable`      | Agent records known to LiteLLM (distinct from LibreChat's `agents` collection — see `chatui`) |
| `MonthlyGlobalSpend`, `DailyTagSpend`, `Last30dModelsBySpend`, `Last30dKeysBySpend`, `Last30dTopEndUsersSpend` | Pre-aggregated spend views — cheaper than aggregating `LiteLLM_SpendLogs` yourself for coarse-grained spend questions |

## Logs — `LiteLLM_SpendLogs`

This is the table to query for call volume, latency, cost, and token usage investigations.

### Key columns

| Column                | Type      | Notes                                                                 |
| ---------------------- | --------- | ---------------------------------------------------------------------- |
| `request_id`           | text      | Primary identifier for a single call                                   |
| `call_type`            | text      | See values below — filter on this to isolate real LLM calls            |
| `model`, `model_group`, `custom_llm_provider` | text | Which model/provider served the call                          |
| `spend`                | float     | Cost in USD. Rows can be `0` (e.g. cache hits, some tool calls) — filter `spend <> 0` for cost-bearing calls |
| `total_tokens`, `prompt_tokens`, `completion_tokens` | int | Token accounting |
| `"startTime"`, `"endTime"`, `"completionStartTime"` | timestamp (no tz) | Quote — camelCase columns. Use for date-range filters and computing duration manually |
| `request_duration_ms`  | int       | Precomputed duration — matches `endTime - startTime` (cross-checked, see below) |
| `status`                | text      | Call outcome                                                          |
| `api_key`, `team_id`, `user`, `end_user`, `session_id` | text | Attribution — who/what made the call |
| `metadata`, `messages`, `response`, `proxy_server_request` | jsonb | Full payloads — useful for deep debugging a specific `request_id` |
| `mcp_namespaced_tool_name` | text  | Set when `call_type` is an MCP tool call, not a completion             |

### `call_type` values seen in this DB

- `acompletion` — an actual LLM completion call. **This is what "LLM type calls" means** — filter
  on this to exclude MCP-plumbing rows.
- `call_mcp_tool` — an MCP tool invocation proxied through LiteLLM, not a model call.
- `list_mcp_tools` — MCP tool discovery, not a model call.
- `''` (empty string) — seen on a small number of rows, treat as unclassified/noise.

### Common query pattern — average duration for a date range

```sql
SELECT COUNT(*), AVG(request_duration_ms)
FROM "LiteLLM_SpendLogs"
WHERE call_type = 'acompletion'
  AND "startTime" >= '2026-07-01' AND "startTime" < '2026-07-10'
  AND spend <> 0;
```

Notes:
- Use half-open date ranges (`>= start AND < end_exclusive`) rather than `BETWEEN`/`DATE()` casts —
  cheaper and avoids timezone-cast surprises since the columns have no tz.
- `spend <> 0` is the right filter for "real" cost-bearing calls; a meaningful fraction of rows
  legitimately have `spend = 0` (cache hits, etc.) and should usually be excluded from cost/latency
  averages unless the question is specifically about them.
- Cross-check `request_duration_ms` against `EXTRACT(EPOCH FROM ("endTime" - "startTime"))*1000` if
  a number looks suspicious — they should match closely.

### Debugging a single call

```sql
SELECT request_id, model, status, spend, request_duration_ms, metadata, response
FROM "LiteLLM_SpendLogs"
WHERE request_id = '<id>';
```

For calls that failed outright (no spend row, or `status` indicates failure), check
`LiteLLM_ErrorLogs` as well — spend logs may not capture pre-flight rejections.
