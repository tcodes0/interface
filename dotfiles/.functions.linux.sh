#! /usr/bin/env bash

drive_list() {
  if [[ "$#" == 0 ]]; then
    rclone lsf google-drive:
  else
    rclone lsf "google-drive:$1"
  fi
}

#- - - - - - - - - - -

vpn_up() {
  sudo wg-quick up wg0
  sudo wg
}

#- - - - - - - - - - -

vpn_down() {
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
  if [ "$#" == 0 ] || requested_help "$*"; then
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

pac_orphan_deps_interactive() {
  # shellcheck disable=SC2155
  local keep=(go oath-toolkit git-lfs kdesu5 kdnssd5 knewstuff5 ldns oxygen-sounds qt5-webview re2 extra-cmake-modules hipblas rust make patch rsync wget ffmpeg ffmpeg4.4 libdvbpsi aribb24 libmatroska libebml libmpeg2 libtar libkate libtiger vlc)
  # shellcheck disable=SC2155
  local orphans=$(yay --query --deps --unrequired)

  msgln "$(wc -l <<<"$orphans")" orphans:
  msgln "$orphans"

  # some pkg versions will be present in pkg var due to bash being limited
  for pkg in $orphans; do
    if [[ "$pkg" =~ ^[0-9] ]]; then
      continue
    fi

    if [[ "${keep[*]}" == *"$pkg"* ]]; then
      msgln "keeping $pkg"
      continue
    fi

    if [[ "$pkg" =~ .*-debug.* ]]; then
      msgln "removing debug $pkg"
      continue
    fi

    yay --sync --info "$pkg"
    yay --remove --recursive --recursive "$pkg"
  done
}

#- - - - - - - - - - -

# todo: remove
unalias sys 2>/dev/null
unalias sysu 2>/dev/null

# __sys: A smart wrapper for systemctl commands.
# Supports 'system' (with sudo) and 'user' modes.
# Allows fuzzy subcommand matching
# Adds --now to 'enable' if user confirms.
__sys() {
  local type="$1" sub_cmd="$2" args="${*:3}" cmd prefix="sys:"
  local valid_abrev_sub_cmds=(status restart start stop enable daemon-reload cat)
  local no_sudo_sub_cmds=(status cat)
  local matches=()

  for option in "${valid_abrev_sub_cmds[@]}"; do
    if [[ "$option" == "$sub_cmd"* ]]; then
      matches+=("$option")
    fi
  done

  if ((${#matches[@]} == 1)); then
    sub_cmd="${matches[0]}"
  elif ((${#matches[@]} > 1)); then
    msgln "$prefix ambiguous subcommand '$sub_cmd'. Possible matches:"
    for match in "${matches[@]}"; do
      msgln "\t$match"
    done
    return 1
  fi

  # Determine command prefix
  if [[ "$type" == "system" ]]; then
    local needs_sudo=true
    for n in "${no_sudo_sub_cmds[@]}"; do
      if [[ "$sub_cmd" == "$n" ]]; then
        needs_sudo=false
        break
      fi
    done

    if $needs_sudo; then
      sudo --validate || return 1
      cmd="sudo systemctl"
    else
      cmd="systemctl"
    fi
  elif [[ "$type" == "user" ]]; then
    cmd="systemctl --user"
  else
    err "invalid first argument: must be 'system' or 'user'" >&2
    return 1
  fi

  debug $LINENO "$cmd" "$sub_cmd" "$args"

  if [[ "$sub_cmd" == "" ]]; then
    # shellcheck disable=SC2086 # on purpose, causes systemctl error if quoted or empty sub_cmd
    $cmd $args

    return
  fi

  # shellcheck disable=SC2086
  $cmd $sub_cmd $args # on purpose, causes systemctl error if quoted
}

sys() {
  __sys "system" "$@"
}

sysu() {
  __sys "user" "$@"
}
