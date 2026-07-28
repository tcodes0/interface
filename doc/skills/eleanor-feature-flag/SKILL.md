---
name: eleanor-feature-flag
description: Use when working with Eleanor Health's feature flag service -- checking flag state/value, creating or updating flags and variations, managing environments or API keys, or explaining ehff CLI commands.
---

# Eleanor Health Feature Flag Service

Self-hosted Go HTTP service (SQLite-backed) that stores feature flags and serves their resolved
values. Repo: `git@github.com:eleanorhealth/feature-flag.git` (default branch `main`). Full specs
live in the repo -- `doc/design.md` (schema, business rules, full endpoint/response reference) and
`doc/cli.md` (the `ehff` CLI plan/spec). This skill is the day-to-day usage summary; consult those
docs for anything not covered here.

## MCP Tools

Two tools, both plain authenticated HTTP passthroughs to the same deployment:

| Tool | Scope |
| --- | --- |
| `eh_feature_flag_prod` | Production environment |
| `eh_feature_flag_qa` | QA environment |

**Both point at the same base URL: `https://feature-flag.prod.eleanorhealth.io`.** There is a
separate `feature-flag.qa.eleanorhealth.io` deployment, but it is health-check only -- flag
management is centralized on the prod deployment, which internally hosts a QA *environment*
alongside the production one. Do not confuse the QA *deployment* (unused) with the QA
*environment* (real, lives in prod). Each tool injects a different API key, and the key's
registered environment determines which one you're hitting by default.

Auth header (handled automatically by the tool): `Authorization: Key ff-...`.

## Environments

- A read-write key defaults to its own registered environment but can target another via
  `?environment={id}` on any request -- see `env list` to find IDs.
- A read-only key ignores `?environment` entirely and always resolves against its own registered
  environment. Read-only keys can also only issue `GET` requests (403 on anything else).
- Every response is wrapped in an envelope naming the environment that was actually resolved:
  `{"environment": {"id": "...", "name": "..."}, ...}`. Always check this field rather than
  assuming -- especially when passing `?environment`.

## Endpoint Reference

All routes below are under `/v1/` and require the `Authorization: Key ...` header except
`/health`. Full request/response bodies and edge cases are in `doc/design.md`; this is the shape:

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/flags` | any | List flags (+ variations + resolved state for caller's env) |
| GET | `/v1/flags/{key}` | any | Same, filtered to one flag |
| PUT | `/v1/flags/{key}` | read-write | Create/update a flag (body: `{"description": "..."}`) |
| DELETE | `/v1/flags/{key}` | read-write | Soft delete (global, not per-env) |
| GET | `/v1/flags/{key}/value` | any | Resolved value for caller's env -- the hot-path read |
| PUT | `/v1/flags/{key}/variation` | read-write | Set active variation for caller's env (body: `{"variation": "on"}`) |
| PUT | `/v1/flags/{key}/variations/{name}` | read-write | Create/update a variation (body: `{"value": {...}, "description": "..."}`) |
| DELETE | `/v1/flags/{key}/variations/{name}` | read-write | Soft delete a variation (409 if it's active anywhere) |
| POST | `/v1/environments` | read-write | Create an environment |
| GET | `/v1/environments` | any | List environments (`?include_deleted=true` supported) |
| DELETE | `/v1/environments/{id}` | read-write | Soft delete (409 on the `default` env -- undeletable) |
| POST | `/v1/keys` | read-write | Create an API key; plaintext shown only once in the response |
| GET | `/v1/keys` | any | List keys, never includes the hash (`?environment=`, `?include_deleted=`) |
| DELETE | `/v1/keys/{id}` | read-write | Soft delete a key |
| GET | `/health` | none | Health check |

Most list/get endpoints accept `?include_deleted=true` to surface soft-deleted rows.

### Value shape (tagged union)

Variation values are exactly one of:
```json
{ "boolean": "true" }      // "true" or "false", as strings
{ "string": "foo" }
{ "json": { "threshold": 0.5 } }
```

### Errors

`{"error": "message"}` body on all 4xx/5xx. Common codes: 400 invalid request, 401 bad/deleted key
or deleted key-environment, 403 read-only key attempting a write, 404 not found, 409 conflict
(e.g. deleting an active variation, reusing a soft-deleted flag/variation/environment name).

## Common Workflows

**Check a flag's value** (the hot path other services poll):
```
GET /v1/flags/ff-se-2887/value
-> {"environment": {...}, "key": "ff-se-2887", "state": "on", "value": {"boolean": "true"}}
```

**Create a new flag end-to-end:**
1. `PUT /v1/flags/{key}` -- create the flag (starts with no variations, no state).
2. `PUT /v1/flags/{key}/variations/on` and `.../off` -- define variations with concrete values.
3. `PUT /v1/flags/{key}/variation` with `{"variation": "on"}` -- activate one for the caller's env.

**Roll out to another environment:** repeat step 3 with `?environment={id}` using a read-write key
(read-only keys can't do this even with the query param -- they're locked to their own env).

## The `ehff` CLI

`ehff` (built from `cmd/ehff` in the repo, `./run build:cli` -> `bin/ehff`) is a thin 1:1 wrapper
over the same HTTP API for human operators -- every subcommand is exactly one HTTP call. Full
command tree, flag semantics, and output formatting are in the repo's `doc/cli.md`; the mapping to
the endpoints above is direct:

| CLI command | HTTP call |
| --- | --- |
| `ehff flag list [--env <name>] [--deleted]` | `GET /v1/flags` |
| `ehff flag get <key>` | `GET /v1/flags/{key}` |
| `ehff flag set <key> [--description <text>]` | `PUT /v1/flags/{key}` |
| `ehff flag delete <key>` | `DELETE /v1/flags/{key}` |
| `ehff flag value <key> [--env <name>]` | `GET /v1/flags/{key}/value` |
| `ehff flag use <key> <variation> [--env <name>]` | `PUT /v1/flags/{key}/variation` |
| `ehff variation set <flag-key> <name> (--bool true\|false \| --string <text> \| --json <json>)` | `PUT /v1/flags/{key}/variations/{name}` |
| `ehff variation delete <flag-key> <name>` | `DELETE /v1/flags/{key}/variations/{name}` |
| `ehff env list` / `env create <name>` / `env delete <id>` | environments endpoints |
| `ehff key list` / `key create <name> --env <name> [--read-only]` / `key delete <id>` | keys endpoints |
| `ehff health` | `GET /health` |

Config: `FF_URL` + `FF_KEY` env vars, or `--url`/`--key` flags (must precede the subcommand name).
Exit code 0 on success, 1 on any error; errors go to stderr as `ehff: <message>`.

Note for agent use: prefer the MCP tools (`eh_feature_flag_prod` / `eh_feature_flag_qa`) directly
over building/running the `ehff` binary -- the CLI exists for human operators at a terminal, and
adds no capability the MCP tools don't already expose.

## Consumers

Other Eleanor repos read flags via `pkg/client` (Go) in the feature-flag repo itself, or via
`useFeatureFlag(key)` hooks in the frontend repos (see `project_state:client` /
`project_state:member-client` memories for the current `ff-se-2887` gating pattern as a worked
example of a flag rollout/rollback across hub-server, hub-client, member-client, and scheduling).
