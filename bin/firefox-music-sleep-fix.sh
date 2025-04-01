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
trap 'err $LINENO && kill $child' ERR

### vars and functions ###

inhibition_duration_secs=59
pooling_interval_secs=60
playing="Playing"
child=""

usage() {
  msgln "Usage: $0"
  msgln
  msgln This tool is meant to be fire-and-forget by an automation.
  msgln It will work if invoked manually as well.
}

### script ###

if requested_help "$*"; then
  usage
  exit 1
fi

while true; do
  status=$(playerctl --player=plasma-browser-integration status 2>/dev/null)

  if [ "$status" = $playing ]; then
    systemd-inhibit --what=idle --who="$0" --why='Firefox is playing audio' sleep $inhibition_duration_secs &
    child=$!
  fi

  sleep $pooling_interval_secs
done
