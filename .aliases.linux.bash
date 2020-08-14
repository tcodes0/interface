#! /usr/bin/env bash

# Linux aliases

#####################################################
# If not running interactively, skip remaining code #
#####################################################
[[ $- != *i* ]] && return

alias ls='ls -ph --color=always'

#========== Override macos
alias gmv='mv'
alias gsed='sed'
alias gfind='find'
alias gdd='dd'
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'
alias gls='/usr/bin/ls'
alias google="s -p duckduckgo"
alias .i="cd \$DOTFILE_PATH"
alias grep='grep --color=auto'
unalias find
unalias stat
unalias emulator
alias rns="react-native start"
alias o.="dolphin ."
alias acceptAllLicenses="yes | sdkmanager --licenses"

#========== Generic
############
# systemctl
###########
alias sys='systemctl'
alias sysstat='systemctl status'
alias sysrestart='systemctl restart'
alias sysstart='systemctl start'
alias sysstop='systemctl stop'
alias sysenab='systemctl enable'
alias sysu='systemctl --user'
alias sysustat='systemctl --use status'
alias sysurestart='systemctl --use restart'
alias sysustart='systemctl --use start'
alias sysustop='systemctl --use stop'
alias sysuenab='systemctl --use enable'
######
# misc
######
alias lsblk='lsblk -f'
alias desktop='sudo systemctl start sddm.service'
alias sddm='sddm.service'
alias soff='systemctl poweroff'
# alias drive='rclone'
alias ssh='ssh-ident'
alias sudo='root'
alias .s='root'
alias dol='dolphin'
########
# pacman
########
alias pac='pacman'
alias paci='pacman --sync --info'                     # -Si
alias pacii='pacman --sync --info --info'             # -Sii
alias pacl='pacman --query'                           # -Q
alias pacql='pacman --query --list'                   # -Ql
alias pacI='sudo pacman --sync --refresh --noconfirm' # -S
alias pacR='sudo pacman --remove'                     # -R
alias pacRdd='sudo pacman --remove --nodeps --nodeps' # -Rdd
alias pacWhyFile='pacman -Qo'
#####
# yay
#####
# search AUR too
alias pacs='yay --sync --search'              # -Ss
alias yayi='yay --sync --info'                # -Si
alias yayii='yay --sync --info --info'        # -Sii
alias yayl='yay --query'                      # -Q
alias yayql='yay --query --list'              # -Ql
alias yayI='yay --sync --refresh --noconfirm' # -S
alias yayR='yay --remove'                     # -R
alias yayRdd='yay --remove --nodeps --nodeps' # -Rdd
########
# others
########
alias tw='twitter'
alias twt='twitter tweet'
alias tx='tmux'
