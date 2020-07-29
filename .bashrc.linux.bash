#! /usr/bin/env bash

# Linux ~/.bashrc

export DOTFILE_PATH="/home/vacation/Desktop/interface"

# order matters here
safe_source $DOTFILE_PATH/.bashrc.bash
safe_source $DOTFILE_PATH/.aliases.bash
safe_source $DOTFILE_PATH/.aliases.linux.bash
safe_source $DOTFILE_PATH/.functions.bash
safe_source $DOTFILE_PATH/.functions.linux.bash
safe_source $DOTFILE_PATH/.private.bash
safe_source $DOTFILE_PATH/.prompt.linux.bash
safe_source $DOTFILE_PATH/linux/home/.config/git-prompt.sh
safe_source /usr/share/bash-completion/bash_completion

#========== Environment
# android SDK
# gradle needs this to find SDK. Opening android studio once fixes.
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$HOME/Android/Sdk"
# custom var
export ANDROID_BUILD_TOOLS_VER="29.0.2"

export PATH="\
$HOME/bin:\
$HOME/.asdf/installs/elixir/1.10.0/bin:\
$HOME/.asdf/installs/nodejs/13.7.0/bin:\
$HOME/.gem/ruby/2.7.0/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/usr/bin:\
/usr/bin/site_perl:\
/usr/bin/vendor_perl:\
/usr/bin/core_perl:\
/home/linuxbrew/.linuxbrew/bin:\
$HOME/bin/monero-gui:\
$HOME/rn-debugger:\
$HOME/.config/yarn/global/node_modules/.bin:\
$ANDROID_HOME/tools:\
$ANDROID_HOME/platform-tools:\
$ANDROID_HOME/tools/bin:\
$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VER:\
/usr/local/go/bin"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"

# generic stuff
# export PATH="$ANDROID_SDK_ROOT/build-tools/28.0.0/:$HOME/.asdf/installs/elixir/1.9.2/bin:/usr/local/opt/libxslt/bin:/usr/local/opt/openssl/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/local/sbin:/usr/sbin:/opt/X11/bin:$HOME/Documents/GoogleDrive/Mackup:/usr/local/opt/go/libexec/bin:$HOME/.config/yarn/global/node_modules/.bin:/usr/local/opt/util-linux/bin:/usr/local/opt/ruby/bin:$HOME/.rvm/bin:$HOME/.cargo/bin:$HOME/Library/Android/sdk/tools:$HOME/Library/Android/sdk/tools/bin:/Applications/Postgres.app/Contents/Versions/latest/bin"
# export MANPATH="/usr/local/opt/erlang/lib/erlang/man:$MANPATH"
export CDPATH=$HOME:/Media:/
export EDITOR='code -w'
# export GOPATH="$HOME/.go"
# LS_COLORS=$(cat "$HOME/Code/LS_COLORS/LS_COLORS_RAW")
# export LS_COLORS

# NVM
unset PREFIX            # NVM hates this
unset npm_config_prefix # NVM hates this
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && safe_source "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && safe_source "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# elixir/erlang with asdf
export ERL_AFLAGS="-kernel shell_history enabled"
safe_source "$HOME/.asdf/asdf.sh"
safe_source "$HOME/.asdf/completions/asdf.bash"
export KERL_CONFIGURE_OPTIONS="--disable-debug --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx"

# gpg agent
export GPGKEY=D600E88A0C5FE062

#####################################################
# If not running interactively, skip remaining code #
#####################################################
[[ $- != *i* ]] && return

# start on desktop
if [ -d "./Desktop" ]; then
  command cd ./Desktop
fi

# fast keyboard key response rate
if [[ ! "$(tty)" =~ /dev/tty[0-9]* ]]; then
  # don't run when on a real tty, only graphic X11 ttys
  xset r rate 140 60
fi

# add ssh key to ssh agent, bypass prompt
if [ ! "$SSH_AUTH_SOCK" ] && [ -f "$DOTFILE_PATH/.private-ssh-add.expect" ]; then
  eval "$(ssh-agent)" 2>/dev/null 1>&2
  "$DOTFILE_PATH/.private-ssh-add.expect" 2>/dev/null 1>&2
fi

# add gpg key to gpg agent, bypass prompt
"$DOTFILE_PATH/.private-gpg-init.sh" 2>/dev/null 1>&2

#tmux
# [ ! "$TMUX" ] && {
#   tmux attach || tmux new-session
# }
