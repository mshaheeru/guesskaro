# جھٹ پٹ (Jhat Pat) — Cursor Implementation Prompts

> **Purpose**: Phased implementation prompts for Cursor AI. Each prompt is a self-contained unit. Run in order.
> **Tech Stack**: Flutter (Dart) + Supabase (PostgreSQL + Auth + Storage) + Riverpod
> **App**: Urdu phrase learning game — image card shown + timed guess from 4 options → phrase revealed → second timed 4-option meaning check

---

## Prompt 0: Project Foundation

### Phase 0.1: Folder Structure & pubspec
**Goal**: Clean folder structure and all dependencies installed.

**Tasks**:
- Create this folder structure inside `lib/`:
  ```
  core/constants/   core/theme/   core/router/
  data/models/      data/repositories/   data/local/
  providers/
  screens/splash/   screens/onboarding/   screens/auth/
  screens/home/     screens/game/         screens/library/
  screens/profile/  screens/settings/
  widgets/card/     widgets/mcq/   widgets/timer/
  widgets/scoring/  widgets/common/
  ```
- Create empty `.dart` stub files for every screen and widget listed in scope
- Add to `pubspec.yaml`: `supabase_flutter`, `flutter_riverpod`, `go_router`, `hive_flutter`, `cached_network_image`, `google_fonts`, `lottie`, `flutter_animate`, `google_sign_in`, `shared_preferences`, `flutter_dotenv`, `shimmer`, `package_info_plus`
- Add `assets/images/` and `assets/lottie/` to flutter assets section
- Run `flutter pub get`

**Verify**: Project compiles with no errors. All folders exist.

---

### Phase 0.2: Theme & Constants
**Goal**: App-wide colors, text styles, and Urdu string constants.

**Tasks**:
- `app_colors.dart`: Define static colors — `primary` (orange `#FF6B35`), `correct` (green), `wrong` (red), `timerGreen/Yellow/Red`, `gold`, `background` (warm off-white), `streakOrange`
- `app_text_styles.dart`: Define styles using `GoogleFonts.notoNastaliqUrdu()` for Urdu (sizes 16/22/28/bold variants) and `GoogleFonts.poppins()` for English/numbers. All Urdu styles must include `textDirection: TextDirection.rtl`
- `app_strings.dart`: All UI strings in Urdu — question prompt, next question, see example, play again, go home, correct/wrong messages, mode names, daily goal, meaning label, session complete
- `app_theme.dart`: Build `ThemeData` using above colors. Rounded buttons (radius 12). Poppins as default font

**Verify**: Theme applies correctly when set in `MaterialApp`.

---

### Phase 0.3: Supabase & Environment Init
**Goal**: App boots with Supabase connected and Riverpod wrapping everything.

**Tasks**:
- Create `.env` file with `SUPABASE_URL` and `SUPABASE_ANON_KEY` placeholders
- Add `.env` to `.gitignore`
- `main.dart`: Load `.env` → init Supabase → init Hive → `runApp(ProviderScope(child: JhatPatApp()))`
- `app.dart`: `JhatPatApp` as `ConsumerWidget` returning `MaterialApp.router` with theme and GoRouter (stub router for now)

**Verify**: App launches, Supabase initialises without error, console shows connection success.

---

### Phase 0.4: Navigation Setup
**Goal**: GoRouter with all routes defined and auth-aware redirects.

**Tasks**:
- `app_router.dart`: Define named routes — `splash (/)`, `onboarding`, `sign-in`, `home`, `game/photo-card`, `game/reveal-card`, `game/summary`, `library`, `profile`, `settings`
- Initial location: `/` (splash)
- Redirect logic on splash: check `supabase.auth.currentUser` + `shared_preferences` key `has_seen_onboarding` → route accordingly:
  - Not logged in + no onboarding seen → `/onboarding`
  - Not logged in + onboarding seen → `/sign-in`
  - Logged in → `/home`
- No back button allowed mid-game (intercept pop on `/game/*` routes with exit confirmation dialog)

**Verify**: Navigating to `/` redirects correctly based on auth state.

---

## Prompt 1: Supabase Database Setup

### Phase 1.1: Create All Tables
**Goal**: Full database schema live in Supabase.

**Run this SQL in Supabase SQL editor**:

