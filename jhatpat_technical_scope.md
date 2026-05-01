# جھٹ پٹ (Jhat Pat) — Technical Build Scope
**Flutter + Supabase | Claude Code Reference Document | v3.1 | April 2026**

---

## 1. Project Overview

جھٹ پٹ is a Flutter mobile app that teaches Urdu idioms and phrases through AI-illustrated picture cards. Users see an image depicting a phrase, guess its meaning from 4 options, then see a phrase reveal, then complete a second timed 4-option meaning check before the correct answer and score feedback.

**Stack:**
- Frontend: Flutter (Dart)
- Backend / DB: Supabase (PostgreSQL + Storage + Auth)
- Images: Supabase Storage (pre-generated, uploaded once)
- State Management: Riverpod
- Local Caching: Hive or shared_preferences

---

## 2. Supabase Architecture

### 2.1 Database Schema

#### Table: `phrases`
```sql
create table phrases (
  id           uuid primary key default gen_random_uuid(),
  urdu_phrase  text not null,
  romanised    text not null,
  meaning_urdu text not null,
  example_sentence text not null,
  category     text not null check (category in ('محاورہ', 'کہاوت')),
  difficulty   text not null check (difficulty in ('آسان', 'درمیانہ', 'مشکل')),
  image_url    text not null,
  is_active    boolean default true,
  created_at   timestamptz default now()
);
```

#### Table: `wrong_options`
```sql
-- Each phrase has 3 wrong MCQ options stored here
create table wrong_options (
  id         uuid primary key default gen_random_uuid(),
  phrase_id  uuid references phrases(id) on delete cascade,
  option_text text not null
);
```

#### Table: `profiles`
```sql
create table profiles (
  id             uuid primary key references auth.users(id),
  display_name   text not null,
  avatar_index   int default 0,
  xp             int default 0,
  level          int default 1,
  day_streak     int default 0,
  longest_streak int default 0,
  coins          int default 50,
  last_played_date date,
  created_at     timestamptz default now()
);
```

#### Table: `user_progress`
```sql
-- Tracks per-phrase outcomes for both quiz steps in one card loop
create table user_progress (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid references profiles(id) on delete cascade,
  phrase_id           uuid references phrases(id) on delete cascade,
  photo_guess_correct  boolean not null,
  photo_time_seconds   int not null,
  photo_points_earned  int not null,
  meaning_guess_correct boolean not null,
  meaning_time_seconds  int not null,
  meaning_points_earned int not null,
  total_points_earned   int not null,
  played_at           timestamptz default now(),
  unique(user_id, phrase_id)  -- one record per phrase per user (upsert on replay)
);
```

#### Table: `sessions`
```sql
-- Each time a user completes a set of cards
create table sessions (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid references profiles(id) on delete cascade,
  mode           text check (mode in ('quick_play', 'learn', 'speed_round', 'category')),
  category       text,
  total_cards    int not null,
  correct_count  int not null,
  total_points   int not null,
  xp_earned      int not null,
  max_streak     int not null,
  completed_at   timestamptz default now()
);
```

---

### 2.2 Supabase Storage

- Bucket name: `phrase-images`
- Access: Public read
- Naming convention (flat files, slug-based):
  - `<phrase_slug>_photo.png`
  - `<phrase_slug>_reveal.png`
- Example: `asmansarparuthana_photo.png`, `asmansarparuthana_reveal.png`
- Keep DB `id` as UUID for relations; use stable lowercase slugs for asset names.
- For Phase 1 schema, `phrases.image_url` stores the photo image URL; reveal image can be derived from the same slug with `_reveal.png`.

---

### 2.3 Row Level Security (RLS)

```sql
-- Profiles: users can only read/update their own
alter table profiles enable row level security;
create policy "Own profile only" on profiles
  using (auth.uid() = id);

-- user_progress: users see only their own
alter table user_progress enable row level security;
create policy "Own progress only" on user_progress
  using (auth.uid() = user_id);

-- phrases: everyone can read active phrases
alter table phrases enable row level security;
create policy "Public read" on phrases
  for select using (is_active = true);

-- wrong_options: public read
alter table wrong_options enable row level security;
create policy "Public read" on wrong_options
  for select using (true);
```

