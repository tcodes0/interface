#! /usr/bin/env bash

rand_256_color() {
  local c
  c=$(echo -n $((RANDOM % 231)))
  if [ "$c" -le 17 ] || [ "$c" -ge 232 ]; then
    # bad constrast colors, get another one
    rand_256_color
  else
    echo -ne "\\e[38;05;${c}m"
  fi
}

export_columns() {
  if [ ! "$COLUMNS" ]; then
    if command -v tput 2>/dev/null 1>&2; then
      COLUMNS="$(tput cols | tr -d \\n)"
      export COLUMNS
    fi
  fi
}

# args $1: "pre" "post" or "", used to integrate with vcs information
#  $pre_prompt <git stuff> $post_prompt
#  empty: just the prompt
make_ps1() {

  export_columns

  local spacer=' '

  if is_me; then
    decorations=$SECOND_COLOR"~>"$spacer$END
  else
    decorations=$SECOND_COLOR"#>"$spacer$END
  fi

  local horizontal_line="\n"
  local workdir="$MAIN_COLOR\\w$END" host_name=""

  if macos; then
    host_name=$(hostname)
  else
    host_name=$(hostnamectl hostname)
  fi

  local current_host=""

  if [[ ! ${KNOWN_HOSTS[*]} =~ $host_name ]]; then
    current_host="$SECOND_COLOR@$host_name$END"
    decorations=$SECOND_COLOR"*>"$spacer$END
  fi

  case "$1" in
  "pre") printf %s "${horizontal_line}${workdir}${current_host} " ;;
  "post") printf %s "\\n${decorations}" ;;
  *) printf %s "${horizontal_line}${workdir}\\n${decorations}" ;;
  esac
}

END="\\[\\e[0m\\]"
MAIN_COLOR="\\[$(rand_256_color)\\]"
SECOND_COLOR="\\[$(rand_256_color)\\]"
