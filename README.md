# Interface

Things I use to use computers

```bash
# tree -d -L 1
.
├── bin      # executables to be added to path
├── dotfiles # dotfiles to be symlinked in $HOME
├── etc      # files meant to be symlinked in /etc
└── priv     # private

5 directories
```

## Absolute-path symlinks

This repository contains several symbolic links that reference
absolute paths (e.g. under `/home/vacation/` or `/Users/thom.ribeiro/`).
These links work only in environments that have the same directory
structure. When cloning the repo elsewhere, you may encounter broken
links. We found 11 such links, but there may be more.

This happens because this is a personal dotfile repository. You can
replace the prefix with your own home directory if you wish.

