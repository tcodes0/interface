#! /usr/bin/env  bash

#####################
### Pacman update ###
#####################

lts_name="gallium" # v16
response=""
pg_major_update="no"
services_to_stop=("sddm postgresql")
services_to_restart=("postgresql")

log_fatal() {
  echo pacu.sh error: "$*": "${FUNCNAME[1]}"
  echo -ne "\n\n"
  exit 1
}

extract_version() {
  if [ -z "$*" ]; then
    echo "empty version"
    return 1
  fi

  echo -n "$*" | grep -o -E '[0-9]+\.[0-9]+'
}

pg_major_cleanup() {
  set -e

  local initdb_args=(--encoding=UTF8 -D /var/lib/postgres/data)
  local old_version

  echo
  echo "manually migrating pg cluster..."
  echo "sudo required"
  sudo true

  old_version="$(sudo -u postgres cat /var/lib/postgres/data/PG_VERSION)"
  echo "old version: $old_version"

  # mv and mkdir will fail here if directories exist
  sudo mv /var/lib/postgres/data /var/lib/postgres/olddata
  sudo mkdir /var/lib/postgres/data /var/lib/postgres/tmp
  sudo chown postgres:postgres /var/lib/postgres/data /var/lib/postgres/tmp

  cd /var/lib/postgres/tmp
  sudo -u postgres initdb "${initdb_args[@]}"
  sudo -u postgres pg_upgrade -b "/opt/pgsql-${old_version}/bin" -B /usr/bin -d /var/lib/postgres/olddata -D /var/lib/postgres/data

  set +e
}

# set -e not used to handle errors manually attaching debug messages with log_fatal

echo "please logout and switch to a console. All done? (timeout 10s) [y/N]"
read -t 10 -r response
if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
  exit 0
fi

echo "start a new @root snapshot? Sudo is necessary (timeout 10s) [y/N]"
read -t 10 -r response
if [ "$response" == "y" ] || [ "$response" == "Y" ]; then
  if ! sudo snapshot.sh; then log_fatal creating snapshot; fi
fi

echo "stopping services..."
echo "${services_to_stop[*]}"

# stop services
for service in "${services_to_stop[@]}"; do
  if ! sudo systemctl stop "$service".service; then log_fatal stopping "$service"; fi
done

#######################
### Postgres update ###
#######################

echo "posgresql major updates require a cleanup script"
echo
echo "current PG version"
if ! extract_version psql --version; then log_fatal checking current pg version; fi

echo
echo "new PG version"
new_ver=$(yay --sync --refresh --info postgresql | grep Version)
if ! extract_version "$new_ver"; then log_fatal checking new pg version; fi

echo
echo "is this a major pg update? (timeout 10s) [y/n]"
read -t 10 -r response
if [ -z "$response" ]; then
  echo "timeout"
  exit 1
fi
if [ "$response" == "y" ] || [ "$response" == "Y" ]; then
  pg_major_update="yes"
fi

# update pg
if ! yay --sync postgresql --needed --noconfirm; then log_fatal upgrading pg; fi

if [ "$pg_major_update" == "yes" ]; then
  if ! pg_major_cleanup; then log_fatal pg_major_cleanup; fi
fi

######################
### System upgrade ###
######################

# Some software only builds from AUR in old node versions
# we start by updating NVM itself
if ! command cd "$NVM_DIR" && git pull; then log_fatal nvm pull; fi

# temporarily downgrade the default node in nvm
set -e
echo "using node LTS $lts_name for upgrade..."
nvm install --lts="$lts_name" 1>/dev/null
# after install NVM sets the installed node as the one in use
LTS_VER="$(node -v)"
nvm alias default "$LTS_VER" 1>/dev/null

# fix some install errors
chmod -R u+w,u+r "$HOME/.cache/yay"

# continue handling errors manually from now on
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

# reset PWD
command cd "$HOME/Desktop"

for service in "${services_to_restart[@]}"; do
  if ! sudo systemctl start "$service".service; then log_fatal restarting "$service"; fi
done

if [ "$pg_major_update" == "yes" ]; then
  sudo rm -fr /var/lib/postgres/olddata /var/lib/postgres/tmp
  vacuumdb --all --analyze-in-stages
fi

echo "success"
echo "reboot now? (timeout 10s) [y/N]"
read -t 10 -r response
if [ "$response" == "y" ] || [ "$response" == "Y" ]; then
  systemctl reboot
fi
