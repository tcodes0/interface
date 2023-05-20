#! /usr/bin/env bash

target=""
cancel=""

if [ "$1" = "cancel" ]; then
  cancel="true"
  shift
fi

case "$1" in
Archlinux) target="/" ;;
Dator) target="/media/data" ;;
esac

#  if target is not dator or archlinux
if [ "$target" != "/" ] && [ "$target" != "/media/data" ]; then
  echo "$target is unkown volume, edit script to add it"
  exit 1
fi

#  grep mounts to check if target is mounted
if ! grep -qs "$target" /proc/mounts; then
  echo "$target is not mounted"
  exit 1
fi

# if cancel is true, cancel scrub
if [ "$cancel" = "true" ]; then
  btrfs scrub cancel $target
else
  btrfs scrub $target
fi
