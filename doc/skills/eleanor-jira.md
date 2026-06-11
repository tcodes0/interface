---
name: eleanor-jira
description: Use when working with Jira — querying issues, sprints, projects, or updating tickets for Eleanor Health.
---

# Jira

Use the jira tool for all operations.

## Known IDs

| Resource            | Value                           |
| ------------------- | ------------------------------- |
| Operator account ID | `5f5a8fd086199e007c2727c1`      |
| PC project ID       | `10022`                         |
| PC board ID         | `26`                            |
| PC project type     | Agile                           |
| IT project ID       | `10030`                         |
| IT project name     | IT Support                      |
| IT project type     | Service Desk (no board/sprints) |

## Sprint Naming Convention

Sprints are named with letters of the alphabet in increasing order, typically followed by a theme word (e.g. foods, animals). The current active sprint letter can be found by inspecting the active sprint name. Next sprint = next letter.

Example progression: … `Jellyfish Sandwich` (J) → `K` → …

## Project Type Differences

| Feature               | Agile (PC)   | Service Desk (IT)                                                                            |
| --------------------- | ------------ | -------------------------------------------------------------------------------------------- |
| Boards/sprints        | yes          | no                                                                                           |
| `description` format  | Plain string | ADF (structured JSON — walk `content` tree to extract text)                                  |
| Comment `body` format | Plain string | ADF                                                                                          |
| SLA fields            | no           | yes (`customfield_10056` = time to resolution, `customfield_10057` = time to first response) |

## Patterns

### Get active sprint issues

1. `GET /rest/agile/1.0/board?projectKeyOrId=PC` → board ID
2. `GET /rest/agile/1.0/board/{boardId}/sprint?state=active` → sprint ID
3. `GET /rest/agile/1.0/board/{boardId}/sprint/{sprintId}/issue` → issues

### Get any issue

GET `/rest/api/3/issue/{key}`

Works for both project types (e.g. `PC-2816`, `IT-13276`).

### Rolling a sprint (close current, open next)

Jira Cloud does **not** support passing a destination sprint when closing — incomplete issues must be moved manually first.

1. **Check active sprint** — `GET /rest/agile/1.0/board/{boardId}/sprint?state=active` → get sprint ID and name
2. **Create new sprint** — `POST /rest/agile/1.0/sprint`
   ```json
   { "name": "<letter or name>", "originBoardId": 26 }
   ```
   → returns new sprint ID
3. **Find incomplete issues** — `GET /rest/agile/1.0/board/{boardId}/sprint/{oldSprintId}/issue`
   Filter for any not in `Done` status category
4. **Move incomplete issues to new sprint** — `POST /rest/agile/1.0/sprint/{newSprintId}/issue`
   ```json
   { "issues": ["PC-XXXX", ...] }
   ```
5. **Close old sprint** — `POST /rest/agile/1.0/sprint/{oldSprintId}`
   ```json
   { "state": "closed" }
   ```
6. **Start new sprint** — `POST /rest/agile/1.0/sprint/{newSprintId}`
   ```json
   {
     "state": "active",
     "startDate": "<ISO8601>",
     "endDate": "<ISO8601 + 2 weeks>"
   }
   ```

> Note: "Move to top" is not exposed via Jira Cloud API. It's a no-op when only one future sprint exists at creation time.

## Comment Tone Guidelines

When writing comments on IT tickets, match the operator's voice:

- **No exclamation marks** — ever.
- **Neutral, matter-of-fact tone** — not enthusiastic, not overly formal.
- **Concise** — say what needs to be said, nothing more.
- Avoid filler phrases like "Great news", "Happy to help", "Hope this helps", "Thank you for your patience".
- Greetings are fine ("Hi [name],") but keep them brief.
- Sign off with a period, not a comma or exclamation mark.
