#! /bin/bash
# shellcheck disable=SC1090
# runs on login only

safe_source() {
  warnSourceFailed="yes"

  if [ -f "$1" ]; then
    source "$1"
  elif [ "$warnSourceFailed" ]; then
    echo "$1" not found to source
  fi
}

#========== Environment
export HISTSIZE=5000
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT="%b %d "
export HISTCONTROL="ignoredups:erasedups"
export TIMEFORMAT=$'\n-time elapsed-\nreal\t%3Rs\nuser\t%3Us\nsystem\t%3Ss'
export BLOCKSIZE=1000000 #1 Megabyte
export LESS="--RAW-CONTROL-CHARS --HILITE-UNREAD --window=-5 --quiet --buffers=32768 --quit-if-one-screen --prompt=?eEND:%pb\\%. ?f%F:Stdin.\\: page %d of %D, line %lb of %L"
export PAGER="less"
export BASH_ENV="$HOME/.bashrc"
export GOPRIVATE="github.com/eleanorhealth/\* github.com/tcodes0/\*"
export DOTFILE_PATH=""

GPG_TTY=$(tty)
export GPG_TTY

if [ "$(whoami)" == "root" ]; then
  # use vacation files on root to have the same envs and aliases
  DOTFILE_PATH="/home/vacation/Desktop/interface/dotfiles"
elif [ "$(whoami)" == "vacation" ]; then
  DOTFILE_PATH="$HOME/Desktop/interface/dotfiles"
fi

safe_source "$DOTFILE_PATH/lib.sh"

# If running from script, skip remaining code
[[ $- != *i* ]] && return

shopt -s autocd cdspell dirspell globstar cmdhist lithist histverify histappend

export EDITOR='code -w'
# gpg agent
export GPGKEY=D600E88A0C5FE062

# gcloud
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# nvm
unset PREFIX            # nvm hates this
unset npm_config_prefix # nvm hates this
export NVM_DIR="$HOME/.nvm"

if [ -f "$NVM_DIR/nvm.sh" ]; then
  safe_source "$NVM_DIR/nvm.sh"
fi

if [ -d "./Desktop" ]; then
  command cd ./Desktop || echo 'cd desktop failed'
fi

#========== Completions, external scripts, git prompt
export GIT_PS1_SHOWDIRTYSTATE="true"
export GIT_PS1_SHOWSTASHSTATE="true"
export GIT_PS1_SHOWUNTRACKEDFILES="true"
# You can further control behaviour by setting GIT_PS1_SHOWUPSTREAM to a space-separated list of values: verbose name legacy git svn
export GIT_PS1_SHOWUPSTREAM="verbose git"
export GIT_PS1_STATESEPARATOR=""
# If you would like to see more information about the identity of commits checked out as a detached HEAD, set GIT_PS1_DESCRIBE_STYLE to one of these values: contains branch describe tag default
export GIT_PS1_DESCRIBE_STYLE="branch"
export GIT_PS1_SHOWCOLORHINTS="true"
export GIT_PS1_HIDE_IF_PWD_IGNORED="true"

# order matters

safe_source "$HOME/Desktop/interface/priv/.bashrc"
safe_source "$DOTFILE_PATH/lib-git-prompt.sh"
safe_source "$DOTFILE_PATH/lib-prompt.sh"
safe_source "$DOTFILE_PATH/.aliases.sh"
safe_source "$DOTFILE_PATH/.functions.sh"

if [[ "$(uname -s)" =~ Darwin ]]; then
  safe_source "$DOTFILE_PATH/.bashrc.mac.sh"
  safe_source "$DOTFILE_PATH/.aliases.mac.sh"
  safe_source "$DOTFILE_PATH/.functions.mac.sh"
  safe_source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc
fi

if [[ "$(uname -s)" =~ Linux ]]; then
  safe_source "$DOTFILE_PATH/.bashrc.linux.sh"
  safe_source "$DOTFILE_PATH/.aliases.linux.sh"
  safe_source "$DOTFILE_PATH/.functions.linux.sh"
  safe_source "$HOME/google-cloud-sdk/completion.bash.inc"
  safe_source /usr/share/bash-completion/bash_completion
  safe_source /usr/share/LS_COLORS/dircolors.sh
fi