```sql
create table phrases (
  id uuid primary key default gen_random_uuid(),
  urdu_phrase text not null,
  romanised text not null,
  meaning_urdu text not null,
  example_sentence text not null,
  category text not null check (category in ('محاورہ','کہاوت')),
  difficulty text not null check (difficulty in ('آسان','درمیانہ','مشکل')),
  image_url text not null default '',
  is_active boolean default true,
  created_at timestamptz default now()
);

create table wrong_options (
  id uuid primary key default gen_random_uuid(),
  phrase_id uuid references phrases(id) on delete cascade,
  option_text text not null
);

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_index int default 0,
  xp int default 0,
  level int default 1,
  day_streak int default 0,
  longest_streak int default 0,
  coins int default 50,
  last_played_date date,
  created_at timestamptz default now()
);

create table user_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  phrase_id uuid references phrases(id) on delete cascade,
  photo_guess_correct boolean not null,
  photo_time_seconds int not null,
  photo_points_earned int not null,
  meaning_guess_correct boolean not null,
  meaning_time_seconds int not null,
  meaning_points_earned int not null,
  total_points_earned int not null,
  played_at timestamptz default now(),
  unique(user_id, phrase_id)
);

create table sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  mode text check (mode in ('quick_play','learn','speed_round','category')),
  category text,
  total_cards int not null,
  correct_count int not null,
  total_points int not null,
  xp_earned int not null,
  max_streak int not null,
  completed_at timestamptz default now()
);
```

**Verify**: All 5 tables visible in Supabase Table Editor.

---

### Phase 1.2: RLS Policies
**Goal**: Secure all tables with Row Level Security.

**Run this SQL**:
```sql
alter table phrases enable row level security;
alter table wrong_options enable row level security;
alter table profiles enable row level security;
alter table user_progress enable row level security;
alter table sessions enable row level security;

create policy "phrases_read" on phrases for select using (is_active = true);
create policy "wrong_options_read" on wrong_options for select using (true);
create policy "profiles_all" on profiles using (auth.uid() = id);
create policy "profiles_insert" on profiles for insert with check (auth.uid() = id);
create policy "progress_own" on user_progress using (auth.uid() = user_id);
create policy "progress_insert" on user_progress for insert with check (auth.uid() = user_id);
create policy "sessions_own" on sessions using (auth.uid() = user_id);
create policy "sessions_insert" on sessions for insert with check (auth.uid() = user_id);
```

**Verify**: Anon user can read phrases. Authenticated user can only see their own profile/progress/sessions.

---

### Phase 1.3: Seed Data
**Goal**: 10 phrases and their wrong options in the database.

**Tasks**:
- Insert 10 phrases (see scope doc for full list with Urdu text, romanised, meaning, example, category, difficulty). Leave `image_url` empty for now.
- For each phrase insert 3 wrong option rows in `wrong_options` table. Wrong options should be plausible Urdu meanings that could confuse someone genuinely learning.
- Use flat slug-based image names in Storage:
  - `[phrase_slug]_photo.png`
  - `[phrase_slug]_reveal.png`
- After upload, update `image_url` (photo URL) for each phrase to: `https://[project].supabase.co/storage/v1/object/public/phrase-images/[phrase_slug]_photo.png`
- Keep phrase DB IDs as UUIDs; slugs are only for asset file naming.

**Verify**: `SELECT * FROM phrases` returns 10 rows. `SELECT * FROM wrong_options` returns 30 rows (3 per phrase).

---

## Prompt 2: Data Layer

### Phase 2.1: Data Models
**Goal**: Dart model classes for all 3 entities.

**Tasks**:
- `phrase_model.dart`: Fields matching `phrases` table + `wrongOptions: List<String>` (populated separately). `fromJson`, `toJson`, `copyWith`.
- `profile_model.dart`: Fields matching `profiles` table. `fromJson`, `toJson`, `copyWith`. Add computed getter `levelTitle` returning Urdu string based on level (1→'نیا سیکھنے والا', 5→'پکا شاگرد', 10→'زبان دان', 15→'محاورہ ماہر', 20→'استاد', 30→'زبان کا بادشاہ'). Add `xpForNextLevel` getter.
- `session_model.dart`: Fields matching `sessions` table. `fromJson`, `toJson`, `copyWith`. Add `accuracy` getter (correct/total * 100).

**Verify**: Can construct each model from a hardcoded JSON map with no errors.

---

### Phase 2.2: Cache Service
**Goal**: Hive-based local cache for offline support.

