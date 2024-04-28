#! /usr/bin/env bash

set -e

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "usage: snapshot.sh [-n|--dry-run]"
  echo "this is an interactive script, use -n or --dry-run to experiment"
  echo "run without dry-run flags to make snapshots"
  echo "- choose subvolume to snapshot from /toplevel, we'll list the options"
  echo "- choose snapshot name, default to \$name-\${todays_date}"
  echo "- choose read-only or read-write, default is read-write"
  exit 0
fi

dryrun=""

if [ "$1" = "-n" ] || [ "$1" = "--dry-run" ]; then
  dryrun="true"
fi

if [ -n "$dryrun" ]; then
  echo "dry run..."
  echo
fi

echo "subvolumes in /toplevel owned by you ($(whoami)):"
echo

find /toplevel -maxdepth 1 -user "$(whoami)"

echo
echo "snapshot source:"

response=""
read -r response

if [ -z "$response" ] || [ ! -d "/toplevel/$response" ]; then
  echo "error: /toplevel/$response is not a valid subvolume"
  exit 1
fi

source="$response"
source_no_trailing="${response%%-*}"

echo
echo "read-write? (Y/n) Default read-only:"

read -r response

readonly="-r"
if [ -n "$response" ] && [ "$response" != "n" ] && [ "$response" != "N" ]; then
  readonly=""
fi

today="$(date +%Y-%m-%d)"
default_name="$source_no_trailing-$today"

if [ -n "$readonly" ]; then
  default_name="$default_name-ro"
fi

echo
echo "snapshot name, default $default_name:"

read -r response

destination=""
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
