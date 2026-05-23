# جھٹ پٹ — Game Depth & Multiplayer Implementation
**Cursor Prompts | Work phase by phase, one session per phase**

---

## Before You Start

Paste your technical scope document at the start of every Cursor session.
Run all SQL in Supabase dashboard BEFORE the corresponding Cursor session.

---

## Phase 1 — Mastery Layer (Database)

Run this SQL in Supabase first:

```sql
-- Add mastery tracking to user_progress
alter table user_progress 
  add column mastery_level int default 0 check (mastery_level between 0 and 5),
  add column last_seen_at timestamptz default now(),
  add column times_correct int default 0,
  add column times_seen int default 0;

-- Add scenario sentence for State 5
alter table phrases 
  add column scenario_urdu text,
  add column blank_word_index int;
-- blank_word_index: which word in example_sentence to blank out for State 4

-- Seed mastery level 0 for all existing progress rows
update user_progress set mastery_level = 0 where mastery_level is null;
```

**Cursor Prompt — Phase 1:**

```
I am building mastery-based progression for جھٹ پٹ. Each phrase has 
5 mastery states per user. Read the scope document and implement:

1. Update PhraseModel to include scenario_urdu and blank_word_index fields

2. Update UserProgressModel to include:
   mastery_level (0-5), last_seen_at, times_correct, times_seen

3. In phrase_repository.dart, add:
   - getMasteryLevel(userId, phraseId) → int
   - updateMastery(userId, phraseId, wasCorrect) with this logic:
     * Correct + times_correct reaches threshold → increment mastery_level
     * Thresholds: State 1 after 1 correct, State 2 after 2, 
       State 3 after 3, State 4 after 4, State 5 after 5
     * Wrong answer → decrement mastery_level by 1 (min 0)
     * Phrase not seen in 7 days → decrement by 1 on next open

4. In cache_service.dart, cache mastery levels locally in Hive.
   Key: 'mastery_{userId}_{phraseId}' → int

5. In game_provider.dart, before building each card's MCQ options, 
   check mastery_level and apply:
   State 0-1: 4 options, 15s timer (current behaviour)
   State 2: 3 options (silently drop one wrong), 15s timer
   State 3: show phrase text, user picks correct IMAGE from 2x2 grid
   State 4: show example sentence with one word blanked, 4 word options
   State 5: show scenario_urdu text, user picks correct phrase from 4

After each answer call updateMastery(). No UI changes yet — 
logic and data layer only.
```

---

## Phase 2 — Mastery UI (Library Screen)

**Cursor Prompt — Phase 2:**

```
Add mastery visuals to جھٹ پٹ. Read the scope document.

1. In phrase_library_screen.dart, update each grid card to show 
   mastery state visually:
   State 0: dark card, no border (اجنبی)
   State 1: normal card (جان پہچان)  
   State 2: subtle warm border
   State 3: amber border
   State 4: green border
   State 5: golden border + small crown icon top-right

2. Add a mastery progress bar at top of library screen:
   "X/Y محاورے مکمل" with a thin progress bar
   Count only State 5 phrases as complete

3. On photo_card_screen.dart, add a small state indicator 
   top-left (a dot with colour matching mastery state).
   No label — just the coloured dot.

4. For State 3 (image grid mode): build a new widget
   lib/widgets/card/image_grid_mcq.dart
   Shows 2x2 grid of CachedNetworkImages (phrase images).
   One is correct, three are from other phrases.
   Same tap behaviour as mcq_option_tile.dart

5. For State 4 (fill the blank): in reveal_card_screen.dart
   second stage, if mastery_level == 3:
   Show example_sentence with word at blank_word_index 
   replaced by "___". Options are 4 Urdu words.
   Store wrong word options in wrong_options table 
   (add a type column: 'meaning' or 'blank_word').

Add to wrong_options table:
alter table wrong_options add column option_type text 
  default 'meaning' check (option_type in ('meaning','blank_word'));
```

---

## Phase 3 — Story Mode & Reverse Mode

**Cursor Prompt — Phase 3:**

