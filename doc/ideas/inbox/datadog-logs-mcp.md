# Datadog logs MCP server

An MCP server that wraps the Datadog Logs API so agents can search and tail logs directly in context.

## Motivation

Investigating production issues currently means switching to the Datadog UI or curling the API manually. An MCP server would let agents search logs, correlate errors, and dig into incidents without leaving the workflow.

## Rough Design

- Tools: `search_logs(query, from, to)`, `get_log(id)`, `list_indexes`
- Auth via Datadog API key + app key injected server-side (never in model context — see auth-injection-mcp idea)
- Time range defaults to last 15 minutes if not specified
- Return a trimmed, readable slice of log lines — not raw JSON blobs
- Configurable site (datadoghq.com vs datadoghq.eu)
