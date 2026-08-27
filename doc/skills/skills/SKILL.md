---
name: skills
description: Use when creating a new skill, editing an existing SKILL.md, or figuring out how skills are discovered, read, or registered for model/agent use.
---

# Writing & Registering Skills

A skill is a single `SKILL.md` file — YAML frontmatter plus a Markdown body of instructions. Skills
are plain files hosted in a git repo; there is no separate database record for the content itself.
An agent discovers and reads skills over plain HTTP: list what's available, resolve the entry to a
raw file URL, fetch it.

## SKILL.md Format

```markdown
---
name: my-skill
description: Use when the user asks to do X or mentions Y.
---

# Skill Title

Instruction body here — procedures, rules, examples, references.
```

### Frontmatter Fields

| Key           | Type   | Description                                                                                   |
| ------------- | ------ | --------------------------------------------------------------------------------------------- |
| `name`        | String | Kebab-case identifier. `^[a-z0-9][a-z0-9-]*$`. Stable — renaming breaks references.           |
| `description` | String | **Primary trigger signal.** Write as "Use when [specific situation]". Vague = under-triggers. |

`name` and `description` are required.

Keep the body focused and procedural: what to do, in what order, with concrete commands/examples.
Link out to other skills by name rather than duplicating their content.

## Discovering Skills

Skills are published to a registry that stores metadata + a git pointer only — it does not host
content. Discovering a skill means listing the registry, then resolving that pointer yourself.

### List all public skills

```bash
curl -s http://litellm:4000/public/skill_hub
```

No auth required. Returns `{"plugins": [...], "count": N}`. Each entry has `name`, `description`,
`domain`, `namespace`, `version`, `enabled`, and a `source` object.

### Read a skill's content

1. Find the entry by `name` in the list above.
2. Resolve `source` to a raw file URL, based on `source.source`:

   | `source.source` | Fields        | Raw URL pattern                                                               |
   | --------------- | ------------- | ----------------------------------------------------------------------------- |
   | `git-subdir`    | `url`, `path` | `https://raw.githubusercontent.com/<org>/<repo>/<branch>/<path>/SKILL.md`     |
   | `github`        | `repo`        | `https://raw.githubusercontent.com/<repo>/<branch>/SKILL.md`                  |
   | `url`           | `url`         | Same repo, root-level `SKILL.md` — branch/path conventions vary, inspect repo |

   `<org>/<repo>` comes from parsing `url` or `repo`. **`branch` is not included in the response** —
   assume the repo's default branch unless told otherwise (e.g. `interface` uses `dev`).

3. Fetch it:

   ```bash
   curl -s https://raw.githubusercontent.com/rthomazel/interface/dev/doc/skills/github/SKILL.md
   ```

Example:

```json
{
  "name": "github",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/rthomazel/interface.git",
    "path": "doc/skills/github"
  }
}
```

Resolves to:

```
https://raw.githubusercontent.com/rthomazel/interface/dev/doc/skills/github/SKILL.md
```

Works without any token as long as the source repo is public. If a listed repo is private, this
recipe fails — that's the point at which a dedicated authenticated tool becomes worth building.

## Registering / Updating a Skill

Publishing a skill means registering its git pointer with the registry — never uploading content.

```bash
curl -s -X POST http://litellm:4000/claude-code/plugins \
  -H "Authorization: Bearer ${LITELLM_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-skill",
    "source": {"source": "git-subdir", "url": "https://github.com/<org>/<repo>.git", "path": "doc/skills/my-skill"},
    "description": "Use when ...",
    "category": "Engineering",
    "domain": "Engineering",
    "namespace": "<namespace>"
  }'
```

`LITELLM_API_KEY` lives in `/lga/services/librechat/.env` (see the `chatui-memory` skill for the same
key/lookup pattern). Re-posting the same `name` with updated fields **updates in place** —
`{"status": "success", "action": "updated", ...}` — no separate edit endpoint needed.

Other management endpoints, all under `/claude-code/plugins`:

| Method | Path                                  | Purpose                                       |
| ------ | ------------------------------------- | --------------------------------------------- |
| GET    | `/claude-code/plugins`                | List all (add `?enabled_only=true` to filter) |
| GET    | `/claude-code/plugins/{name}`         | Get one                                       |
| POST   | `/claude-code/plugins/{name}/enable`  | Enable a disabled skill                       |
| POST   | `/claude-code/plugins/{name}/disable` | Disable without deleting                      |
| DELETE | `/claude-code/plugins/{name}`         | Remove from the registry entirely             |

All of the above require the `Authorization` header; `/public/skill_hub` does not.

## Conventions

- One `SKILL.md` per directory, directory name matches `name` in frontmatter.
- Write a fresh skill's `description` field first and sanity-check it triggers on the situations you
  intend — this is the only signal used for model-invoked selection.
- Prefer editing an existing skill over creating a near-duplicate; consolidate overlapping skills.
- When a skill's guidance changes, update the file and re-register (see above) — the registry only
  ever reflects what's committed to the source repo at the referenced path/branch.
