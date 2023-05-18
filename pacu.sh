#! /usr/bin/env  bash

#####################
### Pacman update ###
#####################

SPACE="\n\n"
LTS_NAME="gallium" # v16
response=""

# $* message
log_fatal() {
  echo pacu.sh error: "$*": "${FUNCNAME[1]}"
  echo -ne "$SPACE"
  exit 1
}

echo "For safety: snapshot @root, logout, switch to a console, stop and disable: sddm, postgresql. All done? (timeout 10s) [y/N]"
read -t 10 -r response
if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
  exit 0
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
chmod -R u+w,u+r "$HOME/.cache/yay"

# handle errors manually from now on
set +e

# updaters
if ! mackup backup; then log_fatal mackup; fi
# not using any global packages atm
#if ! yarn global upgrade --latest; then log_fatal yarn global update; fi
if ! nvm install node; then log_fatal nvm install node; fi

# update arch pkgs first to avoid errors
if ! yay --sync --refresh --needed --noconfirm archlinux-appstream-data archlinux-keyring; then log_fatal upgrading arch pkgs; fi
# update linux
if ! yay --sync linux linux-api-headers linux-firmware linux-headers --needed --noconfirm; then log_fatal upgrading linux; fi
# update everything but linux from repositories
if ! yay --repo --sync --sysupgrade --ignore linux,linux-api-headers,linux-firmware,linux-headers --needed --noconfirm; then log_fatal upgrading system; fi
# update everything but linux from AUR
if ! yay --aur --sync --sysupgrade --ignore linux,linux-api-headers,linux-firmware,linux-headers --needed --noconfirm; then log_fatal upgrading system; fi

set -e

# restore node to latest
nvm alias default node 1>/dev/null

command cd "$HOME/Desktop"