**Tasks**:
- `cache_service.dart`: Methods — `init()` (open Hive boxes), `cachePhrases(List<PhraseModel>)`, `getCachedPhrases()`, `shouldRefetch()` (true if never synced or > 24h ago), `saveOnboardingSeen()`, `hasSeenOnboarding()`, `clearAll()`
- Register as Riverpod `Provider<CacheService>`
- Call `init()` in `main.dart` before `runApp`

**Verify**: After caching phrases, kill network and verify phrases still load.

---

### Phase 2.3: Phrase Repository
**Goal**: Fetch phrases from Supabase (with wrong options) with cache fallback.

**Tasks**:
- `phrase_repository.dart`: `fetchAllPhrases()` — check cache freshness first, else query `phrases` table + join `wrong_options` per phrase, cache result, return list
- `getSessionPhrases({mode, category, difficulty, count})` — filter + shuffle + return `count` items
- On any Supabase error: fall back to cache. If cache also empty: throw readable exception.
- Register as Riverpod `Provider<PhraseRepository>`

**Verify**: On first load, fetches from Supabase. On second load within 24h, returns from Hive.

---

### Phase 2.4: Profile Repository
**Goal**: CRUD for user profiles with XP/level/streak logic.

**Tasks**:
- `profile_repository.dart`: `fetchProfile(userId)`, `createProfile({userId, displayName, avatarIndex})`, `updateProfile(ProfileModel)`, `addXpAndCoins({userId, xp, coins})` (recalculates level), `updateDayStreak(userId)` (yesterday→increment, today→no change, older→reset to 1), `deductCoins({userId, amount})` returns bool
- Level thresholds array: `[0, 100, 250, 400, 500, 700, 900, 1100, 1300, 1500, 1800, 2100, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 10000]`
- Register as Riverpod `Provider<ProfileRepository>`

**Verify**: Create profile → fetch it → add XP → verify level recalculates correctly.

---

### Phase 2.5: Session Repository
**Goal**: Write completed sessions and per-phrase results to Supabase.

**Tasks**:
- `session_repository.dart`: `saveSession(SessionModel)`, `saveUserProgress({userId, phraseId, photoGuessCorrect, photoTimeSeconds, photoPointsEarned, meaningGuessCorrect, meaningTimeSeconds, meaningPointsEarned, totalPointsEarned})` using upsert on `(user_id, phrase_id)`, `saveFullSession({session, phraseResults})` using `Future.wait` for parallel writes, `getRecentSessions({userId, limit: 5})`, `getTodayCardCount(userId)` (count `user_progress` rows since midnight)
- Register as Riverpod `Provider<SessionRepository>`

**Verify**: Complete a mock session → check Supabase table for saved rows.

---

## Prompt 3: Authentication

### Phase 3.1: Auth Provider
**Goal**: Riverpod-managed auth state wrapping Supabase Auth.

**Tasks**:
- `auth_provider.dart`: `AuthNotifier` as `AsyncNotifier<User?>`. Methods: `signInAsGuest()` (Supabase anonymous auth), `signInWithGoogle()` (Supabase OAuth), `signOut()` (clear cache + set null). Listen to `supabase.auth.onAuthStateChange` and sync state.
- Derived providers: `currentUserProvider`, `isLoggedInProvider`

**Verify**: Sign in as guest → `currentUserProvider` returns non-null user.

---

### Phase 3.2: Sign In Screen
**Goal**: Fun, game-like entry screen (not corporate login).

**Tasks**:
- `sign_in_screen.dart`: Avatar selector (6 emoji circles). Display name `TextField` (Urdu hint, max 20 chars). Two buttons: guest play + Google sign-in. Loading indicator during auth.
- On success: call `profileRepository.createProfile()` if profile doesn't exist → navigate to `/home`
- Show SnackBar on error. All labels in Urdu using `AppTextStyles`.

**Verify**: Sign in as guest with a name → profile created in Supabase → lands on home screen.

---

### Phase 3.3: Profile Provider
**Goal**: Riverpod state for the current user's profile with real-time updates.

**Tasks**:
- `profile_provider.dart`: `ProfileNotifier` as `AsyncNotifier<ProfileModel?>`. Methods: `refreshProfile()`, `awardXpAndCoins({xp, coins})` (calls repo + updates state + triggers `levelUpProvider` if level changed), `spendCoins(amount)` (throws if insufficient), `syncDayStreak()`
- `levelUpProvider`: `StateProvider<bool>` defaulting to false — set true when level increases, reset to false after overlay dismissed
- `currentCoinsProvider`: derived `Provider<int>` reading profile coins

