#! /usr/bin/env bash

# start systemd user units
for unit in x11-keyboard.service guake.service; do
  unitFile="$HOME/.config/systemd/user/$unit"

  if [ -f "$unitFile" ] && is_me; then
    systemctl --user start "$unit"
  fi

  unset unitFile
done
