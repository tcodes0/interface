---
name: eh-jotform
description: Use when working with JotForm — fetching forms, submissions, or questions via the JotForm API for Eleanor Health.
---

# Eleanor Health JotForm

## MCP Tool

Use `eh_jotform_mcp_api_keys` for all JotForm API calls.

## Configuration

| Key              | Value                                    |
| ---------------- | ---------------------------------------- |
| Base URL         | `https://eleanorhealth.jotform.com/API`  |
| Team ID          | `243125834203044`                        |

## Critical: Team-Owned Forms

All Eleanor Health forms are owned by the team account (`!team_243125834203044`).
**Standard `/form/{id}/submissions` returns 401 for team-owned forms.**

Always use the team-scoped path:

```
GET /team/243125834203044/form/{FORM_ID}/submissions
```

### Endpoint Reference

| Resource                    | Path                                                     | Notes                          |
| --------------------------- | -------------------------------------------------------- | ------------------------------ |
| Form metadata               | `GET /form/{FORM_ID}`                                    | Works without team prefix      |
| Form questions              | `GET /form/{FORM_ID}/questions`                          | Works without team prefix      |
| Form submissions            | `GET /team/{TEAM_ID}/form/{FORM_ID}/submissions`         | **Team prefix required**       |
| Single submission           | `GET /team/{TEAM_ID}/submission/{SUBMISSION_ID}`         | **Team prefix required**       |

### Why the team prefix is required

The API key is scoped to the team account. Calls to `/form/{id}/submissions` route to the personal-account submission handler, which rejects the key with 401. The `/team/{team_id}/...` variants route to the team account handler where the key has full access.

## Address Widget Submissions

The "Address Search & Preview" widget (`control_widget`) serializes its answer as a **double-encoded JSON string**. Parse it in two steps:

1. `JSON.parse(answer)` → `{ value: "...", widget_metadata: {...} }`
2. Split `value` on `\n`, then split each line on `": "` to get key/value pairs.

Example raw `answer`:
```json
"{\"value\":\"Street Address: 167 Berkeley St\\nCity: Boston\\nState \\/ Province: Massachusetts\\nPostal \\/ Zip Code: 02116\", ...}"
```

Contrast with the structured `control_address` field, which returns a plain object directly:
```json
{ "addr_line1": "167 Berkeley St", "city": "Boston", "state": "Massachusetts", "postal": "02116" }
```