**Verify**: Award XP → level recalculates → `levelUpProvider` becomes true when crossing a threshold.

---

## Prompt 4: Scoring Logic

### Phase 4.1: Scoring Constants & Utilities
**Goal**: Single source of truth for all scoring logic. Pure Dart, no Flutter.

**Tasks**:
- `scoring_constants.dart`:
  - Timer durations: quick_play=15s, speed_round=8s, learn=0 (disabled)
  - Hint costs: eliminate=10 coins, freeze=15 coins. Freeze duration=5s
  - XP rates: correct=+10, card completed=+2, perfect session bonus=+50, daily goal bonus=+25
  - Coin rate: +5 per correct answer. Starting balance: 50
  - `calculatePoints(secondsRemaining, isCorrect)` → 500/400/300/200/100/0 based on time brackets (12+/9+/6+/3+/0+)
  - `calculateStreakMultiplier(streak)` → 1.0 / 1.5 / 2.0 / 3.0 at streaks 1-2 / 3-4 / 5-7 / 8+
  - `getStreakLabel(streak)` → '' / '🔥 آگ لگ گئی' / '⚡ ناقابلِ روک' / '👑 استادوں کا استاد'
  - `applyStreakMultiplier(basePoints, streak)` → returns int
  - `calculateSessionXp({correctCount, totalCards, dailyGoalHit})` → totals all XP components
- `urdu_utils.dart`: `toUrduNumerals(int)` converts 0-99 to Urdu numeral characters (٠١٢٣٤٥٦٧٨٩)

**Verify**: Unit test each method with edge cases (0 seconds, streak of 8, perfect session).

---

## Prompt 5: Core Game Loop

### Phase 5.1: Game State Machine
**Goal**: The heart of the app — a Riverpod Notifier managing the full game lifecycle.

**Tasks**:
- Define `GamePhase` enum: `idle, loadingPhrases, showingPhoto, showingResultFlash, showingReveal, showingMeaningQuiz, sessionComplete`
- Define `GameState` with fields: `phase`, `phrases`, `currentIndex`, `currentOptions` (shuffled list of 4 for photo guess), `meaningOptions` (shuffled list of 4 for meaning quiz), `selectedOptionIndex`, `selectedMeaningOptionIndex`, `wasCorrect`, `wasMeaningCorrect`, `secondsRemaining`, `meaningSecondsRemaining`, `streak`, `maxStreak`, `totalPoints`, `sessionResults`, `mode`, `category`, `correctAnswerIndex`, `meaningCorrectAnswerIndex`, `eliminatedIndices (Set<int>)`, `isTimerFrozen`, `hintsUsed`
- `game_provider.dart` — `GameNotifier` as `Notifier<GameState>`:
  - `startSession({mode, category})`: fetch phrases via phraseRepository → setup first card → start timer → set phase to `showingPhoto`
  - `_setupCurrentCard()`: get phrase → combine correct + 3 wrong options → shuffle → record `correctAnswerIndex`
  - `_startTimer()`: periodic 1s timer for photo stage → decrement `secondsRemaining` unless `isTimerFrozen` → on 0 call `_onTimeout()`
  - `submitPhotoAnswer(selectedIndex)`: cancel timer → determine correct → calc photo points with streak multiplier → update streak/maxStreak → set `showingResultFlash` → after 1200ms auto-transition to `showingReveal`
  - `startMeaningQuiz()`: prepare `meaningOptions`, reset meaning selection, start meaning timer (Quick Play 8s, Speed 6s, Learn disabled), set phase `showingMeaningQuiz`
  - `submitMeaningAnswer(selectedIndex)`: cancel meaning timer → determine correct → calc meaning points → append final per-card result to sessionResults → move to next card or `endSession()`
  - `proceedToNextCard()`: increment index → if last card → `endSession()` else → `_setupCurrentCard()` + timer + `showingPhoto`
  - `endSession()`: set `sessionComplete` → calc total XP → call `sessionRepository.saveFullSession()` → call `profileProvider.awardXpAndCoins()` → call `profileProvider.syncDayStreak()`
  - `useEliminateHint()`: spend 10 coins → remove 2 wrong options from `currentOptions` → update `eliminatedIndices`
  - `useFreezeHint()`: spend 15 coins → set `isTimerFrozen=true` → after 5s set false
  - Reset `eliminatedIndices` and `hintsUsed` on `proceedToNextCard()`

