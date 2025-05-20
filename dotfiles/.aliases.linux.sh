#! /usr/bin/env bash

# a mac version exists

alias ls='ls -ph --color=always'
alias mv='mv -i'
alias pbc='wl-copy'
alias pbp='wl-paste'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias open="xdg-open"

# pacman and yay

alias pac='pacman'
alias pacs='yay --sync --search'
alias pacwhyfile='pacman -Qo'
alias paci='yay --sync --info'
alias pacii='yay --sync --info --info'
alias pacinfodeps='yay --query --info' # -Qi
alias pacl='yay --query'
alias pacll='yay --query --list'
alias pacI='yay --sync --noconfirm'
alias pacremove='yay --remove' # -R
alias pacR='yay --remove --recursive --recursive'
alias pacremoveforce='yay --remove --nodeps --nodeps' # -Rdd
# shellcheck disable=SC2142
alias pacbigpackages="LC_ALL=C pacman -Qi | awk '/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}' | sort -rh | head -100 | less"

# work

alias chromevpn='google-chrome-stable --proxy-server="socks5://localhost:31337"'
alias ehtoken="gcloud auth print-access-token | wl-copy"

# others

alias lsblk='lsblk -f'
alias ssh='ssh-ident'
alias vi=nano
alias unmount="umount"
alias uux="chmod u+x"
alias sunano='sudo nano'
alias jrn='journalctl --reverse'
alias jrnu='journalctl --user --reverse --catalog'
alias mouse="rivalcfg"
alias ol="ollama"
# --audio fixes stuttering, --target peak allows hdr like experience, --demuxer was recommended by warnings
alias mpv="mpv --audio-buffer=10 --audio-channels=2 --target-peak=1000 --demuxer-lavf-analyzeduration=100 --demuxer-lavf-probesize=10000000"