```
Add Story Mode and Reverse Mode to جھٹ پٹ. Read the scope document.

STORY MODE:

1. Create Supabase table:
create table stories (
  id uuid primary key default gen_random_uuid(),
  title_urdu text not null,
  connector_text text not null,
  phrase_ids uuid[] not null,
  display_order int default 0,
  is_active boolean default true
);

Seed 3 starter stories using your existing 16 phrase UUIDs:
Story 1: "غصے کے محاورے" — آگ بگولہ ہونا، ناک میں دم کرنا، 
         آستین کا سانپ ہونا
Story 2: "خوشی کے محاورے" — باغ باغ ہونا، آنکھوں کا تارا ہونا،
         طوطے اڑ جانا  
Story 3: "دھوکے کے محاورے" — ہاتھ صاف کرنا، گڑے مردے اکھاڑنا،
         پیٹھ پیچھے بات کرنا

2. Create lib/screens/game/story_mode_screen.dart
   - Fetch story by id, load its phrases in order
   - Between each card show a full-width card with 
     connector_text in Nastaliq font (2 seconds, auto-advance)
   - Otherwise identical game loop to Quick Play
   - On home screen add "کہانی موڈ" button below Quick Play

REVERSE MODE:

3. In game_provider.dart add a reverseMode boolean flag.
   When true, for each card:
   - Show meaning_urdu as the prompt (text only, no image)
   - 4 options are urdu_phrase values (the phrase itself)
   - Timer same as Quick Play
   - Only available for phrases where user mastery_level >= 3
     (enforce in the session builder: filter eligible phrases)

4. On home screen add "الٹا موڈ" button.
   If user has fewer than 3 phrases at mastery >= 3, show 
   button greyed with tooltip "پہلے 3 محاورے سیکھیں"
```

---

## Phase 4 — Time Trial Mode

**Cursor Prompt — Phase 4:**

```
Add Time Trial mode to جھٹ پٹ. Read the scope document.

1. Create lib/screens/game/time_trial_screen.dart

Behaviour:
- Load 10 random phrases (Quick Play selection logic)
- ONE shared countdown timer: 90 seconds for all 10 cards
- No per-card timer bar — replace with a single top bar 
  showing remaining total seconds, coloured green→yellow→red
- Cards advance immediately on tap (no result flash delay)
- If timer hits 0 mid-card, session ends immediately
- Wrong answers deduct 5 seconds from the shared timer
  (show "-5s" flash in red when wrong)
- Correct answers add 3 seconds (show "+3s" flash in green)

2. Session summary for Time Trial:
- Show time remaining as a stat ("X ثانیے بچے")
- Show cards completed out of 10
- High score tracking: store best time_remaining in profiles
  alter table profiles add column best_time_trial_remaining int default 0;
  Update if current remaining > stored best

3. On home screen add "وقت کی دوڑ" button (unlock at Level 3).
   Show a small "ہائی اسکور: Xs" below the button if 
   best_time_trial_remaining > 0.
```

---

## Phase 5 — Online Multiplayer Duel Mode

This is the most complex phase. Run SQL first, then do two 
Cursor sessions (5A: backend, 5B: UI).

**SQL — Run in Supabase first:**

```sql
create table duels (
  id uuid primary key default gen_random_uuid(),
  player_a_id uuid references profiles(id),
  player_b_id uuid references profiles(id),
  phrase_ids uuid[] not null,
  status text default 'waiting' 
    check (status in ('waiting','active','complete')),
  current_card_index int default 0,
  player_a_score int default 0,
  player_b_score int default 0,
  player_a_answers jsonb default '[]',
  player_b_answers jsonb default '[]',
  winner_id uuid references profiles(id),
  invite_code text unique,
  created_at timestamptz default now(),
  expires_at timestamptz default now() + interval '10 minutes'
);

-- Enable realtime on duels table
alter publication supabase_realtime add table duels;

-- RLS
alter table duels enable row level security;
create policy "Players can read their own duels" on duels
  for select using (
    auth.uid() = player_a_id or auth.uid() = player_b_id
  );
create policy "Players can update their own duels" on duels
  for update using (
    auth.uid() = player_a_id or auth.uid() = player_b_id
  );
```

**Cursor Prompt — Phase 5A (Backend):**

```
Implement Duel Mode backend for جھٹ پٹ using Supabase Realtime.
Read the scope document. The duels table is already created.

1. Create lib/data/models/duel_model.dart
   Fields match duels table. Add helper:
   bool get isPlayerA => supabase.auth.currentUser?.id == playerAId

2. Create lib/data/repositories/duel_repository.dart with:

   createDuel() → DuelModel
   - Select 5 random active phrase IDs
   - Generate 6-character invite_code (random uppercase alphanumeric)
   - Insert row with player_a_id = current user, status = 'waiting'
   - Return the created duel

   joinDuel(String inviteCode) → DuelModel
   - Find duel by invite_code where status = 'waiting'
   - Update player_b_id = current user, status = 'active'
   - Return updated duel

   submitAnswer(String duelId, int cardIndex, 
                String phraseId, bool correct, int points)
   - Determine if current user is player_a or player_b
   - Append {cardIndex, phraseId, correct, points} to 
     the correct player's answers jsonb array
   - Update the corresponding score field
   - If both players have answered cardIndex:
     increment current_card_index
   - If current_card_index == 5:
     set status = 'complete'
     set winner_id to higher scorer (null if tie)

   watchDuel(String duelId) → Stream<DuelModel>
   - supabase.from('duels').stream(primaryKey: ['id'])
     .eq('id', duelId).map(...)

3. Create lib/providers/duel_provider.dart
   StateNotifier<DuelState> with states:
   idle | creating | waiting_for_opponent | 
   active | complete | error
   
   Expose: currentDuel, myScore, opponentScore, 
   currentCardIndex, isMyTurn (always true in this mode —
   both players answer every card simultaneously)
```

