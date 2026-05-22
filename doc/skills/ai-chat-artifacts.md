---
name: ai-chat-artifacts
description: Use when presenting substantial, self-contained content — diagrams, HTML pages, React components, markdown documents, SVGs, or when the user mentions an artifact explicitly.
---

# Artifacts

Artifacts are rendered in a separate UI panel. Use them for substantial, self-contained content. Prefer inline responses for short or simple content.

## Syntax

````
:::artifact{identifier="my-id" type="text/html" title="My Title"}
```html
<!-- content here -->
```
:::
````

- `identifier` — stable kebab-case ID; reuse it when updating an existing artifact
- `type` — MIME type from the table below
- `title` — human-readable label shown in the panel

> Use 4 backticks for the outer fence when the artifact body itself contains triple-backtick code blocks.

## Supported Types

| Type                                | MIME                      |
| ----------------------------------- | ------------------------- |
| HTML (single-file, JS+CSS included) | `text/html`               |
| SVG                                 | `image/svg+xml`           |
| Markdown                            | `text/markdown`           |
| Mermaid diagrams                    | `application/vnd.mermaid` |
| React components                    | `application/vnd.react`   |
| Code, plain text, etc.              | `text/markdown`           |

## Rules

- One artifact per message
- Always provide complete content — no placeholders or ellipses
- Reuse the same `identifier` when updating an existing artifact
- Placeholder images: `<img src="/api/placeholder/400/320" alt="placeholder" />`
- External scripts and images are blocked, except: `https://cdnjs.cloudflare.com`

## React Notes

- Styling via Tailwind only (no arbitrary values)
- Available: `lucide-react`, `recharts`, `three.js`, `date-fns`, `react-day-picker`, `shadcn/ui`
- Must use default export, no required props

## Rendering a Diff

Diffs have no styling in `text/markdown` — always use `text/html`. Use a dark background, monospace font, and one `div` per line (not `pre` + `span`) so background colors fill the full line width without spacing issues.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <style>
      body {
        background: #0f172a;
        color: #e2e8f0;
        font-family: monospace;
        font-size: 13px;
        padding: 1.5rem;
        line-height: 1.35;
      }
      .add {
        color: #86efac;
        background: #14532d44;
      }
      .del {
        color: #fca5a5;
        background: #7f1d1d44;
      }
      .hunk {
        color: #67e8f9;
      }
      .meta {
        color: #94a3b8;
      }
      .ctx {
        color: #cbd5e1;
      }
    </style>
  </head>
  <body>
    <div class="meta">--- a/path/to/file</div>
    <div class="meta">+++ b/path/to/file</div>
    <div class="hunk">@@ -1,4 +1,4 @@</div>
    <div class="ctx">unchanged line</div>
    <div class="del">-removed line</div>
    <div class="add">+added line</div>
  </body>
</html>
```

Class reference: `.add` green, `.del` red, `.hunk` cyan, `.meta` muted, `.ctx` plain.

## Quirks

- Code blocks inside `text/markdown` artifacts work fine — use **4 backticks** for the outer fence to avoid the inner ` ``` ` closing it prematurely
- The artifact panel runs in dark mode — always write HTML artifacts with an explicit dark background (e.g. `background: #0f172a; color: #e2e8f0`)
- Prefer `text/html` over `text/markdown` for structured documents with tables, sections, or code blocks — markdown rendering can collapse line breaks between headings and paragraphs
