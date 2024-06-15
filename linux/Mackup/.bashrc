#! /usr/bin/env bash
# shellcheck disable=SC1090

# runs on login only

export WARN_SOURCE_FAIL="yes"

safe_source() {
  if [ -f "$1" ]; then
    source "$1"
  else
    [ "$WARN_SOURCE_FAIL" == "yes" ] && echo "$1" not found to source
  fi
}

CONFIG_FILE=""
# set to known hostname we usually ssh into
export KNOWN_HOST="other"

if [[ "$(uname -s)" =~ Darwin ]]; then
  CONFIG_FILE="/Users/vacation/Desktop/interface/.bashrc.mac.bash"
  KNOWN_HOST="$(hostname)"
fi

if [[ "$(uname -s)" =~ Linux ]]; then
  CONFIG_FILE="/home/vacation/Desktop/interface/.bashrc.linux.bash"

  if [[ "$(uname --nodename)" =~ Arch7 ]]; then
    KNOWN_HOST="Arch7"
  fi
fi

if [ $CONFIG_FILE ]; then
  source "$CONFIG_FILE"
fi
