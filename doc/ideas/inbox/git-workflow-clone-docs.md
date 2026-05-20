# Git workflow: document clone URLs

Update the Git workflow documentation so that every repository entry includes where it can be cloned from.

## Motivation

When picking up a project on a new machine or handing context to an agent, it's not always obvious where a repo lives. Having the clone URL alongside the workflow steps removes that friction.

## Rough Design

- Audit existing workflow/repo docs (e.g. `doc/workflows.md`, `doc/structure.md`)
- For each project, add the GitHub clone URL (SSH or HTTPS)
- Keep it close to wherever the repo name and purpose are already documented
