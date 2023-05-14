#! /usr/bin/env bash
# shellcheck disable=SC2154

err() {
  echo "error: $1"
  exit 1
}

##-----------------------  Deps & Setup  ----------------------##
for name in bkp-routines progress; do
  # shellcheck disable=SC1090
  source "$HOME/bin/$name.sh" || err "Dependency $name failed"
done

# parse-options "$@"

######----------------- Quick exits  -----------------######
if [[ "$#" != 0 ]]; then
  if [ "$help" ] || [ "$h" ]; then
    do-help
    exit 1
  fi
fi

#-- Test for backup drive plugged in
# [ ! -d "$BKPDIR" ] && echo "Backup destination not plugged in?"

[[ ! "$(uname -s)" =~ Darwin ]] && err "Careful using this on Win/linux."

######----------------- Main  -----------------######
start-run
# copyRegular
# copyRedundant
# syncDeleting
listApps
listVscodeExtensions
# copyZipping
software-update.sh -v
# updateSoftware
updateBrewfile
# runMackup
finish-run
