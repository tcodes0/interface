#! /bin/bash
# $HOME is different if root, but root's $HOME/Desktop/interface
# symlinks to me's $HOME/Desktop/interface, covering our bases

shopt -s autocd cdspell dirspell globstar cmdhist lithist histverify histappend

source_noisy() {
  local path=$1 fileLine=$2

  # shellcheck disable=SC1090
  if ! source "$path" 2>/dev/null; then
    echo "$fileLine" source "$path": not found
  fi
}

source_dotfile() {
  local path=$1 line=$2
  source_noisy "$DOTFILES/$path" "$DOTFILES/.bashrc:$line"
}

# !is_linux will be macOS
is_linux() {
  [ "$(uname)" == "Linux" ]
}

# !is_me will be root
is_me() {
  [[ "$(whoami)" =~ vacation|thom.ribeiro ]]
}

export DOTFILES="$HOME/Desktop/interface/dotfiles"

if [ ! "$(pgrep ssh-agent)" ]; then
  eval "$(ssh-agent)" >/dev/null
elif [[ ! "$SSH_AUTH_SOCK" =~ $(pgrep ssh-agent) ]]; then
  SSH_AUTH_SOCK=$(find /tmp -maxdepth 2 -type s -name 'agent.*' 2>/dev/null)
fi

export SSH_AUTH_SOCK
export GOPRIVATE="github.com/eleanorhealth/\* github.com/tcodes0/\*"
export BASH_ENV="$HOME/.bash_env"
export CMD_COLOR=true
export EDITOR='code -w'
export GPGKEY=D600E88A0C5FE062
export KNOWN_HOSTS=(Arch7 Thoms-MacBook-Pro-14.local ThomRiberio-MacBook-Air)
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export HISTSIZE=5000
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT="%b %d "
export HISTCONTROL="ignoredups:erasedups"
export TIMEFORMAT=$'\n-time elapsed-\nreal\t%3Rs\nuser\t%3Us\nsystem\t%3Ss'
export BLOCKSIZE=1000000 #1 Megabyte
export LESS="--RAW-CONTROL-CHARS --HILITE-UNREAD --window=-5 --quiet --buffers=32768 --quit-if-one-screen --prompt=?eEND:%pb\\%. ?f%F:Stdin.\\: page %d of %D, line %lb of %L"
export PAGER="less"
#  shellcheck disable=SC2155 # not using exit code of subshell
export GPG_TTY=$(tty)
export XDG_RUNTIME_DIR
export WAYLAND_DISPLAY

# prompt
source_dotfile "lib-git-prompt.sh" "$LINENO"
source_dotfile "lib-prompt.sh" "$LINENO"

export PS1
export PROMPT_COMMAND
PS1=$(makePS1)
UNDERLINE="\\[\\e[4m\\]"
PROMPT_COMMAND="__git_ps1 '$(makePS1 preGit)' '$(makePS1 postGit)' '$MAIN_COLOR$UNDERLINE%s$END'"

# nvm
unset PREFIX            # nvm hates this
unset npm_config_prefix # nvm hates this
export NVM_DIR="$HOME/.nvm"
source_noisy "$NVM_DIR/nvm.sh" "$DOTFILES/.bashrc:$LINENO"

if is_me && [ -d "./Desktop" ] && ! command cd ./Desktop; then
  echo 'cd desktop failed'
fi

# Completions, external scripts, git prompt
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

source_dotfile ".aliases.sh" "$LINENO"

if is_linux; then
  source_dotfile ".bashrc.linux.sh" "$LINENO"
  source_dotfile ".aliases.linux.sh" "$LINENO"
  source_dotfile ".functions.linux.sh" "$LINENO"
  # beware $HOME is different if root
  source_noisy "$HOME/google-cloud-sdk/completion.bash.inc" "$DOTFILES/.bashrc:$LINENO"
  source_noisy /usr/share/bash-completion/bash_completion "$DOTFILES/.bashrc:$LINENO"
  source_noisy /usr/share/LS_COLORS/dircolors.sh "$DOTFILES/.bashrc:$LINENO"
else
  source_dotfile ".bashrc.mac.sh" "$LINENO"
  source_dotfile ".aliases.mac.sh" "$LINENO"
  source_dotfile ".functions.mac.sh" "$LINENO"
  source_noisy /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc "$DOTFILES/.bashrc:$LINENO"
fi

# after aliases
source_dotfile ".functions.sh" "$LINENO"
source_noisy "$HOME/Desktop/interface/priv/.bashrc" "$DOTFILES/.bashrc:$LINENO"
# after PATH is set
nvm use node >/dev/null
