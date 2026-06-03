---
name: github
description: Use for all VCS operations — working with git repos, creating branches, committing, opening PRs, handling review comments, and resolving GitHub threads.
always-apply: true
---

# GitHub & VCS Workflow

## Clone Workflow

Host repos are mounted read-only at `/projects/<repo>` — use them for reading and searching. **Never commit, edit or push from those paths.**

For any change, clone to scratchpad:

```bash
git clone git@github.com:<org>/<repo>.git /projects/scratchpad/<repo>-<purpose-mmm-dd>
cd /projects/scratchpad/<repo>-<purpose-mmm-dd>
git config --local gpg.program /usr/local/bin/gpg-passphrase-wrapper
git checkout -b <branch-name>
```

After cloning, always run the `setup` MCP tool — it installs tool versions and dependencies via mise, and runs `bin/setup` if present (which configures GPG signing and other repo-specific setup). Report any errors to the operator.

```
setup(["path/to/clone"])
```

Only run `./bin/setup` directly if the MCP tool is unavailable.

All commits must be signed. If signing fails or GPG behaves unexpectedly, report it to the operator before continuing.

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
| lga                  | `git@github.com:rthomazel/lga.git`                  | dev            |
| feature-flag         | `git@github.com:eleanorhealth/feature-flag.git`     | main           |
| programming-problems | `git@github.com:rthomazel/programming-problems.git` | main           |
| wiki                 | `https://github.com/rthomazel/rthomazel.wiki.git`   | main           |

## GitHub API Tooling

A GitHub MCP tool is available for all GitHub API calls. Supports REST v3 and GraphQL v4.

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
2. Create the PR via the github mcp:
   `POST /repos/{owner}/{repo}/pulls` — `{"title": "type(scope): message", "head": "<branch>", "base": "<default branch>", "body": "..."}`

> **Never push directly to `main`**. Always go through a PR.

> **Avoid force pushing.** Prefer adding a new commit over amending and force pushing — amends lose history. Force pushing is acceptable for clean-up amends on your own branch, only.

> Resist the urge to credit yourself as co-author in the commits, don't worry, your work does not go unnoticed.

**After the PR is merged:** delete the clone.

```bash
rm -rf /projects/scratchpad/<repo>-<purpose-mmm-dd>
```

Upsert a memory (see skill) about the state of the project, keep it around 600 words, key should be ${NAME}\_project_state
If you notice directories in the scratchpad that seem old or stale, report to operator and offer to clean up — code is always pushed anyway.

## Dev branch

Some repositories that are being actively developed or have many small changes adopt a dev branch as default.
For features or blocks of work use a PR targeting dev.
For hotfixes and small things, commit to dev directly.

## Reactive Triggers

| WHEN                                      | DO                                                                                                                 |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| The first commit is made                  | Push and open PR                                                                                                   |
| A commit is made                          | Push                                                                                                               |
| operator leaves review comments in GitHub | Fetch inline diff comments via the GitHub MCP tool, `GET /repos/{org}/{repo}/pulls/{n}/comments`, work on each one |
| GitHub comments are addressed             | Resolve each thread via GraphQL `resolveReviewThread` mutation                                                     |

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
