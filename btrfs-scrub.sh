#! /usr/bin/env bash

set -e

target=""
cancel=""
volumes=("Archlinux" "Dator")

function helpExit() {
  echo "Usage: $0 [cancel] <volume>"
  echo "Known volumes: ${volumes[*]}"
  exit 1
}

if [ "$1" = "cancel" ]; then
  cancel="true"
  shift
fi

case "$1" in
"${volumes[0]}") target="/" ;;
"${volumes[1]}") target="/media/data" ;;
esac

#  if target is not dator or archlinux
if [ -z "$target" ]; then
  echo "Unkown volume: $1, edit script to add it"
  echo "Known volumes: ${volumes[*]}"
  helpExit
fi

#  grep mounts to check if target is mounted
if ! grep -qs "$target" /proc/mounts; then
  echo "$target is not mounted"
  helpExit
fi

echo "Scrub requires sudo"
sudo true

# if cancel is true, cancel scrub
if [ "$cancel" = "true" ]; then
  sudo btrfs scrub cancel $target
else
  sudo btrfs scrub start $target
fi
