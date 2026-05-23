-- Story import system: slug, icon, per-line narration (N idioms => N+1 lines)

ALTER TABLE stories
  ADD COLUMN IF NOT EXISTS slug TEXT,
  ADD COLUMN IF NOT EXISTS icon_key TEXT NOT NULL DEFAULT 'book',
  ADD COLUMN IF NOT EXISTS title_en TEXT,
  ADD COLUMN IF NOT EXISTS story_lines_urdu TEXT[];

CREATE UNIQUE INDEX IF NOT EXISTS stories_slug_unique ON stories (slug)
  WHERE slug IS NOT NULL;

-- Backfill seeded rows (3 idioms => 4 lines each)
UPDATE stories SET
  slug = 'ghussay_kay_muhawray',
  icon_key = 'fire',
  title_en = 'Anger idioms',
  story_lines_urdu = ARRAY[
    'آج علی بہت غصے میں تھا…',
    'اب اگلا غصے والا محاورہ…',
    'اب اگلا غصے والا محاورہ…',
    'غصہ تھوڑا اُترا — کہانی یہیں رکتی ہے۔'
  ]
WHERE title_urdu = 'غصے کے محاورے' AND (slug IS NULL OR story_lines_urdu IS NULL);

UPDATE stories SET
  slug = 'khushi_kay_muhawray',
  icon_key = 'flower',
  title_en = 'Joy idioms',
  story_lines_urdu = ARRAY[
    'آج سب کے چہروں پر مسکراہٹ تھی…',
    'اب خوشی کا اگلا محاورہ…',
    'اب خوشی کا اگلا محاورہ…',
    'دل خوش ہو گیا — کہانی مکمل۔'
  ]
WHERE title_urdu = 'خوشی کے محاورے' AND (slug IS NULL OR story_lines_urdu IS NULL);

UPDATE stories SET
  slug = 'dhokay_kay_muhawray',
  icon_key = 'masks',
  title_en = 'Deception idioms',
  story_lines_urdu = ARRAY[
    'کسی نے دھوکا دیا، مگر سب کچھ سامنے آ گیا…',
    'اب دھوکے کا اگلا محاورہ…',
    'اب دھوکے کا اگلا محاورہ…',
    'سچ سامنے آ چکا — کہانی ختم۔'
  ]
WHERE title_urdu = 'دھوکے کے محاورے' AND (slug IS NULL OR story_lines_urdu IS NULL);

-- Optional sanity: story_lines count should be phrase count + 1 when both set
-- (enforced in import script; not a DB CHECK so partial rows still load)
