-- Leaderboard needs rows from all profiles. Typical RLS is `id = auth.uid()`, which
-- makes client `.from('profiles').select()` return only the current user.
-- This SECURITY DEFINER function aggregates safely (no email in `profiles`).
CREATE OR REPLACE FUNCTION public.leaderboard_bundle(p_user_id uuid DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  j_top jsonb;
  rec profiles%ROWTYPE;
  r_you integer;
BEGIN
  SELECT COALESCE(
    (
      SELECT jsonb_agg(to_jsonb(t))
      FROM (
        SELECT
          id::text AS id,
          display_name,
          xp,
          longest_streak,
          coins
        FROM profiles
        ORDER BY
          xp DESC NULLS LAST,
          last_played_date DESC NULLS LAST,
          longest_streak DESC
        LIMIT 10
      ) t
    ),
    '[]'::jsonb
  )
  INTO j_top;

  IF p_user_id IS NULL THEN
    RETURN jsonb_build_object('top', j_top, 'you', NULL::jsonb);
  END IF;

  SELECT * INTO rec FROM profiles WHERE id = p_user_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('top', j_top, 'you', NULL::jsonb);
  END IF;

  SELECT COUNT(*)::int INTO r_you
  FROM profiles p
  WHERE
    p.id <> rec.id
    AND (
      p.xp > rec.xp
      OR (
        p.xp = rec.xp
        AND COALESCE(p.last_played_date, DATE '1970-01-01')
          > COALESCE(rec.last_played_date, DATE '1970-01-01')
      )
    );

  r_you := r_you + 1;

  RETURN jsonb_build_object(
    'top',
    j_top,
    'you',
    jsonb_build_object(
      'id',
      rec.id::text,
      'display_name',
      rec.display_name,
      'xp',
      rec.xp,
      'longest_streak',
      rec.longest_streak,
      'coins',
      rec.coins,
      'rank',
      r_you
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.leaderboard_bundle(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.leaderboard_bundle(uuid) TO anon;
GRANT EXECUTE ON FUNCTION public.leaderboard_bundle(uuid) TO authenticated;

COMMENT ON FUNCTION public.leaderboard_bundle(uuid) IS
  'Top 10 + optional signed-in user stats; bypasses profiles RLS.';