---

## 3. Flutter Project Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, theme, router
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart      # Nastaliq + Latin fonts
│   │   └── app_strings.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── router/
│       └── app_router.dart           # GoRouter
│
├── data/
│   ├── models/
│   │   ├── phrase_model.dart
│   │   ├── profile_model.dart
│   │   └── session_model.dart
│   ├── repositories/
│   │   ├── phrase_repository.dart    # Supabase queries + local cache
│   │   ├── profile_repository.dart
│   │   └── session_repository.dart
│   └── local/
│       └── cache_service.dart        # Hive local cache
│
├── providers/
│   ├── auth_provider.dart
│   ├── phrase_provider.dart
│   ├── game_provider.dart            # Core game state machine
│   ├── profile_provider.dart
│   └── session_provider.dart
│
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   └── sign_in_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── game/
│   │   ├── photo_card_screen.dart    # Main gameplay screen
│   │   ├── result_flash_screen.dart
│   │   ├── reveal_card_screen.dart
│   │   └── session_summary_screen.dart
│   ├── library/
│   │   └── phrase_library_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
└── widgets/
    ├── card/
    │   ├── photo_card.dart
    │   ├── reveal_card.dart
    │   └── card_flip_animation.dart
    ├── mcq/
    │   └── mcq_option_tile.dart
    ├── timer/
    │   └── countdown_timer_bar.dart
    ├── scoring/
    │   ├── streak_badge.dart
    │   └── xp_progress_bar.dart
    └── common/
        ├── urdu_text.dart            # Reusable Nastaliq text widget
        └── loading_shimmer.dart
