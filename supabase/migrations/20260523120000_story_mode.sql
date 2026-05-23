-- Phase 3: Story mode curated phrase sequences
CREATE TABLE IF NOT EXISTS stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title_urdu TEXT NOT NULL,
  connector_text TEXT NOT NULL,
  phrase_ids UUID[] NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "stories read" ON stories;
CREATE POLICY "stories read" ON stories
  FOR SELECT
  USING (is_active = true);

INSERT INTO stories (title_urdu, connector_text, phrase_ids, display_order)
VALUES
  (
    'غصے کے محاورے',
    'اب اگلا غصے والا محاورہ…',
    ARRAY[
      (SELECT id FROM phrases WHERE urdu_phrase = 'آگ بگولہ ہونا' AND is_active = true LIMIT 1),
      (SELECT id FROM phrases WHERE urdu_phrase = 'ناک میں دم کرنا' AND is_active = true LIMIT 1),
      (SELECT id FROM phrases WHERE urdu_phrase = 'آستین کا سانپ ہونا' AND is_active = true LIMIT 1)
    ],
    1
  ),
  (
    'خوشی کے محاورے',
    'اب خوشی کا اگلا محاورہ…',
    ARRAY[
      (SELECT id FROM phrases WHERE urdu_phrase = 'باغ باغ ہونا' AND is_active = true LIMIT 1),
      (SELECT id FROM phrases WHERE urdu_phrase = 'آنکھوں کا تارا ہونا' AND is_active = true LIMIT 1),
      (SELECT id FROM phrases WHERE urdu_phrase = 'طوطے اڑ جانا' AND is_active = true LIMIT 1)
    ],
    2
  ),
  (
    'دھوکے کے محاورے',
    'اب دھوکے کا اگلا محاورہ…',
    ARRAY[
      (SELECT id FROM phrases WHERE urdu_phrase = 'ہاتھ صاف کرنا' AND is_active = true LIMIT 1),
      (SELECT id FROM phrases WHERE urdu_phrase = 'گڑے مردے اکھاڑنا' AND is_active = true LIMIT 1),
      (SELECT id FROM phrases WHERE urdu_phrase = 'پیٹھ پیچھے بات کرنا' AND is_active = true LIMIT 1)
    ],
    3
  )
ON CONFLICT DO NOTHING;
