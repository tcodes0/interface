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
# see lazy-git
export PUSH_REPOS="member-client interface priv hub-client"

# Completions, external scripts, git prompt
for file in "$HOME"/.bash_completion.d/*; do
  src "$file" "$DOTFILES/.bashrc.linux.sh:$LINENO"
done

# /dev/pts ensures it runs on GUI terminal not before
if is_me && [ "$USER_SERVICES_STARTED" == "" ] && [[ $(tty) =~ /dev/pts ]]; then
  # systemctl call is slow, so only run once, also errors if already running
  export USER_SERVICES_STARTED="true"
  systemctl --user start xkbcomp.service
  systemctl --user start xset-rate.service
  systemctl --user start firefox-sync.service
fi

# tmux
if [ ! "$TMUX" ] && is_me; then
  tmux attach || tmux new-session
  tmux source-file "$HOME/.tmux.conf"
fi
