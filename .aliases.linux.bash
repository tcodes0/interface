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
alias ggrep='grep'
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'
alias gls='/usr/bin/ls'
alias google="s -p duckduckgo"
alias grep='grep --color=auto'
unalias find
unalias stat
unalias emulator
alias rns="react-native start"
alias o.="dolphin ."
alias acceptAllLicenses="yes | sdkmanager --licenses"
alias open="xdg-open"

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
alias dol='dolphin'
alias vi=nano
alias unmount="umount"
########
# pacman
########
alias pac='pacman'
alias pacInfo='pacman --sync --info'                          # -Si
alias pacInfoVerbose='pacman --sync --info --info'            # -Sii
alias pacList='pacman --query'                                # -Q
alias pacListVerbose='pacman --query --list'                  # -Ql
alias pacInstall='sudo pacman --sync --refresh --noconfirm'   # -S
alias pacRemove='sudo pacman --remove'                        # -R
alias pacRemoveForce='sudo pacman --remove --nodeps --nodeps' # -Rdd
alias pacWhyFile='pacman -Qo'
alias paci='pacInfo'
alias pacii='pacInfoVerbose'
alias pacl='pacList'
alias pacql='pacListVerbose'
alias pacI='pacInstall'
alias pacR='pacRemove'
alias pacRdd='pacRemoveForce'
alias pacWhyFile='pacman -Qo'
#####
# yay
#####
# search AUR too
alias pacSearch='yay --sync --search'                 # -Ss
alias yayInfo='yay --sync --info'                     # -Si
alias yayInfoVerbose='yay --sync --info --info'       # -Sii
alias yayList='yay --query'                           # -Q
alias yayListVerbose='yay --query --list'             # -Ql
alias yayInstall='yay --sync --refresh --noconfirm'   # -S
alias yayRemove='yay --remove'                        # -R
alias yayRemoveForce='yay --remove --nodeps --nodeps' # -Rdd
alias pacs='pacSearch'
alias yayi='yayInfo'
alias yayii='yayInfoVerbose'
alias yayl='yayList'
alias yayql='yayListVerbose'
alias yayI='yayInstall'
alias yayR='yayRemove'
alias yayRdd='yayRemoveForce'
########
# others
########
alias tw='twitter'
alias twt='twitter tweet'
alias tx='tmux'
alias hsup="godotenv -f .env go run cmd/migration/main.go && godotenv -f .env go run cmd/server/main.go"
alias mkvtomp4='ffmpeg -i example.mkv -c copy example.mp4'
######
# dot
######
alias .s='root'
alias .z="cd \$HOME/Desktop/zet"
alias .h="cd \$HOME/Desktop/client"
alias .hs="cd \$HOME/Desktop/server"
alias .i="cd \$DOTFILE_PATH"
