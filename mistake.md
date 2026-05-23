# Agent Mistake Log

Purpose: record real mistakes so they are not repeated. Use entries to update Cursor rules and review patterns before similar work.

---

## 1. Story mode crash — null `iconKey` / `sessionPhraseIds`

### Issue

Story picker screen showed a red Flutter error:

`type 'Null' is not a subtype of type 'String' of 'function result'`

Stack pointed at `StoryModel.iconKey` in `StoryPickCard`. A related error hit `GameState.sessionPhraseIds` during gameplay after hot reload.

### Why it happened

1. **New non-nullable fields added to existing models** (`iconKey`, `storyLinesUrdu`, `sessionPhraseIds`) while the app was running. Hot reload can leave old in-memory instances with **null** where new fields should be non-null `String` / `List<String>`.

2. **`StoryModel.fromJson` used loose casts** (`as String? ?? 'book'`) without normalizing missing keys, wrong JSON keys (`icon` vs `icon_key`), or empty strings. That is fragile when the DB or API shape drifts.

3. **Assumed DB rows always had `icon_key`** after migration; did not harden the client parse path before UI read the field.

4. **Treated “analyzer clean” as enough** without checking terminal stack traces that named the exact getter (`StoryModel.iconKey`).

### Solution

- Harden `StoryModel.fromJson` with `_readString` / `_readStringList` and fallback `icon_key` → `icon` → `'book'`.
- Ensure `GameState.initial()` and `copyWith` never leave list fields unset.
- Filter invalid stories in `StoryRepository` (empty id, title, or phrase list).
- Tell user to **full restart** (`flutter run`), not hot reload, after model/schema changes.
- Import `jhoothi_chamak.json` via `tool/import_story.dart` so data matches the new schema.

### Lesson learned

- After adding fields to **data models used by Riverpod + Supabase JSON**, always: defensive `fromJson`, safe defaults in `initial()` / `copyWith`, and **require full app restart** in the handoff note.
- When UI shows `function result` + `Null` + `String`, read the **stack trace line** (e.g. `#0 StoryModel.iconKey`) — do not guess at generic “null safety” causes.
- New DB columns are not enough; **client parse + UI** must tolerate null/missing until restart and bad rows are filtered.

### Code example (optional)

```dart
// Prefer explicit readers instead of bare casts
static String _readString(Object? raw, {String fallback = ''}) {
  if (raw == null) return fallback;
  final String value = raw.toString().trim();
  return value.isEmpty ? fallback : value;
}

// fromJson
iconKey: _readString(json['icon_key'] ?? json['icon'], fallback: 'book'),
```

---

<!-- Add new entries below with the next number -->
