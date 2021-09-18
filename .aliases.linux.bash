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
#################
# pacman and yay
#################
alias pac='pacman'
alias pacSearch='yay --sync --search' # -Ss
alias pacWhyFile='pacman -Qo'
alias pacs='pacSearch'
alias pacInfo='yay --sync --info'                          # -Si
alias pacInfoVerbose='yay --sync --info --info'            # -Sii
alias pacList='yay --query'                                # -Q
alias pacListVerbose='yay --query --list'                  # -Ql
alias pacInstall='yay --sync --refresh --noconfirm'        # -S
alias pacRemove='yay --remove'                             # -R
alias pacRemoveDeps='yay --remove --recursive --recursive' # -Rss
alias pacRemoveForce='yay --remove --nodeps --nodeps'      # -Rdd
alias paci='pacInfo'
alias pacii='pacInfoVerbose'
alias pacl='pacList'
alias pacql='pacListVerbose'
alias pacI='pacInstall'
alias pacR='pacRemove'
alias pacRss='pacRemoveDeps'
alias pacRdd='pacRemoveForce'
######
# dot
######
alias .z="cd \$HOME/Desktop/zet"
alias .hc="cd \$HOME/Desktop/client"
alias .hs="cd \$HOME/Desktop/server"
alias .ms="cd \$HOME/Desktop/member-server"
alias .mc="cd \$HOME/Desktop/member-client"
alias .s="cd \$HOME/Desktop/shared"
alias .wtf="cd \$HOME/Desktop/wtf-dot-env"
alias .i="cd \$DOTFILE_PATH"
alias .dj="cd \$HOME/Desktop/data-jobs"
######
# work
######
alias pdfret="echo return \&bytes.Buffer\{\}, nil"
alias sqllocal="psql -U postgres -d hub"
alias sqlqa="qapass && psql -U hub-server -W -d hub -h /home/vacation/eleanor_sql_sockets/ele-qa-436057:us-east1:eleanor-postgres"
######
# misc
######
alias tw='twitter'
alias twt='twitter tweet'
alias tx='tmux'
alias mkvtomp4='ffmpeg -i example.mkv -c copy example.mp4'
alias wasabi="\cd \$HOME/Desktop/WalletWasabi/WalletWasabi.Gui && dotnet run"
alias makebrl="echo var makeBrlToUsd = rate => brl => Math.round(brl*rate)"
alias lsblk='lsblk -f'
alias desktop='sudo systemctl start sddm.service'
alias sddm='sddm.service'
alias soff='systemctl poweroff'
# alias drive='rclone'
alias ssh='ssh-ident'
alias dol='dolphin'
alias vi=nano
alias unmount="umount"
alias uux="chmod u+x"
alias desktopRsync="echo rsync --recursive --links --progress --exclude=\"interface/\*\" /home/vacation/Desktop/ vacation@192.168.0.214:/home/vacation/Desktop"