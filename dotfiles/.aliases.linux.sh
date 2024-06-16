#! /usr/bin/env bash

# Mac incompatible
alias ls='ls -ph --color=always'
alias mv='mv -i'
alias pbc='xclip -selection c'
alias pbp='xclip -selection c -o'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias open="xdg-open"

# Linux system

alias sys='systemctl'
alias sysstat='systemctl status'
alias sysrestart='systemctl restart'
alias sysstart='systemctl start'
alias sysstop='systemctl stop'
alias sysenab='systemctl enable'
alias sysu='systemctl --user'
alias sysustat='systemctl --user status'
alias sysurestart='systemctl --user restart'
alias sysustart='systemctl --user start'
alias sysustop='systemctl --user stop'
alias sysuenab='systemctl --user enable'
alias sunano='sudo nano'
alias jrn='journalctl --reverse'
alias jrnu='journalctl --user --reverse --catalog'
alias fs="btrfs"
alias fsv="btrfs subvolume"

# pacman and yay

alias pac='pacman'
alias pacSearch='yay --sync --search' # -Ss
alias pacWhyFile='pacman -Qo'
alias pacs='pacSearch'
alias pacInfo='yay --sync --info'                          # -Si
alias pacInfoVerbose='yay --sync --info --info'            # -Sii
alias pacInfoDeps='yay --query --info'                     # -Qi
alias pacOrphanDeps='yay --query --deps --unrequired'      # -Qdt
alias pacList='yay --query'                                # -Q
alias pacListVerbose='yay --query --list'                  # -Ql
alias pacInstall='yay --sync --noconfirm'                  # -S
alias pacRemove='yay --remove'                             # -R
alias pacRemoveDeps='yay --remove --recursive --recursive' # -Rss
alias pacRemoveForce='yay --remove --nodeps --nodeps'      # -Rdd
alias paci='pacInfo'
alias pacii='pacInfoVerbose'
alias pacl='pacList'
alias pacll='pacListVerbose'
alias pacI='pacInstall'
alias pacR='pacRemoveDeps'
# shellcheck disable=SC2142
alias pacBigPackages="LC_ALL=C pacman -Qi | awk '/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}' | sort -rh | head -100 | less"

# work

alias chromevpn='google-chrome-stable --proxy-server="socks5://localhost:31337"'

# misc

alias mkvtomp4='ffmpeg -i example.mkv -c copy example.mp4'
alias lsblk='lsblk -f'
alias ssh='ssh-ident'
alias vi=nano
alias unmount="umount"
alias uux="chmod u+x"
alias desktopRsync="echo rsync --recursive --links --progress --exclude=\"interface/\*\" /home/vacation/Desktop/ vacation@192.168.0.214:/home/vacation/Desktop"
# shellcheck disable=SC2154
alias run-command-with-file="echo 'while read -r line; do foo=\$line; done <file.txt'"
alias apg="apg -M SNCL"
alias pwgen="apg"
