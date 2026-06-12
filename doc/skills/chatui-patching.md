---
name: chatui-patching
description: Use when writing, fixing, or validating LibreChat patches for the LGA project, or when working on files under images/librechat/danny-avila.librechat/ or images/librechat/librechat.agents/.
---

# LGA — LibreChat Patch Workflow

Patches live in the `lga` repo under `images/librechat/`, in two directories
named after the GitHub repo they target.
Clone URL: `git@github.com:rthomazel/lga.git`

## Layout

```
lga/
├── bin/upgrade-chatui                       upgrade script
├── compose.yml                              api: build: ./images/librechat
└── images/librechat/
    ├── Dockerfile
    ├── danny-avila.librechat/               patches targeting LibreChat source
    │   ├── 001-...diff
    │   └── ...
    └── librechat.agents/                    patches targeting @librechat/agents dist
        ├── 001-...diff
        └── ...
```

Directory naming convention: `<github-owner>.<repo-name>`, lowercase, dots only.

## How the Build Works

`images/librechat/Dockerfile` mirrors LibreChat's own build pipeline exactly:

1. `git clone --depth 1 --branch $LIBRECHAT_VERSION` into `/app`
2. LibreChat patch loop — applies every `danny-avila.librechat/*.diff` via `patch -p1` against `/app`
3. `npm ci --no-audit` — installs dependencies from the cloned lockfile
4. Agents patch loop — applies every `librechat.agents/*.diff` via `patch -p1` against `node_modules/@librechat/agents`
5. `npm run frontend` — React/Vite build (slow, ~5 min)
6. `npm prune --production` + `npm run backend` as CMD

> **Order matters:** agents patches run after `npm ci` because `node_modules` does not exist before that step.

Three build args are passed from `compose.yml` and have no defaults in the
Dockerfile — a missing value fails the build loudly:

| Arg                    | Example                                        | Source                             |
| ---------------------- | ---------------------------------------------- | ---------------------------------- |
| `LIBRECHAT_VERSION`    | `v0.8.6-rc1`                                   | git tag                            |
| `LIBRECHAT_NODE_IMAGE` | `node:20-alpine`                               | upstream Dockerfile `FROM`         |
| `UV_IMAGE`             | `ghcr.io/astral-sh/uv:0.9.5-python3.12-alpine` | upstream Dockerfile `COPY --from=` |

`LIBRECHAT_NODE_IMAGE` and `UV_IMAGE` must be kept in sync with whatever
the upstream Dockerfile pins at the target version. The upgrade-chatui script
extracts them automatically.

> **Docker ARG limitation:** `COPY --from=` does not support variable
> expansion. The workaround is a named intermediate stage:
> `FROM ${UV_IMAGE} AS uv` then `COPY --from=uv ...`

## Paths

| What                   | Where                                                             |
| ---------------------- | ----------------------------------------------------------------- |
| LibreChat patch files  | `images/librechat/danny-avila.librechat/NNN-*.diff`               |
| Agents patch files     | `images/librechat/librechat.agents/NNN-*.diff`                    |
| TSC environment        | `/projects/librechat-tsc` (persistent, do not delete)             |
| Agents dist in TSC env | `/projects/librechat-tsc/node_modules/@librechat/agents/dist/cjs` |
| Upgrade script         | `bin/upgrade-chatui`                                              |

## Persistent TSC Environment

A LibreChat source clone with `node_modules` and built workspace packages lives at:

```
/projects/librechat-tsc
```

This is a **persistent volume** — survives session restarts. Do not delete it.
Setup takes ~5 min to re-run. If it needs rebuilding:

```bash
rm -rf /projects/librechat-tsc
git clone --depth 1 --branch v0.8.6-rc1 \
  https://github.com/danny-avila/LibreChat.git /projects/librechat-tsc
cd /projects/librechat-tsc
npm ci --no-audit
npm run build -w packages/data-provider
npm run build -w packages/client
```

The tag must match `LIBRECHAT_VERSION` in `compose.yml`.

**Upstream baseline:** The unpatched source has ~152 pre-existing TSC errors in
upstream files we don't touch. These are upstream issues. Ignore them.
Only errors in **files touched by the patch** matter.

## Mandatory Validation After Every Patch Write or Fix

Always run both checks before committing.

### 1 — Full sequence apply check

Reset the TSC clone, then apply every patch in order:

```bash
git -C /projects/librechat-tsc checkout -- .
for p in $(ls /path/to/lga-clone/images/librechat/danny-avila.librechat/*.diff | sort); do
  printf '%-70s ' "$(basename $p)"
  patch -p1 -d /projects/librechat-tsc < $p && echo CLEAN || echo FAILED
done
```

Every patch must print `CLEAN`. A `FAILED` means the patch itself or its hunk header (line count / offset) is wrong.

For agents patches, restore the original file first (agents dist is not tracked by git), then apply:

