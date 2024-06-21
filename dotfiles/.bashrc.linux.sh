#! /bin/bash

# /bin symlinked to /usr/bin
# /sbin symlinked to /usr/sbin
export PATH="\
$HOME/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/usr/bin:\
/usr/sbin:\
/usr/bin/vendor_perl:\
/usr/bin/core_perl:\
$HOME/go/bin:\
$HOME/.cargo/bin:\
/usr/local/go/bin:\
$HOME/Desktop/scripts-eleanor:\
$HOME/Desktop/dir-rename/build:\
$HOME/google-cloud-sdk/bin:\
$HOME/.local/bin:\
/opt/android-sdk/platform-tools"

export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

if [ -f "$NVM_DIR/bash_completion" ]; then
  safe_source "$NVM_DIR/bash_completion"
fi

if [ "$DESKTOP_SESSION" ] && [ ! "$SSH_AUTH_SOCK" ]; then
  agent_pid=$(pgrep ssh-agent)

  if [ "$agent_pid" ]; then
    kill -HUP "$agent_pid"
  fi

  eval "$(ssh-agent)" >/dev/null
  export SSH_AUTH_SOCK
fi

# /dev/pts ensures it runs on GUI terminal not before
if [ "$(whoami)" == "vacation" ] && [ "$USER_SERVICES_SET" == "" ] && [[ $(tty) =~ /dev/pts ]]; then
  echo "setting user services"
  # systemctl call is slow, so only run once, also errors if already running
  export USER_SERVICES_SET="true"
  systemctl --user start x11-keyboard.service
  systemctl --user start srit.service
  systemctl --user start firefox-sync@mpakm5ej.dev-edition-default.service
fi

# tmux
if [ ! "$TMUX" ] && [ "$(whoami)" == "vacation" ] && [[ ! "$(tty)" =~ /dev/tty[0-9]* ]]; then
  tmux attach || tmux new-session
  tmux source-file "$HOME/.tmux.conf"
fi
