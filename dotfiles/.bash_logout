#! /bin/bash

# /dev/pts ensure it runs on GUI terminal not before
if [[ "$(uname -s)" =~ Linux ]] && [ "$(whoami)" == "vacation" ] && [[ $(tty) =~ /dev/pts ]]; then
  systemctl --user start firefox-sync.service
fi
