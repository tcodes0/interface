---
name: jira
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
