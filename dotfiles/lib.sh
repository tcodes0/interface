#! /usr/bin/env bash
# Copyright 2024 Raphael Thomazella. All rights reserved.
# Use of this source code is governed by the BSD-3-Clause
# license that can be found in the LICENSE file and online
# at https://opensource.org/license/BSD-3-clause.
#
# Library of shell functions and vars.
# This script is sourced by path from other scripts, careful if moving or renaming it.
# Sourcing this library causes side effects only to library variables.
#
# this lib should be kept in sync with https://github.com/tcodes0/sh/blob/main/lib.sh

############
### vars ###
############

# ANSI escape codes for visual formatting
export LIB_VISUAL_END="\e[0m"
export LIB_FORMAT_DIM="\e[2m"

# ANSI escape codes for specific colors
export LIB_COLOR_DARK_GRAY="\e[38;05;8m"
export LIB_COLOR_RED="\e[38;05;124m"
export LIB_COLOR_YELLOW="\e[38;05;214m"
export LIB_COLOR_RED_BRIGHT="\e[38;05;197m"

# on most systems, sed is GNU sed
# on macOS, this variable should be set to gsed
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
  if [ "${T0_COLOR:-}" == "true" ]; then
    __log "${LIB_COLOR_DARK_GRAY}INFO" "$@" "${LIB_VISUAL_END}"
  else
    __log INFO "$@"
  fi
}

# Description: Log a message with DEBUG level and line number
# Globals    : T0_COLOR (env) colored output if "true"
# Args       : Any
# STDERR     : INFO (pizza.sh:34) message + \n
# Example    : log $LINENO inside for loop
debug() {
  if [ "${T0_COLOR:-}" == "true" ]; then
    __log "${LIB_COLOR_DARK_GRAY}DEBUG" "$@" "${LIB_VISUAL_END}"
  else
    __log DEBUG "$@"
  fi
}

# Description: Log a message with ERROR level and line number
# Globals    : T0_COLOR (env) colored output if "true"
# Args       : Any
# STDERR     : ERROR (pizza.sh:34) message + \n
# Example    : err $LINENO oven temperature too high
err() {
  if [ "${T0_COLOR:-}" == "true" ]; then
    __log "${LIB_COLOR_RED}ERROR" "$@" "${LIB_VISUAL_END}"
  else
    __log ERROR "$@"
  fi
}

# Description: Log a message with ERROR level and line number
# Globals    : T0_COLOR (env) colored output if "true"
# Args       : Any
# STDERR     : WARN (pizza.sh:34) message + \n
# Example    : err $LINENO cheese is dripping
warn() {
  if [ "${T0_COLOR:-}" == "true" ]; then
    __log "${LIB_COLOR_YELLOW}WARN" "$@" "${LIB_VISUAL_END}"
  else
    __log WARN "$@"
  fi
}

# Description: Calls err with args, then exits with status 1
# Globals    : T0_COLOR (env) colored output if "true"
# Args       : Any
# STDERR     : FATAL (pizza.sh:34) message + \n
# Example    : fatal $LINENO we've run out of cheese
fatal() {
  if [ "${T0_COLOR:-}" == "true" ]; then
    __log "${LIB_COLOR_RED_BRIGHT}FATAL" "$@" "${LIB_VISUAL_END}"
  else
    __log FATAL "$@"
  fi
  exit 1
}

# Description: Reports whether the user provided a standard help flag
# Args       : $@
# Example    : if requested_help "$*"; then echo "help"; fi
requested_help() {
  [[ "$*" =~ [[:blank:]]+-h[[:blank:]]+|[[:blank:]]+--help[[:blank:]]+|[[:blank:]]+help[[:blank:]]+ ]]
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
  if macos; then
    # on macOS we're always in emulator
    return
  fi

  [[ $(tty) =~ /dev/pts ]]
}

# Description: Reports whether the user is me (and not root for example)
# Example    : if is_me; then echo "yes"; fi
is_me() {
  [[ "$(whoami)" =~ vacation|thom.ribeiro ]]
}
