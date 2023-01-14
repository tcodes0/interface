#! /usr/bin/env bash

SLEEP_DURATION=1
SPACE="\n"

message() {
  echo "$*"
  echo -ne $SPACE
  sleep $SLEEP_DURATION
}

# $1 line number
log_err() {
  echo disk-cleanup.sh error: "$1": "${FUNCNAME[1]}"
}

#########################################
### cleaners
#########################################

journal_as_root() {
  message "vaccuing journals"
  echo "journal operations are root only, sudoing..."
  command sudo journalctl --rotate
  command sudo journalctl --vacuum-time=1w
}

clean_yarn() {
  message "cleaning yarn cache"
  yarn cache clean
}

pacman_as_root() {
  local keep="1"

  message "cleaning pacman cache, keeping only $keep versions of each package"
  paccache --dryrun --keep "$keep"

  message "proceed with cleaning? (timeout 30s) [y/N]"
  read -t 30 -r response
  if [ "$response" != "y" ] && [ ! "$response" != "Y" ]; then
    echo "aborted"
    return
  fi

  echo "pacman cache operations are root only, sudoing..."
  command sudo paccache --remove --keep "$keep"
}

clean_golang() {
  message "cleaning golang caches"
  go clean -cache
  go clean -modcache
}

clean_nvm() {
  echo "bugged, fix me"
  return
  local node_ver
  node_ver=$(node --version)
  message "cleaning other node versions from nvm, current $node_ver"
  if [[ ! $node_ver =~ v[[:digit:]]{1,2}[.][[:digit:]]{1,2}[.][[:digit:]]{1,2} ]]; then
    log_err "invalid node version"
    return 1
  fi
  find "$HOME"/.nvm/versions/node -maxdepth 1 -type d -name "v*" -not -name "$node_ver" -exec rm -fr {} \;
  find "$HOME"/.nvm/.cache/bin -maxdepth 1 -type d -name "node-*" -not -name "*${node_ver}*" -exec rm -fr {} \;
}

typescript_cache() {
  message "cleaning .cache/typescript"
  find "$HOME/.cache/typescript" -maxdepth 2 -type d -name node_modules -exec rm -fr {} \;
}

electron_cache() {
  message "cleaning .cache/electron"
  rm -fr "$HOME"/.cache/electron/*
}

chrome_cache() {
  message "cleaning .cache/chrome"
  rm -fr "$HOME"/.cache/google-chrome/Default/Cache/*
  rm -fr "$HOME"/.cache/google-chrome/Default/Code\ Cache/*
}

noop() {
  message "noop: this does nothing, except for printing this message"
}

#########################################
### main
#########################################

# setup
trap 'log_err $LINENO' ERR
set -e

# vars
response=""
cleaners_available=(
  noop
  clean_yarn
  clean_golang
  clean_nvm
  typescript_cache
  electron_cache
  chrome_cache
  journal_as_root
  pacman_as_root
)
selected_cleaners=("$@")
dry_run_cmd=""

if [ "$#" == "0" ]; then
  basename "$0"
  echo "No cleaners passed, pass cleaners separated by spaces (Ex: foo bar baz)"
  echo "Flags supported: --dry-run: Just print, dont run cleaners"
  echo "Available cleaners are:"
  echo "${cleaners_available[@]}"

  exit 0
fi

if [[ "$*" =~ .*--dry-run.* ]]; then
  dry_run_cmd="echo *cleaner run*"
  echo "Dry runnnig cleaners..."

  # remove --dry-run from cleaners
  temp=()
  for cleaner in "${selected_cleaners[@]}"; do
    if [ "$cleaner" != "--dry-run" ]; then
      temp+=("$cleaner")
    fi
  done

  selected_cleaners=("${temp[@]}")
fi

message "Do you want to run the ${#selected_cleaners[*]} cleaners below? (timeout 10s) [y/N]"
for cleaner in "${selected_cleaners[@]}"; do
  echo "$cleaner"
done

read -t 10 -r response
if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
  echo "Aborted"
  exit 0
fi

for cleaner in "${selected_cleaners[@]}"; do
  message "Running \"$cleaner\""...
  eval "$dry_run_cmd $cleaner"
done
