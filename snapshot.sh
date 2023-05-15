#! /usr/bin/env bash

set -e

response=""
source=""
destination=""
today="$(date +%Y-%m-%d)"

echo "subvolumes in /toplevel owned by you:"
echo

find /toplevel -maxdepth 1 -user "$(whoami)" # will work for root also

echo
echo "snapshot source:"
read -r response

# if response is not in toplevel, echo error and exit
if [ -z "$response" ] || [ ! -d "/toplevel/$response" ]; then
  echo "error: /toplevel/$response is not a valid subvolume"
  exit 1
fi

source="$response"

echo "snapshot name, enter to use $source-$today:"
read -r response

# if no response or response is not a string, echo error and exit
if [ -z "$response" ]; then
  destination="$source-$today"
else
  destination="$response"
fi

btrfs subvolume snapshot "/toplevel/$source" "/toplevel/$destination"
