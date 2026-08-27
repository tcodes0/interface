---
name: lga-websearch
description: Use when debugging or tuning LGA's SearXNG search stack directly -- verifying category/engine config, testing queries against specific categories, or diagnosing why the web_search tool returns unexpected results.
---

# Hitting LGA's SearXNG Directly

LGA runs its own SearXNG instance (compose service `websearch`) that backs the `web_search` tool.
When you need ground truth about search config -- categories, engines, whether a token/key is wired
up correctly -- query it directly instead of going through the tool. Direct access gives you full
JSON responses, per-result engine/category metadata, and unlimited iteration in one turn (the
`web_search` tool caps at one call per reply and hides all of this).

## Base URL

```
http://websearch:8080
```

Reachable from the bench shell. Note: the container's public brand name is "SearXNG" but the
compose service/hostname is `websearch` -- don't guess port 8888 or similar, it's `8080`.

## Inspect the live config

Always start here when something looks off -- this reflects the config actually loaded by the
running container, post-templating (see "Config source & templating" below).

```bash
curl -s 'http://websearch:8080/config' | python3 -m json.tool
```

Useful extractions:

```bash
# List active categories
curl -s 'http://websearch:8080/config' | python3 -c "import json,sys; print(json.load(sys.stdin)['categories'])"

# List engines and their assigned categories
curl -s 'http://websearch:8080/config' | python3 -c "
import json,sys
for e in json.load(sys.stdin)['engines']:
    print(e['name'], e.get('categories'))
"
```

## Running a search

Use `GET /search` with query params, `-G --data-urlencode` from curl to keep escaping sane:

```bash
curl -s -G 'http://websearch:8080/search' \
  --data-urlencode 'q=<query>' \
  --data-urlencode 'categories=<category>' \
  --data-urlencode 'format=json'
```

- `q` -- the query string.
- `categories` -- **singular category per request in practice**; comma-joining
  (`categories=general,it`) is accepted but just unions engines, it does not give you clean
  per-category attribution in the response. Omit entirely to search the default category (`general`).
- `format=json` -- gives structured output. Omit to get the HTML page (see below for when that's
  more useful).

Parse JSON results with Python for a quick signal check:

```bash
curl -s -G 'http://websearch:8080/search' --data-urlencode 'q=python' \
  --data-urlencode 'categories=it' --data-urlencode 'format=json' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['number_of_results'], len(d['results']))"
```

Fields worth checking per result: `engine`, `category`, `score`, `positions`, `url`, `title`,
`publishedDate`.

### Known quirk: occasional empty JSON on first GET

A `format=json` GET has intermittently returned `{"number_of_results": 0, "results": []}` on a
first attempt with otherwise-valid params, then returned real results on retry (or via `-X POST`
with the same params as form data).

### `number_of_results` is not the count to trust

SearXNG's own `number_of_results` field in the JSON response is frequently `0` even when
`len(results)` is large (tens to thousands). Always check `len(d['results'])`, not
`d['number_of_results']`.

## Falling back to HTML output

If JSON output looks suspicious (empty when it shouldn't be), fetch the HTML page instead as a
sanity check -- it goes through the same search path but is easier to eyeball raw:

```bash
curl -s -G 'http://websearch:8080/search' --data-urlencode 'q=<query>' \
  --data-urlencode 'categories=<category>' -o /tmp/out.html
grep -c 'href="http' /tmp/out.html   # rough result count
```

## Picking good queries per category

Engines differ in what they index, so query style matters:

- `general` / `it` / `code` / `science` -- natural language works fine (these hit
  Brave/Google/GitHub/arXiv/Semantic Scholar/Stack Exchange/MDN style engines).
- `huggingface` -- only 3 engines live here (`huggingface`, `huggingface datasets`,
  `huggingface spaces`), and they match against repo/dataset/space **names and slugs**, not
  descriptive phrases. `q=python` or `q=llama` finds plenty; `q=large language model training
techniques` returns nothing useful even though the category is fully healthy. If a query against
  `huggingface` comes back empty, try a bare keyword before assuming the category is broken.

## Config source & templating

The source template lives at `<lga repo>/services/websearch/config/settings.yml.template`;
`categories_as_tabs` and the `engines:` list there are the actual source of truth for which categories/engines exist.
