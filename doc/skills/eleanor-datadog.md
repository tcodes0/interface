---
name: eleanor-datadog
description: Use when investigating member app issues, tracing requests in Datadog, or looking up member IDs across hub-server and member-server for Eleanor Health.
---

# Eleanor Datadog

## Service Architecture

Eleanor Health runs two backend services, each with its own database:

| Service         | Role                                     | Database    |
| --------------- | ---------------------------------------- | ----------- |
| `hub-server`    | Staff-facing API, patient records        | prod_hub    |
| `member-server` | Member-facing API, proxies to hub-server | prod_member |

Member app traffic flows: **Member app → member-server → hub-server**.

The two services use different UUIDs for the same patient — always resolve both.

## Member ID Lookup

### Step 1 — hub UUID from Athena patient ID

```sql
-- prod_hub DB
SELECT id, first_name, last_name, created_at
FROM members
WHERE athena_patient_id = '<id>';
```

### Step 2 — member-server UUID from hub UUID

```sql
-- prod_member DB
SELECT id, hub_id, created_at
FROM members
WHERE hub_id = '<hub-uuid>';
```

## Datadog Query Templates

### Member app requests reaching hub-server (via member-server)

```
env:prod service:(hub-server) @url:*/members/<hub-uuid>* @userAgent:member-server
```

### Member app requests at the member-server layer

```
env:prod service:(member-server) @http.url:*/members/<member-server-uuid>*
```

### Specific endpoint across all members

```
env:prod service:(hub-server) @url:*/drug-screens* @userAgent:member-server
```

## Key Log Fields

| Field               | Meaning                                                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `userId`            | **Staff / hub user** — the human logged into the hub portal. Hub has no concept of members as users; members are patients. |
| `memberId`          | **Patient** — MemberIds refer to patients.                                                                                 |
| `hubUserId`         | Staff user ID, used in member-server logs when a staff member masquerades as a patient                                     |
| `userAgent`         | `member-server` indicates traffic proxied from the member app                                                              |
| `@http.status_code` | HTTP status of the response                                                                                                |

## Endpoint Reference

| Endpoint                        | Service       | Purpose                        |
| ------------------------------- | ------------- | ------------------------------ |
| `POST /v1/drug-screens`         | hub-server    | Submit UDS (urine drug screen) |
| `GET /v3/action-items`          | member-server | Member action items            |
| `GET /v1/most-recent-scales`    | member-server | Recent scale readings          |
| `GET /v2/onboarding/sections`   | member-server | Onboarding state               |
| `GET /v1/past-appointments`     | member-server | Past appointment list          |
| `POST /v1/onetime-interactions` | member-server | Record one-time member events  |

## Investigation Pattern

1. **Resolve member IDs** — get hub UUID and member-server UUID from Athena patient ID (see above).
2. **Check if the request hit the server** — search hub-server logs for the specific endpoint and member UUID.
3. **If zero hits** — the issue is client-side; the request never left the app.
4. **If hits exist** — check status codes, error messages, and response bodies.
5. **Check member activity** — search member-server for recent sessions to confirm the member is otherwise active.
6. **Check for masquerade** — a `hubUserId` in member-server logs means a staff user is acting as the member.
7. **Compare against other members** — run the same endpoint query without the member filter to confirm the endpoint is healthy for other users.
