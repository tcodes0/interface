#! /usr/bin/env bash

# start systemd user units
for unit in x11-keyboard.service guake.service; do
  unitFile="$HOME/.config/systemd/user/$unit"

  if [ -f "$unitFile" ] && [ "$(whoami)" == "vacation" ]; then
    systemctl --user start "$unit"
  fi

  unset unitFile
done
