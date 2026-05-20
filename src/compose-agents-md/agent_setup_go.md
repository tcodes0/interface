## Agent setup

Run `bin/setup` at session start if not already done — it is idempotent and safe to re-run.
It installs Go and Node via mise (.tool-versions), configures git auth for private modules,
and downloads dependencies.

`GITHUB_TOKEN` is required for private module access. Cloud agents have it injected into
the environment automatically. Jail agents (local container) carry it in `.env` — `bin/setup`
sources it from there. Human devs rely on SSH instead.
