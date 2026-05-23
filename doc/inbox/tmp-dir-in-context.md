# tmp dir — expose /tmp in context output

In the Dockerfile, explicitly create a `/tmp` directory and ensure it survives
the build (it usually exists, but making it explicit documents intent).

In `handlers/context.go`, surface `/tmp` in the `context` tool response — mention
it as a writable scratch space that agents can use freely. The OS cleans it
automatically; nothing written there survives container restarts (which is fine
and expected).

## motivation

Agents sometimes need a place to write intermediate files (rendered templates,
downloaded archives, scratch data) without worrying about leaking into project
directories or consuming persistent volume space. Pointing explicitly to `/tmp`
in the context output removes any ambiguity about where scratch files should go.

## rough design

- Dockerfile: `RUN mkdir -p /tmp && chmod 1777 /tmp` (belt-and-suspenders, most
  base images already have this).
- `context` output: add a `scratch:` field (or similar) alongside the `volumes:`
  block, e.g.:

  ```
  scratch: /tmp (ephemeral, cleaned by OS, not a volume)
  ```

- No config needed — `/tmp` path is universal on Linux.
