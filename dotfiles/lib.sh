#! /bin/bash
# Copyright 2024 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
#
# utilities sourced by scripts (non-interactively)
#

# usage: err $LINENO "message" (default message: error)
err() {
  local linenum=$1 msg=error

  if [ "${*:2}" ]; then
    msg=${*:2}
  fi

  echo "$msg: $0":"$linenum" \("${FUNCNAME[1]}"\) >&2
}

#- - - - - - - - - - -

# usage: fatal $LINENO "message" (default message: error)
fatal() {
  local linenum=$1 msg=error

  if [ "${*:2}" ]; then
    msg=${*:2}
  fi

  echo "$msg: $0":"$linenum" \("${FUNCNAME[1]}"\) >&2

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
