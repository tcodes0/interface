# BigQuery MCP server

An MCP server that exposes BigQuery as a tool, letting agents run queries and inspect datasets directly in context.

## Motivation

Querying BigQuery today requires leaving the agent workflow — opening the console or running bq CLI manually. An MCP server would let agents investigate data, validate assumptions, and answer questions without breaking flow.

## Rough Design

- Tools: `run_query(sql)`, `list_datasets`, `list_tables(dataset)`, `get_schema(dataset, table)`
- Auth via Google Application Default Credentials or a service account key mounted as a volume
- Read-only by default — no DDL, no DML
- Return results as JSON or a simple table string
- Configurable project ID and billing project
