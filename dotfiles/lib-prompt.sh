#! /bin/bash

random256Color() {
  local c && c=$(echo -n $((RANDOM % 231)))
  # bad constrast colors, get another one
  if [ "$c" -le 17 ] || [ "$c" -ge 232 ]; then
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

  # colors
  local spacer horizontalLine workdir
  spacer=' '

  getTermColumns

  if [ "$(whoami)" != "root" ]; then
    decorations=$AUXILIAR_COLOR"~>"$spacer$END
  else
    decorations=$AUXILIAR_COLOR"#>"$spacer$END
  fi

  horizontalLine="\n"
  workdir="$MAIN_COLOR\\w$END"
  hostname=""

  if [[ ! ${KNOWN_HOSTS[*]} =~ $(hostname) ]]; then
    hostname="$AUXILIAR_COLOR@$(hostname)$END"
    decorations=$AUXILIAR_COLOR"*>"$spacer$END
  fi

  case "$1" in
  "preGit") printf %s "${horizontalLine}${workdir}${hostname} " ;;
  "postGit") printf %s "\\n${decorations}" ;;
  *) printf %s "${horizontalLine}${workdir}\\n${decorations}" ;;
  esac
}

END="\\[\\e[0m\\]"
MAIN_COLOR="\\[$(random256Color)\\]"
AUXILIAR_COLOR="\\[$(random256Color)\\]"
