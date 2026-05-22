---
name: ai-chat
description: Use when working with the LibreChat instance — querying or updating the database, managing agent records, or syncing agent system prompts.
always-apply: true
---

# LibreChat Instance Reference

## Database

**Reads / inspection:** use `mongosh`

```bash
mongosh mongodb:27017/LibreChat --quiet
```

**Writes that embed file content:** use pymongo via single-quoted heredoc — `$set` and regex literals are mangled by bash expansion in all mongosh CLI modes

```bash
PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
db = MongoClient('mongodb', 27017)['LibreChat']
# ... your write here
PYEOF
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

Source files live at `/projects/interface/doc/prompts/agents/*.md`. Skill definitions live at `/projects/interface/doc/skills/*.md`.

Sync a prompt file to its agent database record after editing:

```bash
PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
content = open('/projects/interface/doc/prompts/agents/<name>.md').read()
MongoClient('mongodb', 27017)['LibreChat'].agents.update_one(
    {'name': {'$regex': '<agent-name>', '$options': 'i'}}, {'$set': {'instructions': content}})
PYEOF
```

## Environment

Call the `context` tool at session start to understand what tools and paths are available in the current environment.
