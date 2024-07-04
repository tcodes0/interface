#!/usr/bin/env bash
# shellcheck disable=SC2034 disable=SC1090

# Completions, external scripts, git prompt
for file in /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm /usr/local/etc/bash_completion.d/*; do
  src "$file" "$DOTFILES/.bashrc.mac.sh:$LINENO"
done

# Environment

if [ ! "$(pgrep ssh-agent)" ]; then
  eval "$(ssh-agent)" >/dev/null
elif [[ ! "$SSH_AUTH_SOCK" =~ $(pgrep ssh-agent) ]]; then
  SSH_AUTH_SOCK=$(find /var/folders -type s -name 'agent.*' 2>/dev/null)
fi

export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

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
