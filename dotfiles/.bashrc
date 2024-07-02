#! /bin/bash
# $HOME is different if root, but root's $HOME/Desktop/interface
# symlinks to me's $HOME/Desktop/interface, covering our bases

shopt -s autocd cdspell dirspell globstar cmdhist lithist histverify histappend

# more helpful error message on source
src() {
  local path=$1 fileLine=$2

  # shellcheck disable=SC1090
  if ! source "$path" 2>/dev/null; then
    echo "$fileLine" source "$path": not found
  fi
}

src_dotfile() {
  local path=$1 line=$2
  src "$DOTFILES/$path" "$DOTFILES/.bashrc:$line"
}

# !is_linux will be macOS
is_linux() {
  [ "$(uname)" == "Linux" ]
}

# !is_me will be root
is_me() {
  [[ "$(whoami)" =~ vacation|thom.ribeiro ]]
}

if [ ! "$(pgrep ssh-agent)" ]; then
  eval "$(ssh-agent)" >/dev/null
elif [[ ! "$SSH_AUTH_SOCK" =~ $(pgrep ssh-agent) ]]; then
  SSH_AUTH_SOCK=$(find /tmp -maxdepth 2 -type s -name 'agent.*' 2>/dev/null)
fi

export DOTFILES="$HOME/Desktop/interface/dotfiles"
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
export GPG_TTY
GPG_TTY=$(tty)
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

# prompt
src_dotfile "lib-git-prompt.sh" "$LINENO"
src_dotfile "lib-prompt.sh" "$LINENO"
export PS1
PS1=$(makePS1)
export PROMPT_COMMAND
UNDERLINE="\\[\\e[4m\\]"
PROMPT_COMMAND="__git_ps1 '$(makePS1 preGit)' '$(makePS1 postGit)' '$MAIN_COLOR$UNDERLINE%s$END'"

# nvm
unset PREFIX            # nvm hates this
unset npm_config_prefix # nvm hates this
export NVM_DIR="$HOME/.nvm"
src "$NVM_DIR/nvm.sh" "$DOTFILES/.bashrc:$LINENO"

if is_me && [ "$(basename "$PWD")" != Desktop ]; then
  # shellcheck disable=SC2164
  command cd ./Desktop 2>/dev/null
fi

# order matters
src_dotfile ".aliases.sh" "$LINENO"

if is_linux; then
  src_dotfile ".bashrc.linux.sh" "$LINENO"
  src_dotfile ".aliases.linux.sh" "$LINENO"
  src_dotfile ".functions.linux.sh" "$LINENO"
  src "$HOME/google-cloud-sdk/completion.bash.inc" "$DOTFILES/.bashrc:$LINENO"
  src /usr/share/bash-completion/bash_completion "$DOTFILES/.bashrc:$LINENO"
  src /usr/share/LS_COLORS/dircolors.sh "$DOTFILES/.bashrc:$LINENO"
else
  src_dotfile ".bashrc.mac.sh" "$LINENO"
  src_dotfile ".aliases.mac.sh" "$LINENO"
  src_dotfile ".functions.mac.sh" "$LINENO"
  src /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc "$DOTFILES/.bashrc:$LINENO"
fi

# after aliases
src_dotfile ".functions.sh" "$LINENO"
src "$HOME/Desktop/interface/priv/.bashrc" "$DOTFILES/.bashrc:$LINENO"
# after PATH is set
nvm use node >/dev/null
