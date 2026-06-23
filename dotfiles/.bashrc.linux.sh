#! /usr/bin/env bash

# /bin symlinked to /usr/bin
# /sbin symlinked to /usr/sbin
export PATH="\
$HOME/.local/share/mise/shims:\
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
$HOME/.local/bin:\
/opt/rocm/bin"

export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

# Completions, external scripts, git prompt
for file in "$HOME"/.bash_completion.d/*; do
  src "$file" "$DOTFILES/.bashrc.linux.sh:$LINENO"
done

