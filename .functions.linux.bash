#! /usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

#========== Override macos

#- - - - - - - - - - -

goo() {
  google "$@"
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
  *) ;;
  esac
}

#- - - - - - - - - - -

absolute-drive-push() {
  if [ "$#" -gt 2 ] || [ "$1" == -h ] || [ "$#" == 0 ]; then
    echo "Usage: drive-push targets/to/push"
    echo "Usage: drive-pull local remote"
    echo "Pushes target to google drive using rclone remote google-drive"
    echo "Paths are absolute to \$DOTFILE_PATH"
    return
  fi
  if [[ "$#" == 1 ]]; then
    rclone copyto "$DOTFILE_PATH/$1" "google-drive:$1"
  else
    rclone copyto "$DOTFILE_PATH/$1" "google-drive:$2"
  fi
}

#- - - - - - - - - - -

absolute-drive-pull() {
  if [ "$#" -gt 2 ] || [ "$1" == -h ] || [ "$#" == 0 ]; then
    echo "Usage: drive-pull target"
    echo "Usage: drive-pull local remote"
    echo "Pulls target from google drive using rclone remote google-drive"
    echo "Paths are absolute to \$DOTFILE_PATH"
    return
  fi
  if [[ "$#" == 1 ]]; then
    rclone copyto "google-drive:$1" "$DOTFILE_PATH/$1"
  else
    rclone copyto "google-drive:$2" "$DOTFILE_PATH/$1"
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
  \sudo bash -ic "$*"
}

#- - - - - - - - - - -

pacu() {
  sudo pacman --sync --sysupgrade --refresh --noconfirm # -Syu
  sudo pacman --sync --clean --noconfirm                # Sc
  asdf update
  asdf plugin update --all
}
#- - - - - - - - - - -

# base64 decode
bd() {
  base64 -d <<<"$@"
}

# search pacman and AUR
pacs() {
  pacman --sync --search "$@"
  echo "fetching AUR results..."
  # AUR is slower, so background it
  yay --sync --search "$@" &
}
