-- Mastery layer: user_progress, phrases depth, wrong_options typing

-- user_progress mastery
ALTER TABLE user_progress
  ADD COLUMN IF NOT EXISTS mastery_level int DEFAULT 0
    CHECK (mastery_level BETWEEN 0 AND 5),
  ADD COLUMN IF NOT EXISTS last_seen_at timestamptz DEFAULT now(),
  ADD COLUMN IF NOT EXISTS times_correct int DEFAULT 0,
  ADD COLUMN IF NOT EXISTS times_seen int DEFAULT 0;

-- phrases depth fields
ALTER TABLE phrases
  ADD COLUMN IF NOT EXISTS scenario_urdu text,
  ADD COLUMN IF NOT EXISTS blank_word_index int;

-- wrong_options typing
ALTER TABLE wrong_options
  ADD COLUMN IF NOT EXISTS option_type text DEFAULT 'meaning'
    CHECK (option_type IN ('meaning', 'blank_word'));

UPDATE user_progress SET mastery_level = 0 WHERE mastery_level IS NULL;
UPDATE wrong_options SET option_type = 'meaning' WHERE option_type IS NULL;

-- blank_word_index: 0-based token index in example_sentence (split on whitespace)
UPDATE phrases SET blank_word_index = v.idx
FROM (VALUES
  ('طوطے اڑ جانا', 7),
  ('ہاتھ صاف کرنا', 5),
  ('دانتوں تلے انگلی دبانا', 9),
  ('آنکھوں کا تارا ہونا', 8),
  ('رگوں میں بس جانا', 7),
  ('چکا چوند ہونا', 7),
  ('آگ بگولہ ہونا', 6),
  ('باغ باغ ہونا', 5),
  ('اونچی دکان پھیکا پکوان', 12),
  ('آگ لگنے پر کنواں کھودنا', 10),
  ('آستین کا سانپ ہونا', 7),
  ('گڑے مردے اکھاڑنا', 5),
  ('ہاتھ پاؤں مارنا', 8),
  ('کان کھڑے ہونا', 7),
  ('ناک میں دم کرنا', 8),
  ('پیٹھ پیچھے بات کرنا', 3)
) AS v(phrase, idx)
WHERE phrases.urdu_phrase = v.phrase;

-- blank_word distractors (3 per phrase; do not duplicate existing meaning rows)
DELETE FROM wrong_options
WHERE option_type = 'blank_word'
  AND phrase_id IN (SELECT id FROM phrases WHERE urdu_phrase IN (
    'طوطے اڑ جانا', 'ہاتھ صاف کرنا', 'دانتوں تلے انگلی دبانا', 'آنکھوں کا تارا ہونا',
    'رگوں میں بس جانا', 'چکا چوند ہونا', 'آگ بگولہ ہونا', 'باغ باغ ہونا',
    'اونچی دکان پھیکا پکوان', 'آگ لگنے پر کنواں کھودنا', 'آستین کا سانپ ہونا',
    'گڑے مردے اکھاڑنا', 'ہاتھ پاؤں مارنا', 'کان کھڑے ہونا', 'ناک میں دم کرنا',
    'پیٹھ پیچھے بات کرنا'
  ));

INSERT INTO wrong_options (phrase_id, option_text, option_type)
SELECT p.id, w.word, 'blank_word'
FROM phrases p
JOIN (VALUES
  ('طوطے اڑ جانا', 'صاف'),
  ('طوطے اڑ جانا', 'بگولہ'),
  ('طوطے اڑ جانا', 'کھڑے'),
  ('ہاتھ صاف کرنا', 'اڑ'),
  ('ہاتھ صاف کرنا', 'دم'),
  ('ہاتھ صاف کرنا', 'تارا'),
  ('دانتوں تلے انگلی دبانا', 'صاف'),
  ('دانتوں تلے انگلی دبانا', 'باغ'),
  ('دانتوں تلے انگلی دبانا', 'سانپ'),
  ('آنکھوں کا تارا ہونا', 'بس'),
  ('آنکھوں کا تارا ہونا', 'چوند'),
  ('آنکھوں کا تارا ہونا', 'اکھاڑنا'),
  ('رگوں میں بس جانا', 'طوطے'),
  ('رگوں میں بس جانا', 'پکوان'),
  ('رگوں میں بس جانا', 'پیچھے'),
  ('چکا چوند ہونا', 'بگولہ'),
  ('چکا چوند ہونا', 'دم'),
  ('چکا چوند ہونا', 'مارے'),
  ('آگ بگولہ ہونا', 'باغ'),
  ('آگ بگولہ ہونا', 'کنوں'),
  ('آگ بگولہ ہونا', 'انگلی'),
  ('باغ باغ ہونا', 'بگولہ'),
  ('باغ باغ ہونا', 'صاف'),
  ('باغ باغ ہونا', 'کھڑے'),
  ('اونچی دکان پھیکا پکوان', 'باغ'),
  ('اونچی دکان پھیکا پکوان', 'سانپ'),
  ('اونچی دکان پھیکا پکوان', 'دم'),
  ('آگ لگنے پر کنواں کھودنا', 'بگولہ'),
  ('آگ لگنے پر کنواں کھودنا', 'صاف'),
  ('آگ لگنے پر کنواں کھودنا', 'تارا'),
  ('آستین کا سانپ ہونا', 'اکھاڑنا'),
  ('آستین کا سانپ ہونا', 'باغ'),
  ('آستین کا سانپ ہونا', 'کھڑے'),
  ('گڑے مردے اکھاڑنا', 'صاف'),
  ('گڑے مردے اکھاڑنا', 'بس'),
  ('گڑے مردے اکھاڑنا', 'پیچھے'),
  ('ہاتھ پاؤں مارنا', 'بگولہ'),
  ('ہاتھ پاؤں مارنا', 'طوطے'),
  ('ہاتھ پاؤں مارنا', 'تارا'),
  ('کان کھڑے ہونا', 'دم'),
  ('کان کھڑے ہونا', 'صاف'),
  ('کان کھڑے ہونا', 'باغ'),
  ('ناک میں دم کرنا', 'کھڑے'),
  ('ناک میں دم کرنا', 'بگولہ'),
  ('ناک میں دم کرنا', 'اکھاڑنا'),
  ('پیٹھ پیچھے بات کرنا', 'صاف'),
  ('پیٹھ پیچھے بات کرنا', 'باغ'),
  ('پیٹھ پیچھے بات کرنا', 'سانپ')
) AS w(phrase, word) ON p.urdu_phrase = w.phrase;
