# mise version pruning in sysupdate

Enhance `bin/sysupdate` to manage installed mise tool versions, keeping only the N most recent and removing the rest.

## Motivation

Mise accumulates old versions over time (`go`, `node`, `npm`, etc). There is currently no automated way to prune them. A `mise ls` run shows many stale versions sitting alongside the current one. Cleaning them up manually is tedious and easy to forget.

## Rough Design

- Add a "pruning" step to `bin/sysupdate` (or a subcommand / flag)
- Parse `mise ls` output to get all installed versions per tool
- Join with `~/.config/mise/config.toml` (and any local `.tool-versions`) to know which versions are pinned / in active use
- For each tool, apply a keep policy — e.g. "keep latest 2" means retain the 2 highest versions plus any that are pinned somewhere
- Run `mise uninstall <tool>@<version>` for everything outside the keep set
- Policy should be configurable per tool (some tools like `go` may want only 1, `node` may want 2)
- Dry-run mode to preview what would be removed before committing

## Notes

- use ollama?
