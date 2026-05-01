-- Run once on Supabase (SQL Editor or migration): ranks only opt-in profiles.
alter table public.profiles
add column if not exists show_on_leaderboard boolean not null default false;

comment on column public.profiles.show_on_leaderboard is 'True only for email/Google accounts; excluded from leaderboard when false (e.g. offline guest has no row).';

-- RLS (adjust names to fit your policies): leaderboard query must SELECT rows where show_on_leaderboard = true.
-- Example:
-- create policy "profiles public leaderboard read"
--   on public.profiles for select
--   using (show_on_leaderboard = true);
