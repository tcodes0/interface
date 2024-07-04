#! /usr/bin/env bash

# work

alias ele-db-select="go run \$HOME/Desktop/scripts/db-select/main.go"

# brew

alias brewi='brew info'
alias brewl='brew list'
alias brews='brew search'
alias brewh='brew home'
alias brewI='brew install'
alias brewR='brew uninstall'
alias caski='brew info --cask'
alias caskl='brew list --cask'
alias casks='brew search --cask'
alias caskh='brew home --cask'
alias caskI='brew install --cask'
alias caskR='brew uninstall --cask'

# gnu

alias ls='gls -ph --color=always'
alias dircolors="gdircolors"
alias find="gfind"
alias mv='gmv -i'
alias dd='gdd status=progress bs=4M'
alias grep='ggrep --color=auto'
alias sed='gsed'

# general

alias caf="caffeinate"
alias tableplus="LD_LIBRARY_PATH=/opt/tableplus/lib tableplus"
alias maclog="log show --predicate 'processID == 0' --start \$(date "+%Y-%m-%d") --debug"
alias chromevpn='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-server="socks5://localhost:31337"'
alias act="act --container-architecture linux/amd64"
alias pbc='pbcopy'
alias pbp='pbpaste'
