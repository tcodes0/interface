#! /usr/bin/env  bash

errExit() {
  echo "$*"
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

if ! yay --sync --sysupgrade --refresh --refresh; then errExit yay --sync failed; fi
if ! yay --sync --clean --noconfirm; then errExit yay --clean --noconfirm; fi
if ! mackup backup; then errExit mackup failed; fi
if ! yarn global upgrade --latest; then errExit yarn global update failed; fi
if ! yarn cache clean; then errExit yarn cache clean failed; fi
if ! command cd "$NVM_DIR" && hub pull; then errExit nvm pull failed; fi
if ! nvm install node; then errExit nvm install node failed; fi
if ! asdf_ update; then errExit asdf_ update failed; fi
if ! asdf_ plugin update --all; then errExit asdf_ plugin update failed; fi
command cd "$HOME/Desktop" || exit 1
