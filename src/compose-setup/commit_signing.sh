# shellcheck shell=bash
# Imports GPG key and configures git signing; skips if no key.
# Falls back to /run/secrets/ when env vars are absent (Docker secrets).
commit_signing() {
  if [[ -z "${GPG_PRIVATE_KEY:-}" && -f /run/secrets/gpg_private_key ]]; then
    GPG_PRIVATE_KEY=$(cat /run/secrets/gpg_private_key)
  fi
  if [[ -z "${GPG_PASSPHRASE:-}" && -f /run/secrets/gpg_passphrase ]]; then
    GPG_PASSPHRASE=$(cat /run/secrets/gpg_passphrase)
  fi

  if [[ -z "${GPG_PRIVATE_KEY:-}" ]]; then
    echo "bin/setup: GPG_PRIVATE_KEY not set, skipping" >&2
    return 0
  fi

  mkdir -p ~/.gnupg && chmod 700 ~/.gnupg
  echo "allow-loopback-pinentry" >~/.gnupg/gpg-agent.conf
  gpg-connect-agent reloadagent /bye >/dev/null 2>&1 || true

  if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
    echo "${GPG_PRIVATE_KEY}" | base64 --decode |
      gpg --batch --passphrase "${GPG_PASSPHRASE}" --pinentry-mode loopback --import
  else
    echo "${GPG_PRIVATE_KEY}" | base64 --decode | gpg --batch --import
  fi

  FINGERPRINT=$(gpg --list-secret-keys --with-colons |
    awk -F: '/^fpr:/{print $10; exit}')

  git config --global user.signingkey "${FINGERPRINT}"
  git config --global commit.gpgsign true
  git config --global gpg.format openpgp
  git config --global gpg.program gpg

  if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
    if ! curl -fsSL https://raw.githubusercontent.com/rthomazel/interface/dev/bin/gpg-passphrase-wrapper \
      -o /usr/local/bin/gpg-passphrase-wrapper; then
      echo "bin/setup: WARN could not fetch gpg-passphrase-wrapper, writing fallback" >&2
      cat >/usr/local/bin/gpg-passphrase-wrapper <<'WRAPPER'
#!/usr/bin/env bash
_gpg_passphrase="${GPG_PASSPHRASE:-$(cat /run/secrets/gpg_passphrase 2>/dev/null)}"
exec gpg --batch --passphrase "${_gpg_passphrase}" --pinentry-mode loopback "$@"
WRAPPER
    fi
    chmod +x /usr/local/bin/gpg-passphrase-wrapper
    git config --global gpg.program /usr/local/bin/gpg-passphrase-wrapper
  fi

  echo "bin/setup: GPG signing configured (${FINGERPRINT})" >&2
}
