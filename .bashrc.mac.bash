#!/usr/bin/env bash
# shellcheck disable=SC2034 disable=SC1090

DOTFILE_PATH="/Users/vacation/Desktop/interface"

#========== Completions, external scripts, git prompt
if [ -d /usr/local/etc/bash_completion.d ]; then
  for file in /usr/local/etc/bash_completion.d/*; do
    safe_source "$file"
  done
fi

# order matters here
safe_source $DOTFILE_PATH/.bashrc.bash
safe_source $DOTFILE_PATH/.aliases.bash
# safe_source $DOTFILE_PATH/.aliases.mac.bash
safe_source $DOTFILE_PATH/.functions.bash
safe_source $DOTFILE_PATH/.functions.mac.bash
safe_source $DOTFILE_PATH/.prompt.linux.bash
safe_source $DOTFILE_PATH/linux/home/.config/git-prompt.sh

#========== Environment

# generic stuff
export PATH="\
/opt/homebrew/bin:\
/usr/local/bin:\
/bin:\
/usr/bin:\
/sbin:\
/usr/local/sbin:\
/usr/sbin"

# export MANPATH="/usr/local/opt/erlang/lib/erlang/man:$MANPATH"
# export CDPATH=$HOME:/Volumes:$HOME/Desktop
export EDITOR='code -w'
export GOPATH="$HOME/.go"
# LS_COLORS=$(cat "$HOME/Code/LS_COLORS/LS_COLORS_RAW")
# export LS_COLORS

# compiler flags
# export LDFLAGS="-L/usr/local/opt/ruby/lib -L/usr/local/opt/libxslt/lib -L/usr/local/opt/openssl/lib -L/usr/local/opt/krb5/lib"
# export CPPFLAGS="-I/usr/local/opt/ruby/include -I/usr/local/opt/libxslt/include -I/usr/local/opt/openssl/include -I/usr/local/opt/krb5/include"

# NVM
# unset PREFIX            # NVM hates this
# unset npm_config_prefix # NVM hates this
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# elixir/erlang with asdf
# export ERL_AFLAGS="-kernel shell_history enabled"
# safe_source /usr/local/opt/asdf/asdf.sh
# export ERLANG_OPENSSL_PATH="/usr/local/opt/openssl"
# export KERL_CONFIGURE_OPTIONS="--disable-debug --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --enable-darwin-64bit --with-ssl=/usr/local/Cellar/openssl/1.0.2t"