**Verify**: Start a session → answer all 10 cards → session saves to Supabase → profile XP updates.

---

### Phase 5.2: Game Widgets
**Goal**: Reusable widgets used on the photo card screen.

**Tasks**:
- `countdown_timer_bar.dart`: Horizontal bar, height 8px. Progress depletes from full to empty. Color: green→yellow→red based on `secondsRemaining/totalSeconds` thresholds (50%/25%). Pulse animation when in red zone. Show Urdu numeral seconds on right. If `isTimerDisabled`: full grey bar, no animation. When `isTimerFrozen`: blue tint + ❄️ icon.
- `mcq_option_tile.dart`: Rounded card, shadow. Left circle with Urdu letter label (الف/ب/ج/د). Center text in Noto Nastaliq RTL. Right icon when answered. States: `normal, selectedCorrect, selectedWrong, revealedCorrect, eliminated`. Tap scale animation (0.95 bounce). Eliminated = grey + strikethrough + not tappable.
- `streak_badge.dart`: Pill badge. Only renders if streak ≥ 3. Color scales with streak. Pulse animation every 1.5s.
- `xp_progress_bar.dart`: Level badge circle + Urdu title + XP fraction + animated fill bar.
- `urdu_text.dart`: Wrapper widget — always applies Noto Nastaliq + RTL. Use this everywhere Urdu text appears.
- `loading_shimmer.dart`: Shimmer variants — `PhraseCardShimmer` (image rect + 4 option rects), `LibraryGridShimmer` (6 cards), `ProfileShimmer`, `SessionRowShimmer`

**Verify**: Each widget renders in isolation with no overflow or font issues.

---

### Phase 5.3: Photo Card Screen
**Goal**: Main gameplay screen — image + timer + 4 MCQ options + hints.

**Tasks**:
- `photo_card_screen.dart`: Watch `gameProvider`. No AppBar — custom top row with round number (Urdu numerals) on left and `StreakBadge` on right.
- `CountdownTimerBar` below top row — reads `secondsRemaining` and `totalSeconds` from game state
- `CachedNetworkImage` card (height 240px, rounded 16, `LoadingShimmer` while loading, grey 🖼 on error)
- Urdu prompt text below image
- 2×2 grid of `McqOptionTile` widgets — pass correct `McqOptionState` per tile based on `selectedOptionIndex`, `wasCorrect`, `correctAnswerIndex`, and `eliminatedIndices`
- Tiles only tappable when `phase == showingPhoto` and no answer yet selected — on tap: `gameProvider.submitPhotoAnswer(index)`
- Hint buttons row: eliminate (💡) and freeze (⏱) with coin costs shown. Disable if: answer already submitted, hint already used this card, insufficient coins.
- Show current coin balance between hint buttons

**Verify**: Tap correct option → green flash → auto-transitions. Tap wrong → red flash + correct revealed. Timer runs out → correct revealed automatically.

---

### Phase 5.4: Result Flash Overlay
**Goal**: 1.2s fullscreen result overlay shown after every answer.

**Tasks**:
- Implement as a `Stack` overlay inside `photo_card_screen.dart` — NOT a separate route
- Show when `phase == showingResultFlash` using `AnimatedOpacity` (fade in 200ms)
- Correct: green background, ✅, animated count-up to points earned, streak label if applicable
- Wrong: red background, ❌, '+0'
- Timeout: grey background, ⏱, 'وقت ختم!'
- Auto-dismissed after 1200ms by `GameNotifier` — overlay fades out when phase changes

**Verify**: Overlay appears and disappears correctly. Points count-up animation plays.

---

### Phase 5.5: Reveal Card Screen
**Goal**: Phrase reveal shown after every photo answer — always, win or lose.

**Tasks**:
- `reveal_card_screen.dart`: Slide-up from bottom when `phase == showingReveal`
- Same image (smaller, 180px). White card slides over bottom of image with rounded top corners.
- Show correct/wrong pill badge. Phrase in large Nastaliq. Keep meaning hidden at this stage. 'مثال میں دیکھیں 👁' button.
- CTA button: 'معنی چنو' → `gameProvider.startMeaningQuiz()`
- Example sentence bottom sheet: full sentence in Nastaliq + romanised below + close button
- Photo stage points chip (gold) top right

