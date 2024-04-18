#! /usr/bin/env bash

# Linux aliases

###############################################
# If running from script, skip remaining code #
###############################################
[[ $- != *i* ]] && return

alias ls='ls -ph --color=always'

#========== Overrides macos
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
alias rns="react-native start"
alias o.="dolphin ."
alias acceptAllLicenses="yes | sdkmanager --licenses"
alias open="xdg-open"

###############
# Linux system
###############
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

#################
# pacman and yay
#################
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

######
# dot
######
alias .hc="cd \$HOME/Desktop/client"
alias .hs="cd \$HOME/Desktop/server"
alias .ms="cd \$HOME/Desktop/member-server"
alias .mc="cd \$HOME/Desktop/member-client"
alias .i="cd \$DOTFILE_PATH"
alias .b="cd \$HOME/Desktop/baristai"
alias .bw="cd \$HOME/Desktop/baristai/client/web"

######
# work
######
alias pdfret="echo return \&bytes.Buffer\{\}, nil"
alias qhub="psql -U postgres -d hub -c"
alias qhubtest="psql -U postgres -d hub_test -c"
alias qmember="psql -U postgres -d member -c"
alias qmembertest="psql -U postgres -d member_test -c"
alias sqlqa="echo renamed to qahub and qamember"
alias qahub="PGPASSWORD=\$(gcloud auth print-access-token) psql -U thom.ribeiro@eleanorhealth.com -d hub -h /home/vacation/.eleanor_sql_sockets/ele-qa-436057:us-east1:eleanor-postgres"
alias qamember="PGPASSWORD=\$(gcloud auth print-access-token) psql -U thom.ribeiro@eleanorhealth.com -d member -h /home/vacation/.eleanor_sql_sockets/ele-qa-436057:us-east1:eleanor-postgres"
alias kb="kubectl"
alias deploy="make release ENV=prod"
alias tableplus="LD_LIBRARY_PATH=/opt/tableplus/lib tableplus"
alias golint="golangci-lint run --timeout 20s --tests=false"
alias gen="godotenv -f .env go generate ./..."
alias golint="golangci-lint run --timeout 20s --tests=false"
alias ehvpn="gcloud alpha cloud-shell ssh --project=ele-qa-436057 --authorize-session -- -D 31337 -CNq; echo configure firefox to use SOCKS proxy v5 on port 31337"
alias gorun="godotenv -f .env go run -race"
alias gotest="godotenv -f .env go test ./... -race"
alias chromevpn='google-chrome-stable --proxy-server="socks5://localhost:31337"'
alias ehtoken="gcloud auth print-access-token"
alias kubecheck="kubeconform --strict --schema-location=https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master --schema-location=https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"

######
# misc
######
alias mkvtomp4='ffmpeg -i example.mkv -c copy example.mp4'
alias makebrl="echo var makeBrlToUsd = rate => brl => Math.round(brl*rate)"
alias lsblk='lsblk -f'
alias ssh='ssh-ident'
alias vi=nano
alias unmount="umount"
alias uux="chmod u+x"
alias desktopRsync="echo rsync --recursive --links --progress --exclude=\"interface/\*\" /home/vacation/Desktop/ vacation@192.168.0.214:/home/vacation/Desktop"
# shellcheck disable=SC2154
alias run-command-with-file="echo 'while read -r line; do foo=\$line; done <file.txt'"
alias command-with-file=run-command-with-file
alias apg="apg -M SNCL"
alias pwgen="apg"
