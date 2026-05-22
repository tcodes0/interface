---
name: ai-chat-skills
description: Use when creating, inspecting, repairing, or inserting LibreChat agent skills directly into the database — including schema layout, ACL requirements, and the always-apply body sync rule.
---

# LibreChat Skills — Database Management

For connection details and known IDs, see the `ai-chat` skill.

> Skill inserts embed body content — use pymongo heredoc. For reads, ACL entries, and repairs use mongosh directly.

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
| `author`                 | operator's user ObjectId                                                      |
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