**Cursor Prompt — Phase 5B (UI):**

```
Build the Duel Mode UI for جھٹ پٹ. Read the scope document.
duel_repository.dart and duel_provider.dart are complete.

1. Create lib/screens/game/duel_lobby_screen.dart

   Two options shown:
   A) "نئی دوہری شروع کریں" — calls createDuel(), shows the 
      6-character invite_code in large text with a copy button.
      Shows "دوست کا انتظار..." with a subtle pulse animation.
      Generates a WhatsApp share message:
      "جھٹ پٹ پر مجھ سے مقابلہ کریں! کوڈ: [CODE]
       10 منٹ میں شامل ہوں"
      
   B) "کوڈ سے شامل ہوں" — text field for 6-char code,
      calls joinDuel(), navigates to duel_game_screen.

   watchDuel() stream: when status changes to 'active',
   auto-navigate both players to duel_game_screen.

2. Create lib/screens/game/duel_game_screen.dart

   Layout (from top):
   - Score bar: [Player A name + score] vs [Player B name + score]
     Both update in realtime via watchDuel() stream
   - "کارڈ X/5" indicator  
   - Full photo_card widget (existing widget, reused)
   - MCQ options (existing mcq_option_tile, reused)
   - After tap: show result immediately, then wait for 
     opponent's answer (show "دوست جواب دے رہا ہے..." 
     with a 3-dot pulse). Max wait: 10 seconds, then advance.
   - Call submitAnswer() on every tap

   The realtime stream drives all state changes.
   When current_card_index increments, load the next phrase.

3. Create lib/screens/game/duel_result_screen.dart

   Show: winner name + "جیت گئے!" or "برابر!"
   Final scores side by side
   Per-card breakdown: whose answer was faster/correct
   Two buttons: "دوبارہ چیلنج" (new duel, same opponent)
                "گھر جائیں"

4. Add "مقابلہ موڈ" button to home screen.
   Guests see it greyed with "اکاؤنٹ بنائیں" — 
   duel mode requires auth (no guest support).

5. Add duel results to session_repository.dart:
   When duel completes, write a row to sessions table
   with mode = 'duel' for both players.
```

---

## Phase 6 — Library Mastery View (Polish)

**Cursor Prompt — Phase 6:**

```
Final polish pass for جھٹ پٹ game depth features.
Read the scope document.

1. On profile_screen.dart add a "میری لائبریری" section:
   - Count of phrases at each mastery state as a bar chart
   - "X محاورے سیکھے جا رہے ہیں" (mastery 1-4)
   - "X محاورے مکمل" (mastery 5, shown in gold)

2. Spaced repetition decay — run on app launch in 
   phrase_repository.dart after phrases load:
   - Query all user_progress rows where 
     last_seen_at < now() - 7 days AND mastery_level > 0
   - Decrement mastery_level by 1 for each
   - Update last_seen_at to now()
   - Show a toast if any phrases decayed:
     "X محاورے دہرانے کا وقت آگیا! 🔄"

3. On home screen, if any phrases have decayed this session:
   Add a "دہرائیں" (Review) quick button that launches 
   a Quick Play session with ONLY the decayed phrases.
   This is the highest-priority engagement trigger in 
   the entire app — users will tap it reflexively.

4. Achievement system — add to profiles:
   alter table profiles add column achievements jsonb default '[]';
   
   Check and award after every session:
   - 'first_master': first phrase reaches State 5
   - 'speed_demon': Time Trial with > 30s remaining
   - 'no_miss': perfect Quick Play session
   - 'duel_winner': first duel win
   - 'full_library': all phrases at State 5
   
   Show achievement unlocked overlay (1.5s) after session 
   summary if new achievement earned.
```

---

## Implementation Order

| Phase | What | Effort | Do After |
|---|---|---|---|
| 1 | Mastery data layer | Medium | Now |
| 2 | Mastery UI | Medium | Phase 1 |
| 3 | Story + Reverse Mode | Low | Phase 2 |
| 4 | Time Trial | Low | Phase 3 |
| 5A | Duel backend | High | Phase 4 |
| 5B | Duel UI | High | Phase 5A |
| 6 | Polish + decay | Low | Phase 5B |

---

## Key Rule

One Cursor session per phase.
Paste scope document at the start of each session.
Test the full game loop before moving to the next phase.
Do NOT start Phase 5 until Phases 1-4 are stable.