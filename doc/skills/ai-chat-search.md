---
name: ai-chat-search
description: Use when the user mentions search not working, wants to inspect or repair the Meilisearch index, or asks how LibreChat search is architected.
---

# LibreChat Search — Architecture & Ops

## How search works end-to-end

1. User types in the **Search Messages** bar → `SearchBar.tsx` sets `store.search.debouncedQuery` (Recoil atom)
2. React Router navigates to `/search` → `Search.tsx` mounts and calls `useMessagesInfiniteQuery({ search: query })`
3. That hits `GET /api/messages?search=<query>` (backend `messages.js` route)
4. Backend calls `db.searchMessages(query, { filter: 'user = "<userId>"' }, true)` → **Meilisearch** `messages` index full-text search
5. Results carry `conversationId`; backend calls `db.getConvosQueried(userId, hits)` to enrich each hit with `title`, `model`, etc.
6. Right pane renders the enriched message hits via `SearchMessage` components

**The sidebar** (`ConversationsSection`) is independent — it always shows all conversations. When search is active it shows **only conversations with matching messages** (patch 020 v2), derived from the same message search query — zero extra network cost.

## Two separate search endpoints

| Endpoint | What it searches | Used by |
|---|---|---|
| `GET /api/messages?search=` | Meilisearch `messages` index (full-text) | Search route right pane |
| `GET /api/convos?search=` | MongoDB title match | Not used for sidebar — title search is useless for message content |

Conversation title search is essentially useless for message retrieval — never pass `search` to the convos endpoint for the sidebar.

## Meilisearch indexes

| Index | Primary key | Filterable | What's in it |
|---|---|---|---|
| `messages` | `messageId` | `user` | `messageId`, `conversationId`, `user`, `sender`, `text` |
| `convos` | `conversationId` | `user` | `conversationId`, `title`, `user`, `tags` |

## The content-parts indexing bug (patch 021)

**Problem:** Agent messages store their response in `content[]` typed parts (`type: text`, `type: think`, `type: tool_call`) with `text: ""`. The `mongoMeili` plugin's per-save hook (`preprocessObjectForIndex`) correctly calls `parseTextParts(content)` to extract text. But the bulk sync path (`processSyncBatch`) just does `_.pick(doc, attributesToIndex)` — `content` is not in `attributesToIndex`, so bulk sync always indexed an empty `text` for every agent message.

**Impact:** All historical agent messages (and their thoughts) are invisible to search after any bulk re-index (e.g. after wiping Meilisearch). New messages saved post-startup are fine.

**Fix (patch 021):** In `syncWithMeili`, add `content` to the `.select()`. In `processSyncBatch`, apply `parseTextParts(doc.content)` when `text` is empty and `content` is present.

**What `parseTextParts` includes by default (`skipReasoning: false`):**
- `type: text` — agent response text ✅
- `type: think` — reasoning/thoughts ✅
- `type: tool_call` — skipped (not a text type) ✅

## Sync mechanism

The `_meiliIndex` (or `meiliIndex` in the flag reset context — note: the sync code uses `_meiliIndex`, the reset commands use `meiliIndex` because the schema field is aliased) boolean on each MongoDB document tracks whether it has been pushed to Meilisearch.

`indexSync.js` runs at startup and checks `getSyncProgress()` (counts `_meiliIndex: true` vs total). Key thresholds:
- `MEILI_SYNC_THRESHOLD` (default `1000`) — if fewer than this many documents are unindexed, skip bulk sync. Protects against noisy re-syncs on large instances.
- `MEILI_SYNC_BATCH_SIZE` (default `100`) — documents per batch during `syncWithMeili`
- `MEILI_SYNC_DELAY_MS` (default `100`) — ms between batches

## When Meilisearch is wiped — recovery procedure

Wiping Meilisearch leaves MongoDB `_meiliIndex` flags as `true`. `indexSync` sees "all synced" and does nothing.

**Step 1 — Reset flags in MongoDB:**
```bash
mongosh mongodb:27017/LibreChat --quiet --eval '
  db.messages.updateMany({}, { $set: { _meiliIndex: false } });
  db.conversations.updateMany({}, { $set: { _meiliIndex: false } });
  print("reset done");
'
```

**Step 2 — Restart the API** to trigger `indexSync`:
```bash
docker compose restart api
```

**Step 3 — Watch logs:**
```bash
docker compose logs -f api | grep indexSync
```
Expect: `Starting message sync (N unindexed)` → `Sync completed successfully`.