```

---

## 4. Screen-by-Screen Specification

---

### Screen 1 — Splash Screen (`splash_screen.dart`)

**Behaviour:**
- Show app logo and name جھٹ پٹ with a scale-in animation
- Check if user is logged in via Supabase Auth
- If logged in → navigate to Home
- If not → navigate to Onboarding (first time) or Sign In

**Duration:** 2 seconds minimum, then auto-navigate

---

### Screen 2 — Onboarding (`onboarding_screen.dart`)

**Behaviour:**
- 3 slides explaining the game mechanic (shown only once, gated by shared_preferences flag)
- Slide 1: "تصویر دیکھو" — See the image
- Slide 2: "جواب چنو" — Pick the meaning
- Slide 3: "سیکھو اور آگے بڑھو" — Learn and level up
- Skip button on all slides
- "شروع کریں" button on last slide → Sign In screen

---

### Screen 3 — Sign In (`sign_in_screen.dart`)

**Behaviour:**
- Display name input (text field)
- "مہمان کے طور پر کھیلو" — Guest play button (anonymous Supabase auth)
- Google Sign-In button (Supabase OAuth)
- On success → create profile record in `profiles` table if new user → Home

**Supabase calls:**
```dart
await supabase.auth.signInAnonymously();                    // guest
await supabase.auth.signInWithOAuth(OAuthProvider.google);  // google
```

---

### Screen 4 — Home Screen (`home_screen.dart`)

**Layout:**
- Top: XP progress bar + level badge + day streak flame
- Daily challenge card (5 phrases today — progress bar)
- Four mode buttons:
  - ⚡ جھٹ پٹ کھیلو (Quick Play — 10 random cards)
  - 📚 سیکھو (Learn Mode — no timer)
  - 🔥 اسپیڈ راؤنڈ (Speed Round — unlocked at Level 5)
  - 📁 زمرہ چنو (Category Play)
- Bottom nav: Home / Library / Profile

**Data needed:** profile (XP, level, streak), today's session count

---

### Screen 5 — Photo Card Screen (`photo_card_screen.dart`)

This is the core gameplay screen. Every detail matters here.

**Layout:**
```
┌─────────────────────────────────┐
│  Round 3/10          [Streak 🔥]│
│  ─────────────────────────────  │  ← Timer bar (animates left to right)
│                                 │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │     [PHRASE IMAGE]      │   │  ← Full width card, rounded corners
│   │                         │   │
│   └─────────────────────────┘   │
│                                 │
│  اس تصویر میں کیا ہو رہا ہے؟    │  ← Prompt text in Urdu
│                                 │
│  ┌─────────┐  ┌─────────────┐   │
│  │ Option A│  │   Option B  │   │
│  └─────────┘  └─────────────┘   │
│  ┌─────────┐  ┌─────────────┐   │
│  │ Option C│  │   Option D  │   │
│  └─────────┘  └─────────────┘   │
│                                 │
│  💡 اشارہ (10 سکے) ⏱ (15 سکے)  │  ← Hint buttons
└─────────────────────────────────┘
```

**Behaviour:**
- Timer starts immediately on screen load (15s Quick Play, 8s Speed Round, disabled in Learn Mode)
- Timer bar fills from full to empty with colour transition: green → yellow → red
- 4 MCQ options shown — 1 correct (from `phrases.meaning_urdu`) + 3 wrong (from `wrong_options`)
- Options are shuffled randomly each time
- On option tap:
  - Correct: flash green, stop timer, record time taken, calculate points → navigate to Result Flash
  - Wrong: flash red on tapped option, reveal correct option in green → navigate to Result Flash
  - Timeout: all options briefly shown, correct highlighted → navigate to Result Flash

**Points Calculation:**
```dart
int calculatePoints(int secondsRemaining, bool isCorrect) {
  if (!isCorrect) return 0;
  if (secondsRemaining >= 12) return 500;
  if (secondsRemaining >= 9)  return 400;
  if (secondsRemaining >= 6)  return 300;
  if (secondsRemaining >= 3)  return 200;
  return 100;
}
```

**Hint — Eliminate (10 coins):**
- Remove 2 wrong options, leaving 1 wrong + 1 correct (2 options total)

**Hint — Time Freeze (15 coins):**
- Pause timer animation for 5 seconds

---

### Screen 6 — Result Flash (`result_flash_screen.dart`)

**Behaviour:**
- Fullscreen overlay, shown for 1.2 seconds, auto-advances
- Correct: green background, ✅ icon, points earned shown with animation (`+500`)
- Wrong: red background, ❌ icon
- Streak badge shown if streak ≥ 3
- No user input needed — auto-navigates to Reveal Card

---

### Screen 7 — Reveal Card Screen (`reveal_card_screen.dart`)

**Layout:**
```
┌─────────────────────────────────┐
│                                 │
│   ┌─────────────────────────┐   │
│   │     [PHRASE IMAGE]      │   │  ← Same image, now smaller
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │      طوطے اڑ جانا       │   │  ← Phrase in large Nastaliq
│   │                         │   │
│   │  [مثال میں دیکھیں 👁]  │   │  ← Button → opens modal
│   └─────────────────────────┘   │
│                                 │
│     [معنی چنو →]                │  ← Starts timed meaning check
└─────────────────────────────────┘
```

**Modal (Example Sentence):**
- Bottom sheet slides up
- Shows full example sentence in Nastaliq font
- Romanised transliteration below
- Close button

**Behaviour:**
- Always shown regardless of correct/wrong
- Shows phrase first (learning reveal step) before any second answer input
- "معنی چنو" starts second timed MCQ round for the same card
- On last card in session: same flow applies, then session summary after meaning round

---

### Screen 8 — Meaning Check (Timed) (`reveal_card_screen.dart` second stage)

This is stage 2 for the same phrase, shown immediately after reveal stage.

**Layout:**
- Timer bar at top (8s Quick Play, 6s Speed Round, disabled in Learn Mode)
- Prompt: "اس فقرے کا صحیح مفہوم چنیں"
- 4 MCQ options shown in 2x2 (reshuffle each time)
- Optional small helper text: "مرحلہ 2/2"

**Behaviour:**
- Timer starts when meaning check stage appears
- 4 options shown — 1 correct (`phrases.meaning_urdu`) + 3 wrong (`wrong_options`)
- On option tap:
  - Correct: highlight green, record time, award meaning-round points
  - Wrong: tapped red + correct green, meaning-round points = 0
  - Timeout: reveal correct option, meaning-round points = 0
- After answer/timeout, show short result state (800ms), then proceed:
  - Next card photo screen, or
  - Session summary if last card

---

### Screen 9 — Session Summary (`session_summary_screen.dart`)

**Layout:**
- Total score with animation (count-up)
- XP earned this session
- Streak badge (max streak reached)
- Accuracy percentage (e.g., ٨ میں سے ٧ صحیح)
- Phrases learned list (scrollable — phrase + Photo guess ✅/❌ + Meaning check ✅/❌)
- Two buttons: "دوبارہ کھیلو" (Play Again) | "گھر جاؤ" (Home)

**Supabase writes on this screen:**
- Insert row into `sessions`
- Upsert rows into `user_progress` for each phrase played
- Update `profiles` (XP, level, coins, day streak, last_played_date)

---

### Screen 10 — Phrase Library (`phrase_library_screen.dart`)

**Layout:**
- Search bar (filters by romanised or urdu text)
- Category filter chips: سب / محاورہ / کہاوت
- Difficulty filter chips: سب / آسان / درمیانہ / مشکل
- Grid of cards — each shows image thumbnail + phrase text
- Tap a card → shows full Reveal Card view (read-only, no game context)

---

### Screen 11 — Profile (`profile_screen.dart`)

**Layout:**
- Avatar + display name + level badge
- XP progress bar to next level
- Stats row: Day Streak 🔥 | Total Correct ✅ | Coins 🪙
- Level title in Urdu (see level system below)
- Recent sessions list (last 5)

---

## 5. Game State Machine

Manage entirely in `game_provider.dart` using Riverpod `StateNotifier`:

```
GameState:
  idle
    ↓ (startSession called)
  loading_phrases
    ↓ (phrases fetched)
  showing_photo        ← timer running
    ↓ (option tapped OR timeout)
  showing_result_flash ← 1.2 seconds auto
    ↓
  showing_reveal
    ↓ (start meaning check)
  showing_meaning_quiz  ← timer running
    ↓ (meaning tapped OR timeout)
  showing_photo        ← loops until all cards done
    ↓ (last card revealed)
  session_complete
    ↓ (summary dismissed)
  idle
