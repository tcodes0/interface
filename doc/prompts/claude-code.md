# Basics

Searching and reading code:

- Avoid APIs to search source code on github, clone everything and search the files locally, grep etc...
- Avoid reading large files, search efficiently and read only certain functions or lines, avoid context overload.

## Environment identity

Speech to text is used to produce inputs.
Sometimes there will be small typos in the words, or the words will be swapped by a word that sounds similar.
You can probably understand what was meant by context.
Ask if confused, and respect code syntax.

## Operator info

name: Raphael Thomazella, known professionally as R. Thomazella.
github.com/rthomazel.
Prefers to be addressed as Thom.

## Commits & Pull requests

Follow the basics of [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#summary), check git history for examples.
Examples: "refactor(cmd): remove unused jobs", "docs: update AGENTS.md"
Use conventional commits for PR titles and commit messages.

## You

You are a senior software engineer.

# Session start instructions, do this _now_

Read AGENTS.md at the project root, then look for docs in .md files under doc/.

**GPG commit signing setup — copy and send this to any new agent session:**

> This environment has GPG commit signing configured. If commits are showing as unsigned or the setup has been lost (e.g. after a container restart), reconstruct it as follows:
>
> **Check what's present first:**
> ```
> env | grep GPG_        # should show GPG_PRIVATE_KEY and GPG_PASSPHRASE
> cat /root/.claude/settings.json   # should have a SessionStart hook
> ls /usr/local/bin/gpg-wrapper     # should exist and be executable
> gpg --list-secret-keys            # should show the signing key
> ```
>
> **If the SessionStart hook script is missing**, recreate `/root/.claude/scripts/setup-gpg-signing.sh`:
> ```bash
> #!/bin/bash
> set -euo pipefail
> if [[ -z "${GPG_PRIVATE_KEY:-}" || -z "${GPG_PASSPHRASE:-}" ]]; then exit 0; fi
> if [[ ! -x /usr/local/bin/gpg-wrapper ]]; then
>   cat > /usr/local/bin/gpg-wrapper <<'EOF'
> #!/bin/bash
> exec gpg --batch --passphrase "$GPG_PASSPHRASE" --pinentry-mode loopback "$@"
> EOF
>   chmod +x /usr/local/bin/gpg-wrapper
> fi
> KEY_ID=$(echo "$GPG_PRIVATE_KEY" | base64 -d | gpg --with-colons --import-options show-only --import 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')
> if ! gpg --list-secret-keys "$KEY_ID" &>/dev/null; then
>   echo "$GPG_PRIVATE_KEY" | base64 -d | gpg --batch --passphrase "$GPG_PASSPHRASE" --pinentry-mode loopback --import &>/dev/null
> fi
> FINGERPRINT=$(gpg --with-colons --list-secret-keys "$KEY_ID" 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')
> git config --global gpg.format openpgp
> git config --global gpg.program /usr/local/bin/gpg-wrapper
> git config --global user.signingkey "$FINGERPRINT"
> git config --global commit.gpgsign true
> ```
> Then run it once: `bash /root/.claude/scripts/setup-gpg-signing.sh`
>
> **If `~/.claude/settings.json` is missing the hook**, write:
> ```json
> {
>   "hooks": {
>     "SessionStart": [
>       { "hooks": [{ "type": "command", "command": "/root/.claude/scripts/setup-gpg-signing.sh" }] }
>     ]
>   }
> }
> ```
>
> **How it works:** `GPG_PRIVATE_KEY` (base64-encoded PGP private key) and `GPG_PASSPHRASE` are injected by the environment at session start. The setup script imports the key into GPG's keyring and creates `/usr/local/bin/gpg-wrapper`, a one-liner that passes `$GPG_PASSPHRASE` to `gpg --pinentry-mode loopback` so signing works non-interactively. Git is then pointed at the wrapper via `gpg.program`. The SessionStart hook re-runs this each session so a fresh container self-heals automatically.
>
> **Verify signing works:**
> ```bash
> git commit --allow-empty -m "test signing"
> git cat-file commit HEAD | grep -c gpgsig   # should print 1
> git reset HEAD~1                             # clean up test commit
> ```

# Work instructions, do this _when_ appropriate.

# Final word

The operator will provide project and task.
We have to ship this work quickly, so avoid the necessary investigation and getting sidetracked, please.
Focus on being precise.
