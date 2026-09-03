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

git() {
  # Only intercept `git fetch`
  if [[ $1 != fetch ]]; then
    command git "$@"
    return
  fi

  local fetch_head
  fetch_head=$(command git rev-parse --git-path FETCH_HEAD 2>/dev/null) || {
    # Not a git repository.
    command git "$@"
    return
  }

  if [[ -f $fetch_head ]]; then
    local now last age
    local threshold=${GIT_FETCH_MIN_INTERVAL:-180} # default to 3 minutes

    now=$(date +%s)
    last=$(stat -c %Y "$fetch_head" 2>/dev/null ||
      stat -f %m "$fetch_head")
    age=$((now - last))

    if ((age < threshold)); then
      warn $LINENO "Last fetch was $age seconds ago, skipping. Use \"command git fetch\" to bypass this check."
      return 0
    fi
  fi

  command git "$@"
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

gd() {
  if ! command jj root &>/dev/null; then
    command git diff "$@"
    return $?
  fi

  command jj diff "$@"
}

#- - - - - - - - - - -

# when there's no repo, call ls instead
gss() {
  if ! command jj root &>/dev/null; then
    _git_gss
    return $?
  fi

  if command jj root &>/dev/null; then
    command jj status
  else
    warn $LINENO "not a jj root"
    ls
  fi

}

#- - - - - - - - - - -

_git_gss() {
  if command git status -s 2>/dev/null 1>&2; then
    command git status -s
  else
    warn $LINENO "not a git repo"
    ls
  fi
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

_git_gcom() {
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

gcom() {
  if ! command jj root &>/dev/null; then
    _git_gcom "$@"
    return $?
  fi

  jnm
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
  local change_id description change_id_parent description_parent jj_bookmarks=() temp

  temp=$(command jj log --color=always --no-graph --limit 1 --template 'change_id.shortest()  ++" desc:"++ description ++" "++ parents.map(|c| c.change_id().shortest() ++" desc:"++ c.description()) ++" "++ description ++ "\n"')
  read -r change_id description change_id_parent description_parent <<<"$temp"

  # color=always produces strings unsuitable for anything but display, they contain escape sequences
  read -ra jj_bookmarks < <(__jj_bookmarks always)

  # remove prefix to erase empty descriptions
  description=${description/desc:/}
  description_parent=${description_parent/desc:/}
  # set empty if second parent bookmark is main or master
  jj_bookmarks[1]=${jj_bookmarks[1]/main/}
  jj_bookmarks[1]=${jj_bookmarks[1]/master/}

  local light_black="\\[\\e[33;90m\\]" green="\\[\\e[33;32m\\]"
  local format="${jj_bookmarks[0]} ${jj_bookmarks[1]} $green@$END$change_id $description $green@-$END$change_id_parent $light_black$description_parent$END"

  # strip double spaces
  format=${format//  / }

  printf %s "$format"
}

#- - - - - - - - - - -

# jj bookmark set private
# $1 - bookmark name
# $2 - revision
# $3 - additional arguments
__jj_bookmark_set() {
  jj bookmark set "$1" --revision "$2" "${@:3}"
}

#----------------

# jj bookmark set on @
jb() {
  if [[ $# == 0 ]]; then
    echo "jb bookmark set on @"
    echo "'jb foobar' jj bookmark set foobar --revision @"
    return
  fi

  __jj_bookmark_set "$1" @
}

#----------------

# jj bookmark set on @ with today's date, e.g. may-3-1423
jbn() {
  __jj_bookmark_set "$(date +%b-%-d-%H%M | tr '[:upper:]' '[:lower:]')" @
}

#----------------

# jj bookmark set on @- with today's date, e.g. may-3-1423
jbn-() {
  __jj_bookmark_set "$(date +%b-%-d-%H%M | tr '[:upper:]' '[:lower:]')" @- --allow-backwards
}

#----------------

# jj bookmark set on @-
jb-() {
  if [[ $# == 0 ]]; then
    echo "jb- bookmark set on @-"
    echo "'jb- foobar' jj bookmark set foobar --revision @- --allow-backwards"
    return
  fi

  __jj_bookmark_set "$1" @- --allow-backwards
}

#----------------

# jj bookmark track --remote=origin
jbt() {
  if [[ $# == 0 ]]; then
    echo "jbt <bookmark> — jj bookmark track <bookmark> --remote=origin"
    return
  fi

  jj bookmark track "$1" --remote=origin
}

#----------------

# jj rebase --source $1 --destination $2
jrb() {
  if [[ $# != 2 ]]; then
    echo "jj rebase --source \$1 --destination \$2"
    return
  fi

  jj rebase --source "$1" --destination "$2"
}

#----------------

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

  jj git fetch

  local refAt="$1@origin"

  jj new "$refAt"
  jj_working_bookmark_set "$refAt"
  jj bookmark track "$refAt"
  __jj_bookmark_set "$1" @- --allow-backwards
}

#----------------

jnm() {
  if ! command jj root &>/dev/null; then
    _git_gcom
    return $?
  fi

  if ! jj git fetch; then
    return
  fi

  jj new main
}

#----------------

jnd() {
  if ! command jj root &>/dev/null; then
    _git_gcom
    return $?
  fi

  if ! jj git fetch; then
    return
  fi

  jj new dev
}

#----------------

jn() {
  if [ -z "$1" ]; then
    err $LINENO "Usage: jn <bookmark or ref>"
    return 1
  fi

  jj git fetch --quiet
  jj new "$1"
  jj_working_bookmark_set "$1"
}

#----------------

# todo: remove
unalias jd 2>/dev/null
jd() {
  if [ -z "$1" ]; then
    err $LINENO "Usage: jd <ref>"
    return 1
  fi

  jj diff -r "$1" -r @
}

#----------------

__npc() {
  local branch=$1 backwards_flag="$2" today_date=$(date +"%b-%d" | tr '[:upper:]' '[:lower:]') prefix=px

  if [ "$backwards_flag" == "-" ]; then
    jb- "$prefix-$1-$today_date"
  else
    jb "$prefix-$1-$today_date"
  fi
}

#----------------

# new PC ticket bookmark on @
npc() {
  if [[ $# != 1 ]]; then
    echo "runs jj bookmark set px-<ticket number> @"
    echo "sufixes with today's date"
    return
  fi

  __npc "$1"
}

#----------------

# new PC ticket bookmark on @-
npc-() {
  if [[ $# != 1 ]]; then
    echo "runs jj bookmark set px-<ticket number> @-"
    echo "sufixes with today's date"
    return
  fi

  __npc "$1" -
}

#----------------

# url decode and json format
urldecode_json() {
  if [ ! "$1" ]; then
    echo "urldecode_json '%7B%22foo%22%3A+%22bar%22%7D'"
    return
  fi

  python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$1" | jq
}

#----------------

save_session() {
  echo "$PWD" "$@" >>"$HOME/Desktop/txt/sessions.txt"
}

restore_session() {
  local dir="$PWD"
  local command
  command=$(command grep "^$dir " "$HOME/Desktop/txt/sessions.txt" | sed "s|^$dir ||")

  if [[ -z "$command" ]]; then
    echo "no session found for $dir"
    claude
  fi

  eval "$command"
}

#----------------

lg() {
  if ! command jj root &>/dev/null; then
    lazy-git "$@"
    return $?
  fi

  lazy-jujutsu "$@"
  return $?
}

#----------------

__jj_basename() {
  local root
  root=$(jj root 2>/dev/null) || return 1
  basename "$root"
}

#----------------

jj_working_bookmark_get() {
  local JJ_WORKING_BOOKMARK_CONFIG_FILE="$HOME/.config/github.com.rthomazel/.jjbookmarksrc"
  local project cached
  project=$(__jj_basename) || {
    warn $LINENO "failed to get jj project root"
    return 1
  }

  if [ -f "$JJ_WORKING_BOOKMARK_CONFIG_FILE" ]; then
    cached=$(awk -v key="$project" '$1 == key { print $2; exit }' "$JJ_WORKING_BOOKMARK_CONFIG_FILE")
  fi

  if [ -n "$cached" ]; then
    printf "%s" "$cached"
    return
  fi

  local bookmark
  bookmark=$(jj_bookmark0)

  if [ -z "$bookmark" ]; then
    warn $LINENO "empty bookmark ref, bookmarks: $(__jj_bookmarks)"
    return 1
  fi

  printf "%s" "$bookmark"
}

#----------------

jj_working_bookmark_set() {
  local JJ_WORKING_BOOKMARK_CONFIG_FILE="$HOME/.config/github.com.rthomazel/.jjbookmarksrc"
  local bookmark="$1" project
  bookmark="${bookmark%@origin}"
  project=$(__jj_basename) || {
    warn $LINENO "failed to get jj project root"
    return 1
  }

  mkdir -p "$(dirname "$JJ_WORKING_BOOKMARK_CONFIG_FILE")"
  touch "$JJ_WORKING_BOOKMARK_CONFIG_FILE"

  if grep -q "^${project}[[:space:]]" "$JJ_WORKING_BOOKMARK_CONFIG_FILE"; then
    sed -i "s|^${project}[[:space:]].*|${project}\t${bookmark}|" "$JJ_WORKING_BOOKMARK_CONFIG_FILE"
  else
    printf "%s\t%s\n" "$project" "$bookmark" >>"$JJ_WORKING_BOOKMARK_CONFIG_FILE"
  fi
}

#----------------

# jj "git pull" variable is set by jj new wrappers.
jl() {
  if ! command jj root &>/dev/null; then
    git pull
    return
  fi

  local bookmark=${1:-}

  if [ -z "$bookmark" ]; then
    bookmark=$(jj_working_bookmark_get) || return 1
  fi

  jj_working_bookmark_set "$bookmark"
  jj git fetch
  jj new "${bookmark}@origin"
}

#----------------

# git merge origin/main, handles jj
gmom() {
  if ! command jj root &>/dev/null; then
    git fetch --all --prune && git merge -q origin/main
    return $?
  fi

  git fetch --all --prune && git merge -q origin/main

  local b
  b=$(jj_bookmark0)

  if [ -n "$b" ]; then
    jb- "$b"

    if in_push_repos; then
      jj git push --option quiet
    fi
  fi
}

#----------------

# cat and copy to clipboard a prompt file under the prompts directory.
# If an argument is given, it is used as a prefix to find the prompt file.
# If no argument is given, lists available prompt files without extensions.
prompt() {
  local dir="$HOME/Desktop/interface/doc/prompts"
  if [[ -n "$1" ]]; then
    local file
    file=$(find "$dir" -maxdepth 1 -type f -name "$1*" | head -1)

    if [[ -n "$file" ]]; then
      command cat "$file"
      pbc < <(cat "$file")
    else
      while IFS= read -r f; do
        basename "$f" | sed 's/\.[^.]*$//'
      done < <(find "$dir" -maxdepth 1 -type f)
    fi
  else
    while IFS= read -r f; do
      basename "$f" | sed 's/\.[^.]*$//'
    done < <(find "$dir" -maxdepth 1 -type f)
  fi
}

#----------------

inf() {
  local rc="$HOME/.config/github.com.rthomazel/.infrc"
  local project SECRETS_HOST=secrets.golang.dev.br
  project=$(basename "$PWD")

  if ! timeout 2 infisical user get token >/dev/null 2>&1; then
    echo "[ERR] infisical not logged in, run 'infisical login' first"
    exit 1
  fi

  echo connecting to "$SECRETS_HOST" please wait...
  if ! timeout 120 bash -c "until ping -c 1 -W 1 $SECRETS_HOST > /dev/null 2>&1; do sleep 1; done"; then
    echo "[ERR] $SECRETS_HOST timeout, aborting"
    exit 1
  fi

  if [[ ! -f "$rc" ]]; then
    infisical "$@"
    return
  fi

  local project_id
  project_id=$(grep "^${project}:" "$rc" | awk '{print $2}')

  if [[ -n "$project_id" ]]; then
    infisical "$@" --projectId="$project_id"
  else
    infisical "$@"
  fi
}

#----------------

bad_vast_host() {
  case "$1" in
  145602)
    echo "shit. slow internet"
    ;;
  *)
    echo "ok"
    ;;
  esac
}
