# Notebooku Sync API

Default local endpoint:

```text
http://127.0.0.1:5001/notebooku/us-central1/api
```

## Health

```http
GET /health
```

## List Notes

```http
GET /notes/{userId}
```

Returns notes ordered by `updatedAt` descending.

## Create Note

```http
POST /notes/{userId}
Content-Type: application/json
```

```json
{
  "title": "Meeting produk",
  "content": "- [ ] Kirim summary",
  "category": "work",
  "color": "sky",
  "createdAt": "2026-06-10T10:00:00.000Z",
  "updatedAt": "2026-06-10T10:00:00.000Z",
  "isPinned": false
}
```

## Upsert Note

```http
PUT /notes/{userId}/{noteId}
Content-Type: application/json
```

Use this for offline-first sync because the mobile app already owns the note id.

## Delete Note

```http
DELETE /notes/{userId}/{noteId}
```

## Summary

```http
GET /summary/{userId}
```

Returns total notes, pinned notes, and task-like notes.
