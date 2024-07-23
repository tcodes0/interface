#! /usr/bin/env bash

# ensure it runs on GUI terminal /dev/pts not before
if is_linux && is_me && [[ $(tty) =~ /dev/pts ]]; then
  systemctl --user start firefox-sync.service
fi
