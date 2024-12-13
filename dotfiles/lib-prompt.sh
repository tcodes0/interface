#! /usr/bin/env bash

random256Color() {
  local c
  c=$(echo -n $((RANDOM % 231)))
  if [ "$c" -le 17 ] || [ "$c" -ge 232 ]; then
    # bad constrast colors, get another one
    random256Color
  else
    echo -ne "\\e[38;05;${c}m"
  fi
}

getTermColumns() {
  if [ ! "$COLUMNS" ]; then
    if command -v tput 2>/dev/null 1>&2; then
      COLUMNS="$(tput cols | tr -d \\n)"
      export COLUMNS
    fi
  fi
}

makePS1() {
  # use "preGit" or "postGit" as arg 1 to integrate with gitprompt script

  local spacer=' ' horizontal_line workdir current_host="" host_name=""

  getTermColumns

  if is_me; then
    decorations=$SECOND_COLOR"~>"$spacer$END
  else
    decorations=$SECOND_COLOR"#>"$spacer$END
  fi

  horizontal_line="\n"
  workdir="$MAIN_COLOR\\w$END"

  if macos; then
    host_name=$(hostname)
  else
    host_name=$(hostnamectl hostname)
  fi

  if [[ ! ${KNOWN_HOSTS[*]} =~ $host_name ]]; then
    current_host="$SECOND_COLOR@$host_name$END"
    decorations=$SECOND_COLOR"*>"$spacer$END
  fi

  case "$1" in
  "preGit") printf %s "${horizontal_line}${workdir}${current_host} " ;;
  "postGit") printf %s "\\n${decorations}" ;;
  *) printf %s "${horizontal_line}${workdir}\\n${decorations}" ;;
  esac
}

END="\\[\\e[0m\\]"
MAIN_COLOR="\\[$(random256Color)\\]"
SECOND_COLOR="\\[$(random256Color)\\]"
