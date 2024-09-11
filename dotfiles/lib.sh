#! /usr/bin/env bash
# Copyright 2024 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
#
# Library of shell functions and vars.
# This script is sourced by path from other scripts, careful if moving or renaming it.
# Sourcing this library causes side effects only to library variables.

############
### vars ###
############

# ANSI escape codes for visual formatting
export LIB_VISUAL_END="\e[0m"
export LIB_FORMAT_DIM="\e[2m"
export LIB_COLOR_DARK_GRAY="\e[38;05;8m"

# on most systems, sed is GNU sed
export SED="sed"

###############
### private ###
###############

# internal, do not use
__log() {
  local level=$1 linenum=${2:-} msg=${*:3}

  if [ ! "$linenum" ]; then linenum="?"; fi

  echo -e "$level ($0:$linenum) $msg"
} >&2

#################
### functions ###
#################

# Description: Reports whether the current OS is macOS
# Example    : if macos; then echo "yes"; fi
macos() {
  [ "$(uname)" == "Darwin" ]
}

# Description: Print a message without a newline
# Args       : Any
# STDOUT     : Message
# Example    : msg hello world
msg() {
  echo -ne "$*"
}

# Description: Print a message with a newline
# Args       : Any
# STDOUT     : Message + \n
# Example    : msg hello world
msgln() {
  msg "$*\\n"
}

# Description: Log a message with INFO level and line number
# Args       : Any
# STDERR     : INFO (pizza.sh:34) message + \n
# Example    : log $LINENO pizza order received
log() {
  __log INFO "$@"
}

# Description: Log a message with DEBUG level and line number
# Globals    : T0_COLOR (env) colored output if "true"
# Args       : Any
# STDERR     : INFO (pizza.sh:34) message + \n
# Example    : log $LINENO pizza order received
debug() {
  if [ "${T0_COLOR:-}" == "true" ]; then
    __log "${LIB_COLOR_DARK_GRAY}DEBUG" "$@" "${LIB_VISUAL_END}"
  else
    __log DEBUG "$@"
  fi
}

# Description: Log a message with ERROR level and line number
# Args       : Any
# STDERR     : ERROR (pizza.sh:34) message + \n
# Example    : err $LINENO oven temperature too high
err() {
  __log ERROR "$@"
}

# Description: Calls err with args, then exits with status 1
# Args       : Any
# STDERR     : FATAL (pizza.sh:34) message + \n
# Example    : fatal $LINENO we've run out of cheese
fatal() {
  __log FATAL "$@"
  exit 1
}

# Description: Reports whether the user provided a standard help flag
# Args       : $@
# Example    : if requested_help "$*"; then echo "help"; fi
requested_help() {
  [[ "$*" =~ -h|--help|help ]]
}

####################
### side effects ###
####################

if macos; then
  # on macOS, this library assumes gsed is installed.
  # BSD sed is very different from GNU sed
  SED="gsed"
fi

############################################################################################
### this lib should be kept in sync with https://github.com/tcodes0/sh/blob/main/lib.sh  ###
###                     with its own additions below this box                            ###
############################################################################################

# Description: Reports whether the shell is in a terminal emulator or console
# Example    : if term_emulator; then echo "yes"; fi
term_emulator() {
  [[ $(tty) =~ /dev/pts ]]
}

# Description: Reports whether the user is me (and not root for example)
# Example    : if is_me; then echo "yes"; fi
is_me() {
  [[ "$(whoami)" =~ vacation|thom.ribeiro ]]
}