**Verify**: Always shows after result flash. 'معنی چنو' starts stage-2 quiz. Example sentence modal opens/closes.

---

### Phase 5.6: Meaning Quiz Stage
**Goal**: Timed second MCQ stage to reinforce phrase meaning.

**Tasks**:
- Add meaning quiz section in `reveal_card_screen.dart` for `phase == showingMeaningQuiz`
- Top timer bar (Quick Play 8s, Speed Round 6s, Learn no timer)
- Prompt: 'اس فقرے کا صحیح مفہوم چنیں'
- Render 2x2 `McqOptionTile` using `meaningOptions`
- On tap: `gameProvider.submitMeaningAnswer(index)`; on timeout auto-reveal correct and submit with 0 points
- After answer, show a short 800ms feedback state (green/red/timeout) and continue
- If last card, go to `/game/summary`; else return to next photo card

**Verify**: Meaning stage always appears after reveal stage. Timer works per mode. Session result includes both stage outcomes.

---

### Phase 5.7: Session Summary Screen
**Goal**: End-of-session results with XP award and navigation.

**Tasks**:
- `session_summary_screen.dart`: All Supabase writes handled by `GameNotifier.endSession()` — just read final state here.
- Trophy 🏆 bounces in. Animated score count-up. 3-stat row: accuracy (Urdu %) / max streak / XP earned.
- If perfect session: gold banner 'کمال! سب صحیح!'
- Scrollable list of phrases played with ✅/❌ and points per card.
- XP progress bar animating from old to new value. Level-up overlay (see Prompt 7) if `levelUpProvider` is true.
- Two buttons: 'دوبارہ کھیلو' (restarts same mode) and 'گھر جاؤ'
- Share button: compose text 'میں نے جھٹ پٹ میں X پوائنٹ حاصل کیے! 🎉' and share via `share_plus`

**Verify**: Full game loop works end to end. Supabase has session + progress rows. Profile XP updated.

---

## Prompt 6: Home & Supporting Screens

### Phase 6.1: Splash Screen
**Goal**: Branded entry point that routes based on auth state.

**Tasks**:
- `splash_screen.dart`: Orange gradient background. App name 'جھٹ پٹ' in large white Nastaliq — scale bounce animation on load. Subtitle below. Small Lottie loader at bottom (use any free loading dots lottie, save to `assets/lottie/loading.json`).
- Logic: `Future.wait([Future.delayed(2s), authCheck])` → navigate based on auth + onboarding flag

**Verify**: Always waits minimum 2 seconds. Routes correctly for new user / returning user / logged-in user.

---

### Phase 6.2: Onboarding Screen
**Goal**: 3-slide intro shown only on first install.

**Tasks**:
- `onboarding_screen.dart`: `PageView` with 3 slides. Slide 1 (orange): 'تصویر دیکھو'. Slide 2 (teal): 'جواب چنو'. Slide 3 (purple): 'سیکھو اور آگے بڑھو'.
- Each slide: full-color background + large emoji in circle + bold white Urdu title + description
- Page indicator dots. Skip button (slides 1-2). Next button (slides 1-2). 'شروع کریں' button (slide 3) → `cacheService.saveOnboardingSeen()` → `/sign-in`

**Verify**: Shows only on first install. After completing, never shows again.

---

### Phase 6.3: Home Screen
**Goal**: Central hub with all game modes and daily progress.

**Tasks**:
- `home_screen.dart`: Custom top bar (avatar + app name 'جھٹ پٹ' + settings icon). `XpProgressBar`. Day streak row (🔥 + coin balance 🪙).
- Daily challenge card (orange-red gradient): 'آج کا ہدف' + X/5 progress + complete state. Read count from `sessionRepository.getTodayCardCount()`.
- 2×2 mode grid — each a gradient card with icon + Urdu label:
  - ⚡ Quick Play → `gameProvider.startSession(mode: 'quick_play')` → `/game/photo-card`
  - 📚 Learn → `startSession(mode: 'learn')` → `/game/photo-card`
  - 🔥 Speed Round → locked if `profile.level < 5` (show lock icon + 'لیول ٥ پر کھلے گا') → `startSession(mode: 'speed_round')`
  - 📁 Category → bottom sheet with category (محاورہ/کہاوت) + difficulty chips + confirm → `startSession(mode: 'category', category: selected)`
- Bottom nav: 🏠 گھر / 📚 لائبریری / 👤 پروفائل

