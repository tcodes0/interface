#- - - - - - - - - - -

relative-drive-push() {
  true
}

relative-dropbox-push() {
  true
}

#- - - - - - - - - - -

relative-drive-pull() {
  true
}

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
