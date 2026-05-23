-- Fix slug upsert: partial index is not valid for ON CONFLICT; use table UNIQUE.

DROP INDEX IF EXISTS stories_slug_unique;

ALTER TABLE stories DROP CONSTRAINT IF EXISTS stories_slug_key;

ALTER TABLE stories ADD CONSTRAINT stories_slug_key UNIQUE (slug);