```

---

## 6. Scoring & Progression System

### 6.1 Points Per Card

| Time Remaining (Photo Guess) | Points |
|---|---|
| 12–15 seconds | 500 |
| 9–12 seconds | 400 |
| 6–9 seconds | 300 |
| 3–6 seconds | 200 |
| 0–3 seconds | 100 |
| Wrong / Timeout | 0 |

| Time Remaining (Meaning Check) | Points |
|---|---|
| 6–8 seconds | 200 |
| 4–6 seconds | 150 |
| 2–4 seconds | 100 |
| 0–2 seconds | 50 |
| Wrong / Timeout | 0 |

### 6.2 Streak Multiplier

| Streak | Multiplier | Label |
|---|---|---|
| 1–2 | 1× | — |
| 3–4 | 1.5× | 🔥 آگ لگ گئی |
| 5–7 | 2× | ⚡ ناقابلِ روک |
| 8+ | 3× | 👑 استادوں کا استاد |

### 6.3 XP Rules

| Action | XP |
|---|---|
| Photo guess correct | +10 |
| Meaning check correct | +5 |
| Card completed (any result) | +2 |
| Perfect session (all correct) | +50 bonus |
| Daily goal hit (5 cards) | +25 bonus |

### 6.4 Level Titles

| Level | XP Required | Title |
|---|---|---|
| 1 | 0 | نیا سیکھنے والا |
| 2 | 100 | شوقین شاگرد |
| 5 | 500 | پکا شاگرد |
| 10 | 1500 | زبان دان |
| 15 | 3000 | محاورہ ماہر |
| 20 | 5000 | استاد |
| 30 | 10000 | زبان کا بادشاہ |

### 6.5 Coins

| Action | Amount |
|---|---|
| Correct answer | +5 coins |
| Eliminate hint | −10 coins |
| Time freeze hint | −15 coins |
| Starting balance | 50 coins |

---

## 7. Local Caching Strategy

Use **Hive** for offline support.

| Data | Cache Strategy |
|---|---|
| All active phrases + wrong options | Fetch on app start, cache in Hive box, TTL 24 hours |
| Images | `CachedNetworkImage` package handles automatically |
| User profile | Cache locally, sync to Supabase on any change |
| Session data | Write to Supabase immediately; queue locally if offline |

```dart
// Cache check on app start
final lastSync = prefs.getString('last_phrase_sync');
final shouldRefetch = lastSync == null ||
  DateTime.now().difference(DateTime.parse(lastSync)).inHours > 24;

