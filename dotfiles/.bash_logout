#! /bin/bash

# /dev/pts ensure it runs on GUI terminal not before
if is_linux && is_me && [[ $(tty) =~ /dev/pts ]]; then
  systemctl --user start firefox-sync.service
fi
