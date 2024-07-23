#!/usr/bin/env bash
#
# git commit hook lib

### vars and functions ###

spellcheck() {
  if ! output=$(cspell --unique . 2>&1); then
    tail -3 <<<"$output"
    return 1
  fi
}
