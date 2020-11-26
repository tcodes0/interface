#! /usr/bin/env  bash

errExit() {
  echo "$*"
  printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
  exit 1
}

if ! yay --sync --sysupgrade --refresh --noconfirm; then errExit yay --sync failed; fi
if ! yay --sync --noconfirm --clean; then errExit yay --clean; fi
if ! mackup backup; then errExit mackup failed; fi
if ! yarn global upgrade --latest; then errExit yarn global update failed; fi
if ! yarn cache clean; then errExit yarn cache clean failed; fi
if ! command cd "$NVM_DIR" && hub pull; then errExit nvm pull failed; fi
if ! nvm install node; then errExit nvm install node failed; fi
if ! asdf update; then errExit asdf update failed; fi
if ! asdf plugin update --all; then errExit asdf plugin update failed; fi
command cd "$HOME/Desktop"