```bash
# agents patches validate against node_modules — no git reset, restore manually if needed
for p in $(ls /path/to/lga-clone/images/librechat/librechat.agents/*.diff | sort); do
  printf '%-70s ' "$(basename $p)"
  patch -p1 -d /projects/librechat-tsc/node_modules/@librechat/agents < $p && echo CLEAN || echo FAILED
done
```

### 2 — TSC check on touched files

Filter by the filename(s) you changed — ~176 pre-existing upstream errors exist in unrelated files; ignore those.

```bash
cd /projects/librechat-tsc
npx tsc --noEmit -p client/tsconfig.json 2>&1 | grep 'error TS' | grep -E 'File1|File2'
```

No output = clean. Any output means the patch introduces a type error.

## Writing a New Patch

Reset to clean upstream first, discard changes in the worktree from previous sessions.

### 1. Reset and save the original

```bash
git -C /projects/librechat-tsc checkout -- .
```

Capture the baseline **in one atomic command** — write to `/tmp` and verify in the same shell invocation. Each `shell` tool call is a fresh process, so a `cd` or file write from a prior call is not visible if the next call fails partway through.

```bash
git -C /projects/librechat-tsc checkout -- . && \
  cp /projects/librechat-tsc/client/src/path/to/File.tsx /tmp/File.orig.tsx && \
  echo "baseline: $(wc -l < /tmp/File.orig.tsx) lines"
```

For files extracted from git history (e.g. to generate a diff against a pre-patch state):

```bash
git -C /projects/librechat-tsc show HEAD:client/src/path/to/File.tsx > /tmp/File.upstream.ts && \
  echo "upstream: $(wc -l < /tmp/File.upstream.ts) lines"
```

Always print the line count as confirmation — a silent zero-byte file is the most common failure mode when an intermediate step in a chain fails.

### 2. Edit the target file

Edit directly in `/projects/librechat-tsc/`.

### 3. Run mandatory validation (see above)

TSC-check before generating the diff.

### 4. Generate the diff

For LibreChat patches (paths relative to LibreChat repo root):

```bash
diff -u \
  --label a/client/src/path/to/File.tsx \
  --label b/client/src/path/to/File.tsx \
  /tmp/File.orig.tsx \
  /projects/librechat-tsc/client/src/path/to/File.tsx \
  > images/librechat/danny-avila.librechat/NNN-description--path-File.diff
```

For agents patches (paths relative to the agents package root):

```bash
diff -u \
  --label a/dist/cjs/messages/format.cjs \
  --label b/dist/cjs/messages/format.cjs \
  /tmp/format.orig.cjs \
  /projects/librechat-tsc/node_modules/@librechat/agents/dist/cjs/messages/format.cjs \
  > images/librechat/librechat.agents/NNN-description--dist-cjs-file.diff
```

Multi-file patch: concatenate with `>>`.

### 5. Run mandatory validation again on the full sequence

After the diff is on disk, reset the TSC clone and run the full sequence check.

## Fixing a Broken Patch

1. Apply all patches **up to but not including** the broken one to see the actual source state
2. Read `patch` stderr and any `.rej` files in the TSC clone — they show what context didn't match
3. Correct the hunk header counts in `@@ -old,n +new,n @@` and/or surrounding context lines
4. Run the full sequence check to confirm

Common cause: a hunk line count is off by one because the added `+` or removed `-` lines don't add up to the number in `@@ -old,n +new,n @@`.

## Diagnostic Logging Patches

When a fix is based on a hypothesis about what caused a bug — especially one that
could not be directly reproduced — ship the fix with accompanying diagnostic
`console.log`/`console.warn` statements **in the same patch**, so the next test
run can confirm or falsify the hypothesis.

### When to add diagnostic logs

- The root cause was inferred from symptoms, not directly observed
- The fix involves race conditions, cross-component state contamination, or
  context-switch timing
- The operator says they will test but cannot reliably reproduce

### How to write the logs

**Use a consistent prefix** so logs can be filtered in the browser console:

```ts
console.warn("[featureName] handlerName: short description | key:", value, "| other:", other);
```

The prefix should reflect the feature area, e.g. `[queuedSend]`, `[sidebarTitle]`.

**Log at decision points**, not just entry points:

| Point                                | What to log                                          |
| ------------------------------------ | ---------------------------------------------------- |
| Enqueue / trigger                    | The value being acted on + relevant IDs              |
| Guard / early return                 | Why the guard fired + the mismatched values          |
| State write (e.g. `setConversation`) | `prevState` ID vs incoming event ID                  |
| Happy-path execution                 | Confirmation + reduced context (text preview, count) |

**Use `console.warn` for unexpected conditions** (guard fires, ID mismatch) so
they stand out in the console as orange, not noise.

**Use `console.log` for expected, informational flow** (enqueue, normal flush).

**Keep log values short** — truncate text previews to 60 chars
(`str.slice(0, 60)`), include IDs, counts, and the specific values that are
being compared.

### Example — state contamination