if (shouldRefetch) {
  await phraseRepository.fetchAndCachePhrases();
}
```

---

## 8. Key Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Backend
  supabase_flutter: ^2.x.x

  # State Management
  flutter_riverpod: ^2.x.x

  # Navigation
  go_router: ^13.x.x

  # Local Cache
  hive_flutter: ^1.x.x

  # Images
  cached_network_image: ^3.x.x

  # Fonts
  google_fonts: ^6.x.x           # Noto Nastaliq Urdu

  # Animations
  lottie: ^3.x.x                 # Result flash animations
  flutter_animate: ^4.x.x        # XP bar, score count-up

  # Auth
  google_sign_in: ^6.x.x

  # Utils
  intl: ^0.19.x
  shared_preferences: ^2.x.x
```

---

## 9. Supabase Setup Checklist

Complete these in Supabase dashboard before Claude Code starts building:

- [ ] Create Supabase project
- [ ] Run all 5 table SQL scripts (Section 2.1)
- [ ] Enable RLS and run all policy scripts (Section 2.3)
- [ ] Create `phrase-images` storage bucket — set to **Public**
- [ ] Upload phrase images using flat slug names: `<phrase_slug>_photo.png` and `<phrase_slug>_reveal.png`
- [ ] Enable Anonymous Auth in Supabase Auth settings
- [ ] Enable Google OAuth provider
- [ ] Seed `phrases` table with all 16 phrases
- [ ] Seed `wrong_options` table (3 wrong options per phrase = 48 rows)
- [ ] Copy `SUPABASE_URL` and `SUPABASE_ANON_KEY` into Flutter `.env`

---

## 10. Environment Setup

```dart
// lib/core/constants/supabase_constants.dart
class SupabaseConstants {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

```
# .env (never commit to git)
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

---

## 11. Build Order for Claude Code

Build in this exact sequence — each phase is independently testable:

### Phase A — Foundation
1. Flutter project setup + folder structure
2. Supabase client initialisation
3. Theme + fonts (Nastaliq for Urdu, clean sans-serif for English/numbers)
4. GoRouter navigation scaffold (all screens as empty placeholders)
5. Riverpod setup

### Phase B — Data Layer
6. `phrase_model.dart` + `profile_model.dart` + `session_model.dart`
7. `phrase_repository.dart` — fetch phrases + wrong options from Supabase
8. `cache_service.dart` — Hive local caching
9. `profile_repository.dart` — CRUD on profiles
10. `session_repository.dart` — write sessions + user_progress

### Phase C — Auth
11. Sign in screen (Guest + Google)
12. Auth state provider
13. Profile auto-creation on first sign-in

### Phase D — Core Game Loop
14. `game_provider.dart` — full state machine
15. `photo_card_screen.dart` — image + timer bar + MCQ options
16. `countdown_timer_bar.dart` widget
17. `result_flash_screen.dart` — 1.2s overlay
18. `reveal_card_screen.dart` — phrase reveal stage + sentence modal
19. `reveal_card_screen.dart` meaning-check stage — timer + 4 options + result
20. `session_summary_screen.dart` + Supabase writes

### Phase E — Home & Navigation
21. `home_screen.dart` — all 4 mode buttons wired up
22. XP bar + streak display
23. Daily challenge progress

### Phase F — Supporting Screens
24. `phrase_library_screen.dart`
25. `profile_screen.dart`
26. Onboarding slides
27. Splash screen with auth check

### Phase G — Polish
28. Lottie animations (correct/wrong flash)
29. Streak badge animations
30. Level-up celebration overlay
31. Hint system (eliminate + time freeze)

---

## 12. Out of Scope — Phase 1

