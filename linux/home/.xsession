#! /usr/bin/env bash

# start systemd user units
for unit in x11-keyboard.service guake.service; do
  unitFile="$HOME/.config/systemd/user/$unit"
  if [ -f "$unitFile" ]; then
    systemctl --user start "$unit"
  fi
  unset unitFile
done

# fast keyboard key response rate
if [[ ! "$(tty)" =~ /dev/tty[0-9]* ]]; then
  # don't run when on a real tty, only graphic X11 ttys
  xset r rate 140 60
fi

# add ssh key to ssh agente, bypass prompt
if [ ! "$SSH_AUTH_SOCK" ] && [ -f "$DOTFILE_PATH/.private-ssh-add.expect" ]; then
  eval "$(ssh-agent)" 2>/dev/null 1>&2
  "$DOTFILE_PATH/.private-ssh-add.expect" 2>/dev/null 1>&2
fi