**Verify**: All 4 modes launch correct game. Speed Round locked below level 5. Daily challenge progress accurate.

---

### Phase 6.4: Phrase Library Screen
**Goal**: Browse all phrases. Read-only — no game.

**Tasks**:
- `phrase_library_screen.dart`: Search bar (Urdu hint: 'محاورہ تلاش کریں...'). Filter chips: category (سب/محاورہ/کہاوت) and difficulty (سب/آسان/درمیانہ/مشکل).
- 2-column image grid with phrase text + difficulty badge chip. Show `LibraryGridShimmer` while loading.
- Tap card → bottom sheet with full image + phrase + meaning + example sentence button
- Search filters by `urduPhrase` and `romanised`. Filter state via Riverpod `StateProvider`
- Show 'X محاورے ملے' result count. Show empty state if 0 results.

**Verify**: Search, category filter, and difficulty filter all work independently and combined.

---

### Phase 6.5: Profile Screen
**Goal**: User stats, level, streak, and recent sessions.

**Tasks**:
- `profile_screen.dart`: Gradient header card with avatar + name + level badge. `XpProgressBar`. Stats row (streak / total correct / coins). Achievements row (3 locked grey badges, 'جلد آ رہا ہے' label — placeholder).
- Recent sessions list: last 5 from `sessionRepository.getRecentSessions()`. Each row: mode icon + date + score + accuracy. Empty state if none.
- Sign out button (red outlined) → confirmation dialog → `authProvider.signOut()` → `/sign-in`
- Pull-to-refresh calls `profileProvider.refreshProfile()`

**Verify**: Profile data matches Supabase. Sign out clears cache and returns to sign-in.

---

### Phase 6.6: Settings Screen
**Goal**: Simple user-configurable settings.

**Tasks**:
- `settings_screen.dart`: AppBar with 'ترتیبات' Urdu title.
- Section 1 — Gameplay: Sound toggle, Haptic toggle (both save to `shared_preferences`)
- Section 2 — Account: Change name (dialog + repo update), Change avatar (bottom sheet)
- Section 3 — App: Version (from `package_info_plus`), Clear cache (confirm dialog → `cacheService.clearAll()`)
- Section 4: Sign out (same as profile screen)

**Verify**: Toggles persist across app restarts. Name/avatar changes reflect immediately in profile.

---

## Prompt 7: Polish

### Phase 7.1: Card Flip Animation
**Goal**: Satisfying 3D flip between photo card and reveal card.

**Tasks**:
- `card_flip_animation.dart`: `StatefulWidget` with `frontWidget` and `backWidget` params. Use `AnimationController` (600ms) + `Matrix4.rotationY` for 3D effect. First half: front rotates to 90° (hidden). Second half: back rotates from -90° to 0°. Add perspective (`Matrix4..setEntry(3,2,0.001)`). `Curves.easeInOut`. Subtle scale pulse at midpoint.
- Integrate in transition from photo card state to reveal state

**Verify**: Flip looks smooth and 3D. No flicker at the midpoint.

---

### Phase 7.2: Level Up Overlay
**Goal**: Celebratory overlay when user levels up.

**Tasks**:
- `level_up_overlay.dart`: Full-screen dark overlay. Center white card (rounded 24px). Bouncing ⭐. 'لیول اپ!' text. New level number (large, gold). New level Urdu title. Animated colored dots spreading from center (fake confetti using `flutter_animate`). 'شکریہ! آگے بڑھو' dismiss button → resets `levelUpProvider` to false.
- Show as `Stack` overlay in `session_summary_screen.dart` when `levelUpProvider == true`

**Verify**: Appears after leveling up. Dismisses correctly. Does not re-appear on screen rebuild.

---

### Phase 7.3: Error & Empty States
**Goal**: Consistent fallback UI across all screens.

**Tasks**:
- `error_state.dart`: ⚠️ + Urdu message + optional 'دوبارہ کوشش کریں' retry button
- `empty_state.dart`: Emoji + Urdu message. Centered.
- Apply `ErrorState` in: `photo_card_screen` (phrase load fail), `profile_screen` (profile load fail)
- Apply `EmptyState` in: `phrase_library_screen` (0 results), `profile_screen` (no sessions)
- In `session_repository.dart`: if `saveFullSession` fails, store to a Hive `pending_sessions` box and retry on next app launch

