#! /usr/bin/env bash

#- - - - - - - - - - -

func_echo() {
  # 0 is func_echo itself
  echo "${FUNCNAME[1]}> $*"
}

#- - - - - - - - - - -

today-date() {
  local fhelp="
today-date
set or read today's date from a file
usage examples:
today-date write ~/file
today-date read ~/file
today-date -h
"

  case $1 in
  write | read)
    local mode="$1"
    ;;
  -h | --help)
    echo "$fhelp"
    ;;
  *)
    func_echo "wanted write, read or -h, as \$1, got: $1"
    return 1
    ;;
  esac

  if [ ! "$2" ]; then
    func_echo "missing arg \$2, wanted a file"
    return 1
  fi
  local file="$2"

  if [ "$mode" == "write" ]; then
    if ! date +%D >"$file"; then
      func_echo "error: saving date to $file"
      return 1
    fi
  elif [ "$mode" == "read" ]; then
    local rawdate pdate today

    rawdate=$(cat "$file")
    if [ ! "$rawdate" ]; then
      func_echo "error: cat $file"
      return 1
    fi
    if [[ ! $rawdate =~ ^[0-9][0-9][/][0-9][0-9][/][0-9][0-9]$ ]]; then
      func_echo "error: invalid date from $file. Wanted mm/dd/yy, got: $rawdate"
      return 1
    fi

    pdate=$(date --date="$rawdate" +%D)
    if [ ! "$pdate" ]; then
      func_echo "error: date --date=$rawdate"
      return 1
    fi
    today=$(date +%D)

    if [ "$pdate" != "$today" ] && [ "$pdate" ] && [ "$today" ]; then
      echo -e "Date from file\t\t$pdate"
      echo -e "Today\t\t\t$today"
      echo "What do you want to do? Type enter to continue, anything else to exit"
      echo "Aborting in 20s"
      read -rt 20
      if [ "$REPLY" != "" ]; then
        echo "$REPLY"
        exit 1
      fi
    elif [ "$pdate" == "$today" ]; then
      echo "Date from $file is today"
    else
      func_echo "error: logic fell through"
      return 1
    fi
  fi
}
