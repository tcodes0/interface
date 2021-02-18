#! /usr/bin/env bash
# Linux ~/.bashrc

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
$HOME/.gem/ruby/2.7.0/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/usr/local/go/bin:\
/usr/bin:\
/usr/bin/site_perl:\
/usr/bin/vendor_perl:\
/usr/bin/core_perl:\
$HOME/bin/monero-gui:\
$HOME/rn-debugger:\
$HOME/.config/yarn/global/node_modules/.bin:\
$ANDROID_HOME/tools:\
$ANDROID_HOME/platform-tools:\
$ANDROID_HOME/tools/bin:\
$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VER"

# NVM
unset PREFIX            # NVM hates this
unset npm_config_prefix # NVM hates this
export NVM_DIR="$HOME/.nvm"
[ -f "$NVM_DIR/nvm.sh" ] && safe_source "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -f "$NVM_DIR/bash_completion" ] && safe_source "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export EDITOR='code -w'
export GOPATH=/usr/local/go

# elixir/erlang with asdf
export ERL_AFLAGS="-kernel shell_history enabled"
export KERL_CONFIGURE_OPTIONS="--disable-debug --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx"

# gpg agent
export GPGKEY=D600E88A0C5FE062

#####################################################
# If not running interactively, skip remaining code #
#####################################################
[[ $- != *i* ]] && return

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
# AUR  lscolors-git package
safe_source /usr/share/LS_COLORS/dircolors.sh
safe_source /usr/share/bash-completion/bash_completion
safe_source "$HOME/.asdf/asdf.sh"
safe_source "$HOME/.asdf/completions/asdf.bash"

# generic stuff
# export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"
# export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"
# export MANPATH="/usr/local/opt/erlang/lib/erlang/man:$MANPATH"
export CDPATH=$HOME/Desktop:/media:/

# start on desktop
if [ -d "./Desktop" ]; then
  command cd ./Desktop
fi

systemctl --user start srit.service

# add ssh key to ssh agent, bypass prompt
if [ ! "$SSH_AUTH_SOCK" ] && [ -f "$DOTFILE_PATH/.private-ssh-add.expect" ]; then
  eval "$(ssh-agent)" 2>/dev/null 1>&2
  "$DOTFILE_PATH/.private-ssh-add.expect" 2>/dev/null 1>&2
fi

# add gpg key to gpg agent, bypass prompt
"$DOTFILE_PATH/.private-gpg-init.sh" 2>/dev/null 1>&2

#tmux
if [ ! "$TMUX" ] && [ $UID == 1000 ] && [[ ! "$(tty)" =~ /dev/tty[0-9]* ]]; then
  tmux attach || tmux new-session
  tmux source-file "$HOME/.tmux.conf"
fi

# Check we're booting Maglinux by kernel arg with root UUID
if grep --quiet '1016010e-7023-4886-a6b4-34733052fdd5' /proc/cmdline; then
  blkDevice="$(lsblk --raw --noheadings | sed -ne '/EFI-MAG/p' | sed -E 's/^([a-z0-9]+)\ .*/\1/g')"
  # mount EFI-MAG to /boot if not mounted already
  if ! grep --quiet "[/]dev[/]$blkDevice\ [/]boot" /proc/mounts; then
    echo "Please authenticate as root to mount Maglinux /boot correctly. Aborting in 5s..."
    command sudo -T 5 true
    if grep --quiet '[/]boot' /proc/mounts; then
      command sudo umount /boot
    fi
    command sudo mount /dev/disk/by-label/EFI-MAG /boot
  fi
fi