**Verify**: Force a network error → error state shows with retry button that works.

---

### Phase 7.4: RTL & Urdu Text Audit
**Goal**: Every piece of Urdu text renders correctly on both iOS and Android.

**Tasks**:
- Audit every screen and widget — every Urdu string must use `UrduText` widget (or manually set `textDirection: RTL` + `GoogleFonts.notoNastaliqUrdu`)
- All `TextField` with Urdu input: `textDirection: RTL`, `textAlign: TextAlign.right`
- All `Row` containing Urdu content: `textDirection: TextDirection.rtl`
- Wrap `MaterialApp` in `Directionality(textDirection: TextDirection.ltr)` — layout is LTR, text is RTL per widget
- Move `toUrduNumerals()` helper to `urdu_utils.dart` and use everywhere numbers display in Urdu context
- Verify all `BottomSheet` widgets handle RTL without clipping

**Verify**: Run on physical Android + iOS. All Urdu renders in Nastaliq. Numbers in Urdu where specified. No overflow.

---

### Phase 7.5: Final Integration & Build Check
**Goal**: App is complete, stable, and builds for release.

**Tasks**:
- Verify Supabase RLS doesn't block any operation by testing each flow as anonymous + authenticated user
- Verify `gameProvider` fully resets between sessions (no state leakage)
- Verify `levelUpProvider` resets correctly after overlay dismissed
- Add `PopScope` widget on all `/game/*` screens — on back press: show 'کیا آپ واقعی چھوڑنا چاہتے ہیں؟' dialog
- Add `errorWidget` to all `CachedNetworkImage` widgets (grey box + 🖼 emoji)
- Test offline: kill network → phrases load from cache → progress saves locally → syncs when online
- Run `flutter analyze` — fix all warnings
- Run `flutter build apk --release` — confirm successful build

**Verify**: Clean analyze output. Release APK builds. Full game loop works on physical device.

---

## Dependency Chain

```
Prompt 0 (Foundation)
    ↓
Prompt 1 (Supabase DB — run SQL manually before any code)
    ↓
Prompt 2 (Data Layer — models, cache, repositories)
    ↓
Prompt 3 (Auth — provider, sign-in screen, profile provider)
    ↓
Prompt 4 (Scoring Logic — pure Dart utils, no UI)
    ↓
Prompt 5 (Core Game Loop — state machine + all game screens)
    ↓
Prompt 6 (All Other Screens — splash, home, library, profile, settings)
    ↓
Prompt 7 (Polish — animations, error states, RTL audit, build)
```

---

## Coverage Checklist

| Scope Item | Prompt |
|---|---|
| Folder structure + dependencies | 0.1 |
| Theme, colors, Urdu fonts | 0.2 |
| Supabase init + env | 0.3 |
| Navigation + auth redirect | 0.4 |
| All 5 DB tables + RLS | 1.1, 1.2 |
| Phrase + wrong option seed data | 1.3 |
| Data models (phrase, profile, session) | 2.1 |
| Hive local cache | 2.2 |
| Phrase repository + caching | 2.3 |
| Profile repository + XP/level/streak | 2.4 |
| Session repository + parallel writes | 2.5 |
| Auth provider (guest + Google) | 3.1 |
| Sign in screen | 3.2 |
| Profile provider + level-up state | 3.3 |
| Scoring constants + Urdu numerals | 4.1 |
| Game state machine (full lifecycle) | 5.1 |
| Timer bar, MCQ tile, streak, XP, shimmer widgets | 5.2 |
| Photo card screen (image + timer + MCQ + hints) | 5.3 |
| Result flash overlay | 5.4 |
| Reveal card + example sentence modal | 5.5 |
| Session summary + XP animation + share | 5.6 |
| Splash screen | 6.1 |
| Onboarding (3 slides, one-time) | 6.2 |
| Home screen (4 modes + daily challenge) | 6.3 |
| Phrase library (search + filters + grid) | 6.4 |
| Profile screen (stats + sessions) | 6.5 |
| Settings screen | 6.6 |
| Card flip animation | 7.1 |
| Level up celebration overlay | 7.2 |
| Error + empty states + offline queue | 7.3 |
| RTL + Urdu text audit | 7.4 |
| Final integration + release build | 7.5 |

**Total: 24 prompts across 7 phases**

---

*جھٹ پٹ — زبان سیکھو، مزہ کرو | Cursor Prompt Playbook v2.0 | April 2026*
