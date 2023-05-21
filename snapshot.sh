#! /usr/bin/env bash

set -e

echo "subvolumes in /toplevel owned by you:"
echo

find /toplevel -maxdepth 1 -user "$(whoami)" # will work for root also

echo
echo "snapshot source:"

response=""
read -r response

# if response is not in toplevel, echo error and exit
if [ -z "$response" ] || [ ! -d "/toplevel/$response" ]; then
  echo "error: /toplevel/$response is not a valid subvolume"
  exit 1
fi

source="$response"
source_no_trailing="${response%%-*}"

echo
echo "read-only? (y/N) Default read-write:"
read -r response

readonly=""

# if response is empty or n or N, set readonly to false
if [ -n "$response" ] && [ "$response" != "n" ] && [ "$response" != "N" ]; then
  readonly="-r"
fi

today="$(date +%Y-%m-%d)"
default_name="$source_no_trailing-$today"

#  if readonly is not empty, append -ro to default_name
if [ -n "$readonly" ]; then
  default_name="$default_name-ro"
fi

echo
echo "snapshot name, default $default_name:"
read -r response

destination=""

# if no response or response is not a string, echo error and exit
if [ -z "$response" ]; then
  destination="$default_name"
else
  destination="$response"
fi

btrfs subvolume snapshot $readonly "/toplevel/$source" "/toplevel/$destination"
