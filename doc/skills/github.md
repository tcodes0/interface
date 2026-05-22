---
name: github
description: Use for all VCS operations — working with git repos, creating branches, committing, opening PRs, handling review comments, and resolving GitHub threads.
always-apply: true
---

# GitHub & VCS Workflow

## Clone Workflow

Host repos are mounted read-only at `/projects/<repo>` — use them for reading and searching. **Never commit or push from those paths.**

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

| Mount                | Clone URL                                           |
| -------------------- | --------------------------------------------------- |
| server               | `git@github.com:eleanorhealth/hub-server.git`       |
| member-server        | `git@github.com:eleanorhealth/member-server.git`    |
| interface            | `git@github.com:rthomazel/interface.git`            |
| client               | `git@github.com:eleanorhealth/hub-client.git`       |
| comms                | `git@github.com:eleanorhealth/comms.git`            |
| go                   | `git@github.com:tcodes0/go.git`                     |
| go-athenahealth      | `git@github.com:eleanorhealth/go-athenahealth.git`  |
| go-common            | `git@github.com:eleanorhealth/go-common.git`        |
| jail-mcp             | `git@github.com:rthomazel/jail-mcp.git`             |
| member-client        | `git@github.com:eleanorhealth/member-client.git`    |
| scheduling           | `git@github.com:eleanorhealth/scheduling.git`       |
| shared               | `git@github.com:eleanorhealth/frontend-shared.git`  |
| compose-files        | `git@github.com:rthomazel/compose-files.git`        |
| feature-flag         | `git@github.com:eleanorhealth/feature-flag.git`     |
| programming-problems | `git@github.com:rthomazel/programming-problems.git` |
| wiki                 | `https://github.com/rthomazel/rthomazel.wiki.git`   |

## Pushing & PRs

**When ready to push:**

1. `git push origin <branch>`
2. `gh pr create --head <branch> --base main --title "type(scope): message" --body "..."`

> **Never push directly to `main`**. Always go through a PR.

> **Avoid force pushing.** Prefer adding a new commit over amending and force pushing — amends lose history. Force pushing is acceptable for clean-up amends on your own branch, but never on `main`.

**After the PR is merged:** delete the clone.

```bash
rm -rf /projects/scratchpad/<repo>-<purpose-mmm-dd>
```

## Reactive Triggers

| WHEN                                      | DO                                                                                                  |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------- |
| The first commit is made                  | Push and open PR                                                                                    |
| A commit is made                          | Push                                                                                                |
| operator leaves review comments in GitHub | Fetch inline diff comments via `gh api repos/rthomazel/{repo}/pulls/{n}/comments`, work on each one |
| GitHub comments are addressed             | Resolve each thread via GraphQL `resolveReviewThread` mutation                                      |

## Resolving GitHub Review Threads

The comments API (`/pulls/{n}/comments`) returns comment node IDs prefixed `PRRC_`. The `resolveReviewThread` mutation requires the **thread** node ID prefixed `PRRT_`.

Get thread IDs via GraphQL:

```graphql
{
  repository(owner: "rthomazel", name: "<repo>") {
    pullRequest(number: <n>) {
      reviewThreads(first: 10) {
        nodes { id isResolved }
      }
    }
  }
}
```
