## Agent setup

Run `bin/setup` at session start if not already done — it is idempotent and safe to re-run.
It installs Go and Node via mise (.tool-versions), configures git auth for private modules using ssh,
and downloads dependencies.
