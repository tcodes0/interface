#! /usr/bin/env bash

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
$HOME/.local/bin:\
/opt/rocm/bin:\
/opt/android-sdk/platform-tools"

if [ ! "$(pgrep ssh-agent)" ]; then
  eval "$(ssh-agent)" >/dev/null
elif [[ ! "$SSH_AUTH_SOCK" =~ $(pgrep ssh-agent) ]]; then
  SSH_AUTH_SOCK=$(find /tmp -maxdepth 2 -type s -name 'agent.*' 2>/dev/null)
fi

export SSH_AUTH_SOCK
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

# Completions, external scripts, git prompt
for file in "$HOME"/.bash_completion.d/*; do
  src "$file" "$DOTFILES/.bashrc.linux.sh:$LINENO"
done
