---
name: ai-chat-memory
description: Use when the user asks to remember something, says "remember this", wants to save, update, or delete a memory, or asks what you remember about a topic.
---

# Memory Management

Memories are stored in the database. For connection details, see the `ai-chat` skill.

## Tooling

All memory operations are simple enough to use mongosh directly:

```bash
mongosh mongodb:27017/LibreChat --quiet
```

If mongosh is not installed, install it once to `/root/bin` (persists across sessions):

```bash
VERSION=$(curl -sf https://api.github.com/repos/mongodb-js/mongosh/releases/latest | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'].lstrip('v'))")
curl -fsSL "https://downloads.mongodb.com/compass/mongosh-${VERSION}-linux-x64.tgz" | tar -xz -C /root
mv /root/mongosh-${VERSION}-linux-x64/bin/mongosh /root/bin/mongosh && chmod +x /root/bin/mongosh
rm -rf /root/mongosh-${VERSION}-linux-x64
```

If you need pymongo instead (e.g. for bulk writes in a script), install it once to `/root/pylib` (persists):

```bash
pip3 install pymongo --target /root/pylib -q --break-system-packages
# use with: PYTHONPATH=/root/pylib python3 << 'PYEOF' ... PYEOF
```

Collection: `memoryentries`

## Schema

| Field        | Notes                                                           |
| ------------ | --------------------------------------------------------------- |
| `userId`     | Always the operator's user ObjectId: `69e6beb74aa4d2249360a4ab` |
| `key`        | Snake-case identifier — short, descriptive, stable              |
| `value`      | Free-text content of the memory                                 |
| `tokenCount` | Approximate token count of `value` — estimate if unknown        |
| `updated_at` | Set to `new Date()` on every write                              |
| `__v`        | `0`                                                             |

## Read All Memories

```javascript
db.memoryentries
  .find({ userId: ObjectId("69e6beb74aa4d2249360a4ab") }, { key: 1, value: 1, _id: 0 })
  .toArray();
```

## Save a New Memory

```javascript
db.memoryentries.insertOne({
  userId: ObjectId("69e6beb74aa4d2249360a4ab"),
  key: "snake_case_key",
  value: "Memory content here.",
  tokenCount: 20,
  updated_at: new Date(),
  __v: 0,
});
```

## Update an Existing Memory

```javascript
db.memoryentries.updateOne(
  { userId: ObjectId("69e6beb74aa4d2249360a4ab"), key: "snake_case_key" },
  { $set: { value: "Updated content.", tokenCount: 25, updated_at: new Date() } },
);
```

## Delete a Memory

```javascript
db.memoryentries.deleteOne({
  userId: ObjectId("69e6beb74aa4d2249360a4ab"),
  key: "snake_case_key",
});
```

## Key Conventions

- Use snake_case: `project_preferences`, `go_style_notes`
- Be specific enough that the key is self-documenting
- Prefer updating an existing memory over creating a duplicate
