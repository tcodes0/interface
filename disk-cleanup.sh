#! /usr/bin/env bash

SLEEP_DURATION=1
SPACE="\n"

message() {
  echo "$*"...
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

clean_journal() {
  message "vaccuing journals"
  echo "journal operations are root only, sudoing..."
  command sudo journalctl --rotate
  command sudo journalctl --vacuum-time=1w
}

clean_yarn() {
  message "cleaning yarn cache"
  yarn cache clean
}

# DO NOT USE THIS
clean_pacman() {
  local log="$DOTFILE_PATH/pacman-cache-clear.log"
  if ! [ -f "$log" ]; then
    message "log file not found"
    return 1
  fi

  #  { date; echo -e '\n\n'; find /var/cache/pacman/pkg -name '*.tar.zst' } >> log
  date >>log
  echo -e '\n\n' >>log
  find /var/cache/pacman/pkg -name '*.tar.zst' >>log

  message "cleaning pacman cache, packages appended to $log"
  echo yay --sync --clean --noconfirm
}

clean_golang() {
  message "cleaning golang caches"
  go clean -cache
  go clean -modcache
}

clean_nvm() {
  local node_ver
  node_ver=$(node --version)
  message "cleaning other node versions from nvm, current $node_ver"
  if [[ ! $node_ver =~ v[[:digit:]]{1,2}[.][[:digit:]]{1,2}[.][[:digit:]]{1,2} ]]; then
    log_err "invalld node version"
    return 1
  fi
  find "$HOME"/.nvm/versions/node -maxdepth 1 -type d -name "v*" -not -name "$node_ver" -exec rm -fr {} \;
  find "$HOME"/.nvm/.cache/bin -maxdepth 1 -type d -name "node-*" -not -name "*${node_ver}*" -exec rm -fr {} \;
}

clean_typescript_cache() {
  message "cleaning .cache/typescript"
  find "$HOME/.cache/typescript" -maxdepth 2 -type d -name node_modules -exec rm -fr {} \;
}

clean_electron_cache() {
  message "cleaning .cache/electron"
  rm -fr "$HOME"/.cache/electron/*
}

clean_chrome_cache() {
  message "cleaning .cache/chrome"
  rm -fr "$HOME"/.cache/google-chrome/Default/Cache/*
  rm -fr "$HOME"/.cache/google-chrome/Default/Code\ Cache/*
}

#########################################
### main
#########################################

trap 'log_err $LINENO' ERR

clean_yarn
# clean_pacman
clean_golang
clean_nvm
clean_typescript_cache
clean_electron_cache
clean_chrome_cache
clean_journal
