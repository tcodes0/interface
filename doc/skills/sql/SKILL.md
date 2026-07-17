---
name: sql
description: Use when interacting with SQL databases, writing queries, investigating data, or running any SQL statement.
---

# SQL Querying

## Display Rule

**Always display every query to the user before running it** — no silent execution.

For SELECT queries used as quick internal investigation steps within a larger task (e.g. checking a foreign key before writing a migration), brief inline display is fine.

## SELECT Queries (DQL)

`SELECT`, `SHOW`, `DESCRIBE`, `EXPLAIN` and similar read-only statements:

- Display the query
- Run immediately — no confirmation required
- Show sample output when it adds context

## Mutation Queries

`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `CREATE`, `ALTER`, `DROP`, `GRANT`, `REVOKE` and any other statement that changes data or schema:

- Display the query
- **Wait for explicit user confirmation before running**
- Never infer confirmation from prior context — ask each time
