#! /usr/bin/env bash

rand_256_color() {
  local color
  color=$(echo -n $((RANDOM % 231)))

  while :; do
    color=$((RANDOM % 231))
    if [ "$color" -gt 17 ] && [ "$color" -lt 232 ]; then
      echo -ne "\\e[38;05;${color}m"
      return
    fi
  done
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
    decorations=$SECONDARY_COLOR"~>"$spacer$END
  else
    decorations=$SECONDARY_COLOR"#>"$spacer$END
  fi

  local horizontal_line="\n"
  local workdir="$MAIN_COLOR\\w$END" host_name=""

  if macos; then
    host_name=$(hostname)
  else
    host_name=$(hostnamectl hostname)
  fi

  local current_host="" known_host=false

  for k_host in "${KNOWN_HOSTS[@]}"; do
    if [[ "$k_host" == "$host_name" ]]; then
      known_host=true

      break
    fi
  done

  if ! $known_host; then
    current_host="$SECONDARY_COLOR@$host_name$END"
    decorations=$SECONDARY_COLOR"*>"$spacer$END
  fi

  case "$1" in
  "pre") printf %s "${horizontal_line}${workdir}${current_host} " ;;
  "post") printf %s "\\n${decorations}" ;;
  *) printf %s "${horizontal_line}${workdir}\\n${decorations}" ;;
  esac
}

END=$(tput sgr0)
MAIN_COLOR="\\[$(rand_256_color)\\]"
SECONDARY_COLOR="\\[$(rand_256_color)\\]"
