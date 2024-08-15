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
alias pacSearch='yay --sync --search' # -Ss
alias pacs='yay --sync --search'
alias pacWhyFile='pacman -Qo'
alias pacInfo='yay --sync --info' # -Si
alias paci='yay --sync --info'
alias pacInfoVerbose='yay --sync --info --info' # -Sii
alias pacii='yay --sync --info --info'
alias pacInfoDeps='yay --query --info'                # -Qi
alias pacList='yay --query'                           # -Q
alias pacl='yay --query'
alias pacListVerbose='yay --query --list' # -Ql
alias pacll='yay --query --list'
alias pacInstall='yay --sync --noconfirm' # -S
alias pacI='yay --sync --noconfirm'
alias pacRemove='yay --remove'                             # -R
alias pacRemoveDeps='yay --remove --recursive --recursive' # -Rss
alias pacR='yay --remove --recursive --recursive'
alias pacRemoveForce='yay --remove --nodeps --nodeps' # -Rdd
# shellcheck disable=SC2142
alias pacBigPackages="LC_ALL=C pacman -Qi | awk '/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}' | sort -rh | head -100 | less"

# work

alias chromevpn='google-chrome-stable --proxy-server="socks5://localhost:31337"'
alias ehtoken="gcloud auth print-access-token | wl-copy"

# others

alias lsblk='lsblk -f'
alias ssh='ssh-ident'
alias vi=nano
alias unmount="umount"
alias uux="chmod u+x"
alias sys='systemctl'
alias sysa='systemctl status'
alias sysr='systemctl restart'
alias syss='systemctl start'
alias sysn='systemctl stop'
alias syse='systemctl enable'
alias sysu='systemctl --user'
alias sysua='systemctl --user status'
alias sysur='systemctl --user restart'
alias sysus='systemctl --user start'
alias sysun='systemctl --user stop'
alias sysue='systemctl --user enable'
alias sunano='sudo nano'
alias jrn='journalctl --reverse'
alias jrnu='journalctl --user --reverse --catalog'
alias mouse="rivalcfg"
