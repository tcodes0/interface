#! /usr/bin/env bash

#- - - - - - - - - - -

cl() {
  local path="$1"

  if [ ! "$path" ]; then
    path=$HOME
  fi

  command cd -P "$path" >/dev/null || return
  ls
}

#- - - - - - - - - - -

findname() {
  if [ $# == "0" ]; then
    echo "findname foo runs find . -iname *foo*"
    echo "findname foo bar runs find foo -iname *bar*"
    return
  fi

  local where=. pattern="$1"

  if [ $# == "2" ]; then
    where="$1"
    pattern="$2"
  fi

  find "$where" -iname "*$pattern*"
}

#- - - - - - - - - - -

tra() {
  [ $# == 0 ] && return 1

  for pathToTrash in "$@"; do
    trash "$pathToTrash" || return
    local last="$pathToTrash"
  done

  if [[ $last =~ (.+)[/][^/]+$ ]] && [ -n "${BASH_REMATCH[1]}" ]; then
    ls "${BASH_REMATCH[1]}"
  else
    ls
  fi
}

#- - - - - - - - - - -

grepr() {
  if [ "$#" == "0" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    grepl -h
    echo "recursive."
    return
  fi

  grep --color=auto -ri -E "$@" -l 2>/dev/null
}

#- - - - - - - - - - -

grepl() {
  if [ "$#" == "0" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "grep files with matches, case-insensitive, extended regex, on \$PWD, no error messages."
    return
  fi

  grep --color=auto -iE "$@" -l ./* .* 2>/dev/null
}

#- - - - - - - - - - -

aliasg() {
  if [ "$1" ]; then
    alias | grep "$@"
  fi
}

#- - - - - - - - - - -

# lazy commit
gcmsg() {
  if [ "$*" ]; then
    git commit -q -m "$*"
  else
    git commit -q -v
  fi

  gss
}

#- - - - - - - - - - -

# git tag push
gtp() {
  if [ "$1" ] && git tag "$1"; then
    git push -q origin "$1"
  fi
}

#- - - - - - - - - - -

goo() {
  local escapedQuery
  escapedQuery=$(echo -n "$@" | tr ' ' '+')
  open "https://duckduckgo.com/?q=${escapedQuery}&t=ffab&ia=web"
}

#- - - - - - - - - - -

gbg() {
  git branch | grep "$1"
}

#- - - - - - - - - - -

# yarn add
ya() {
  yarn add --exact "$@"
}

#- - - - - - - - - - -

# yarn add dev
yad() {
  yarn add -D --exact "$@"
}

#- - - - - - - - - - -

# fix calling git status when there's no repo, call ls instead
gss() {
  if command git status -s 2>/dev/null 1>&2; then
    command git status -s
  else
    echo "warning: not a git repo"
    ls
  fi
}

#- - - - - - - - - - -

grbonto() {
  if [ ! "$1" ] || [ "$1" == -h ] || [ "$1" == --help ]; then
    echo "Usage: grbonto 5 to rebase HEAD~5 commits into origin main"
    return
  fi
  git rebase "HEAD~$1" --onto=origin/main
}

#- - - - - - - - - - -

gcom() {
  if ! git fetch --all --prune; then
    return
  fi

  local branch=main checkout
  checkout=$(git checkout $branch 2>&1)

  if [[ "$checkout" =~ 'can be fast-forwarded' ]]; then
    echo "gcom > Branch behind remote counterpart, pulling..."

    if ! git diff --quiet; then
      echo "gcom > You have unstaged changes"
      return
    fi

    git pull
  elif [[ "$checkout" =~ 'did not match any file' ]]; then
    echo "gcom > Branch $branch does not exist, checkout manually"
  fi
}

#----------------

gotest() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: gotest path/to/test"
    return
  fi

  godotenv -f .env go test "./$1" -race -json 2>&1 | gotestfmt
}

#----------------

tableinfo() {
  if [ "$1" == "" ]; then
    echo -n "\"SELECT column_name, is_nullable, data_type, column_default FROM information_schema.columns WHERE table_name = 'foo' ORDER BY column_name;\"" | pbc
    echo "copied to clipboard as foo"
  else
    echo -n "\"SELECT column_name, is_nullable, data_type, column_default FROM information_schema.columns WHERE table_name = '$1' ORDER BY column_name;\"" | pbc
    echo "copied to clipboard as $1"
  fi
}

#- - - - - - - - - - -

root() {
  command sudo bash -ic "$*"
}
