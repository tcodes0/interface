# compose-agents-md

Centralized source for `AGENTS.md` deployed across all projects.

Assembled by `bin/compose-agents-md`.

## How it works

`bin/compose-agents-md` assembles an `AGENTS.md` for each project by concatenating:

1. `header.md` — `# Project Guidelines` title (always prepended)
2. One fragment file per entry in `.composeagentsmdrc` for the project

Each fragment file contains exactly one cohesive markdown section or sub-section.
Fragments are assembled in the order listed in the RC — the RC defines document structure.

The project → parts mapping lives in
`~/.config/github.com.rthomazel/.composeagentsmdrc`.
Each line has the form `project: part1 part2 ...`.

```
# .composeagentsmdrc
my-go-service:  role build_go arch_ddd style_gofumpt commits agent_setup misc misc_go
my-ts-app:      role_extended build_ts style_ts misc misc_no_pool
```

## Fragments with `## Headings` vs inline appenders

Most fragments open a new `##` section. A few (`misc_go`, `misc_db_*`, `misc_no_pool`) have
no heading and are designed to append lines directly under the `## Misc` section started by
`misc`. List them immediately after `misc` in the RC.

## Usage

```sh
# Check all projects for drift (default, no writes)
bin/compose-agents-md

# Check specific projects
bin/compose-agents-md server comms

# Deploy all
bin/compose-agents-md --commit

# Deploy specific
bin/compose-agents-md --commit server comms

# Use an alternate RC file
bin/compose-agents-md --rc=path/to/.composeagentsmdrc
```

## Formatting

Oxfmt is used

## Adding a fragment

1. Create `<name>.md` in `src/compose-agents-md/` with the section content.
2. Add `<name>` to the relevant project lines in `.composeagentsmdrc`.
3. Run `bin/compose-agents-md` to verify, `--commit` to deploy.

## Adding a project

1. Add a line to `.composeagentsmdrc`: `<project>: role <parts...>`
2. Run `bin/compose-agents-md --commit <project>`.

## Projects not managed here

Some projects have `AGENTS.md` files too unique to assemble from common fragments:

- `interface` — shell-specific role and style
- `bench-mcp` — different document structure
- `scratchpad` — project-specific freeform
- `programming-problems` — entirely different purpose

## Fragment index

<!-- AGENTS: run the snippet below from src/compose-agents-md/, display output as Markdown -->

```bash
printf '| Fragment | Description |\n| --- | --- |\n'; for f in *.md; do [[ "$f" == README.md ]] && continue; name=$(basename "$f" .md); desc=$(head -1 "$f" | sed 's/^#* *//'); printf '| `%s` | %s |\n' "$name" "$desc"; done
```
