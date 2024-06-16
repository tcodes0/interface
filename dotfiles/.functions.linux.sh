#! /usr/bin/env bash

# TODO: inline this in priv repo, rotate creds
relative-drive-push() {
  if [ "$#" -gt 2 ] || [ "$1" == -h ] || [ "$#" == 0 ]; then
    echo "Usage: relative-drive-push targets/to/push"
    echo "Usage: relative-drive-pull local remote"
    echo "Pushes target to google drive using rclone remote google-drive"
    echo "Paths are relative to \$DOTFILE_PATH"
    return
  fi
  if [[ "$#" == 1 ]]; then
    rclone copyto "$DOTFILE_PATH/$1" "google-drive:$1"
  else
    rclone copyto "$DOTFILE_PATH/$1" "google-drive:$2"
  fi
}

#- - - - - - - - - - -

relative-dropbox-push() {
  if [ "$#" -gt 2 ] || [ "$1" == -h ] || [ "$#" == 0 ]; then
    echo "Usage: relative-dropbox-push targets/to/push"
    echo "Usage: relative-dropbox-pull local remote"
    echo "Pushes target to google dropbox using rclone remote google-dropbox"
    echo "Paths are relative to \$DOTFILE_PATH"
    return
  fi
  if [[ "$#" == 1 ]]; then
    rclone copyto "$DOTFILE_PATH/$1" "dropbox:$1"
  else
    rclone copyto "$DOTFILE_PATH/$1" "dropbox:$2"
  fi
}

#- - - - - - - - - - -

relative-drive-pull() {
  if [ "$#" -gt 2 ] || [ "$1" == -h ] || [ "$#" == 0 ]; then
    echo "Usage: relative-drive-pull target"
    echo "Usage: relative-drive-pull local remote"
    echo "Pulls target from google drive using rclone remote google-drive"
    echo "Paths are relative to \$DOTFILE_PATH"
    return
  fi
  if [[ "$#" == 1 ]]; then
    rclone copyto "google-drive:$1" "$DOTFILE_PATH/$1"
  else
    rclone copyto "google-drive:$2" "$DOTFILE_PATH/$1"
  fi
}

#- - - - - - - - - - -

relative-dropbox-pull() {
  if [ "$#" -gt 2 ] || [ "$1" == -h ] || [ "$#" == 0 ]; then
    echo "Usage: relative-dropbox-pull target"
    echo "Usage: relative-dropbox-pull local remote"
    echo "Pulls target from google dropbox using rclone remote google-dropbox"
    echo "Paths are relative to \$DOTFILE_PATH"
    return
  fi
  if [[ "$#" == 1 ]]; then
    rclone copyto "dropbox:$1" "$DOTFILE_PATH/$1"
  else
    rclone copyto "dropbox:$2" "$DOTFILE_PATH/$1"
  fi
}

#- - - - - - - - - - -

drive-list() {
  if [[ "$#" == 0 ]]; then
    rclone lsf google-drive:
  else
    rclone lsf "google-drive:$1"
  fi
}

#- - - - - - - - - - -

vpnup() {
  sudo wg-quick up wg0
  sudo wg
}

#- - - - - - - - - - -

vpndown() {
  sudo wg-quick down wg0
  sudo wg
}

#----------------

mkinitcpio() {
  if [ "$UID" != 0 ]; then
    echo "must run mkinitcpio as root"
    return 0
  fi

  mkinitcpio "$@"
}

#- - - - - - - - - - -

tar7z() {
  if [ "$#" == 0 ] || [ "$1" == "-h" ]; then
    echo "tar7z foo produces foo.tar.7z"
    return 1
  fi

  safeArg=$1
  if [[ "$safeArg" =~ [/]$ ]]; then
    safeArg=${safeArg:0:-1}
  fi

  tar cf - "$safeArg" 2>/dev/null | 7za a -si -mx=7 "${safeArg}.tar.7z" 1>/dev/null
}

#- - - - - - - - - - -

goo() {
  google "$@"
}
