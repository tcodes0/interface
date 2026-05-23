---
name: lga-patching
description: Use when writing, fixing, or validating LibreChat patches for the LGA project, or when working on files under images/librechat/patches/.
---

# LGA — LibreChat Patch Workflow

Patches live in the `lga` repo at `images/librechat/patches/`.
Clone URL: `git@github.com:rthomazel/lga.git`

## Paths

| What | Where |
| ---- | ----- |
| Patch files | `images/librechat/patches/NNN-*.diff` |
| Patching docs | `doc/patching-librechat.md` |
| TSC environment | `/projects/scratchpad/librechat-tsc` (persistent, do not delete) |
| Upgrade script | `bin/upgrade-chatui` |

The TSC environment is a pinned clone of LibreChat at the current `LIBRECHAT_VERSION` (see `compose.yml`) with `node_modules` already installed. Rebuilding it takes ~5 min.

## Mandatory Validation After Every Patch Write or Fix

Always run both checks before committing.

### 1 — Full sequence apply check

Reset the TSC clone, then apply every patch in order:

```bash
git -C /projects/scratchpad/librechat-tsc checkout -- .
for p in $(ls /path/to/lga-clone/images/librechat/patches/*.diff | sort); do
  printf '%%-70s ' "$(basename $p)"
  patch -p1 -d /projects/scratchpad/librechat-tsc < $p && echo CLEAN || echo FAILED
done
```

Every patch must print `CLEAN`. A `FAILED` means the patch itself or its hunk header (line count / offset) is wrong.

### 2 — TSC check on touched files

Filter by the filename(s) you changed — ~152 pre-existing upstream errors exist in unrelated files; ignore those.

```bash
cd /projects/scratchpad/librechat-tsc
npx tsc --noEmit -p client/tsconfig.json 2>&1 | grep 'error TS' | grep -E 'File1|File2'
```

No output = clean. Any output means the patch introduces a type error.

## Writing a New Patch

### 1. Reset and save the original

```bash
git -C /projects/scratchpad/librechat-tsc checkout -- .
cp /projects/scratchpad/librechat-tsc/client/src/path/to/File.tsx /tmp/File.orig.tsx
```

### 2. Edit the target file

Edit directly in `/projects/scratchpad/librechat-tsc/`.

### 3. Run mandatory validation (see above)

TSC-check before generating the diff.

### 4. Generate the diff

```bash
diff -u \
  --label a/client/src/path/to/File.tsx \
  --label b/client/src/path/to/File.tsx \
  /tmp/File.orig.tsx \
  /projects/scratchpad/librechat-tsc/client/src/path/to/File.tsx \
  > images/librechat/patches/NNN-description--path-File.diff
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

## Patch Conventions

- Naming: `NNN-short-description--Source-File-ComponentName.diff` (NNN zero-padded)
- Format: unified diff, `-p1` (paths relative to repo root)
- Applied in filename sort order — if patch B depends on A, A must have a lower number
- Multi-file patches concatenate multiple `diff -u` outputs into one file

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

Always use `--no-cache` — Docker caches the patch layer by content hash.

```bash
cd ~/Desktop/lga
docker compose build --no-cache api
docker compose up -d api
```

## Upgrading LibreChat

```bash
cd ~/Desktop/lga
./bin/upgrade-chatui <new-version>           # verify only
./bin/upgrade-chatui <new-version> --build   # verify + rebuild
```

See `doc/patching-librechat.md` for the full upgrade procedure and fuzz details.
