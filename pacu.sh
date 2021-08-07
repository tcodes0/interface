#! /usr/bin/env  bash

errExit() {
  echo "$*" failed
  printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
  exit 1
}

asdf_() {
  /home/vacation/.asdf/bin/asdf "$@"
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

if ! nvm alias default v14.16.0 1>/dev/null; then errExit nvm alias node to old; fi
if ! yay --sync --sysupgrade --refresh --refresh; then errExit yay sysupgrade; fi
if ! yay --sync --clean --noconfirm; then errExit yay clean; fi
if ! mackup backup; then errExit mackup; fi
if ! yarn global upgrade --latest; then errExit yarn global update; fi
if ! yarn cache clean; then errExit yarn cache clean; fi
if ! command cd "$NVM_DIR" && hub pull; then errExit nvm pull; fi
if ! nvm install node; then errExit nvm install node; fi
if ! asdf_ update; then errExit asdf_ update; fi
if ! asdf_ plugin update --all; then errExit asdf_ plugin update; fi
if ! nvm alias default node 1>/dev/null; then errExit nvm unalias old node; fi
command cd "$HOME/Desktop" || exit 1