- Multiplayer
- Audio pronunciation
- Push notifications
- Admin CMS for phrase management
- Global leaderboard
- Tablet-specific layouts
- In-app purchases

---

## 13. Seed Data — 16 Phrases

Copy directly into Supabase SQL editor:

```sql
insert into phrases (urdu_phrase, romanised, meaning_urdu, example_sentence, category, difficulty, image_url) values
('طوطے اڑ جانا',           'Totay ur jana',              'حیران و پریشان رہ جانا',                    'جب اسے خبر ملی تو اس کے طوطے اڑ گئے',                              'محاورہ', 'آسان',     ''),
('ہاتھ صاف کرنا',          'Hath saaf karna',             'چوری کرنا یا کوئی چیز غائب کر دینا',        'وہ موقع ملتے ہی ہاتھ صاف کر گیا',                                  'محاورہ', 'آسان',     ''),
('دانتوں تلے انگلی دبانا', 'Danton talay ungli dabana',   'بہت زیادہ حیران ہونا',                      'اس کا کام دیکھ کر سب نے دانتوں تلے انگلی دبا لی',                 'محاورہ', 'درمیانہ',  ''),
('آنکھوں کا تارا ہونا',    'Ankhon ka tara hona',         'بہت عزیز اور پیارا ہونا',                   'یہ بچہ اپنے والدین کی آنکھوں کا تارا ہے',                          'محاورہ', 'آسان',     ''),
('رگوں میں بس جانا',       'Ragon mein bas jana',         'دل و جان میں گہرائی سے سما جانا',           'اس کی آواز میری رگوں میں بس گئی ہے',                               'محاورہ', 'مشکل',     ''),
('چکا چوند ہونا',          'Chaka chaund hona',           'تیز روشنی یا شان و شوکت سے حیران ہو جانا', 'شہر کی روشنیاں دیکھ کر وہ چکا چوند ہو گیا',                       'محاورہ', 'درمیانہ',  ''),
('آگ بگولہ ہونا',          'Aag bagola hona',             'بہت زیادہ غصے میں آ جانا',                  'بات سن کر وہ آگ بگولہ ہو گیا',                                     'محاورہ', 'آسان',     ''),
('باغ باغ ہونا',           'Bagh bagh hona',              'انتہائی خوش اور مسرور ہونا',                'خوشخبری سن کر وہ باغ باغ ہو گئے',                                  'محاورہ', 'آسان',     ''),
('اونچی دکان پھیکا پکوان', 'Oonchi dukan pheeka pakwan',  'ظاہری دکھاوا زیادہ، اصلیت میں کچھ نہیں',  'اس ہوٹل کا کھانا بے ذائقہ نکلا — اونچی دکان پھیکا پکوان',         'کہاوت',  'درمیانہ',  ''),
('آگ لگنے پر کنواں کھودنا','Aag lagne par kuwan khodna',  'مصیبت آنے کے بعد تیاری کرنا',              'امتحان کے دن پڑھنا شروع کرنا آگ لگنے پر کنواں کھودنا ہے',         'کہاوت',  'درمیانہ',  ''),
('آستین کا سانپ ہونا',      'Asteen ka sanp hona',         'اپنا بن کر نقصان پہنچانے والا ہونا',        'وہ دوست نہیں نکلا، آستین کا سانپ ثابت ہوا',                         'محاورہ', 'درمیانہ',  ''),
('گڑے مردے اکھاڑنا',        'Gharay murday ukharna',       'پرانی باتیں چھیڑ دینا',                     'ہر بحث میں گڑے مردے اکھاڑنا اچھی بات نہیں',                          'محاورہ', 'درمیانہ',  ''),
('ہاتھ پاؤں مارنا',         'Hath paoun marna',            'بہت کوشش کرنا',                             'نوکری کے لیے اس نے بہت ہاتھ پاؤں مارے',                             'محاورہ', 'آسان',     ''),
('کان کھڑے ہونا',          'Kaan kharay hona',            'چوکنا یا ہوشیار ہو جانا',                    'مشکوک آواز سنتے ہی اس کے کان کھڑے ہو گئے',                          'محاورہ', 'آسان',     ''),
('ناک میں دم کرنا',        'Naak main dam karna',         'بہت تنگ کرنا',                              'بچوں نے شور مچا کر سب کی ناک میں دم کر دیا',                        'محاورہ', 'آسان',     ''),
('پیٹھ پیچھے بات کرنا',     'Peet pichay baat karna',      'غیر موجودگی میں برائی کرنا',                 'دوستوں کی پیٹھ پیچھے بات کرنا غلط ہے',                              'محاورہ', 'درمیانہ',  '');

-- After inserting, update image_url with your Supabase Storage paths:
-- update phrases
--   set image_url = case urdu_phrase
--     when 'طوطے اڑ جانا' then 'https://xxxx.supabase.co/storage/v1/object/public/phrase-images/totayurjana_photo.png'
--     when 'ہاتھ صاف کرنا' then 'https://xxxx.supabase.co/storage/v1/object/public/phrase-images/hathsaafkarna_photo.png'
--     -- ...continue mapping each phrase to its slug-based _photo file
--   end;
```

