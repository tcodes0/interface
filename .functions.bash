#! /usr/bin/env bash

#- - - - - - - - - - -

cl() {
  local _path="$1"
  if [ ! "$1" ]; then
    _path=$HOME
  fi
  command cd -P "$_path" 1>/dev/null || return
  ls
}

#- - - - - - - - - - -

unicode() {
  if [ "$#" == "0" ] || [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo "usage: unicode f0 9f 8c b8"
    echo "...echoes $(echo -e \\xf0\\x9f\\x8c\\xb8)"
    echo "Warning: beware of invisible/control chars"
    return
  fi

  local spaceNumberPair args e='s/([0-9][0-9])/\1 /gm'

  args="$*"
  if [[ "$args" =~ , ]]; then
    args=${args//,/ }
  fi

  echo -en '\e[1;97m'
  for arg in $args; do
    if [[ "$((${#arg} % 2))" == 0 ]] && [ "${#arg}" != 2 ]; then
      spaceNumberPair=$(gsed --regexp-extended --expression="$e" <<<"$arg")
      for number in $spaceNumberPair; do
        echo -ne \\x"${number}"
      done
    else
      echo -ne \\x"$arg"
    fi
  done
  echo -e '\e[0m'
}

#- - - - - - - - - - -

findname() {
  if [ $# == "0" ]; then
    echo 'run find here ./ case-insensitive and glob around args'
    return
  fi
  local where=.
  local pattern="$1"
  if [ $# == "2" ]; then
    where="$1"
    pattern="$2"
  fi
  find "$where" -iname "*$pattern*"
}

#- - - - - - - - - - -

tra() {
  [ $# == 0 ] && return 1

  local last

  for pathToTrash in "$@"; do
    trash "$pathToTrash" || return
    last="$pathToTrash"
  done

  [[ $last =~ (.+)[/][^/]+$ ]]
  if [ -n "${BASH_REMATCH[1]}" ]; then
    ls "${BASH_REMATCH[1]}"
  else
    ls
  fi
}

#- - - - - - - - - - -

grepr() { #grep recursive
  if [ "$#" == "0" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    grepl -h
    echo "Also recursive. I.e. grep -r"
    return
  fi
  ggrep --color=auto -ri -E "$@" -l 2>/dev/null
}

#- - - - - - - - - - -

grepl() { #grep -l simply
  if [ "$#" == "0" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "grep -l case-insensitive, extended regex, on \$PWD, no error messages."
    return
  fi
  ggrep --color=auto -iE "$@" -l ./* .* 2>/dev/null
}

#- - - - - - - - - - -

bug() {
  set -x
  "$@"
  local functionExitStatus=$?
  set +x
  return $functionExitStatus
}

#- - - - - - - - - - -

sed-rm-html-tags() {
  gsed -Ee 's/<[^>]+>|<\/[^>]+>//gm' || echo error. Please cat an html file into this function.
}

#- - - - - - - - - - -

sed-rm-term-color-escapes() {
  gsed -Ee 's/\[[0-9][0-9]?m/ /gm' || echo error. Please cat terminal output into this function. TIP: caniuse-cli output
}

#- - - - - - - - - - -

tar7z() {
  if [ "$#" == 0 ] || [ "$1" == "-h" ]; then
    echo -e "Provide a file. foo -> foo.tar.7z \\n"
    return 1
  fi
  local safeArg=$1
  if [[ "$safeArg" =~ [/]$ ]]; then
    safeArg=${safeArg:0:-1}
  fi
  tar cf - "$safeArg" 2>/dev/null | 7za a -si -mx=7 "${safeArg}.tar.7z" 1>/dev/null
}

#- - - - - - - - - - -

rawgithub() {
  if [ "$#" == 0 ]; then
    echo "Provide url to clone from GitHub. Output is stdout."
    return 1
  fi
  local args="$*"
  args=${args/github/raw.githubusercontent}
  args=${args/\/raw\//\/}
  curl --silent "$args"
}

#- - - - - - - - - - -

# part of git prompt!
_git_log_prettily() {
  [ "$1" ] && git log --pretty="$1"
}

#- - - - - - - - - - -

aliasg() {
  [ ! "$1" ] && return
  alias | grep "$@"
}

#- - - - - - - - - - -

# Lazy git
lg() {
  _git() {
    # check for another git process running at this time (rare edge-case)
    # i.e. vscode; wait for it to finish
    while [ -f "$PWD/.git/index.lock" ]; do
      printf %s "lg > .git/index.lock exits, waiting..."
      sleep 1
    done

    command git "$@"
  }

  if ! command -v commitlint >/dev/null; then
    printf %s "lg > commitlint not found; please run 'npm install -g @commitlint/cli'"
    return 1
  fi

  if [ ! -f ~/.commitlintrc.yml ]; then
    printf %s "lg > ~/.commitlintrc.yml not found"
    return 1
  fi

  # commit

  manuallyStagedFiles=$(git diff --name-only --cached)

  if [ "$manuallyStagedFiles" ]; then
    printf %b "lg > comitting files already staged...\n"
  fi

  if [ ! "$manuallyStagedFiles" ] && ! _git add --all; then
    printf %s "lg > git add --all failed"
    return 1
  else
    manuallyStagedFiles=$(_git diff --name-only --cached)

    if [ ! "$manuallyStagedFiles" ]; then
      printf %s "lg > no staged files"
      return 1
    fi
  fi

  type="${1/:/}"
  scope="${2/:/}"
  subject="${*:3}"

  if [ ! "$type" ] || [ ! "$scope" ] || [ ! "$subject" ]; then
    printf %s "lg > usage: lg <type> <scope> <commit subject>"
    return 1
  fi

  commitMsg="$type($scope): $subject"
  if [ "$scope" == _ ]; then
    commitMsg="$type: $subject"
  fi

  if ! \commitlint --config ~/.commitlintrc.yml <<<"$commitMsg"; then
    return 1
  fi

  if _git commit -q -m "$commitMsg"; then
    printf "lg > %s\n" "$commitMsg"
  fi

  # push

  shouldPush=""

  if [[ $PUSH ]]; then
    shouldPush='true'
  fi

  if [ $shouldPush ]; then
    noUpstreamRegExp="has no upstream branch"
    pushResult=$(gp 2>&1)

    if [[ "$pushResult" =~ $noUpstreamRegExp ]]; then
      printf "lg > push error: No upstream. Running 'git push --set-upstream origin %s\n" "$GIT_BRANCH"
      _git push --set-upstream origin "$GIT_BRANCH"
    fi
  fi

  _git status -s
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
  local QQ && QQ=$(echo "$@" | tr ' ' '+')
  open "https://duckduckgo.com/?q=${QQ}&t=ffab&ia=web"
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

gco-() {
  if [ -n "$local_lil_flag" ]; then
    if git checkout "${GIT_BRANCH}-1"; then
      local_lil_old_branch="$GIT_BRANCH"
      unset local_lil_flag
    fi
    return
  fi
  if git checkout "$local_lil_old_branch"; then
    local_lil_flag='sdf'
  fi
}

#- - - - - - - - - - -

# base64 decode
base64-decode() {
  base64 -D <<<"$@"
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

gcn() {
  local shouldPush='true'
  if git add --all; then
    git commit -nm "$*"
  fi

  if [[ $DONTPUSH ]]; then
    shouldPush='false'
  fi

  if [ $shouldPush == 'true' ]; then
    # push branch, save output to detect errors
    pushResult=$(gp 2>&1)
    if [[ "$pushResult" =~ 'has no upstream branch' ]]; then
      # handle no upstream branch error
      echo "gcn > Push error: No upstream. Running 'git push --set-upstream origin $GIT_BRANCH'"
      git push --set-upstream origin "$GIT_BRANCH"
    fi
  fi
}

#- - - - - - - - - - -

gcom() {
  if ! git fetch --all --prune; then
    return
  fi

  branch=main
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

#- - - - - - - - - - -

__gen() {
  if ! find . -type f -iregex '.*mock_.*go$' -execdir rm -f {} \;; then
    echo "error running find regex exec rm on all mock* files"
    return 1
  fi

  echo "generating mocks..."
  godotenv -f .env go generate ./...
}

#- - - - - - - - - - -

qai() {
  baristai --use openai:gpt --prompt "$*"
}
