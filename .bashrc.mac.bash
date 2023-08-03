#!/usr/bin/env bash
# shellcheck disable=SC2034 disable=SC1090

DOTFILE_PATH="/Users/vacation/Desktop/interface"

#========== Completions, external scripts, git prompt
if [ -d /usr/local/etc/bash_completion.d ]; then
  for file in /usr/local/etc/bash_completion.d/*; do
    safe_source "$file"
  done
fi

# order matters here
safe_source $DOTFILE_PATH/.bashrc.bash
safe_source $DOTFILE_PATH/.aliases.bash
safe_source $DOTFILE_PATH/.aliases.mac.bash
safe_source $DOTFILE_PATH/.functions.bash
safe_source $DOTFILE_PATH/.functions.mac.bash
safe_source $DOTFILE_PATH/.prompt.linux.bash
safe_source $DOTFILE_PATH/linux/home/.config/git-prompt.sh
safe_source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc
safe_source $DOTFILE_PATH/priv/env

#========== Environment

# Go
export GOPATH=$HOME/.go
# upgrade will break. see line history for previous values, it's set in vscode settings now
# export GOROOT="/opt/homebrew"

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
${GOPATH}/bin"

export EDITOR='code -w'
export GOPATH="$HOME/.go"

# NVM
unset PREFIX            # NVM hates this
unset npm_config_prefix # NVM hates this
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
