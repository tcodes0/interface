# GCP integration in API Key MCP

Integrate Google Cloud Platform into the API Key MCP server, with Cloud Build
and BigQuery as the first-class tool targets.

## Relation to existing ideas

- **[21] keys v2 GCP** — the service account auth layer (JWT → bearer token exchange)
  is a prerequisite; build on or merge with that work
- **[09] bigquery-mcp** — BigQuery tools land here rather than as a separate server
- **[17] cloud build PR comments** — Cloud Build log/status tools enable this

## Scope

### Auth (builds on [21])

- `google_service_account` secret type in the MCP key store
- JWT → access token exchange, cached with refresh
- Shared across all GCP tools in the server

### Cloud Build tools

- `cloud_build_trigger` — trigger a build by trigger ID or tag
- `cloud_build_status` — poll build status by build ID
- `cloud_build_logs` — fetch or stream build logs

### BigQuery tools

- `bq_query` — run a read-only SQL query, return rows as JSON
- `bq_list_datasets` — list datasets in a project
- `bq_list_tables` — list tables in a dataset
- `bq_table_schema` — return schema for a table

## Notes

- Read-only BigQuery by default (no DDL/DML)
- Both Cloud Build and BigQuery APIs are straightforward REST; no client library needed
- Once auth is in, other GCP surfaces (GCS, Drive, Pub/Sub) are incremental adds
