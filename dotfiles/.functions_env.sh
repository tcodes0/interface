#! /usr/bin/env bash
# Functions shared between scripts and the interactive user shell
# sourced from .bashrc and .bash_env.

__jj_bookmarks() {
  jj log --revisions '::@ & bookmarks()' --template 'bookmarks ++ " "' --no-graph --color="${1:-never}"
}

#----------------

# get the first bookmark in the current branch's history that is not main or master, or the second if the first is main or master. If neither exists, returns empty string.
jj_bookmark0() {
  local candidate bookmarks=()
  read -ra bookmarks < <(__jj_bookmarks)
  local first="${bookmarks[0]/\*/}"

  if [[ ! "$first" =~ ^(main|master)$ ]]; then
    candidate="$first"
  elif [ -n "${bookmarks[1]:-}" ]; then
    candidate="${bookmarks[1]/\*/}"
  else
    jj bookmark set "$(date +%b-%-d-%H%M | tr '[:upper:]' '[:lower:]')" --revision @
    read -ra bookmarks < <(__jj_bookmarks)
    first="${bookmarks[0]/\*/}"
    [[ ! "$first" =~ ^(main|master)$ ]] && candidate="$first" || candidate="${bookmarks[1]:-}"
    candidate="${candidate/\*/}"
  fi

  if [ -n "$candidate" ]; then
    printf "%s" "$candidate"
  else
    warn $LINENO "jj_bookmark0 empty, bookmarks: ${bookmarks[*]}"
  fi
}
