---
name: github
description: Use for all VCS operations — working with git repos, creating branches, committing, opening PRs, handling review comments, and resolving GitHub threads.
always-apply: true
---

# GitHub & VCS Workflow

## Working Copy Rules

Repos may be managed by Jujutsu. Git is always in detached HEAD. **Never use `git commit`, `git checkout`, or `git branch` directly on the main working copy.**

Instead, create a git worktree in scratchpad and work there:

```bash
git -C /projects/<repo> worktree list   # check for existing worktrees first
git -C /projects/<repo> worktree add /projects/scratchpad/<repo>-<name-mmm-dd> -b <name-mmm-dd>
```

Reuse an existing worktree if it's on the right branch. Use plain git commits in the worktree.

## Pushing & PRs

**When ready to push:**

1. `git push origin <branch>`
2. `gh pr create --head <branch> --base main --title "type(scope): message" --body "..."`

> **Never push directly to `main`** (e.g. `git push origin HEAD:main`). Always go through a PR.

**When work is done:** clean up the worktree after the PR is **merged**.

```bash
git -C /projects/<repo> worktree remove /projects/scratchpad/<repo>-<name>
```

## Reactive Triggers

| WHEN                                  | DO                                                                                                  |
| ------------------------------------- | --------------------------------------------------------------------------------------------------- |
| The first commit is made              | Push and open PR                                                                                    |
| A commit is made                      | Push                                                                                                |
| Thom leaves review comments in GitHub | Fetch inline diff comments via `gh api repos/rthomazel/{repo}/pulls/{n}/comments`, work on each one |
| GitHub comments are addressed         | Resolve each thread via GraphQL `resolveReviewThread` mutation                                      |

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