> ⚠️ If fewer than `MEILI_SYNC_THRESHOLD` (1000) docs are unindexed after the reset, `indexSync` will still skip. Force a full sync by setting `MEILI_SYNC_THRESHOLD=0` temporarily or by using the manual push below.

## Manual push via Python (bypasses the sync mechanism)

Useful for immediate recovery without a restart, or when `indexSync` is skipping due to threshold:

```python
# PYTHONPATH=/root/pylib python3 << 'PYEOF'
from pymongo import MongoClient
from urllib.request import urlopen, Request
from urllib.error import HTTPError
import json, time

db = MongoClient('mongodb', 27017)['LibreChat']
MEILI = 'http://meilisearch:7700'
KEY = 'YOUR_MEILI_MASTER_KEY'  # from compose .env
HEADERS = {'Authorization': f'Bearer {KEY}', 'Content-Type': 'application/json'}

def meili_post(path, payload):
    data = json.dumps(payload).encode()
    req = Request(f'{MEILI}{path}', data=data, method='POST', headers=HEADERS)
    try:
        with urlopen(req, timeout=30) as r: return r.status, json.loads(r.read())
    except HTTPError as e: return e.code, json.loads(e.read())

def extract_text(content):
    """Extract text+think parts from content array (mirrors parseTextParts)."""
    parts = []
    for p in (content or []):
        if not isinstance(p, dict): continue
        if p.get('type') == 'text':
            t = p.get('text', '')
            parts.append(t if isinstance(t, str) else (t or {}).get('value', ''))
        elif p.get('type') == 'think':
            parts.append(p.get('think', ''))
    return ' '.join(filter(None, parts))

BATCH = 500
pushed, batch, batch_ids = 0, [], []
for msg in db.messages.find({}, {'messageId':1,'text':1,'content':1,'sender':1,'user':1,'conversationId':1,'_id':0}).batch_size(BATCH):
    if not msg.get('messageId'): continue
    text = msg.get('text') or extract_text(msg.get('content', []))
    if not text: continue
    batch.append({'messageId': msg['messageId'], 'text': text,
                  'sender': msg.get('sender',''), 'user': str(msg.get('user','')),
                  'conversationId': msg.get('conversationId','')})
    batch_ids.append(msg['messageId'])
    if len(batch) >= BATCH:
        status, _ = meili_post('/indexes/messages/documents', batch)
        if status in (200,202):
            pushed += len(batch)
            db.messages.update_many({'messageId':{'$in':batch_ids}}, {'$set':{'_meiliIndex':True}})
        batch, batch_ids = [], []
        time.sleep(0.05)
if batch:
    status, _ = meili_post('/indexes/messages/documents', batch)
    if status in (200,202):
        pushed += len(batch)
        db.messages.update_many({'messageId':{'$in':batch_ids}}, {'$set':{'_meiliIndex':True}})
print(f'Pushed: {pushed}')
# PYEOF
```

## Verify Meilisearch state

```bash
# Document counts in each index
curl -s http://meilisearch:7700/indexes/messages/stats \
  -H 'Authorization: Bearer YOUR_KEY' | python3 -c "import sys,json; d=json.load(sys.stdin); print('messages:', d['numberOfDocuments'], 'indexing:', d['isIndexing'])"

# Test a search query
curl -s http://meilisearch:7700/indexes/messages/search \
  -H 'Authorization: Bearer YOUR_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"q": "YOUR_TERM", "filter": "user = \"USER_ID\"", "limit": 5}' | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print('hits:', d.get('estimatedTotalHits',0))"

# MongoDB flag counts
mongosh mongodb:27017/LibreChat --quiet --eval '
  print("indexed:", db.messages.countDocuments({_meiliIndex:true}));
  print("pending:", db.messages.countDocuments({_meiliIndex:{$ne:true}}));
'
```

## Known Meilisearch key location

`MEILI_MASTER_KEY` is set in the compose `.env` file (not committed). For the LGA instance it is loaded from the secrets mount — check `compose.yml` env_file reference.

The Meilisearch container is accessible as `meilisearch:7700` from within the jail network (confirmed). No auth needed for `/health`, master key required for all index operations.

## The FlowStateManager warning

```
warn: [FlowStateManager] completeFlow: flow not found
```

This is benign. It appears when `indexSync` completes faster than the distributed lock TTL check. The sync ran successfully — the warning just means the flow state entry had already been cleaned up by the time the completion handler tried to remove it. Not a bug, safe to ignore.
