#! /usr/bin/env bash

# Mac aliases

#####################################################
# If not running interactively, skip remaining code #
#####################################################
[[ $- != *i* ]] && return

alias ele-db-select="go run $HOME/Desktop/scripts/db-select/main.go"
alias .i="cd \$DOTFILE_PATH"