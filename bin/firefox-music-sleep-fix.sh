#! /usr/bin/env bash
# Copyright 2025 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
#
# checks if firefox is playing music and inhibits idle, fixes https://bugzilla.mozilla.org/show_bug.cgi?id=1665986
# note: undefined functions are in lib.sh (sourced via BASH_ENV)
# shellcheck disable=SC2155

set -euo pipefail
shopt -s globstar
trap 'err $LINENO && cleanup' ERR

### vars and functions ###

inhibition_duration_secs=65
pooling_interval_secs=60
playing="Playing"
child=""

check_dependencies() {
  if [ -z "$BASH_ENV" ]; then
    echo "This script uses functions defined externally."
    echo "\$BASH_ENV is used to source dependencies, and is empty."
    echo "If functions are in the environment, please set BASH_ENV to any string."
    exit 1
  fi
}

help_exit() {
  msgln "Usage: $0"
  msgln
  msgln This tool is meant to be fire-and-forget by an automation.
  msgln It will work if invoked manually as well.
}

cleanup() {
  # we do not care if child is already terminated
  kill $child 2>/dev/null || true
}

### script ###

check_dependencies

if requested_help "$*"; then
  help_exit
  exit 1
fi

while true; do
  # playerctl will error if there are no players, ignore that
  status=$(playerctl --player=plasma-browser-integration status 2>&1 || true)

  if [ "$status" = $playing ]; then
    systemd-inhibit --what=idle --who="$0" --why='Firefox is playing audio' sleep $inhibition_duration_secs &
    child=$!
  fi

  sleep $pooling_interval_secs
done
