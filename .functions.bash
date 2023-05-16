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

# LAZY GIT
# with commitlint automation. Does git add --all:
lg() {
  ######################
  ## index management ##
  ######################

  local manually_staged_files=""
  manually_staged_files=$(git diff --name-only --cached)

  checkGitLock() {
    # check for another git process running at this time (rare edge-case)
    # i.e. vscode and wait for it to finish
    while [ -f "$PWD/.git/index.lock" ]; do
      echo "lg > .git/index.lock exits, waiting..."
      sleep 1
    done
  }

  # feedback that manually added files will be commited
  if [ "$manually_staged_files" ]; then
    echo "lg > comitting files already staged..."
  fi

  local response="y"
  # confirm automatic add in advance, to avoid mistakes
  # if already staged files manually, skip
  if [ "$CONFIRMADD" ] && [ ! "$manually_staged_files" ]; then
    if [ ! "$SKIPADD" ]; then
      echo "lg > running 'git add --all', ok? (y/n)"
      read -r response
    fi
  fi

  checkGitLock
  # git add --all, if fail exit. Check for prompt response, check for files already added                         *adding files here*
  if [ ! "$SKIPADD" ] && [ ! "$manually_staged_files" ] && { [ "$response" == Y ] || [ "$response" == y ]; } && ! git add --all; then
    echo "lg > auto add off or opted-out of or 'git add --all' failed"
    return 1

  else
    # pick up newly added files in block above
    manually_staged_files=$(git diff --name-only --cached)

    if [ ! "$manually_staged_files" ]; then
      echo "lg > no staged files, and auto add opted-out of"
      return 1
    fi
  fi

  unset SKIPADD

  if [ "$*" ]; then
    local message=""
    message="$*"

    if [ "$WIPCOMMIT" ]; then
      message="${message} [skip ci]"
      unset WIPCOMMIT
    fi

    echo "lg > commit message: $message"
    checkGitLock
    git commit -q -m "$message"

  else
    checkGitLock
    git commit -q -v
  fi

  ##########
  ## push ##
  ##########

  local shouldPush='true'

  if [ "$GIT_UPSTREAM" ] && [[ origin/develop =~ $GIT_UPSTREAM ]] && [ ! "$PUSHTOMAIN" ]; then
    shouldPush='false'
  fi

  if [ "$GIT_UPSTREAM" ] && [[ origin/main =~ $GIT_UPSTREAM ]] && [ ! "$PUSHTOMAIN" ]; then
    shouldPush='false'
  fi

  if [[ -1 =~ $GIT_BRANCH ]]; then
    shouldPush='false'
  fi

  if [[ $DONTPUSH ]]; then
    shouldPush='false'
  fi

  if [[ "$PWD" =~ member-server$|server$|member-client$|client$ ]]; then
    shouldPush='false'
  fi

  if [ $shouldPush == 'true' ]; then
    local pushResult=""
    # push branch, save output to detect errors
    pushResult=$(gp 2>&1)

    if [[ "$pushResult" =~ 'has no upstream branch' ]]; then
      # handle no upstream branch error
      echo "lg > push error: No upstream. Running 'git push --set-upstream origin $GIT_BRANCH'"
      git push --set-upstream origin "$GIT_BRANCH"
    fi
  fi

  gss
}

# to alias lg do something else alias _lg instead
_lg() {
  lg "$@"
}

#- - - - - - - - - - -

#lazy commit
gcmsg() {
  if [ "$*" ]; then
    git commit -q -m "$*"
  else
    git commit -q -v
  fi
  gss
}

#- - - - - - - - - - -

#git tag push
gtp() {
  if git tag "$1"; then
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
  checkout=$(git checkout main 2>&1)
  if [[ "$checkout" =~ 'can be fast-forwarded' ]]; then
    echo "gcom > Branch behind remote counterpart, pulling..."
    gl
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
  if [ $# == "0" ]; then
    echo "usage: qai <prompt>"
    return 1
  fi

  if [ -z "$OPENAI_API_KEY" ]; then
    echo "\$OPENAI_API_KEY not found in env"
    return 1
  fi

  echo -en "$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$*\"}]
  }" |
    jq '.choices[0].message.content')"
}
