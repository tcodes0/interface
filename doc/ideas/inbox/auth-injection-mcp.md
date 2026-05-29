# Auth-injecting MCP server

A minimal MCP server whose only job is to make authenticated HTTP requests on behalf of an agent, without ever exposing API keys or tokens to the model context.

## Motivation

Models can see everything in their context window. Putting API keys there is a security risk. But agents still need to call authenticated APIs. A thin server-side proxy that injects credentials at call time keeps secrets out of the model entirely.

## Rough Design

- Agent calls a single `http_request` tool, providing:
  - the full curl command (URL, method, body, any non-secret headers)
  - an `inject` array of header name strings it wants populated (e.g. `["Authorization", "X-Api-Key"]`)
- The server looks up the values for those header names from its own config (env vars or a local secrets file)
- Appends the resolved secret header values to the request and executes it
- Returns the response body to the agent
- The model never sees the actual secret values — only the header names

## Configuration

- Text-based config file mapping header names to env vars or file paths:
  ```
  Authorization = env:OPENAI_API_KEY
  X-Api-Key     = env:ANTHROPIC_API_KEY
  ```
- Server reads config at startup; secrets never leave the server process

## Notes

- Cheapest implementation: small Go or Python MCP server, exec curl under the hood
- Safer alternative: construct the request in code rather than parsing a raw curl string
- Single tool signature: `http_request(method, url, headers[], body, inject[])` where `inject[]` is the list of header names the server should populate from its secrets store
