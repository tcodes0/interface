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

detect_game() {
  local outputs=""
  # remove known outputs that aren't games
  outputs=$(pw-link --output | sed -e "/^alsa_.*/d" -e "/^Midi-.*/d" -e "/^v4l2.*/d" -e "/^Firefox.*/d")

  if [ "$outputs" == "" ]; then
    debug $LINENO "No game outputs found"
    msg ""

    return
  fi

  # if a game is in outputs, it will define 6 channels
  for word in FL FR FC LFE RL RR; do
    if ! grep -q "$word" <<<"$outputs"; then
      debug $LINENO "channel $word not found in outputs"
      msg ""

      return
    fi
  done

  # game outputs have form 'game:output_LFE'
  # split and return the first part
  # any of the 6 channels can be used, LFE is arbitrary
  name=$(grep "LFE" <<<"$outputs" | sed -e "s/^\(.*\):.*/\1/g")
  msg "$name"
}

create_links() {
  pw-link "$1:output_FC" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FL
  pw-link "$1:output_FC" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FR
  pw-link "$1:output_LFE" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FR
  pw-link "$1:output_LFE" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FL
  pw-link "$1:output_RL" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FL
  pw-link "$1:output_RR" alsa_output.usb-Native_Instruments_Komplete_Audio_6_056E39FC-00.analog-stereo-out-ab:playback_FR

  debug $LINENO "Audio fixed $1"
}

### script ###

check_dependencies

game_name=$(detect_game)

if [ "$game_name" == "" ]; then
  debug $LINENO "No game detected"

  exit 0
fi

error=$(create_links 2>&1 "$game_name" || true)

# file exists means we are already linked
if [ "$error" != "" ] && [[ ! "$error" =~ "failed to link ports: File exists" ]]; then
  msgln "$error"
  exit 1
fi
