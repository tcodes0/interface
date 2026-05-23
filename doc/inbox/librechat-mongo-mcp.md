# LibreChat MongoDB MCP Server

Expose the LibreChat MongoDB database to LibreChat agents via an MCP server, so agents can read and update the database themselves as they work.

## Motivation

Currently, syncing agent state (e.g. instructions, memory entries) requires external tooling — running mongosh manually or wiring up scripts outside the chat flow. If LibreChat agents had direct MCP access to their own MongoDB, they could manage their own records in-context: updating instructions, writing memories, querying past entries — without needing a human or a separate process to bridge the gap. This could replace or significantly improve LibreChat's current memory model.

## Rough Design

- Write a small MCP server (likely Python or Go) that wraps MongoDB operations
- Expose tools like: `find_agent`, `update_agent_instructions`, `list_memories`, `upsert_memory`, `delete_memory`
- Mount it into the LibreChat compose stack (compose-files repo) so it's available on the same Docker network as the MongoDB service
- Register it with LibreChat so agents can select it
- Scope permissions carefully — agents probably shouldn't have free DDL access, just scoped read/write on `agents` and `memoryentries` collections
