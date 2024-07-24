#! /usr/bin/env bash

start_user_units() {
  for unit in x11-keyboard.service guake.service; do
    local unitFile="$HOME/.config/systemd/user/$unit"

    if [ -f "$unitFile" ] && is_me; then
      systemctl --user start "$unit"
    fi
  done
}

start_user_units
