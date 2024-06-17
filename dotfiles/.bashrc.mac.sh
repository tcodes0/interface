#!/bin/bash
# shellcheck disable=SC2034 disable=SC1090

#========== Completions, external scripts, git prompt
if [ -d /usr/local/etc/bash_completion.d ]; then
  for file in /usr/local/etc/bash_completion.d/*; do
    safe_source "$file"
  done
fi

if [ -f "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
  source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

#========== Environment

export GOPATH=$HOME/.go
export GOBIN=$HOME/.go/bin

export PATH="\
$HOME/bin:\
/opt/homebrew/bin:\
/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:\
/usr/local/bin:\
/bin:\
/usr/bin:\
/sbin:\
/usr/local/sbin:\
/usr/sbin:\
${GOBIN}"