```ts
setConversation((prevState) => {
  if (prevState?.conversationId != null && prevState.conversationId !== incomingId) {
    console.warn(
      "[sidebarTitle] setConversation mismatch | prevState.conversationId:",
      prevState.conversationId,
      "!== event.conversationId:",
      incomingId,
      "| paramId (viewing):",
      paramId,
    );
  }
  return { ...prevState, ...update };
});
```

### Naming diagnostic patches

Diagnostic-only patches (no functional change, just logs) use the suffix `logs`
or `diag` in their name:

```
NNN-featureName-logs--path-File.diff
NNN-featureName-diag--path-File.diff
```

Fix-plus-logs patches (functional fix that also ships logs) name the patch
after the fix; the logs are implied:

```
NNN-featureName-fix-description--path-File.diff
```

### Removing logs

Once the hypothesis is confirmed and the fix is validated, strip the diagnostic
logs in a follow-up patch (or amend the fix patch). Logs should not survive into
a stable release — they are scaffolding, not permanent instrumentation.

---

## Patch Conventions

- Naming: `NNN-short-description--Source-File-ComponentName.diff` (NNN zero-padded)
- Format: unified diff, `-p1` (paths relative to repo root)
- Applied in filename sort order — if patch B depends on A, A must have a lower number
- Multi-file patches concatenate multiple `diff -u` outputs into one file
- Patches that touch the same file must be independent of each other or applied in order

## JSX Gotcha — Ternaries Inside Expression Context

In the second arm of a JSX ternary (inside `( ... )`), curly braces `{ }` are a JS
**object literal**, not a JSX expression block. If you need a nested conditional there,
use a bare ternary — no wrapping `{ }`:

```jsx
// Wrong — {} is an object literal, esbuild errors:
) : (
  {condition ? <A /> : <B />}
)}

// Correct — bare ternary:
) : (
  condition ? <A /> : <B />
)}
```

The hunk header line count must reflect the actual number of `+` / `-` lines.

## Rebuilding After a Patch Change

Always use `--no-cache` — Docker caches the patch layer by content hash. If the cache
is stale, the old compiled frontend survives and runtime errors like `clearOnSubmit is not defined`
appear even though the patch looks correct.

```bash
cd ~/Desktop/lga
docker compose build --no-cache api
docker compose up -d api
```

For non-patch changes (compose.yml, config, secrets) layer caching is fine:

```bash
docker compose up --build -d api
```

## Upgrading LibreChat

```bash
cd ~/Desktop/lga
./bin/upgrade-chatui <new-version>
```

The script:

1. Fetches the upstream Dockerfile for the new version and extracts
   `LIBRECHAT_NODE_IMAGE` and `UV_IMAGE` — reports if they changed
2. Clones the new version into a temp dir
3. Applies every patch for real (not `--dry-run`) in the temp clone
4. On failure: prints a paste-ready prompt for Merlin to rewrite the diff
5. On success: updates `LIBRECHAT_VERSION` in `compose.yml` via atomic Python write

```bash
./bin/upgrade-chatui v0.9.0 --dry-run    # verify only, write nothing
./bin/upgrade-chatui v0.9.0 --build      # verify + docker compose build api
./bin/upgrade-chatui v0.9.0 --force-fuzz # treat fuzz as warning not failure
```

### When a Patch Fails at Upgrade

The script prints a self-contained prompt:

```
--- paste to Merlin to fix ---
Patch 003-sidebar-min-width--UnifiedSidebar.diff failed against v0.9.0.

== PATCH ==
<full diff content>

== REJECTED HUNKS ==
<.rej file content>

== CURRENT SOURCE ==
<source file with line numbers>

Task: rewrite the patch so it applies cleanly, preserving intent.
--- end of paste ---
```

Paste it in chat. Merlin rewrites the diff. Replace the patch file. Re-run upgrade-chatui.

### Fuzz Warning

Fuzz means patch context lines didn't match exactly but the patch landed
nearby. It exits non-zero by default — requires `--force-fuzz` to skip.
Always review fuzz-applied patches manually; they may have landed in a
semantically wrong location after upstream refactors.

## Known Quirks

**Patches 003 and 006 both touch `UnifiedSidebar.tsx`.**
They are independent changes (003 = drag floor, 006 = overflow).
Patch 006 applies with fuzz 1 due to 003 shifting line numbers — this is
expected and harmless. Watch for this at upgrade time.

**`matchSorter` overrides sort order.**
When a filter is active, `matchSorter` re-ranks by relevance. Sorted order
only applies when the search box is empty (patch 009 handles this).

**The `node` user in `node:20-alpine` is UID/GID 1000,** matching
`compose.yml`'s `user: "1000:1000"`. No permission conflicts.

**`npm ci` is required** — it reads the lockfile from the cloned repo.
Without it `node_modules` doesn't exist and the build fails.

**Build time** is ~10–15 min on first run (network + npm ci + React compile).
Subsequent rebuilds that don't change patches are fast (git clone is the
only uncached layer before the patch step).

If you made updates to the skill, remember to push that to database and to interface.
