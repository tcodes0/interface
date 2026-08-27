---
name: chatui-memory
description: Use when the user asks to remember something, says "remember this", wants to save, update, or delete a memory, or asks what you remember about a topic.
---

# Memory Management

Memories are stored in LiteLLM's `/v1/memory` API (Postgres-backed), not in LibreChat's MongoDB.
See the `eleanor-litellm` / `chatui` skill for stack context if needed.

## Tooling

All memory operations go through plain HTTP against the LiteLLM proxy, reachable from the bench
container at the compose service name:

```
http://litellm:4000/v1/memory
```

Auth: `Authorization: Bearer <LITELLM_API_KEY>` — the key lives in
`/lga/services/librechat/.env` as `LITELLM_API_KEY`. This is a scoped virtual key (not
the master key); memory entries created with it are automatically scoped to its `user_id`/`team_id`
— never pass `user_id`/`team_id` explicitly in requests.

```bash
LITELLM_API_KEY=$(grep LITELLM_API_KEY /lga/services/librechat/.env | cut -d= -f2)
```

## Key Naming Convention

Keys are globally unique across all of LiteLLM memory (not per-user namespaced by the API), so we
impose our own namespace: `<namespace>:<name>`.

- Project-scoped notes: `<project>:<name>` — e.g. `lga:hetzner_network_restrictions`,
  `server:hub_server_tzdata_import` (namespace = repo catalog name from the `github` skill)
- Project state snapshots (see "Reactive Triggers" in the `github` skill): `project_state:<project>`
  — e.g. `project_state:lga`, `project_state:interface`. Note the order: `project_state` is the
  namespace, the project name is the suffix — not the other way around.
- Cross-cutting notes not tied to one repo: `general:<name>` — e.g. `general:host_system`,
  `general:docker_image_avoid_alpine`

## List All Memories

```bash
curl -s "http://litellm:4000/v1/memory?page_size=100" \
  -H "Authorization: Bearer ${LITELLM_API_KEY}"
```

Filter by namespace using `key_prefix`:

```bash
curl -s "http://litellm:4000/v1/memory?key_prefix=lga:" \
  -H "Authorization: Bearer ${LITELLM_API_KEY}"
```

## Get a Memory by Key

```bash
curl -s "http://litellm:4000/v1/memory/project_state:lga" \
  -H "Authorization: Bearer ${LITELLM_API_KEY}"
```

## Save a New Memory

```bash
curl -s -X POST "http://litellm:4000/v1/memory" \
  -H "Authorization: Bearer ${LITELLM_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"key": "general:my_new_key", "value": "Memory content here."}'
```

## Update an Existing Memory (Upsert)

Same endpoint pattern, `PUT` instead of `POST` — creates the entry if the key doesn't exist yet:

```bash
curl -s -X PUT "http://litellm:4000/v1/memory/general:my_new_key" \
  -H "Authorization: Bearer ${LITELLM_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"value": "Updated content."}'
```

## Delete a Memory

```bash
curl -s -X DELETE "http://litellm:4000/v1/memory/general:my_new_key" \
  -H "Authorization: Bearer ${LITELLM_API_KEY}"
```

## Conventions

- Prefer updating (upsert) an existing key over creating a near-duplicate — consolidate rather
  than fork. This especially applies to `project_state:*` entries: one entry per project, not per
  feature or session. If more than one entry exists for the same project, merge them.
- Keep `value` as plain text/markdown, free-form.
- No `metadata`, `tokenCount`, or `updated_at` bookkeeping needed — LiteLLM tracks `created_at`,
  `updated_at`, `created_by`, `updated_by` automatically per entry.
