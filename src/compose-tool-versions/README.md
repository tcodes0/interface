# src/compose-tool-versions/

Canonical tool version fragments for `bin/compose-tool-versions`.

Each file is named after the tool and contains a single line in `.tool-versions` format:

```
<tool> <version>
```

## Adding a tool

Create a new file named after the tool:

```sh
echo 'mytool 1.2.3' > src/compose-tool-versions/mytool
```

Then reference it in `~/.config/github.com.rthomazel/.composetoolversionrc`.

## RC file format

```
# project: tool1 tool2 tool3
server:       golang nodejs tbls oxfmt gh
comms:        golang nodejs tbls oxfmt gh
member-server: golang nodejs oxfmt gh
go-common:    golang nodejs gh
```
