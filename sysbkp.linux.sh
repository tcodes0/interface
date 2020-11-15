#! /usr/bin/env  bash

set -e
command sudo true
echo "Mounting Archbak at /mnt and EFI-HARD at /mnt/boot"
sleep 5
if grep --quiet "[/]mnt" /proc/mounts; then
  echo "Something mounted at /mnt, please run \`sudo umount /mnt\` to continue"
  exit 1
else
  command sudo mount /dev/disk/by-label/Archbak /mnt
fi

if grep --quiet "[/]mnt[/]boot" /proc/mounts; then
  echo "Something mounted at /mnt/boot, please run \`sudo umount /mnt/boot\` to continue"
  exit 1
else
  command sudo mkdir -p /mnt/boot
  command sudo mount /dev/disk/by-label/EFI-HARD /mnt/boot
fi

echo "Rsync /"
sleep 5
# rsync commonly exits with non 0 status because of files vanishing
set +e
# -a means -rlptgoD
# --recursive, -r          recursive
# --links, -l              copy symlinks as symlinks
# --perms, -p              preserve permissions
# --times, -t              preserve modification times
# --group, -g              preserve group
# --owner, -o              preserve owner (super-user only)
# -D                       same as --devices --specials
# --devices                preserve device files (super-user only)
# --specials               preserve special files
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
  --exclude="$HOME/Desktop/*" \
  --exclude=.cache/spotify \
  / '/mnt'; then
  echo "Rsync errored, continue anyway? (y/n)"
  if ! read -r; then exit 1; fi
  if [ "$REPLY" == "n" ] || [ "$REPLY" == "no" ] || [ "$REPLY" == "N" ] || [ "$REPLY" == "NO" ]; then
    echo "Aborted"
    exit 1
  fi
fi

if ! echo sudo rsync \
  -a \
  --progress \
  --one-file-system \
  --delete-during \
  --exclude="node_modules" \
  "$HOME/Desktop/" "/mnt$HOME/Desktop"; then
  echo "Rsync errored, continue anyway? (y/n)"
  if ! read -r; then exit 1; fi
  if [ "$REPLY" == "n" ] || [ "$REPLY" == "no" ] || [ "$REPLY" == "N" ] || [ "$REPLY" == "NO" ]; then
    echo "Aborted"
    exit 1
  fi
fi

echo "Rsync /var/lib/pacman"
sleep 2
command sudo mkdir -p  /mnt/var/lib/pacman
if ! sudo rsync \
  -a \
  --progress \
  --one-file-system \
  --delete-during \
  /var/lib/pacman/ '/mnt/var/lib/pacman'; then
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
