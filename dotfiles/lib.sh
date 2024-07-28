#! /usr/bin/env bash
# Copyright 2024 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
#
# utilities sourced by scripts
#

# internal, do not use
__e() {
  local linenum=${1:?} funcname=$2 msg=ERROR

  if [ "${*:3}" ]; then
    msg=${*:3}
  fi

  echo -ne "$msg $0:$linenum ($funcname)" >&2
}

# usage: err $LINENO "message" (default message: error)
err() {
  __e "$1" "${FUNCNAME[1]}" "${*:2}"
}

#- - - - - - - - - - -

# usage: fatal $LINENO "message" (default message: error)
fatal() {
  __e "$1" "${FUNCNAME[1]}" "FATAL: ${*:2}"

  exit 1
}

#- - - - - - - - - - -

# usage: println hello world
println() {
  print "$*\\n"
}

#- - - - - - - - - - -

# usage: print hello world
print() {
  echo -ne "$*"
}

#- - - - - - - - - - -

# internal, do not use
__log() {
  local level=$1 linenum=${2:?} msg=${*:3}

  if [ "$msg" ]; then
    echo -ne "$level ($0:$linenum) $msg\\n" >&2
  fi
}

#- - - - - - - - - - -

# usage: loginfo $LINENO your pizza is ready
loginfo() {
  __log INFO "$@"
}

#- - - - - - - - - - -

# usage: logwarn $LINENO pizza is too long in oven
logwarn() {
  __log WARNING "$@"
}
