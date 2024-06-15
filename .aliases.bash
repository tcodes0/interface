#! /usr/bin/env bash

###############################################
# If running from script, skip remaining code #
###############################################

[[ $- != *i* ]] && return

##################
#-------dot stuff
##################

alias .d="cd \$HOME/Desktop"
alias .c="cd \$HOME/Code"
alias o.="open ."
alias o="open"
alias .z="cd \$HOME/Desktop/zet"
alias .hc="cd \$HOME/Desktop/client"
alias .hs="cd \$HOME/Desktop/server"
alias .ms="cd \$HOME/Desktop/member-server"
alias .mc="cd \$HOME/Desktop/member-client"
alias .s="cd \$HOME/Desktop/shared"
alias .wtf="cd \$HOME/Desktop/wtf-dot-env"
alias .dj="cd \$HOME/Desktop/data-jobs"

######
# work
######

alias pdfret="echo return \&bytes.Buffer\{\}, nil"
alias qhub="psql -U postgres -d hub -c"
alias qmember="psql -U postgres -d member -c"
alias sqlqa="PGPASSWORD=\$(gcloud auth print-access-token) psql -U thom.ribeiro@eleanorhealth.com -d hub -h /home/vacation/.eleanor_sql_sockets/ele-qa-436057:us-east1:eleanor-postgres"
alias kb="kubectl"
alias deploy="make release ENV=prod"

####################
#--------ls aliases
####################

alias ls='gls -ph --color=always'
alias la='ls -A'
alias ll='ls -lSAi'
alias lt='ls -ltAi'

###########
#-----brew
###########

alias brewi='brew info'
alias brewl='brew list'
alias brews='brew search'
alias brewh='brew home'
alias brewI='brew install'
alias brewR='brew uninstall'

###########
#-----cask
###########

alias caski='brew info --cask'
alias caskl='brew list --cask'
alias casks='brew search --cask'
alias caskh='brew home --cask'
alias caskI='brew install --cask'
alias caskR='brew uninstall --cask'

##########################
# ----------mistakes typos
##########################

alias loca='local'
alias emcas='emacs'
alias emasc='emcas'
alias me='emacs'
alias ndoe='node'
alias yy='yarn'
alias gnc='gcn'
alias lslbk='lsblk'
alias lsbkl='lsblk'

####################
#---------Zsh & Git
####################

alias ...="cl ../../"
alias ....="cl ../../../"
alias .....="cl ../../../../"
alias ......="cl ../../../../../"
# alias g=git
alias ga='git add'
alias gaa='git add --all && gss'
alias gapp='git apply'
alias gap='git add --patch'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbm='git branch -m'
alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(main|main|develop|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gc='git commit'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcf='git config --list'
alias gcl='git clone --recursive'
alias gclean='git clean -fd && gss'
# alias gcmsg='git commit -m' using function
alias gco='git checkout'
alias gcod='git fetch --all --prune && git checkout develop'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcs='git commit -S'
alias gcsm='git commit -s -m'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdct='git describe --tags `git rev-list --tags --max-count=1`'
alias gdcw='git diff --cached --word-diff'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'
# alias gf='git fetch'
alias gf='git fetch --all --prune'
alias gfo='git fetch origin'
alias gg='git gui citool'
alias gga='git commit --amend --no-edit'
alias gae='git add --all && git commit --amend --no-edit'
alias ggae='git commit --amend'
alias ggpull="git pull origin \$GIT_BRANCH"
# alias ggpull="git pull origin \$__git_ps1_branch_name"
alias ggpur=ggu
alias ggpush="git push origin \$GIT_BRANCH"
# alias ggpush="git push origin \$__git_ps1_branch_name"
alias ggsup="git branch --set-upstream-to=origin/\$GIT_BRANCH"
# alias ggsup="git branch --set-upstream-to=origin/\$__git_ps1_branch_name"
alias gpf='git push -f'
alias ghh='git help'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='git svn dcommit && git push github main:svntrunk'
alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log -g --pretty=%h)'
alias gl='git pull'
alias gly='git pull && yarn'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias globurl='noglob urlglobber '
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty='\''%Cred%h%Creset - %ci -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'
alias glola='git log --graph --pretty='\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'' --all'
alias glp='_git_log_prettily'
alias glum='git pull upstream main'
alias gm='git merge -q'
alias gma='git merge --abort'
alias gmom='git fetch --all --prune && git merge -q origin/main'
alias gmod='git fetch --all --prune && git merge -q origin/develop'
alias gmt='git mergetool --no-prompt'
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge -q upstream/main'
alias gmsq='git merge -q --squash'
alias gp='git push -q'
alias gpo='git push origin'
alias gpd='git push --dry-run'
alias gpot='git push origin --tags'
alias gpristine='git reset --hard && git clean -dfx'
alias gpsup="git push -q --set-upstream origin \$GIT_BRANCH"
alias gpsupc="git push -q --set-upstream client \$GIT_BRANCH"
alias gpu='git push upstream'
alias gpv='git push -v'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase main'
alias grbs='git rebase --skip'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias grh='git reset HEAD && gss'
alias grhh='git reset HEAD --hard && gss'
alias grh1="git reset HEAD~1"
alias grh2="git reset HEAD~2"
alias grh3="git reset HEAD~3"
alias grh5="git reset HEAD~5"
alias grh10="git reset HEAD~10"
alias gco1="git checkout HEAD~1"
alias gco2="git checkout HEAD~2"
alias gco3="git checkout HEAD~3"
alias gco5="git checkout HEAD~5"
alias gco10="git checkout HEAD~10"
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'
alias gsb='git status -sb'
alias gsd='git svn dcommit'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gsr='git svn rebase'
# alias gss='git status -s'
alias gsss='gss'
alias gs='gss'
alias gssss='gss'
alias gsssss='gss'
alias gssssss='gss'
alias gsssssss='gss'
alias gssssssss='gss'
alias gsssssssss='gss'
alias gssssssssss='gss'
alias gssssssssssss='gss'
alias gst='git status'
alias gsta='git stash push && gss'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop && gss'
alias gsts='git stash show --text'
alias gsu='git submodule update'
alias gtl='git tag -l'
alias gtd='git tag -d'
alias gta='git tag'
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
alias grev='git revert'
alias gnuke='git reset HEAD --hard && git clean -fd'
alias wip="git add --all && git commit -nm wip"
alias grl="git reflog | head -20 | sed -Ee \"s/^.*from (.*) to (.*).*$/\1 -> \2/\" -e \"/commit|cherry/d"\"
alias lgs="SKIPADD=1 && lg"
alias lgw="WIPCOMMIT=1 && lg"
alias caf="caffeinate"
alias g-="git checkout -"
alias gfp="git fetch --all --prune && git pull"
alias gla="glo | head -10"

