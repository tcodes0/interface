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
######
# misc
######
alias sys='systemctl'
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
alias pacl='pacman --query'                           # -Q
alias pacql='pacman --query --list'                   # -Ql
alias pacI='sudo pacman --sync --refresh --noconfirm' # -S
alias pacR='sudo pacman --remove'                     # -R
alias pacRdd='sudo pacman --remove --nodeps --nodeps' # -Rdd
alias pacWhy='pacman --sync --info --info'            # -Sii
# moved to a function to search AUR too
# alias pacs='pacman --sync --search'                   # -Ss
#####
# yay
#####
alias yayi='yay --sync --info'                     # -Si
alias yayl='yay --query'                           # -Q
alias yayql='yay --query --list'                   # -Ql
alias yayI='sudo yay --sync --refresh --noconfirm' # -S
alias yayR='sudo yay --remove'                     # -R
alias yayRdd='sudo yay --remove --nodeps --nodeps' # -Rdd
alias yayWhy='yay --sync --info --info'            # -Sii
########
# others
########
alias sysu='systemctl --user'
alias tw='twitter'
alias twt='twitter tweet'
alias tx='tmux'
