#! /usr/bin/env bash
# shellcheck disable=2155

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
  if [ "$#" == "0" ] || requested_help "$*"; then
    grepl -h
    echo "recursive."
    return
  fi

  grep --color=auto -ri -E "$@" -l 2>/dev/null
}

#- - - - - - - - - - -

grepl() {
  if [ "$#" == "0" ] || requested_help "$*"; then
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

jss() {
  if command jj status 2>/dev/null 1>&2; then
    command jj status
  else
    warn $LINENO "not a jj root"
    ls
  fi
}

# fix calling git status when there's no repo, call ls instead
gss() {
  jss

  # if command git status -s 2>/dev/null 1>&2; then
  #   command git status -s
  # else
  #   warn $LINENO "not a git repo"
  #   ls
  # fi
}

#- - - - - - - - - - -

grbonto() {
  if [ ! "$1" ] || requested_help "$*"; then
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
    log $LINENO "branch behind remote counterpart, pulling..."

    if ! git diff --quiet; then
      log $LINENO "you have unstaged changes"
      return
    fi

    git pull
  elif [[ "$checkout" =~ 'did not match any file' ]]; then
    log $LINENO "branch $branch does not exist, checkout manually"
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

table_info() {
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

#- - - - - - - - - - -

# lazy branch
lb() {
  local branch=$1

  if [ ! "$branch" ]; then
    echo "Usage: lb branch-name"
    echo "lb - lazy branch: Create a branch from main after pulling latest changes. Deletes the branch locally and remotely if it exists."
    return
  fi

  git checkout main
  git pull --quiet

  if ! git checkout -b "$branch" >/dev/null 2>&1; then
    git branch --delete --force "$branch"
    git push origin --delete "$branch" >/dev/null 2>&1
    git checkout -b "$branch"
  fi
}

#- - - - - - - - - - -

# question an AI, save dialogue, view with pager
qai() {
  if [ ! "$*" ]; then
    echo "Usage: qai \"what is the capital of france\""
    return
  fi

  local question="$*" dir=~/.question-ai now=$(date +%s)
  local filename=$(tr '[:upper:]' '[:lower:]' <<<"$question" | tr -d ' ,\?/'\''"`;')
  local filename_short=${filename:0:25}
  local dir_file="$dir/${now}_${filename_short}" existing_files=()

  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    chmod 700 "$dir"
  fi

  shopt -s nullglob

  # shellcheck disable=2206 # intentional globbing
  existing_files=(./*${filename_short})
  if [ ${#existing_files[@]} == 1 ]; then
    # shellcheck disable=2086 # intentional globbing
    less ${existing_files[0]}
    return
  fi

  touch "$dir_file"

  {
    echo "// $question"
    echo "// $now, $(date)"
    chatgpt "$*" 2>/dev/null
  } >>"$dir_file"

  less "$dir_file"
}

#- - - - - - - - - - -

# $1 current branch
# $2 branch to checkout
helper_g-() {
  if [ "$1" != "$2" ]; then
    git checkout "$2"
  else
    log $LINENO "branch '$2' is already checked out"
  fi
}

#- - - - - - - - - - -

# git checkout 2nd or 3rd ref in reflog that is not a main branch
# first line of reflog is 'from last branch to current branch', second line is 'from before last branch to last branch', etc...
g-() {
  local last_branch=$(git reflog | head -1 | sed -Ene "s/^.*from (.*) to .*$/\1/" -e "/commit|cherry/d" -e '1p')
  local before_last_branch=$(git reflog | head -2 | sed -Ene "s/^.*from (.*) to .*$/\1/" -e "/commit|cherry/d" -e '2p')
  local current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [ -z "$last_branch" ]; then
    warn $LINENO "last branch: '$last_branch' is empty. Doing nothing."
    return
  fi

  if [ "$last_branch" != "main" ] && [ "$last_branch" != "master" ]; then
    helper_g- "$current_branch" "$last_branch"
  else
    if [ -z "$before_last_branch" ]; then
      warn $LINENO "before last branch: '$before_last_branch' is empty. Doing nothing."
      return
    fi

    helper_g- "$current_branch" "$before_last_branch"
  fi
}

#- - - - - - - - - - -

# meant to be called in PROMPT_COMMAND
# args:
# $1 - pre vcs stuff
# $2 - post vcs stuff
# $3 - format string
vcs_prompt() {
  local pre="$1" post="$2"

  if command jj root &>/dev/null; then
    export PS1=$(printf %s%s%s "$pre" "$(jj_prompt)" "$post")
  else
    __git_ps1 "$@"
  fi
}

#- - - - - - - - - - -

jj_prompt() {
  local change_id description change_id_parent description_parent bookmarks=() temp temp2

  temp=$(command jj log --color=always --no-graph --limit 1 --template 'change_id.shortest()  ++" desc:"++ description ++" "++ parents.map(|c| c.change_id().shortest() ++" desc:"++ c.description()) ++" "++ description ++ "\n"')
  read -r change_id description change_id_parent description_parent <<<"$temp"

  # color=always produces strings unsuitable for anything but display, they contain escape sequences
  temp2=$(jj log --revisions 'ancestors(@) & bookmarks()' --template 'bookmarks ++ " "' --color=always --no-graph)
  read -ra bookmarks <<<"$temp2"

  # remove prefix to erase empty descriptions
  description=${description/desc:/}
  description_parent=${description_parent/desc:/}
  # set empty if second parent bookmark is main or master
  bookmarks[1]=${bookmarks[1]/main/}
  bookmarks[1]=${bookmarks[1]/master/}

  # local repo_root

  # if repo_root=$(command jj root 2>/dev/null); then
  #   track_jj_bookmarks "$repo_root" "${bookmarks[0]}"
  # fi

  local light_black="\\[\\e[33;90m\\]" green="\\[\\e[33;32m\\]"
  local format="${bookmarks[0]} ${bookmarks[1]} $green@$END$change_id $description $green@-$END$change_id_parent $light_black$description_parent$END"

  # strip double spaces
  format=${format//  / }

  printf %s "$format"
}

#- - - - - - - - - - -

# Track recent bookmarks per repo using a global var.
# track_jj_bookmarks() {
#   local repo="$1" current_bookmark="$2"

#   if [[ "$current_bookmark" == "main" || "$current_bookmark" == "master" ]]; then
#     return
#   fi

#   if [[ "${JJ_RECENT_BOOKMARK_MAP[$repo]+set}" == "" ]]; then
#     JJ_RECENT_BOOKMARK_MAP[$repo]=""
#   fi

#   local -a bookmarks=()
#   read -ra bookmarks <<<"${JJ_RECENT_BOOKMARK_MAP[$repo]}"

#   if [[ "${bookmarks[0]}" != "$current_bookmark" ]]; then
#     bookmarks=("$current_bookmark" "${bookmarks[@]}")
#   fi

#   if [ "${#bookmarks[@]}" -gt 7 ]; then
#     bookmarks=("${bookmarks[@]:0:7}")
#   fi

#   JJ_RECENT_BOOKMARK_MAP["$repo"]="${bookmarks[*]}"
# }

#- - - - - - - - - - -

# jj bookmark set private
# $1 - bookmark name
# $2 - revision
# $3 - additional arguments
__jj_bookmark_set() {
  jj bookmark set "$1" --revision "$2" "${@:3}"
}

# jj bookmark set on @
jjb() {
  if [[ $# == 0 ]]; then
    echo "jjb bookmark set on @"
    echo "'jjb foobar' jj bookmark set foobar --revision @"
    return
  fi

  __jj_bookmark_set "$1" @
}

# jj bookmark set on @-
jjb-() {
  if [[ $# == 0 ]]; then
    echo "jjb- bookmark set on @-"
    echo "'jjb- foobar' jj bookmark set foobar --revision @- --allow-backwards"
    return
  fi

  __jj_bookmark_set "$1" @- --allow-backwards
}

# jj rebase --source $1 --destination $2
jjrb() {
  if [[ $# != 2 ]]; then
    echo "jj rebase --source \$1 --destination \$2"
    return
  fi

  jj rebase --source "$1" --destination "$2"
}

# jj new <ref>@origin
jno() {
  if [[ $# != 1 ]]; then
    echo "jj new <ref>@origin"
    echo "runs git fetch"
    echo "adds '@origin' to your ref, then runs jj new"
    echo "runs jj bookmark track <ref>@origin"
    echo "runs jj bookmark <ref> @-"
    return
  fi

  git fetch --all --prune

  local refAt="$1@origin"

  jj new "$refAt"
  jj bookmark track "$refAt"
  __jj_bookmark_set "$1" @- --allow-backwards
}

#url decode and json format
urldecode_json() {
  if [ ! "$1" ]; then
    echo "urldecode_json '%7B%22foo%22%3A+%22bar%22%7D'"
    return
  fi

  python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$1" | jq
}