# Interface

things I use to use computers

### Formely

thomazella/bin

thomazella/dotfiles

## Notes

rclone google app to personal google email

## Linux setup

### Notes

perms

```bash
# linux/etc/udev/hwdb.d/70-custom-keyboard.hwdb
sudo chown root 70-custom-keyboard.hwdb
sudo chgrp root 70-custom-keyboard.hwdb
sudo chmod g+w,o+w 70-custom-keyboard.hwdb
# hardlink it
sudo ln \${PWD}/linux/etc/udev/70-custom-keyboard.hwdb /etc/udev/hwdb.d/70-custom-keyboard.hwdb
# see this for editing the file
# https://gist.github.com/Thomazella/fcd1fac083a9c7f792c70fb49a71177c#gistcomment-3122968
```

```bash
# linux/home/.config/systemd/user
for name in linux/home/.config/systemd/user/\*; do echo ln "$PWD/$name" ~/.config/systemd/user/$name; done
```

> linux/home/.config/git-prompt.sh

source from shell, see https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

> linux/home/.gnupg/gpg-agent.conf

`ln $PWD/linux/home/.gnupg/gpg-agent.conf \$HOME/.gnupg/gpg-agent.conf`

### Sudoers stuff

```bash
sudo -i
cd /etc
echo "Defaults timestamp_timeout=45" > sudoers.d/timestamp
echo "Defaults editor=/usr/bin/nano" > sudoers.d/editor
```
