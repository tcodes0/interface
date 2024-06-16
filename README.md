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

### Engines

An application that can be configured to copy/symlink the dotfiles in place,
ideally with extensible configuration to support other things I copied by hand.
- mackup (some pains with distribution via aur, using pip still kinda outdated)

## Notes

There are significant gitignored files, move them manually through machines, or move to priv
