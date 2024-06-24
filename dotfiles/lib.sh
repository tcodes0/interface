#! /bin/bash
# Copyright 2024 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
#
# utilities sourced by scripts (non-interactively)
#

# internal, do not use
__e() {
  local linenum=${1:?} funcname=$2 msg=error

  if [ "${*:3}" ]; then
    msg=${*:3}
  fi

  log "$msg: $0":"$linenum" \("$funcname"\)
}

# usage: err $LINENO "message" (default message: error)
err() {
  __e "$1" "${FUNCNAME[1]}" "${*:2}"
}

#- - - - - - - - - - -

# usage: fatal $LINENO "message" (default message: error)
fatal() {
  __e "$1" "${FUNCNAME[1]}" "${*:2}"

  exit 1
}

#- - - - - - - - - - -

# usage: msgln hello world
msgln() {
  msg "$*\\n"
}

#- - - - - - - - - - -

# usage: msg hello world
msg() {
  echo -ne "${MSG_PREFIX:-}$*"
}

#- - - - - - - - - - -

# usage: log warning!
log() {
  echo -ne "${MSG_PREFIX:-}$*\\n" >&2
}
