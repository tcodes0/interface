# shellcheck shell=bash
# Writes .npmrc and configures git for Eleanor Health Node projects, then installs packages. Detects yarn or npm.
eleanor_node_download() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local env_file="$script_dir/../.env"

  if [[ -z "${GITHUB_TOKEN:-}" && -f /run/secrets/github_token ]]; then
    GITHUB_TOKEN=$(cat /run/secrets/github_token)
  fi
  # shellcheck disable=SC1090
  [[ -z "${GITHUB_TOKEN:-}" && -f "$env_file" ]] && . "$env_file"

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "info: GITHUB_TOKEN not set, skipping Eleanor Health Node auth" >&2
    echo "info: for private @eleanorhealth packages, configure .npmrc manually:" >&2
    echo "  @eleanorhealth:registry=https://npm.pkg.github.com" >&2
    echo "  //npm.pkg.github.com/:_authToken=<your-token>" >&2
  else
    cat >"$script_dir/../.npmrc" <<NPMRC
@eleanorhealth:registry = https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken = ${GITHUB_TOKEN}

engine-strict = true
NPMRC

    git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/eleanorhealth".insteadOf "https://github.com/eleanorhealth"
  fi

  if [[ -f "$script_dir/../yarn.lock" ]]; then
    yarn install
  else
    npm install
  fi
}
