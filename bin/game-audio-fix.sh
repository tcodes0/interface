#! /usr/bin/env bash
# Copyright 2025 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.

set -euo pipefail
shopt -s globstar
trap 'err $LINENO' ERR

### vars and functions ###

check_dependencies() {
  if [ -z "$BASH_ENV" ]; then
    echo "This script uses functions defined externally."
    echo "\$BASH_ENV is used to source dependencies, and is empty."
    echo "If functions are in the environment, please set BASH_ENV to any string."
    exit 1
  fi
}

help_exit() {
  local outputs=""
  outputs=$(pw-link -o)

  msgln "Usage: $0 [-h|--help] [game]"
  msgln "See game name below:"
  debug "\n$outputs"

  exit 1
}

validate_input() {
  if [ $# == 0 ] || [ $# -gt 1 ] || requested_help; then
    help_exit
  fi
}

create_links() {
  pw-link "$1:output_FC" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FL
  pw-link "$1:output_FC" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FR
  pw-link "$1:output_LFE" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FR
  pw-link "$1:output_LFE" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FL
  pw-link "$1:output_RL" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FL
  pw-link "$1:output_RR" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FR
}

### script ###

check_dependencies
validate_input "$@"
error=$(create_links 2>&1 "$1" || true)

# file exists means we are already linked
if [ "$error" != "" ] && [[ ! "$error" =~ "failed to link ports: File exists" ]]; then
  msgln "$error"
  help_exit
fi
