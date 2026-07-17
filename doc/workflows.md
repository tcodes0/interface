# Workflows & Tooling

## Commit workflow — `lazy-git` / `lazy-jujutsu`

Both scripts enforce [Conventional Commits](https://www.conventionalcommits.org/) via `commitlint`
and spell-check the commit message with `cspell`. Invoked as:

```
lg <type> <scope> <subject>   # aliased to lazy-git / lazy-jujutsu
```

Colons in `type` and `scope` are stripped automatically.
If `scope` is a single character, the format collapses to `type: subject` (no parens).

**`lazy-git` flow:**

1. If files are already staged, commits those. Otherwise runs `git add --all`.
2. Builds `type(scope): subject` message, validates with `commitlint` + `cspell`.
3. Commits with `--no-verify` (hook already ran via pre-commit, or skipped intentionally).
4. If `$PWD`'s basename matches `$PUSH_REPOS`, pushes to origin. Sets upstream automatically if missing.
5. Prints `git status --short`.

**`lazy-jujutsu` flow:**

1. Same message construction and validation.
2. Finds the nearest ancestor bookmark via `jj log`. Updates the bookmark to `@` (unless it's `main`/`master`).
3. Runs `jj commit`.
4. If repo matches `$PUSH_REPOS`, runs `jj git push`.

Config fallback: looks for `.commitlintrc.yml` and `.cspell.config.yml` in `$PWD`, falls back to `~/` defaults.

**Globals consumed:**

- `$PUSH_REPOS` — space-separated list of repo basenames to auto-push (set in `.bashrc`)
- `$GIT_BRANCH` — exported by `lib-git-prompt.sh` via `PROMPT_COMMAND` / `__git_ps1`
- `$BASH_ENV` — must be set; sources `lib.sh` functions

## Pre-commit hook (`bin/git/interface-hook-pre-commit`)

Installed on the `interface` and `priv` repos. Runs on every `git commit`:

1. `cspell --unique .` — spellchecks the entire repo.
2. `install_config_plist` — if `boot/EFI/CLOVER/config.plist` changed, copies it to `/boot/EFI/CLOVER/config.plist` (Linux only, skipped on macOS).

## System update — `system-up`

Full Arch Linux update orchestrator. Run manually, interactive.

```
system-up
```

1. Prompts to snapshot `@root` (10s timeout, default skip).
2. Stops `postgresql` service.
3. Optionally runs `btrfs check` on Data2TB and Data4TB (prompts to unmount first).
4. Checks if PostgreSQL has a major version bump in AUR; if so, runs `pg_upgrade` automatically.
5. Runs `mise use --global` to update Node, Go, yarn, npm and reinstalls missing npm globals.
6. Updates Arch packages in order: `archlinux-keyring` → `linux*` → repo packages (non-linux) → AUR packages.
7. Starts `postgresql`, refreshes collations on all known databases.
8. Cleans up old postgres data dirs if a major migration happened.
9. Prompts to `kexec` into the new kernel (fast reboot, no POST).
10. Kills background `sudo -v` refresh loop.

## Snapshot workflow

### Interactive (`snapshot`)

```
snapshot [-n|--dry-run]
```

Prompts for: source subvolume under `/toplevel` → snapshot name (default `name-YYYY-MM-DD[-ro]`) → read-only flag.

### Automated (`system-snapshot`)

Called by `system-snapshot.service` (root, hourly timer). Takes target subvolume names as arguments,
creates read-only snapshots named `target-YYYY-MM-DD-HH-ro`, trims to keep max 50 per target.

## Btrfs scrub

### Manual (`btrfs-scrub`)

```
btrfs-scrub [cancel] <Archlinux|Data2TB|Data4TB>
```

Maps volume labels to mount points and runs `btrfs scrub start` (or `cancel`).

### Automated

`btrfs-scrub@.service` / `btrfs-scrub@.timer` — monthly, randomized ±1 week, IO idle priority.

## User systemd services (dotfiles/.config/systemd/user/)

| Service                      | Timer                | Purpose                                                                                                                                                       |
| ---------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app-inhibit-sleep`          | always-on            | Watches `pacman`, `yay`, and Firefox audio via `playerctl`; calls `systemd-inhibit` to block idle sleep                                                       |
| `forex@.service`             | hourly               | Fetches exchange rate for currency `%i`; reads env from `~/.config/t0/forex.env`                                                                              |
| `game-audio-fix`             | every minute         | Corrects 5.1→2.0 audio routing for games                                                                                                                      |
| `docker-prune`               | Saturdays 15–23h     | `docker system prune`                                                                                                                                         |
| `system-update-notification` | Sundays 11:00        | `notify-send` reminder to run system update                                                                                                                   |
| `ollama`                     | always-on            | `ollama serve` with ROCm (AMD GPU), listens on `0.0.0.0:11434` for Docker bridge access                                                                       |
| `xkbcomp`                    | on graphical session | Loads custom XKB keymap from `dotfiles/.config/keymap.xkb`                                                                                                    |
| `xset-rate`                  | on default target    | Sets key repeat: 140ms delay, 70ms interval                                                                                                                   |
| `whisper`             | always-on            | `whisper` with model loaded on GPU (ROCm); listens on `127.0.0.1:8765` for dictation inference                                                         |
| `dictation-shortcut`         | always-on            | Push-to-talk dictation on `KEY_F2` (Keychron Q10); records via `pw-record`, transcribes via `whisper`, types via `ydotool`. Requires `whisper`. |
| `docker` override            | —                    | Sets `DOCKERD_ROOTLESS_ROOTLESSKIT_DISABLE_HOST_LOOPBACK=false` so containers can reach host                                                                  |

## Prompt

`lib-prompt.sh` builds PS1 via `make_ps1`:

- Random 256-color ANSI color per session.
- Decorations: `~>` for known user, `#>` for root, `*>` in secondary color for unknown hostnames.
- Appends hostname if not in `$KNOWN_HOSTS`.
- Integrates with `lib-git-prompt.sh` (`__git_ps1`) for git/jj branch and dirty-state indicators.

## Go tools — building

```bash
compile-bin   # run from repo root
```

Iterates `src/**/main.go`, builds each with `go build -race -mod=readonly` into `bin/<tool_name>`.

## Code style

- Shell: `shfmt` (run as last step after edits)
- Commits: Conventional Commits via `commitlint`
- Spellcheck: `cspell`
- VCS: **jujutsu** (`jj`) — do not make manual commits
