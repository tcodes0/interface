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
sudo rsync \
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
  --exclude=node_modules \
  --exclude=.cache/spotify \
  / '/mnt'

echo "Rsync /boot"
sleep 5
sudo rsync \
  -a \
  --progress \
  --delete-during \
  --exclude=.DS_Store \
  --exclude="._*" \
  --exclude="._.*" \
  /boot/ '/mnt/boot'