---

## 14. Wrong Options Seed Data

After inserting phrases and noting their UUIDs, insert 3 wrong options per phrase:

```sql
-- Example for طوطے اڑ جانا (replace phrase_id with actual UUID)
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت خوش ہو جانا'),
('<phrase_id>', 'تیز دوڑنا'),
('<phrase_id>', 'کسی کو دھوکہ دینا');

-- Example for ہاتھ صاف کرنا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت محنت کرنا'),
('<phrase_id>', 'ہار مان لینا'),
('<phrase_id>', 'بہت غصہ آنا');

-- Example for دانتوں تلے انگلی دبانا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت تھکا ہوا ہونا'),
('<phrase_id>', 'چھپ جانا'),
('<phrase_id>', 'فرار ہو جانا');

-- Example for آنکھوں کا تارا ہونا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت غصے میں ہونا'),
('<phrase_id>', 'دھوکہ کھانا'),
('<phrase_id>', 'نظرانداز کرنا');

-- Example for رگوں میں بس جانا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بھاگ جانا'),
('<phrase_id>', 'شرمندہ ہونا'),
('<phrase_id>', 'بہت بیمار ہونا');

-- Example for چکا چوند ہونا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت تھک جانا'),
('<phrase_id>', 'غصے میں آنا'),
('<phrase_id>', 'پیسے خرچ کرنا');

-- Example for آگ بگولہ ہونا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت خوش ہونا'),
('<phrase_id>', 'حیران ہو جانا'),
('<phrase_id>', 'تیز چلنا');

-- Example for باغ باغ ہونا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت غصہ آنا'),
('<phrase_id>', 'چوری کرنا'),
('<phrase_id>', 'گم ہو جانا');

-- Example for اونچی دکان پھیکا پکوان
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'بہت مہنگا ہونا'),
('<phrase_id>', 'سب کا پسندیدہ ہونا'),
('<phrase_id>', 'جلدی ختم ہو جانا');

-- Example for آگ لگنے پر کنواں کھودنا
insert into wrong_options (phrase_id, option_text) values
('<phrase_id>', 'پہلے سے تیاری کرنا'),
('<phrase_id>', 'سب کو مدد کرنا'),
('<phrase_id>', 'خاموش رہنا');
```

---

## 15. First Prompt for Claude Code

Once your Flutter project is set up, start a new Claude Code session with this exact prompt:

> "I am building a Flutter app called جھٹ پٹ (Jhat Pat). It is a Urdu phrase learning app. Backend is Supabase (PostgreSQL + Storage + Auth). I have a detailed scope document. Let's start with Phase A — Foundation only. Set up the folder structure as defined in the scope, initialise Supabase using environment variables, configure GoRouter with placeholder screens for all 11 screens, set up Riverpod, and add Google Fonts with Noto Nastaliq Urdu. Do not build any game logic yet — skeleton only. Here is my scope: [paste this document]"

Then work phase by phase: A → B → C → D → E → F → G.

**Start a new Claude Code session for each phase** and paste the scope document each time as context.

---

*Document last updated: April 2026 | Version 3.1 | جھٹ پٹ — زبان سیکھو، مزہ کرو*
