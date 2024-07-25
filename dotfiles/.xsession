#! /usr/bin/env bash

for unit in x11-keyboard.service guake.service; do
  if [ -f "$HOME/.config/systemd/user/$unit" ] && is_me; then
    systemctl --user start "$unit"
  fi
done
