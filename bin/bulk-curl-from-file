#!/usr/bin/env bash

usage() {
  echo "\
  Usage
    bulk-curl-from-file.sh <file-path>
      read lines from file and pass them as args to command
      file-path IS RELATIVE
  "
}

if [ "$#" -lt 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
  exit 1
fi

file=$1
filePath=${PWD}/$file

if [ ! -f "$filePath" ]; then
  usage
  echo "File $filePath not found\\n"
  exit 1
fi

setName=${file/.txt/}
i=1

while read -r line; do
  eval "curl '$line' -L -o '${setName}-${i}.jpg'"
  i=$((i+1))
done <"$filePath"

exit $?
