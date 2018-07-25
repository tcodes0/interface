#!/usr/bin/env bash

#sets COLUMNS env var that iterm2 doesn't set, even tho Terminal does
tput init

#========== Completions, external scripts, git prompt
GIT_PS1_SHOWDIRTYSTATE="true"
GIT_PS1_SHOWSTASHSTATE="true"
GIT_PS1_SHOWUNTRACKEDFILES="true"
GIT_PS1_SHOWUPSTREAM="auto"
# You can further control behaviour by setting GIT_PS1_SHOWUPSTREAM to a space-separated list of values: verbose name legacy git svn
# GIT_PS1_SHOWUPSTREAM="verbose name git"
GIT_PS1_STATESEPARATOR=""
# If you would like to see more information about the identity of commits checked out as a detached HEAD, set GIT_PS1_DESCRIBE_STYLE to one of these values: contains branch describe tag default
GIT_PS1_DESCRIBE_STYLE="branch"
# GIT_PS1_SHOWCOLORHINTS="true"

# Mac home dir
VHOME=/Users/vamac

#========== Early sourcing
if [ -f /usr/local/share/bash-completion/bash_completion ]; then source /usr/local/share/bash-completion/bash_completion; fi
if [ -f $VHOME/.git-completion.bash ]; then source $VHOME/.git-completion.bash; fi
if [ -f $VHOME/.git-prompt.bash ]; then source $VHOME/.git-prompt.bash; fi
if [ -f $VHOME/.yarn-completion.bash ]; then source $VHOME/.yarn-completion.bash; fi

#========== Mac only
if [[ "$(uname -s)" =~ Darwin ]]; then
  export PATH="/usr/local/bin:/bin:/usr/bin:/sbin:/usr/local/sbin:/usr/sbin:/opt/X11/bin:$VHOME/bin:/usr/local/opt/go/libexec/bin"
  export CDPATH=$VHOME:/Volumes:$VHOME/Desktop
  export EDITOR='code'
  export GOPATH="$VHOME/.go"
  export LS_COLORS=$(cat $VHOME/Code/LS_COLORS/LS_COLORS_RAW)

  if [ -f ~/.bash_ps1 ]; then
    source ~/.bash_ps1
  else
    export PS1="\n\w\n\$ "
  fi
fi

#========== Environment
export HISTSIZE=3000
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT="%b %d "
export HISTCONTROL="ignoredups:erasedups"
export TIMEFORMAT=$'\n-time elapsed-\nreal\t%3Rs\nuser\t%3Us\nsystem\t%3Ss'
export BLOCKSIZE=1000000 #1 Megabyte
export LESS="--LINE-NUMBERS --prompt=?eEND:%pb\%. ?f%F:Stdin.\: page %d of %D, line %lb of %L"
export PAGER="/usr/bin/less --RAW-CONTROL-CHARS --HILITE-UNREAD --window=-5 --quiet +3uGg"
export BASH_ENV="$VHOME/.bashrc"
export GPG_TTY=$(tty)
shopt -s autocd cdspell dirspell globstar cmdhist lithist histverify histappend #nullglob

#========== Late sourcing
if [ -f ~/.bash_aliases ]; then source ~/.bash_aliases; fi
if [ -f ~/.bash_functions ]; then source ~/.bash_functions; fi
if [ $VSCODE_OVERRIDES ]; then source $VSCODE_OVERRIDES; fi