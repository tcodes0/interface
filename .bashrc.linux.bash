#! /usr/bin/env bash
# Linux ~/.bashrc
# root user runs these files as well!
# so some whoami or UID checks are needed

#========== Environment

# add over /usr/bin to run irpf java program
# add jre11-openjdk and jdk11-openjdk packages (or maybe just jdk?)
# maybe also the always-up-to-date jdk-openjdk
# /usr/lib/jvm/java-11-openjdk/bin:\
export PATH="\
$HOME/bin:\
$HOME/.asdf/installs/elixir/1.10.0/bin:\
$HOME/.gem/ruby/2.7.0/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/usr/bin:\
/usr/bin/site_perl:\
/usr/bin/vendor_perl:\
/usr/bin/core_perl:\
$HOME/bin/monero-gui:\
$HOME/rn-debugger:\
$HOME/.config/yarn/global/node_modules/.bin:\
$HOME/go/bin:\
$HOME/Desktop/scripts:\
/usr/local/go/bin"

# NVM
unset PREFIX            # NVM hates this
unset npm_config_prefix # NVM hates this
export NVM_DIR="$HOME/.nvm"
[ -f "$NVM_DIR/nvm.sh" ] && safe_source "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -f "$NVM_DIR/bash_completion" ] && safe_source "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export EDITOR='code -w'

# gpg agent
export GPGKEY=D600E88A0C5FE062

# dotfiles
export DOTFILE_PATH=""
if [ "$(whoami)" == "root" ]; then
  DOTFILE_PATH="/home/vacation/Desktop/interface"
elif [ "$(whoami)" == "vacation" ]; then
  DOTFILE_PATH="$HOME/Desktop/interface"
fi

safe_source "$DOTFILE_PATH/.script-functions.linux.bash"

#####################################################
# If not running interactively, skip remaining code #
#####################################################
[[ $- != *i* ]] && return

export SYSBKP_DATE_FILE="$HOME/.sysbkp-last-run.date"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

# order matters here
safe_source "$DOTFILE_PATH/.bashrc.bash"
safe_source "$DOTFILE_PATH/.aliases.bash"
safe_source "$DOTFILE_PATH/.aliases.linux.bash"
safe_source "$DOTFILE_PATH/.functions.bash"
safe_source "$DOTFILE_PATH/.functions.linux.bash"
safe_source "$DOTFILE_PATH/.private.bash"
safe_source "$DOTFILE_PATH/.prompt.linux.bash"
safe_source "$DOTFILE_PATH/linux/home/.config/git-prompt.sh"
safe_source "$DOTFILE_PATH/priv/env"
# AUR  lscolors-git package
safe_source /usr/share/LS_COLORS/dircolors.sh
safe_source /usr/share/bash-completion/bash_completion
safe_source "$HOME/.asdf/asdf.sh"
safe_source "$HOME/.asdf/completions/asdf.bash"
safe_source /opt/google-cloud-sdk/completion.bash.inc

# start on desktop
if [ -d "./Desktop" ]; then
  command cd ./Desktop || echo 'cd desktop failed'
fi

# avoid bugs running systemctl --user as root
# investigate why systemd user services not working here
# investigate why systemd use
if [ "$(whoami)" == "vacation" ] && [ ! "$SRIT_SET" ]; then
  systemctl --user start srit.service
  # bluetooth connections on laptop reset keyboard key speed, so don't set the var to allow easily re-runing this code
  if [ ! "$ARCH_ACER" ]; then
    export SRIT_SET=1
  fi
fi
if [ "$(whoami)" == "vacation" ] && [ ! "$KBD_SET" ]; then
  systemctl --user start x11-keyboard.service
  export KBD_SET=1
fi

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
if [ ! "$ARCH_ACER" ] && grep --quiet '1016010e-7023-4886-a6b4-34733052fdd5' /proc/cmdline; then
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
