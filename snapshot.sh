#! /usr/bin/env bash

set -e

# if first argument is -h or --help, echo help and exit
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "usage: snapshot.sh [-n|--dry-run]"
  echo "this is an interactive script, use -n or --dry-run to experiment"
  echo "run without dry-run flags to make snapshots"
  echo "- choose subvolume to snapshot from /toplevel"
  echo "- choose snapshot name, default is subvolume name and date"
  echo "- choose read-only or read-write, default is read-write"
  exit 0
fi

dryrun=""

# if first argument is -n or --dry-run, set dryrun to true
if [ "$1" = "-n" ] || [ "$1" = "--dry-run" ]; then
  dryrun="true"
fi

# if dryrun is not empty, echo dry run
if [ -n "$dryrun" ]; then
  echo "dry run..."
  echo
fi

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

if [ -n "$dryrun" ]; then
  echo would run: btrfs subvolume snapshot $readonly "/toplevel/$source" "/toplevel/$destination"
  exit 0
fi

btrfs subvolume snapshot $readonly "/toplevel/$source" "/toplevel/$destination"
