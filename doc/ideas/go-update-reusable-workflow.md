# Reusable GitHub Workflow: Go Dependency & Version Updates

## Summary

Consolidate the per-repo Go dependency update cron job into a single reusable
public GitHub Actions workflow. Extend it with Go version bumping so one
workflow handles both routine `go get -u` runs and version upgrades.

## Motivation

Every Go service repo today has its own copy of the dependency update job.
Changes (new steps, token handling, branch naming) must be applied to each
repo individually. A reusable workflow centralises the logic — consuming repos
just pin a ref.

## Design

### Reusable workflow inputs

| Input         | Type    | Default | Description                                                              |
| ------------- | ------- | ------- | ------------------------------------------------------------------------ |
| `go_version`  | string  | `""`    | Target Go version to bump to (e.g. `1.24.2`). Empty = skip version bump. |
| `update_deps` | boolean | `true`  | Run `go get -u ./...` + `go mod tidy`                                    |
| `pr_base`     | string  | `main`  | Base branch for the opened PR                                            |

### Steps

1. **Checkout** the calling repo
2. **Set up Go** (using the existing or target version)
3. **(Optional) Bump Go version** — if `go_version` is set:
   - `go.mod` — update the `go` directive (`go X.Y.Z`)
   - `Dockerfile` / `*.dockerfile` — update `FROM golang:X.Y` image tags
   - `.tool-versions` — update `golang X.Y.Z` line
   - Commit the version bump separately from dep updates
4. **(Optional) Update dependencies** — `go get -u ./...` + `go mod tidy`
5. **Open PR** if any files changed — title: `chore(go): bump to X.Y.Z` or `chore(deps): update go modules`

### Hosting

Live in a public repo (e.g. `rthomazel/github-workflows` or a `.github` repo)
so it can be called from private Eleanor repos without token complications.

### Calling example

```yaml
jobs:
  update-go:
    uses: rthomazel/github-workflows/.github/workflows/go-update.yml@main
    with:
      go_version: "1.24.2"
      update_deps: true
    secrets: inherit
```

## Notes

- Dockerfile detection should handle multi-stage builds (bump every `FROM golang:` line)
- `.tool-versions` may use `golang` or `go` as the tool name — handle both
- Separate commits for version bump vs dep update keeps the diff readable
- Consider `dependabot` overlap — this fills the gap for Go toolchain itself
  (dependabot handles module deps but not the `go` directive or toolchain version)
