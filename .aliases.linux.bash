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
alias sysustat='systemctl --user status'
alias sysurestart='systemctl --user restart'
alias sysustart='systemctl --user start'
alias sysustop='systemctl --user stop'
alias sysuenab='systemctl --user enable'
######
# misc
######
alias lsblk='lsblk -f'
alias desktop='sudo systemctl start sddm.service'
alias sddm='sddm.service'
alias soff='systemctl poweroff'
# alias drive='rclone'
alias ssh='ssh-ident'
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
alias mkvtomp4='ffmpeg -i example.mkv -c copy example.mp4'
alias wasabi="\cd \$HOME/Desktop/WalletWasabi/WalletWasabi.Gui && dotnet run"
alias makebrl="echo var makeBrlToUsd = rate => brl => Math.round(brl*rate)"
######
# dot
######
alias .s='root'
alias .z="cd \$HOME/Desktop/zet"
alias .h="cd \$HOME/Desktop/client"
alias .hs="cd \$HOME/Desktop/server"
alias .ms="cd \$HOME/Desktop/member-server"
alias .m="cd \$HOME/Desktop/member-client"
alias .f="cd \$HOME/Desktop/forms"
alias .wtf="cd \$HOME/Desktop/wtf-dot-env"
alias .i="cd \$DOTFILE_PATH"
