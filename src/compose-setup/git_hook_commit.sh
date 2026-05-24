# shellcheck shell=bash
# Installs a post-commit git hook that prints agent reminders after each commit.
git_hook_commit() {
  local hooks_dir="$SCRIPT_DIR/../.git/hooks"

  if [[ ! -d "$hooks_dir" ]]; then
    echo "bin/setup: .git/hooks not found, skipping hook install" >&2
    return 0
  fi

  cat >"$hooks_dir/post-commit" <<'HOOK'
#!/usr/bin/env bash
# post-commit — agent reminders

printf '\n=== post-commit reminder ===\n'
printf 'TODO: placeholder — add agent reminders here\n'
printf '============================\n\n'
HOOK

  chmod +x "$hooks_dir/post-commit"
  echo "bin/setup: post-commit hook installed"
}
