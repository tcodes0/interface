#! /bin/bash

#                                                                     ensure it runs on GUI terminal not before
if [ "$(whoami)" == "vacation" ] && [ "$FIREFOX_LOGOUT_SYNC" == "" ] && [[ $(tty) =~ /dev/pts ]]; then
  export FIREFOX_LOGOUT_SYNC="true"
  systemctl --user start firefox-sync.service
fi
