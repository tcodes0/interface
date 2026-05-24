---
name: chatui-skills
description: Use when creating, inspecting, repairing, or inserting LibreChat agent skills directly into the database — including schema layout, ACL requirements, and the always-apply body sync rule.
---

# LibreChat Skills — Database Management

For connection details and known IDs, see the `chatui` skill.

> Skill inserts embed body content — use pymongo heredoc. For reads, ACL entries, and repairs use mongosh directly.

## SKILL.md Format

Every skill is a Markdown file with a YAML frontmatter block at the top:

```markdown
---
name: my-skill
description: Use when the user asks to do X or mentions Y.
always-apply: false
user-invocable: true
disable-model-invocation: false
allowed-tools: ["execute_code"]
---

# Skill Title

Instruction body here — procedures, rules, examples, references.
```

### Frontmatter Fields

| Key                        | Type     | Description                                                                                   |
| -------------------------- | -------- | --------------------------------------------------------------------------------------------- |
| `name`                     | String   | Kebab-case identifier. `^[a-z0-9][a-z0-9-]*$`. Stable — renaming breaks references.           |
| `description`              | String   | **Primary trigger signal.** Write as "Use when [specific situation]". Vague = under-triggers. |
| `always-apply`             | Boolean  | Auto-prime into every turn. Default: `false`.                                                 |
| `user-invocable`           | Boolean  | Show in `$` popover. Default: `true`. Set `false` for model-only skills.                      |
| `disable-model-invocation` | Boolean  | Exclude from model catalog. Manual `$` still works. Default: `false`.                         |
| `allowed-tools`            | String[] | Tools temporarily added to the agent's effective set when skill is active.                    |

Only `name` and `description` are required. Omit optional fields rather than setting them to defaults.

## Schema: `skills` Collection

Required fields:

| Field                    | Notes                                                                     |
| ------------------------ | ------------------------------------------------------------------------- |
| `name`                   | Kebab-case, unique per author. `^[a-z0-9][a-z0-9-]*$`                     |
| `description`            | Model trigger sentence — primary signal for model-invoked skills          |
| `body`                   | Full SKILL.md including YAML frontmatter block at the top (see sync rule) |
| `frontmatter`            | Structured bag: `{}` minimum, or `{'always-apply': True}` etc.            |
| `alwaysApply`            | Boolean. Must stay in sync with `frontmatter` and `body` frontmatter      |
| `disableModelInvocation` | `False` for model-invoked skills                                          |
| `userInvocable`          | `True` (default)                                                          |
| `author`                 | operator's user ObjectId                                                  |
| `authorName`             | `'R Thomazella'`                                                          |
| `source`                 | `'inline'`                                                                |
| `version`                | `1` on create                                                             |
| `fileCount`              | `0`                                                                       |
| `category`               | `''` or label string                                                      |
| `__v`                    | `0`                                                                       |

Leave `allowedTools` and `tenantId` absent (not `null`).

## Every Skill Needs an ACL Entry

Skills without an `aclentries` document are invisible in the UI.

```javascript
// /root/insert_acl.js — run: mongosh mongodb:27017/LibreChat --quiet /root/insert_acl.js
var skillId = ObjectId("REPLACE_WITH_SKILL_ID");
var userId = ObjectId("69e6beb74aa4d2249360a4ab");
var roleId = ObjectId("6a0336a122e01bacd9e152fa");
var now = new Date();
db.aclentries.insertOne({
  principalType: "user",
  principalId: userId,
  resourceId: skillId,
  resourceType: "skill",
  principalModel: "User",
  permBits: 15,
  roleId: roleId,
  grantedBy: userId,
  grantedAt: now,
  createdAt: now,
  updatedAt: now,
  __v: 0,
});
```

## The `alwaysApply` / Body Sync Rule

`alwaysApply` is derived from three sources in priority order:

1. Top-level `alwaysApply` field on the document
2. `frontmatter['always-apply']`
3. `always-apply:` line inside the YAML block at the top of `body`

**If the user saves a body in the UI with no `always-apply:` line, `alwaysApply` flips to `false` — the pin disappears.**

Always embed the full frontmatter block at the top of `body`:

```markdown
---
name: my-skill
description: When to use this.
always-apply: true
---

# Skill body here
```

## Syncing a Skill Body

> **`body`, not `content`.** The field is `body`. The agent sync example in `chatui` uses a Python variable named `content` — do not carry that over. Writing to `content` silently creates a stale orphan field and the skill will not update in the UI.

```bash
PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
from datetime import datetime, timezone
db = MongoClient('mongodb', 27017)['LibreChat']
body = open('/projects/interface/doc/skills/<name>.md').read()
result = db.skills.update_one(
    {'name': '<skill-name>'},
    {'$set': {'body': body, 'updatedAt': datetime.now(timezone.utc)}, '$inc': {'version': 1}}
)
print(f'matched: {result.matched_count}, modified: {result.modified_count}')
PYEOF
```

If a stale `content` field was previously written, remove it:

```bash
PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
db = MongoClient('mongodb', 27017)['LibreChat']
db.skills.update_one({'name': '<skill-name>'}, {'$unset': {'content': ''}})
PYEOF
```

## Inspecting a Skill

```javascript
// mongosh mongodb:27017/LibreChat --quiet
db.skills.findOne({ name: "my-skill" }, { name: 1, alwaysApply: 1, frontmatter: 1, version: 1 });
db.aclentries.findOne({ resourceType: "skill", resourceId: ObjectId("...") });
```

## Repairing `alwaysApply`

```javascript
db.skills.updateOne(
  { name: "my-skill" },
  { $set: { alwaysApply: true, updatedAt: new Date() }, $inc: { version: 1 } },
);
```
