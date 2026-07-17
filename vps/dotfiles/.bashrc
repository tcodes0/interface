#! /usr/bin/env bash
# order matters everywhere in this file

shopt -s autocd cdspell dirspell globstar cmdhist lithist histverify histappend

src() {
  local path=$1 fileLine=$2

  # shellcheck disable=SC1090
  if ! source "$path"; then
    echo "$fileLine" source "$path": not found
  fi
}

src_file() {
  local path=$1 line=$2
  src "$path" ".bashrc:$line"
}

export PATH="\
/usr/local/sbin:\
/usr/local/bin:\
/usr/sbin:\
/usr/bin:\
/sbin:\
$HOME/bin:\
/bin"

# less files to symlink if we source directly
export DOTFILES="$HOME/projects/interface/dotfiles"
export VPS_DOTFILES="$HOME/projects/interface/vps/dotfiles"
# shellcheck disable=SC2155
export GPG_TTY=$(tty)
export HISTSIZE=50000
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT="%b %d "
export HISTCONTROL="ignoredups:erasedups"
export TIMEFORMAT='%3Rs'
export BLOCKSIZE=1000000 #1 Megabyte
export LESS="--RAW-CONTROL-CHARS --HILITE-UNREAD --quiet --buffers=32768 --quit-if-one-screen --prompt=?eEND:%pb\\%. ?f%F:Stdin.\\: page %d of %D, line %lb of %L"
export PAGER="less"
# Git prompt
export GIT_PS1_SHOWDIRTYSTATE="true"
export GIT_PS1_SHOWSTASHSTATE="true"
export GIT_PS1_SHOWUNTRACKEDFILES="true"
export GIT_PS1_SHOWUPSTREAM="verbose git"
export GIT_PS1_STATESEPARATOR=""
export GIT_PS1_DESCRIBE_STYLE="branch"
export GIT_PS1_SHOWCOLORHINTS="true"
export GIT_PS1_HIDE_IF_PWD_IGNORED="true"

if [ ! "$(pgrep ssh-agent)" ]; then
  eval "$(ssh-agent)" >/dev/null
elif [[ ! "$SSH_AUTH_SOCK" ]]; then
  SSH_AUTH_SOCK=/run/user/0/openssh_agent
fi

export SSH_AUTH_SOCK

# libs
src_file "$DOTFILES/lib.sh" "$LINENO"

if [[ $- != *i* ]]; then
  # skip rest of file if not interactive (ssh script, etc)
  return
fi

src_file "$DOTFILES/lib-git-prompt.sh" "$LINENO"
src_file "$DOTFILES/lib-prompt.sh" "$LINENO"

export PROMPT_COMMAND

UNDERLINE="\\[\\e[4m\\]"
PROMPT_COMMAND="vcs_prompt '$(make_ps1 pre)' '$(make_ps1 post)' '$MAIN_COLOR$UNDERLINE%s$END'"

# bash
# src_file ".bashrc.linux.sh" do NOT source this file into VPS.
src_file "$DOTFILES/.aliases.sh" "$LINENO"
src_file "$DOTFILES/.aliases.linux.sh" "$LINENO"
src_file "$DOTFILES/.functions.linux.sh" "$LINENO"
src_file "$DOTFILES/.functions.sh" "$LINENO"

# vps dotfiles
src_file "$VPS_DOTFILES/.aliases.linux.vps.sh" "$LINENO"
src_file "$VPS_DOTFILES/.lscolors.sh" "$LINENO"

# start tmux on login only if not already in a tmux session,
if [ -z "$TMUX" ]; then
  tmux attach || tmux new-session
  tmux source-file "$HOME/.tmux.conf"
fi

# load key into SSH agent, if not already loaded and interactive
if [ -S "$SSH_AUTH_SOCK" ]; then
  ssh-add -l | grep -q "$(ssh-keygen -lf ~/.ssh/id_ed25519.pub | awk '{print $2}')" || ssh-add -q
fi
