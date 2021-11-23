#! /usr/bin/env  bash

SPACE="\n\n"
LTS_NAME="fermium" # v12

# $* message
log_fatal() {
  echo pacu.sh error: "$*": "${FUNCNAME[1]}"
  echo -ne "$SPACE"
  exit 1
}

if command -v today-date >/dev/null && [ "$SYSBKP_DATE_FILE" ]; then
  echo "Did you backup?"
  if ! today-date read "$SYSBKP_DATE_FILE"; then
    echo "Backup run date check failed"
    exit 1
  fi
else
  echo "Backup run date check failed"
  exit 1
fi

# Some software only builds from AUR in old node versions
# we start by updating NVM itself
if ! command cd "$NVM_DIR" && git pull; then log_fatal nvm pull; fi

# temporarily downgrade the default node in nvm
set -e
echo "Using node LTS $LTS_NAME for upgrade..."
nvm install --lts="$LTS_NAME" 1>/dev/null
# after install NVM sets the installed node as the one in use
LTS_VER="$(node -v)"
nvm alias default "$LTS_VER" 1>/dev/null

# fix some install errors
chmod -R u+w "$HOME/.cache/yay"

# handle errors manually from now on
set +e

# updaters
# shellcheck disable=SC2046
if ! yay --sync --refresh --needed --noconfirm $(tr \\n ' ' < "$PWD/update.txt"); then log_fatal yay refresh; fi
# if ! yay --sync --sysupgrade --ignore linux,linux-api-headers,linux-firmware,linux-headers ; then log_fatal yay sysupgrade; fi
if ! mackup backup; then log_fatal mackup; fi
if ! yarn global upgrade --latest; then log_fatal yarn global update; fi
if ! nvm install node; then log_fatal nvm install node; fi
if ! /home/vacation/.asdf/bin/asdf update; then log_fatal asdf update; fi
if ! /home/vacation/.asdf/bin/asdf plugin update --all; then log_fatal asdf plugin update; fi
if ! yay --sync linux linux-api-headers linux-firmware linux-headers --needed --noconfirm; then log_fatal updating keyring and linux; fi

set -e

# restore node to latest
nvm alias default node 1>/dev/null

command cd "$HOME/Desktop"
