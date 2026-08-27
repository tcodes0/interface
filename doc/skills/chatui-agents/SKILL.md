---
name: chatui-agents
description: Use when inspecting or updating an agent record in the chat UI's database — syncing a system prompt file to an agent, finding an agent by name, or checking which model an agent runs.
---

# Chat UI Agent Records

Agent records (name, model, system prompt) live in the chat UI's own database, separate from
wherever skills are hosted (see the `skills` skill for that). This skill covers reading and
updating those records.

## Database Access

**Reads / inspection:** use `mongosh`

```bash
mongosh librechat-db:27017/LibreChat --quiet
```

**Writes that embed file content:** use pymongo via a single-quoted heredoc — `$set` and regex
literals get mangled by bash expansion in all `mongosh` CLI modes

```bash
PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
db = MongoClient('librechat-db', 27017)['LibreChat']
# ... your write here
PYEOF
```

No authentication. Key collection: `agents` — includes `name` and `instructions` (the system
prompt).

## Syncing a System Prompt

System prompt source files live at `/projects/interface/doc/agents/*.md`. After editing one, sync
it to the corresponding agent record:

```bash
PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
content = open('/projects/interface/doc/agents/<name>.md').read()
MongoClient('librechat-db', 27017)['LibreChat'].agents.update_one(
    {'name': {'$regex': '<agent-name>', '$options': 'i'}}, {'$set': {'instructions': content}})
PYEOF
```

Note the Python variable is named `content` here for readability — the actual field on the document
is `instructions`, not `content`. Double-check the regex matches exactly one agent before running a
write with a broad pattern; several agent variants can share a name prefix (e.g. multiple model
variants of the same base agent).

## Finding an Agent

```javascript
// mongosh librechat-db:27017/LibreChat --quiet
db.agents.find({ name: { $regex: "<partial-name>", $options: "i" } }, { name: 1, model: 1 });
```

When a system prompt describes itself as "source of truth" and includes its own sync snippet
inline, treat the file on disk as authoritative — verify the embedded snippet still points at the
correct Mongo host before trusting it, since copies embedded in older agent instructions can drift
(e.g. referencing a stale hostname) even after the source file is corrected.

## Environment

Call the `context` tool at session start to understand what tools and paths are available in the
current environment.
