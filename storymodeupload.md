# Story Mode Upload Guide

Add or update a story by writing JSON and running the import script. The app reads from Supabase `stories` — no app rebuild needed.

---

## Step 1 — Confirm idioms exist in DB

Each idiom must already exist in `phrases` with `is_active = true`.

Use the exact **`urdu_phrase`** string (not image filename, not UUID).

**Example** (valid idiom refs):

```json
"idioms": [
  "آگ بگولہ ہونا",
  "ناک میں دم کرنا",
  "آستین کا سانپ ہونا"
]
```

If import fails with `No active phrase for urdu_phrase`, fix the spelling or push the phrase first:

```bash
dart run tool/push_phrases_from_json.dart your_phrases.json
```

---

## Step 2 — Write story JSON

Save under `stories/` (e.g. `stories/my_story.json`).

### Full example (3 idioms → 4 lines)

```json
{
  "slug": "ghussay_kay_muhawray",
  "title_urdu": "غصے کے محاورے",
  "title_en": "Anger idioms",
  "icon": "fire",
  "display_order": 1,
  "is_active": true,
  "idioms": [
    "آگ بگولہ ہونا",
    "ناک میں دم کرنا",
    "آستین کا سانپ ہونا"
  ],
  "story_lines_urdu": [
    "آج علی بہت غصے میں تھا…",
    "اب اگلا غصے والا محاورہ…",
    "اب اگلا غصے والا محاورہ…",
    "غصہ تھوڑا اُترا — کہانی یہیں رکتی ہے۔"
  ]
}
```

### Field reference

| Field | Required | Example |
|-------|----------|---------|
| `slug` | yes | `"ghussay_kay_muhawray"` — unique key; re-import updates same row |
| `title_urdu` | yes | `"غصے کے محاورے"` — shown on story picker card |
| `title_en` | no | `"Anger idioms"` |
| `icon` | yes | `"fire"` — see icon list below |
| `display_order` | yes | `1` — sort order on story screen (lower = higher) |
| `is_active` | no | `true` — `false` hides from app |
| `idioms` | yes | array of `urdu_phrase` strings, **play order** |
| `story_lines_urdu` | yes | array of Urdu narration lines (see rule below) |

### Story lines rule

```
story_lines_urdu.length === idioms.length + 1
```

| Line index | Shown when |
|------------|------------|
| `[0]` | Before first idiom (intro) |
| `[1]` … `[N-1]` | After idiom 1…N−1, before next card |
| `[N]` | After last idiom, before session summary (closing) |

**2-idiom example:**

```json
{
  "slug": "dosti_ki_kahani",
  "title_urdu": "دوستی کی کہانی",
  "icon": "heart",
  "display_order": 4,
  "is_active": true,
  "idioms": ["باغ باغ ہونا", "آنکھوں کا تارا ہونا"],
  "story_lines_urdu": [
    "وہ اپنے دوست کو بہت چاہتا تھا…",
    "جب خوشی ملی تو سب بدل گیا…",
    "دوستی ہمیشہ رہے گی — کہانی ختم۔"
  ]
}
```

(2 idioms + 3 lines ✓)

### Allowed `icon` values

`fire` · `flower` · `masks` · `book` · `star` · `heart` · `lightning` · `moon` · `sun` · `handshake` · `question`

---

## Step 3 — Configure `.env`

Repo root `.env` must have:

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

Service role key required (RLS blocks anon writes on `stories`).

---

## Step 4 — Dry run (validate only)

```bash
dart run tool/import_story.dart --dry-run stories/my_story.json
```

**Example output:**

```
--- C:\jhatpat\stories/my_story.json
  slug: ghussay_kay_muhawray
  idioms: 3 → 4b51fc43-..., 029e17d6-..., cddf7465-...
  lines: 4
  icon: fire  order: 1
  (dry run OK)
```

Fix any error before uploading.

**Common failures:**

| Error | Fix |
|-------|-----|
| `story_lines_urdu must have N lines` | Add/remove lines until count = idioms + 1 |
| `No active phrase for urdu_phrase` | Fix spelling or push phrase to DB |
| `Invalid icon` | Use a key from the icon list |
| `Missing slug` | Add `"slug": "..."` |

---

## Step 5 — Upload

Single file:

```bash
dart run tool/import_story.dart stories/my_story.json
```

All JSON in folder:

```bash
dart run tool/import_story.dart stories/
```

**Example success:**

```
  upserted OK

Imported 1 / 1 stories.
```

Upsert is by `slug` — same slug updates; new slug inserts.

---

## Step 6 — Verify in app

1. Full restart app (not hot reload).
2. Home → **کہانی موڈ** → your story appears at `display_order`.
3. Play through: intro line → cards in `idioms` order → closing line → summary.

---

## Quick checklist

- [ ] Every `idioms[]` entry matches `phrases.urdu_phrase` exactly  
- [ ] `story_lines_urdu` has **one more line than idioms**  
- [ ] `slug` is unique and stable  
- [ ] Dry run passes  
- [ ] Upload succeeds  
- [ ] Tested in app  

---

## Reference files

| Path | Purpose |
|------|---------|
| [`stories/`](stories/) | Story JSON files |
| [`tool/import_story.dart`](tool/import_story.dart) | Import script |
| [`supabase/migrations/20260524120000_story_lines_and_import.sql`](supabase/migrations/20260524120000_story_lines_and_import.sql) | DB schema |
