#! /usr/bin/env bash
# Linux ~/.bashrc
# root user runs these files as well!
# so some whoami or UID checks are needed

#========== Environment

# Old path stuff
# $HOME/.asdf/installs/elixir/1.10.0/bin:\
# $HOME/.gem/ruby/2.7.0/bin:\
# $HOME/bin/monero-gui:\

# Some old comments on file history about java and irpf if you have issues with that
export PATH="\
$HOME/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/usr/bin:\
/usr/bin/vendor_perl:\
/usr/bin/core_perl:\
$HOME/go/bin:\
$HOME/.cargo/bin:\
/usr/local/go/bin:\
$HOME/Desktop/scripts-eleanor:\
$HOME/Desktop/dir-rename/build:\
$HOME/google-cloud-sdk/bin:\
/opt/android-sdk/platform-tools"

# NVM
unset PREFIX            # NVM hates this
unset npm_config_prefix # NVM hates this
export NVM_DIR="$HOME/.nvm"
[ -f "$NVM_DIR/nvm.sh" ] && safe_source "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -f "$NVM_DIR/bash_completion" ] && safe_source "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export EDITOR='code -w'

# gpg agent
export GPGKEY=D600E88A0C5FE062

# dotfiles
export DOTFILE_PATH=""
if [ "$(whoami)" == "root" ]; then
  DOTFILE_PATH="/home/vacation/Desktop/interface"
elif [ "$(whoami)" == "vacation" ]; then
  DOTFILE_PATH="$HOME/Desktop/interface"
fi

# Go
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export GOPRIVATE="github.com/eleanorhealth/* github.com/tcodes0/*"

# gcloud
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

safe_source "$DOTFILE_PATH/.script-functions.linux.bash"

# https://wiki.archlinux.org/title/GNOME/Keyring#Using_the_keyring
if [ -n "$DESKTOP_SESSION" ]; then
  eval "$(gnome-keyring-daemon --start)"
  export SSH_AUTH_SOCK
fi

#                                                                     ensure it runs on GUI terminal not before
if [ "$(whoami)" == "vacation" ] && [ "$USER_SERVICES_SET" == "" ] && [[ $(tty) =~ /dev/pts ]]; then
  echo "setting user services"
  # systemctl call is slow, so only run once, also errors if already running
  export USER_SERVICES_SET="true"
  systemctl --user start x11-keyboard.service
  systemctl --user start srit.service
  systemctl --user start firefox-sync@mpakm5ej.dev-edition-default.service
fi

###############################################
# If running from script, skip remaining code #
###############################################
[[ $- != *i* ]] && return

# order matters here
safe_source "$DOTFILE_PATH/.bashrc.bash"
safe_source "$DOTFILE_PATH/.aliases.bash"
safe_source "$DOTFILE_PATH/.aliases.linux.bash"
safe_source "$DOTFILE_PATH/.functions.bash"
safe_source "$DOTFILE_PATH/.functions.linux.bash"
safe_source "$DOTFILE_PATH/.private.bash"
safe_source "$DOTFILE_PATH/.prompt.linux.bash"
safe_source "$DOTFILE_PATH/linux/home/.config/git-prompt.sh"
safe_source "$DOTFILE_PATH/priv/.bashrc.bash"
# AUR  lscolors-git package
safe_source /usr/share/LS_COLORS/dircolors.sh
safe_source /usr/share/bash-completion/bash_completion
safe_source "$HOME/.asdf/asdf.sh"
safe_source "$HOME/.asdf/completions/asdf.bash"
safe_source "$HOME/google-cloud-sdk/completion.bash.inc"

# start on desktop
if [ -d "./Desktop" ]; then
  command cd ./Desktop || echo 'cd desktop failed'
fi

# add ssh key to ssh agent, bypass prompt
if [ ! "$SSH_AUTH_SOCK" ] && [ -f "$DOTFILE_PATH/.private-ssh-add.expect" ]; then
  eval "$(ssh-agent)" 2>/dev/null 1>&2
  "$DOTFILE_PATH/.private-ssh-add.expect" 2>/dev/null 1>&2
fi

# add gpg key to gpg agent, bypass prompt
"$DOTFILE_PATH/.private-gpg-init.sh" 2>/dev/null 1>&2

#tmux
if [ ! "$TMUX" ] && [ $UID == 1000 ] && [[ ! "$(tty)" =~ /dev/tty[0-9]* ]]; then
  tmux attach || tmux new-session
  tmux source-file "$HOME/.tmux.conf"
fi