################
#-------general
################

alias cd='cd -P'
alias cd='cl'
alias rm='rm -ri'
alias cp='cp -RHi'
alias mv='gmv -i'
alias mkdir='mkdir -p'
alias ..='cl ..'
alias df='df -h'
alias ln='ln -si'
alias disk='diskutil'
alias part='partutil'
alias dd='gdd status=progress bs=4M'
alias srit='source $HOME/.bashrc && clear'
alias pbc='pbcopy'
alias pbp='pbpaste'
alias grep='ggrep --color=auto'
alias dirs='dirs -v'
alias du='du -xa | sort -rn'
alias stat='stat -Ll'
alias j='jobs'
alias f='fg'
alias g='grep -Eie'
alias ping='ping -c 1'
alias sed='gsed'
alias e='echo -e'
alias less="\$PAGER"
alias dircolors="gdircolors"
alias python="python3"
alias ncdu="ncdu -x --si"
alias visudo="EDITOR='code -w' && command sudo visudo"
alias shfmt="shfmt -i 2 -ln bash"
alias shellcheck="shellcheck --color=auto -s bash"
alias cat='bat --theme Monokai\ Extended\ Origin'
alias gppr='gpsup && git pull-request -b main --browse --assign thomazella'
alias gpprd='gpsup && git pull-request -b develop --browse --assign thomazella'
alias cleoskylin="cleos -u http://kylin.fn.eosbixin.com"
alias find="gfind"
alias t="cat"
alias l="less"
alias wget='wget -c'
alias histg="history | grep"
alias myip='curl http://ipecho.net/plain; echo'
alias gpglist="gpg --list-secret-keys --keyid-format LONG"
alias gpgexport="gpg --armor --export"
alias gpgkeygen="gpg --full-generate-key"
alias gpgremove="gpg --delete-secret-key"
alias simplePrompt="PS1='\\n\\[\\e[1;90m\\w \\e[0m\\]\\n$ ' && PROMPT_COMMAND=''"
alias npml="npm list --depth=0"
alias npmgl="npm list --global --depth=0"
alias npms="npm search"
alias npmh="npm repo"
alias npmr="npm run-script"
alias npmI="npm install"
alias y="yarn"
alias yarnl="yarn list --depth=0"
alias yf="yarn --force"
alias ys="yarn start"
alias yc="yarn test && yarn typeCheck && yarn lint:fix"
alias yarngl="yarn global list --depth=0"
alias adbl="adb devices"
alias adbd="adb shell input keyevent 82"
alias c.="code ."
alias c="code"
alias yt="yarn test"
alias maclog="log show --predicate 'processID == 0' --start \$(date "+%Y-%m-%d") --debug"
alias barebash="env -i HOME=\$HOME TERM=\$TERM bash"
alias uuidcp="uuidgen | tr -d '\n' | pbc"
alias d="deploy"
alias m="make"
alias n="nano"
