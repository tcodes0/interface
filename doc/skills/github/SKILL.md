---
name: github
description: Use for all VCS operations — working with git repos, creating branches, committing, opening PRs, handling review comments, and resolving GitHub threads.
---

# GitHub & VCS Workflow

## Clone Workflow

It's better to clone the repository to read code than using the GitHub API to fetch files.

```bash
git clone git@github.com:<org>/<repo>.git /projects/<repo>-<purpose-mmm-dd>
cd /projects/<repo>-<purpose-mmm-dd>
git config --local gpg.program /usr/local/bin/gpg-passphrase-wrapper
git checkout -b <branch-name>
```

Before cloning, check whether a clone for that repo already exists and reuse it if so — avoid redundant re-clones within the same session.
**Careful**: Check the branch the existing clone is checked out on, if it's not your branch, you start a new one from main.
After cloning, always run the `setup` MCP tool — it installs tool versions and dependencies via mise, and runs `bin/setup` if present (which configures GPG signing and other repo-specific setup).
Report any errors to the operator.
Because this tool is async, you can continue other tasks while it works.

```
setup(["path/to/clone"])
```

Only run `./bin/setup` directly if the MCP tool is unavailable.

All commits must be signed. If signing fails or GPG behaves unexpectedly, report it to the operator before continuing.

**`/usr/local/bin` is ephemeral** in agent containers — `gpg-passphrase-wrapper` only exists there after `bin/setup` has run *this session*. If signing fails with "cannot exec" for that path, rerun `setup` rather than hand-placing a copy on a persistent volume (e.g. `/root/bin`) to work around it — a stale hand-edited copy there previously shadowed the real wrapper and silently broke signing for sessions that picked it up first. The canonical wrapper source lives at `interface/bin/gpg-passphrase-wrapper`; `bin/setup` fetches it from raw GitHub. See `doc/ideas/gpg-wrapper-versioning.md`.

### Repo Catalog

| Mount                | Clone URL                                           | Default branch |
| -------------------- | --------------------------------------------------- | -------------- |
| server               | `git@github.com:eleanorhealth/hub-server.git`       | main           |
| member-server        | `git@github.com:eleanorhealth/member-server.git`    | main           |
| interface            | `git@github.com:rthomazel/interface.git`            | dev            |
| client               | `git@github.com:eleanorhealth/hub-client.git`       | main           |
| comms                | `git@github.com:eleanorhealth/comms.git`            | main           |
| go                   | `git@github.com:tcodes0/go.git`                     | main           |
| go-athenahealth      | `git@github.com:eleanorhealth/go-athenahealth.git`  | main           |
| go-common            | `git@github.com:eleanorhealth/go-common.git`        | main           |
| mcp                  | `git@github.com:rthomazel/mcp.git`                  | main           |
| member-client        | `git@github.com:eleanorhealth/member-client.git`    | main           |
| scheduling           | `git@github.com:eleanorhealth/scheduling.git`       | main           |
| shared               | `git@github.com:eleanorhealth/frontend-shared.git`  | main           |
| compose-files        | `git@github.com:rthomazel/compose-files.git`        | main           |
| worker-vllm          | `git@github.com:rthomazel/worker-vllm.git`          | main           |
| lga                  | `git@github.com:rthomazel/lga.git`                  | dev            |
| feature-flag         | `git@github.com:eleanorhealth/feature-flag.git`     | main           |
| data-jobs            | `git@github.com:eleanorhealth/data-jobs.git`        | main           |
| programming-problems | `git@github.com:rthomazel/programming-problems.git` | main           |
| wiki                 | `git@github.com:rthomazel/rthomazel.wiki.git`       | main           |
| litellm-pgvector     | `git@github.com:rthomazel/litellm-pgvector.git`     | main           |

report missing repo clone URLs and stop.

## GitHub API Tooling

A GitHub tool is available for all GitHub API calls. Supports REST v3 and GraphQL v4.
To find it: "api_keys" tool set, "github" tool

```
# Read PR comments
GET /repos/{owner}/{repo}/pulls/{n}/comments

# Create PR
POST /repos/{owner}/{repo}/pulls
body: {"title": "...", "head": "<branch>", "base": "<default branch>", "body": "..."}

# GraphQL
POST /graphql
body: {"query": "{ ... }"}
```

Shell `git` still handles cloning, committing, and pushing.

## Pushing & PRs

**When ready to push:**

1. `git push origin <branch>`
2. Create the PR via the github tool:
   `POST /repos/{owner}/{repo}/pulls` — `{"title": "type(scope): message", "head": "<branch>", "base": "<default branch>", "body": "..."}`

> **Never push directly to `main`**. Always go through a PR.

> **Avoid force pushing.** Prefer adding a new commit over amending and force pushing — amends lose history. Force pushing is acceptable for clean-up amends on your own branch, only.

> Resist the urge to credit yourself as co-author in the commits, don't worry, your work does not go unnoticed.

**When to delete the clone:**

- _PR workflow:_ delete after the PR is merged.
- _Dev-direct workflow:_ keep the clone for the duration of work on that repo in the session. Delete only when the block of work is finished — not after each individual commit.

```bash
rm -rf /projects/<repo>-<purpose-mmm-dd>
```

> Warning: A few projects are permanently cloned
>
> - lga: This is the live stack where the workstation runs, if removed db crashes and everything crashes.
> - librechat-tsc: used in the patching workflow (see skill).

Update if exists or create a memory (see skill) about the state of the project, keep it around 300 words, key should be ${PROJECT_NAME}\_project_state.
The memory entry is per project, not per feature. If there's more than one entry for the same project, consolidate.
If you notice directories under projects that seem old or stale, report to operator and offer to clean up — code is always pushed anyway.

## Dev branch

Some repositories that are being actively developed or have many small changes adopt a dev branch as default.
For features or blocks of work use a PR targeting dev.
For hotfixes and small things, commit to dev directly.

## Reactive Triggers

| WHEN                                      | DO                                                                                                             |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| The first commit is made                  | Push and open PR                                                                                               |
| A commit is made                          | Push                                                                                                           |
| operator leaves review comments in GitHub | Fetch inline diff comments via the GitHub tool, `GET /repos/{org}/{repo}/pulls/{n}/comments`, work on each one |
| GitHub comments are addressed             | Resolve each thread via GraphQL `resolveReviewThread` mutation, push                                           |

## Resolving GitHub Review Threads

The comments API (`/pulls/{n}/comments`) returns comment node IDs prefixed `PRRC_`. The `resolveReviewThread` mutation requires the **thread** node ID prefixed `PRRT_`.

Get thread IDs via GraphQL:

```graphql
{
  repository(owner: "<org>", name: "<repo>") {
    pullRequest(number: <n>) {
      reviewThreads(first: 10) {
        nodes { id isResolved }
      }
    }
  }
}
```
