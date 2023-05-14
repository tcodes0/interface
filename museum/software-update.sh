#! /usr/bin/env bash
# shellcheck source=/Users/vamac/bin/progress.sh
set -e
if [ -f "${HOME}/bin/progress.sh" ]; then source "$HOME/bin/progress.sh"; fi

work() {
  if [[ "$(uname -s)" != Darwin ]]; then
    return
  fi

  [ "$1" == "silently" ] && local silently=">/dev/null 2>&1"
  set -e

  [ "$silently" ] && progress start "Upgrading homebrew"
  # || true because brew fails on pinned itens being upgraded...
  eval setsid -w brew upgrade "$silently" </dev/null || true
  set +e # several cask issues
  eval setsid -w brew cask upgrade "$silently" </dev/null
  set -e
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Scrubbing homebrew's cache"
  eval brew cleanup -s --prune=31 "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating NPM global packages"
  eval npm update -g "$silently"
  eval npm -g i caniuse "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating yarn global packages"
  eval yarn global upgrade --latest "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating gems"
  # /usr/bin/gem often conflicts. MacOS version is root - wheel, no write perm.
  eval "setsid -w yes | /usr/local/opt/ruby/bin/gem update $silently" || true
  eval /usr/local/opt/ruby/bin/gem cleanup "$silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Updating Node & nvm"
  eval "cd $NVM_DIR && git pull $silently"
  eval "yes | nvm install node $silently"
  [ "$silently" ] && progress finish "$?"

  [ "$silently" ] && progress start "Asdf plugin update"
  eval "asdf plugin-update --all"
  [ "$silently" ] && progress finish "$?"
  #   $(node -e "
  # result = $(curl -sH Authorization:\ token\ $GHAUTH https://api.github.com/repos/elixir-lang/elixir/releases)
  # result = result.map(r => r.tag_name).slice(0,1)[0].replace('v','')
  # console.log(result)
  # ")

  # node -e "
  # result = $(curl -sH Authorization:\ token\ $GHAUTH https://api.github.com/repos/erlang/otp/releases)
  # result = result.map(r => r.tag_name).map(x => x.replace(/OTP-|-rc[0-9]/g, '')).sort().reverse().slice(0,1)[0]
  # console.log(result)
  # "
}

case "$1" in
--dont-ask | -f)
  work silently || progress finish "$?"
  exit 0
  ;;
-v | --verbose)
  work
  exit 0
  ;;
esac

#confirm upgrade
echo "Upgrade all cli-software now? (y/n)
   ...defaulting to no in 5s"
if ! read -rt 5; then exit $?; fi

if [ "$REPLY" == "y" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "Y" ] || [ "$REPLY" == "YES" ]; then
  work
fi
