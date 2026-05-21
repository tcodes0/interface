---
name: ai-chat
description: Use when working with the LibreChat instance — querying or updating the database, managing agent records, or syncing agent system prompts.
always-apply: true
---

# LibreChat Instance Reference

## MongoDB

```bash
mongosh mongodb:27017/LibreChat --quiet
```

No authentication. Key collections:

| Collection      | Contains                                               |
| --------------- | ------------------------------------------------------ |
| `skills`        | Agent skill definitions                                |
| `aclentries`    | Access control — gates UI visibility of all resources  |
| `agents`        | Agent records including `instructions` (system prompt) |
| `memoryentries` | Persistent user memories                               |
| `users`         | User accounts                                          |

## Known IDs

| What                    | ID                         |
| ----------------------- | -------------------------- |
| Thom's user `rthomazel` | `69e6beb74aa4d2249360a4ab` |
| Skills ACL role         | `6a0336a122e01bacd9e152fa` |

## Agent System Prompts

Source files live at `/projects/interface/doc/prompts/agent-*.md`. Skill definitions live at `/projects/interface/doc/skills/*.md`.

Sync a prompt file to its MongoDB agent record after editing:

```bash
mongosh mongodb:27017/LibreChat --quiet --eval \
  'db.agents.updateOne({name:/<agent-name>/i},{$set:{instructions:cat("/projects/interface/doc/prompts/agent-<name>.md")}})'
```

## Environment

Call the `context` tool at session start to understand what tools and paths are available in the current environment.
