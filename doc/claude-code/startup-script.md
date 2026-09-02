# cleanup script

Configure the user interface to not attribute commits, PRs or anything for that matter to Claude.
The web application still attaches a note to the PR despite the configuration blocking it, so we use some hooks to work around that.

```bash
#!/bin/bash

mkdir -p /root/.claude

cat > /root/.claude/settings.json <<'EOF'
{
  "attribution": {
    "commit": "",
    "pr": "",
    "sessionUrl": false
  },
  "autoCompactWindow": 300000
}
EOF
```