#! /usr/bin/env  bash

set -e
command sudo true
echo "Mounting Maglinux at /mnt and EFI-MAG at /mnt/boot"
sleep 5
if ! grep --quiet "[/]mnt" /proc/mounts; then
  command sudo mount /dev/disk/by-label/Maglinux /mnt
fi
if ! grep --quiet "[/]mnt[/]boot" /proc/mounts; then
  command sudo mount /dev/disk/by-label/EFI-MAG /mnt/boot
fi

echo "Rsync /"
sleep 5
# rsync commonly exits with non 0 status because of files vanishing
set +e
if ! sudo rsync \
  -a \
  --progress \
  --one-file-system \
  --delete-during \
  --exclude="/media/*" \
  --exclude="/mnt/*" \
  --exclude="/proc/*" \
  --exclude="/sys/*" \
  --exclude="/dev/*" \
  --exclude="/boot/*" \
  --exclude="/tmp/*" \
  --exclude="/var/*" \
  --exclude=node_modules \
  --exclude=.cache/spotify \
  / '/mnt'; then
  echo "Rsync errored, continue anyway? (y/n)"
  if ! read -r; then exit 1; fi
  if [ "$REPLY" == "n" ] || [ "$REPLY" == "no" ] || [ "$REPLY" == "N" ] || [ "$REPLY" == "NO" ]; then
    echo "Aborted"
    exit 1
  fi
fi

echo "Rsync /boot"
sleep 5
if ! sudo rsync \
  -a \
  --progress \
  --delete-during \
  --exclude=.DS_Store \
  --exclude="._*" \
  --exclude="._.*" \
  /boot/ '/mnt/boot'; then
  echo "Rsync errored, but script is over"
  # if ! read -r; then exit 1; fi
  # if [ "$REPLY" == "n" ] || [ "$REPLY" == "no" ] || [ "$REPLY" == "N" ] || [ "$REPLY" == "NO" ]; then
  #   echo "Aborted"
  #   exit 1
  # fi
fi
