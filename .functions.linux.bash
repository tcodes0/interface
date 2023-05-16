#! /usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

#========== Override macos

#- - - - - - - - - - -

goo() {
  google "$@"
  qai "$@"
}

#========== Generic
# need to run on-enter and on-leave back 2 back to avoid submodules conflicts
chpwd() {
  case $PWD in
  $HOME/Desktop/trivia)
    source "$HOME/Desktop/interface/chpwd-to-source/trivia/on-enter-dir"
    ;;
    # $HOME/Desktop/interface)
    #   source "$HOME/Desktop/interface/chpwd-to-source/interface/on-enter-dir"
    #   ;;
  $HOME/Desktop/helpers-console)
    source "$HOME/Desktop/interface/chpwd-to-source/helpers-console/on-enter-dir"
    ;;
  $HOME/Desktop/efis)
    source "$HOME/Desktop/interface/chpwd-to-source/efis/on-enter-dir"
    ;;
  $HOME/Desktop/interface/priv)
    source "$HOME/Desktop/interface/chpwd-to-source/priv/on-enter-dir"
    ;;
    # $HOME/Desktop/client)
    #   source "$HOME/Desktop/interface/chpwd-to-source/mainToMaster/on-enter-dir"
    #   ;;
  $HOME/Desktop/server)
    source "$HOME/Desktop/interface/chpwd-to-source/goToGodotenv/on-enter-dir"
    unalias ys
    alias ys="godotenv -f .env go run cmd/migration/main.go && godotenv -f .env go run cmd/server/main.go"
    ;;
  $HOME/Desktop/member-server)
    source "$HOME/Desktop/interface/chpwd-to-source/goToGodotenv/on-enter-dir"
    unalias ys
    alias ys="godotenv -f .env go run cmd/migration/main.go && godotenv -f .env go run cmd/server/main.go"
    ;;
  $HOME/Desktop/data-jobs)
    source "$HOME/Desktop/interface/chpwd-to-source/goToGodotenv/on-enter-dir"
    unalias ys
    alias ys="godotenv -f .env go run cmd/server/main.go"
    ;;
  *) ;;
  esac

  case $OLDPWD in
  $HOME/Desktop/trivia)
    source "$HOME/Desktop/interface/chpwd-to-source/trivia/on-leave-dir"
    ;;
    # $HOME/Desktop/interface)
    #   source "$HOME/Desktop/interface/chpwd-to-source/interface/on-leave-dir"
    #   ;;
  $HOME/Desktop/helpers-console)
    source "$HOME/Desktop/interface/chpwd-to-source/helpers-console/on-leave-dir"
    ;;
  $HOME/Desktop/efis)
    source "$HOME/Desktop/interface/chpwd-to-source/efis/on-leave-dir"
    ;;
  $HOME/Desktop/interface/priv)
    source "$HOME/Desktop/interface/chpwd-to-source/priv/on-leave-dir"
    ;;
    # $HOME/Desktop/client)
    #   source "$HOME/Desktop/interface/chpwd-to-source/mainToMaster/on-leave-dir"
    #   ;;
  $HOME/Desktop/server)
    source "$HOME/Desktop/interface/chpwd-to-source/goToGodotenv/on-leave-dir"
    unalias ys
    alias ys="yarn start"
    ;;
  $HOME/Desktop/member-server)
    source "$HOME/Desktop/interface/chpwd-to-source/goToGodotenv/on-leave-dir"
    unalias ys
    alias ys="yarn start"
    ;;
  $HOME/Desktop/data-jobs)
    source "$HOME/Desktop/interface/chpwd-to-source/goToGodotenv/on-leave-dir"
    unalias ys
    alias ys="yarn start"
    ;;
  *) ;;
  esac
}

#- - - - - - - - - - -

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

# routine-pull() {
#   drive-pull Mackup/.docker/
#   # drive-pull Mackup/.emacs.d/
#   drive-pull Mackup/.gnupg/
#   drive-pull Mackup/.ssh/
#   drive-pull Mackup/.subversion/
#   drive-pull Mackup/.vscode/
#   # drive-pull Mackup/Library/
#   drive-pull Mackup/.directory
#   drive-pull Mackup/.emacs
#   drive-pull Mackup/.gitconfig
#   drive-pull Mackup/.hyper.js
#   drive-pull Mackup/.inputrc
# }

#- - - - - - - - - - -

root() {
  command sudo bash -ic "$*"
}

#- - - - - - - - - - -

# base64 decode
bd() {
  base64 -d <<<"$@"
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

#----------------

tableinfo() {
  if [ "$1" == "" ]; then
    echo -n "\"SELECT column_name, is_nullable, data_type, column_default FROM information_schema.columns WHERE table_name = 'foo' ORDER BY column_name;\"" | xclip -selection c
    echo "copied to clipboard as foo"
  else
    echo -n "\"SELECT column_name, is_nullable, data_type, column_default FROM information_schema.columns WHERE table_name = '$1' ORDER BY column_name;\"" | xclip -selection c
    echo "copied to clipboard as $1"
  fi
}
