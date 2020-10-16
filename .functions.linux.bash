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
  \sudo bash -ic "$*"
}

#- - - - - - - - - - -

pacu() {
  # pacman
  # sudo pacman --sync --sysupgrade --refresh --noconfirm
  # sudo pacman --sync --noconfirm --clean
  yay --sync --sysupgrade --refresh --noconfirm
  yay --sync --noconfirm --clean
  # misc
  mackup backup
  yarn global upgrade --latest
  yarn cache clean
  command cd "$NVM_DIR" && git pull
  nvm install node
  # aur
  asdf update
  asdf plugin update --all
  # misc
  command cd "$HOME/Desktop"
}

#- - - - - - - - - - -

# base64 decode
bd() {
  base64 -d <<<"$@"
}

#- - - - - - - - - - -

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

sysbkp() {
  sysbkp.linux.sh
}

#- - - - - - - - - - -

vpnUp() {
  sudo wg-quick up wg0
  sudo wg
}

#- - - - - - - - - - -

vpnDown() {
  sudo wg-quick down wg0
  sudo wg
}
