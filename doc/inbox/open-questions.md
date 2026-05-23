# Open Questions

Things that jump out:
The `BASHENV‘patterniscleverbutfragile—everyscripthasthat‘checkdependencies‘boilerplateatthetop.Itworks,butitmeansifyouevermoveorrename‘lib.sh‘,everyscriptbreakssilentlyatruntimeratherthanatsourcetime.Thecheckalsoonlytestsif‘BASH_ENV` pattern is clever but fragile — every script has that `check_dependencies` boilerplate at the top. It works, but it means if you ever move or rename `lib.sh`, every script breaks silently at runtime rather than at source time. The check also only tests if `
BASHE​NV‘patterniscleverbutfragile—everyscripthasthat‘checkd​ependencies‘boilerplateatthetop.Itworks,butitmeansifyouevermoveorrename‘lib.sh‘,everyscriptbreakssilentlyatruntimeratherthanatsourcetime.Thecheckalsoonlytestsif‘BASH_ENV` is _set_, not if `lib.sh` actually _loaded_ — so a wrong path in `.bash_env` would still pass the check.

The binaries committed directly to bin/ (typo, dir-rename) are interesting — they're ELF x86-64 blobs with no source in the repo. That's a trust and portability issue, and if you ever need to rebuild them or debug them, there's no path forward from within the repo.
fstab as a hardlink is a smart workaround but it means the repo and /etc/fstab are silently diverging any time you edit one without the other. There's no enforcement.
The system-up script has a postgres_up function that calls extract_version and then does [ "$major_sub" -ge 1 ] — but extract_version returns strings like "15." (with a trailing dot from the regex). The bc subtraction would work, but the comparison on the result of bc gives a float like "1.0", and [ "1.0" -ge 1 ] is actually a bash integer comparison that would fail on the .0 suffix. Worth checking if that code path has actually been exercised recently.

Genuine questions:

The PUSH_REPOS list in .bashrc has interface in it — but the repo uses jujutsu, not git. lazy-git checks $PUSH_REPOS and calls git push. Does lazy-git ever actually run against this repo, or is lazy-jujutsu always the one used here?
The ollama service listens on 0.0.0.0 so Docker containers can reach it — what are you running in Docker that talks to Ollama? Local LLM tooling for work, or something else?
And the dictation-keyboard-hook on KEY_F2 of the Keychron Q10 — what does it actually do? Does it pipe audio to a Whisper model, or is it hooking into some other dictation stack?
