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
  echo disk-cleanup.sh error: "$1": "${FUNCNAME[0]}"
}

#########################################
### cleaners
#########################################

clean_journal() {
  message "vaccuing journals"
  command sudo journalctl --rotate
  command sudo journalctl --vacuum-time=1w
}

clean_yarn() {
  message "cleaning yarn cache"
  yarn cache clean
}

clean_pacman() {
  message "cleaning pacman cache"
  yay --sync --clean --noconfirm
}

clean_golang() {
  message "cleaning golang caches"
  go cl1ean -cache
  go clean -modcache
}

clean_nvm() {
  message "cleaning old node versions from nvm"
}

clean_config() {
  message "cleaning .config/**/caches"
}

clean_typescript_cache() {
  message "cleaning .cache/typescript"
}

clean_electron_cache() {
  message "cleaning .cache/electron"
}

#########################################
### main
#########################################

trap 'log_err $LINENO' ERR

clean_journal
clean_yarn
clean_pacman
clean_golang
clean_nvm
clean_config
clean_typescript_cache
clean_electron_cache
