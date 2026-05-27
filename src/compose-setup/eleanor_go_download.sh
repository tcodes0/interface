# shellcheck shell=bash
# Configures GOPRIVATE and SSH URL rewrite for Eleanor Health Go projects, then runs go mod download.
eleanor_go_download() {
  export GOPRIVATE="github.com/eleanorhealth/*"
  [[ -n "${CLAUDE_ENV_FILE:-}" ]] && echo "GOPRIVATE=github.com/eleanorhealth/*" >>"$CLAUDE_ENV_FILE"

  git config --global url."ssh://git@github.com/".insteadOf "https://github.com/"

  if ! curl -s --max-time 3 https://storage.googleapis.com >/dev/null 2>&1; then
    export GOPROXY="https://goproxy.io,direct"
    export GONOSUMDB="*"
    echo "info: storage.googleapis.com unreachable, using GOPROXY=goproxy.io" >&2
  fi
  go mod download
  go install tool 2>/dev/null || true
}
