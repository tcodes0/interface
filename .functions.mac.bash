hidedesktop() {
  local state && state=$(defaults read com.apple.finder CreateDesktop)
  if [ "$state" == "true" ]; then
    defaults write com.apple.finder CreateDesktop false
  else
    defaults write com.apple.finder CreateDesktop true
  fi
  killall Finder
}

#- - - - - - - - - - -

notify() {
  if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo "
    Send system notifications using MacOs osascript
    notify <title?> <content?>
    "
    return
  fi
  if [[ ! "$(uname -s)" =~ Darwin ]]; then
    # noop on win/linux
    return 0
  fi
  if ! command -v osascript >/dev/null; then
    echo "osascript not found on \$PATH, we need to work. Try installing Xcode and opening it maybe."
    return 1
  fi
  title="Hello World"
  text="Example notification. Use -h for help"
  if [ "$1" ]; then
    title="$1"
  fi
  if [ "$2" ]; then
    text="$2"
  fi
  osascript -e "
    display notification \"$text\" with title \"$title\"
  "
}

#- - - - - - - - - - -

relative-drive-push() {
  true
}

#- - - - - - - - - - -

relative-dropbox-push() {
  true
}

#- - - - - - - - - - -

relative-drive-pull() {
  true
}

#- - - - - - - - - - -

relative-dropbox-pull() {
  true
}


chpwd() {
  true
}

tableinfo() {
  if [ "$1" == "" ]; then
    echo -n "\"SELECT column_name, is_nullable, data_type, column_default FROM information_schema.columns WHERE table_name = 'foo' ORDER BY column_name;\"" | pbcopy
    echo "copied to clipboard as foo"
  else
    echo -n "\"SELECT column_name, is_nullable, data_type, column_default FROM information_schema.columns WHERE table_name = '$1' ORDER BY column_name;\"" | pbcopy
    echo "copied to clipboard as $1"
  fi
}
