#! /usr/bin/env bash

drive-list() {
  if [[ "$#" == 0 ]]; then
    rclone lsf google-drive:
  else
    rclone lsf "google-drive:$1"
  fi
}

#- - - - - - - - - - -

vpnup() {
  sudo wg-quick up wg0
  sudo wg
}

#- - - - - - - - - - -

vpndown() {
  sudo wg-quick down wg0
  sudo wg
}

#----------------

mkinitcpio() {
  if [ "$UID" != 0 ]; then
    echo "must run mkinitcpio as root"
    return 0
  fi

  command mkinitcpio "$@"
}

#- - - - - - - - - - -

tar7z() {
  if [ "$#" == 0 ] || [ "$1" == "-h" ]; then
    echo "tar7z foo produces foo.tar.7z"
    return 1
  fi

  local safeArg=$1
  if [[ "$safeArg" =~ [/]$ ]]; then
    safeArg=${safeArg:0:-1}
  fi

  tar cf - "$safeArg" 2>/dev/null | 7za a -si -mx=7 "${safeArg}.tar.7z" 1>/dev/null
}

#- - - - - - - - - - -

goo() {
  google "$@"
}

#- - - - - - - - - - -

pacOrphanDepsInteractive() {
  # shellcheck disable=SC2155
  local keep=(go oath-toolkit git-lfs kdesu5 kdnssd5 krunner5 ldns oxygen-sounds qt5-webview re2 wlroots) orphans=$(yay --query --deps --unrequired)

  println "$(wc -l <<<"$orphans")" orphans:
  println "$orphans"
  println removing...

  # some pkg versions will be present in pkg var due to bash being limited
  for pkg in $orphans; do
    if [[ "$pkg" =~ ^[0-9] ]]; then
      continue
    fi

    if [[ "${keep[*]}" == *"$pkg"* ]]; then
      println "keeping $pkg"
      continue
    fi

    yay --sync --info "$pkg"
    yay --remove --recursive --recursive "$pkg"
  done
}
