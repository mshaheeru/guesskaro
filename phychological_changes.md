# جھٹ پٹ — UX & Engagement Improvement Prompts for Cursor
**Version 1.0 | Based on psychological engagement analysis + competitor research**

---

## How to Use This Document

Work through each section in priority order (P0 → P1 → P2).
Each section is a self-contained prompt you can paste directly into Cursor.
Reference the technical scope document alongside each prompt.
Start a new Cursor session for each major section.

---

## P0 — Critical Changes (Do These First)

These directly impact first-session retention and viral growth.
Do not move to P1 until all P0 items are complete.

---

### P0-A: Onboarding Overhaul

**Current problem:**
The app opens with 5 static slides explaining features. This violates the
WYSIATI principle — users form their entire first impression before touching
the actual game. 5 slides of explanation creates cognitive load before any
emotional hook exists. Duolingo discovered that interactive onboarding
outperforms explanatory onboarding by significant margins.

**What to build:**

Replace the 5 static onboarding slides with a single interactive demo round.

Behaviour:
- On first launch, after the splash screen, show ONE screen with the text:
  "آزمائیں — ایک سوال مفت!" (Try it — one free question!)
- Load a single pre-selected "easy" phrase (hardcoded, not fetched —
  use آنکھوں کا تارا ہونا or باغ باغ ہونا for maximum visual impact)
- Run the player through the full photo_card_screen flow for this one card
  with a subtle pulsing highlight on the MCQ options (first-time hint)
- After they answer, show the reveal_card_screen normally
- After the reveal, instead of proceeding to meaning check, show a
  celebration overlay with the text:
  "بس اتنا ہے! اب اصل کھیل شروع کریں"
  with a single CTA button → Login/Signup screen
- Store a flag in shared_preferences: 'onboarding_complete: true'
  so this never shows again

Skip logic:
- If onboarding_complete is true → go directly to splash → home flow
- Add a small "چھوڑیں" (skip) text button top-right for users who tap
  past immediately

Why this works:
The player has experienced the emotional core of the game before being
asked to commit to an account. The ask (sign up) comes after the reward
(fun), not before it.

Files to modify:
- lib/screens/onboarding/onboarding_screen.dart (full replacement)
- lib/screens/splash/splash_screen.dart (add onboarding check)
- lib/core/constants/app_strings.dart (add new strings)

---

### P0-B: Home Screen Restructure

**Current problem:**
The home screen has options listed without hierarchy or emotional urgency.
There is no daily habit trigger visible. A user who opens the app on day 3
sees the same home screen as day 1 — no sense of progress, streak danger,
or daily mission.

**What to build:**

Restructure the home screen into three clear visual zones:

ZONE 1 — STATUS BAR (top, always visible)
- Left: flame icon + streak number (e.g. 🔥 7) — tappable, shows streak
  history modal
- Center: XP progress bar showing progress to next level with level number
- Right: coin count with coin icon

ZONE 2 — DAILY MISSION CARD (prominent, below status bar)
A card that changes state based on time and progress:

State A — Not played today:
  Title: "آج کا چیلنج" 
  Subtitle: "5 محاورے مکمل کریں — 25 XP انعام"
  Progress bar: 0/5
  Button: "ابھی کھیلو" (prominent, filled button)
  
State B — Partially played:
  Show progress: "3/5 مکمل — 2 باقی ہیں"
  Progress bar filled accordingly
  Button: "جاری رکھیں"
  
State C — Daily goal complete:
  Green card, checkmark, "آج کا ہدف مکمل! کل ملیں"
  Still show the play buttons below for extra rounds

ZONE 3 — GAME MODES (below daily card)
Keep existing mode buttons but reorder by frequency of use:
1. ⚡ جھٹ پٹ کھیلو (Quick Play) — largest button
2. 📅 محاورہ روز (Phrase of the Day) — NEW, see P0-C
3. 🔥 اسپیڈ راؤنڈ (Speed Round)
4. 📁 زمرہ چنو (Category Play)

Bottom of screen: small icon row for Leaderboard / Library / Profile
Remove "Meet our actors" from home — move it into Profile screen under
a "کردار" section.

Data needed on this screen (already in scope):
- profile.day_streak
- profile.xp + profile.level
- profile.coins
- today's session count (query sessions table for today's date)

Files to modify:
- lib/screens/home/home_screen.dart
- lib/widgets/scoring/xp_progress_bar.dart
- lib/widgets/scoring/streak_badge.dart

---

### P0-C: Phrase of the Day — محاورہ روز

**This is the most important feature in this entire document.**
This is the Wordle mechanic. This is your viral engine.

**What to build:**

Database change:
Add a column to the phrases table:
```sql
alter table phrases add column featured_date date;
```
Each day, one phrase gets featured_date = today. This is set manually
(or via a Supabase edge function on a schedule). Start by setting them
manually for the first 30 days.

Game behaviour:
- Phrase of the Day uses the standard Quick Play flow but for exactly
  ONE card (the featured phrase)
- Timer is active (same as Quick Play)
- At the end, instead of session summary, show the SHARE CARD screen
  (see below)
- A user can only play Phrase of the Day ONCE per day
- If already played: show their score + share card option again,
  grey out the play button with "آج کھیل چکے ہیں — کل واپس آئیں"

Share Card screen — build this as a new screen:
lib/screens/game/phrase_of_day_share_screen.dart

The share card must contain:
- The phrase's image (full quality)
- The phrase text in Urdu (large, Nastaliq font)
- The player's result: ✅ or ❌
- Points earned (if correct)
- A blurred/hidden meaning — the answer is NOT shown on the card
- App name "جھٹ پٹ" with a small tagline
- A "واٹس ایپ پر شیئر کریں" button

Share card implementation:
Use Flutter's RepaintBoundary widget to capture the card widget as an
image, then share via share_plus package.

```dart
// Add to pubspec.yaml
share_plus: ^7.x.x
```

The share text that accompanies the image on WhatsApp:
"آج کا محاورہ میں نے بوجھ لیا! 🎯
کیا آپ بوجھ سکتے ہیں؟
جھٹ پٹ پر کھیلیں — [App Store link]"

Home screen entry point:
The محاورہ روز button on the home screen should show a subtle
"نیا!" badge until the user plays it that day. Once played, show
their score on the button itself: "✅ 500 pts"

Files to create:
- lib/screens/game/phrase_of_day_share_screen.dart

Files to modify:
- lib/data/repositories/phrase_repository.dart (add featured_date query)
- lib/providers/phrase_provider.dart (add phrase of day provider)
- lib/screens/home/home_screen.dart (add entry point)

---

### P0-D: Session Summary Redesign

**Current problem:**
The session summary is the last thing a user sees before closing the app.
Per the Peak-End Rule (Kahneman), people judge an entire experience by its
peak moment and its final moment. The session summary IS the product in the
user's memory. It must feel like a celebration designed specifically for
this person's performance.

**What to build:**

Replace the current session summary with a multi-stage animated screen:

STAGE 1 — Score reveal (1.5 seconds)
- Black screen fades to the app's primary color
- Score counts up from 0 to final score using flutter_animate
- Large confetti burst (use confetti package) if score > 300

STAGE 2 — Personal insight card (the most important addition)
Generate ONE contextual insight based on the session data.
Use this priority logic:

```dart
String generateInsight(SessionResult session, UserProfile profile) {
  if (session.correctCount == session.totalCards) {
    return "کمال! آپ نے ${session.totalCards} میں سے ${session.totalCards} صحیح کیے — صرف ٪${perfectSessionPercentage} کھلاڑی یہ کر پاتے ہیں";
  }
  if (session.maxStreak >= 5) {
    return "آپ کی ${session.maxStreak} سوالوں کی لڑی — آج کی بہترین کارکردگی!";
  }
  if (session.totalPoints > profile.bestSessionScore) {
    return "نیا ذاتی ریکارڈ! 🎉 آپ نے اپنا پرانا ریکارڈ توڑ دیا";
  }
  if (session.hardPhrasesCorrect > 0) {
    return "${session.hardPhrasesCorrect} مشکل محاورے صحیح — صرف ٪20 کھلاڑی یہ جانتے ہیں";
  }
  // Default
  return "آج ${session.correctCount} نئے محاورے سیکھے — کل مزید سیکھیں";
}
```

STAGE 3 — Stats row
- Accuracy: X/Y صحیح
- Best streak: X 🔥
- XP earned: +X XP (animate the XP bar filling on the profile)
- Coins earned: +X 🪙

STAGE 4 — Phrase list (scrollable)
Keep the existing phrases learned list but add:
- A "واٹس ایپ پر شیئر کریں" share button at the top of the list
- Each phrase row shows: image thumbnail + phrase + ✅/❌

STAGE 5 — Action buttons
- "دوبارہ کھیلو" — primary button
- "گھر جاؤ" — secondary button
- "محاورہ روز کھیلیں" — shown only if they haven't played it today

Add to pubspec.yaml:
```yaml
confetti: ^0.7.x
```

Files to modify:
- lib/screens/game/session_summary_screen.dart (full redesign)
- lib/data/repositories/session_repository.dart (add bestSessionScore query)

---

### P0-E: Streak Shield System

**What to build:**

This converts loss aversion directly into a monetization and engagement event.

New UI element — Streak Shield indicator:
- On the home screen status bar, if the user has a streak >= 3, show
  a small shield icon next to the flame
- Shield states: 🛡️ Active (green), 🛡️ Inactive (grey)

Shield purchase:
- In the home screen or profile, add a "لڑی بچاؤ" section
- Cost: 50 coins for 1 Streak Shield (protects one missed day)
- A user can hold maximum 2 shields at a time

Shield activation logic (in game_provider.dart):
```dart
// Run this check on app launch, in the auth state listener
Future<void> checkAndApplyStreakShield() async {
  final lastPlayed = profile.lastPlayedDate;
  final today = DateTime.now().toLocal();
  final daysSinceLastPlay = today.difference(lastPlayed).inDays;
  
  if (daysSinceLastPlay == 1) return; // played yesterday, no issue
  
  if (daysSinceLastPlay >= 2 && profile.streakShields > 0) {
    // Auto-consume one shield, preserve streak
    await profileRepository.consumeStreakShield();
    // Show a toast: "آپ کی لڑی ڈھال نے بچا لی! 🛡️"
  } else if (daysSinceLastPlay >= 2) {
    // Streak resets to 0
    await profileRepository.resetStreak();
    // Show a modal: "آپ کی X روزہ لڑی ختم ہو گئی"
    // with option to buy shield for NEXT time
  }
}
```

Add to profiles table:
```sql
alter table profiles add column streak_shields int default 0;
```

Push notification (day-end warning):
At 9 PM local time, if the user hasn't played today:
"⚠️ آپ کی ${streak} روزہ لڑی خطرے میں ہے! ابھی کھیلیں"
Use local notifications package for this.

Add to pubspec.yaml:
```yaml
flutter_local_notifications: ^16.x.x
```

Files to modify:
- lib/data/models/profile_model.dart (add streakShields field)
- lib/providers/game_provider.dart (add shield logic)
- lib/data/repositories/profile_repository.dart (add consumeStreakShield)
- lib/screens/home/home_screen.dart (add shield UI)

---

## P1 — Important Retention Features

Build these after all P0 items are complete and tested.

---

### P1-A: Friend Challenge System

**What to build:**

New screen: lib/screens/game/friend_challenge_screen.dart

Flow:
1. After any completed session, add a "دوست کو چیلنج کریں" button
   on the session summary screen
2. Tapping it generates a unique challenge link (deep link) containing:
   - The session's phrase IDs (so friend plays same phrases)
   - The challenger's score
3. Friend receives the link, opens the app, plays the same phrases
4. After completion, show a comparison screen:
   "آپ نے X پوائنٹ کیے — [Friend] نے Y پوائنٹ کیے تھے"
   with ✅ "آپ جیت گئے!" or ❌ "اگلی بار!"

Deep linking setup:
Use app_links package for Flutter deep link handling.

Add to Supabase:
```sql
create table challenges (
  id uuid primary key default gen_random_uuid(),
  challenger_id uuid references profiles(id),
  phrase_ids uuid[] not null,
  challenger_score int not null,
  created_at timestamptz default now(),
  expires_at timestamptz default now() + interval '48 hours'
);
```

The challenge share text for WhatsApp:
"میں نے جھٹ پٹ میں ${score} پوائنٹ کیے! کیا آپ مجھ سے بہتر کر سکتے ہیں؟
چیلنج قبول کریں: [deep_link]"

Files to create:
- lib/screens/game/friend_challenge_screen.dart
- lib/data/repositories/challenge_repository.dart

---

### P1-B: Weekly Leaderboard (Reset-Based)

**Current problem:**
A global all-time leaderboard is demotivating for new players who can
never catch the top. Weekly-reset leaderboards create urgency every 7 days
and give every player a fresh chance.

**What to build:**

Modify the existing leaderboard screen to have two tabs:
- Tab 1: "اس ہفتے" (This Week) — resets every Monday midnight
- Tab 2: "کل وقتی" (All Time) — existing leaderboard

Weekly leaderboard logic:
```sql
-- Add a weekly_xp column that resets every week via a Supabase cron job
alter table profiles add column weekly_xp int default 0;

-- Supabase Edge Function (scheduled, runs every Monday 00:00 PKT):
-- update profiles set weekly_xp = 0;
```

On the weekly leaderboard, show:
- Player rank this week
- A progress motivator below their row:
  "آپ [Name] سے صرف 120 XP پیچھے ہیں!"
  (always reference the person directly above them)

Add to profiles table:
```sql
alter table profiles add column weekly_xp int default 0;
```

Every XP award must also increment weekly_xp alongside xp.

Files to modify:
- lib/screens/profile/leaderboard_screen.dart (add tabs)
- lib/data/repositories/profile_repository.dart (weekly_xp updates)

---

### P1-C: Notification System

**What to build:**

Three notification types, in priority order:

1. STREAK DANGER (highest priority)
Trigger: User has not played by 9 PM local time AND has streak >= 2
Message variants (rotate randomly):
- "🔥 آپ کی ${streak} روزہ لڑی آج رات ختم ہو جائے گی!"
- "⚠️ ابھی کھیلیں — کل بہت دیر ہو جائے گی"
- "🛡️ آپ کی لڑی خطرے میں ہے — ایک راؤنڈ کافی ہے"

2. DAILY REMINDER (medium priority)
Trigger: User has not played today AND it's their usual play time
(track play_hour from session history, default to 8 PM)
Message: "آج کا محاورہ روز آپ کا انتظار کر رہا ہے 📖"

3. FRIEND BEAT YOU (engagement)
Trigger: A friend completes a challenge where their score exceeds yours
Message: "[Friend] نے آپ کو پیچھے چھوڑ دیا! بدلہ لیں 💪"

Implementation:
Use flutter_local_notifications for streak danger and daily reminder
(these are time-based, no server needed).
Use Supabase realtime or a simple polling mechanism for friend beats.

Files to create:
- lib/core/services/notification_service.dart

Files to modify:
- lib/main.dart (initialize notification service)
- lib/providers/auth_provider.dart (schedule notifications on login)

---

### P1-D: Guest-to-User Conversion Flow

**Current problem:**
Guest users who can't access the leaderboard hit a wall. This wall should
be a gentle invitation, not a hard block.

**What to build:**

When a guest user taps Leaderboard:
- Don't block them with an error
- Show the leaderboard with their scores displayed as "مہمان" 
  with a ghost/anonymous avatar
- Below their row, show a non-intrusive card:
  "اپنا نام لیڈر بورڈ پر لگائیں — مفت اکاؤنٹ بنائیں"
  with Google Sign-In button and "بعد میں" dismiss option

When a guest completes 3 sessions:
- After the third session summary, before the action buttons, show
  a full-screen modal (dismissible):
  "آپ نے ${totalScore} پوائنٹ کمائے — انہیں محفوظ کریں!"
  "اکاؤنٹ بنائیں اور اپنی ترقی کبھی نہ گنوائیں"
  
Guest score preservation:
When a guest converts to a real account:
- Transfer their sessions and progress to the new account
- Show: "آپ کے تمام پوائنٹ محفوظ کر لیے گئے ✅"

Files to modify:
- lib/screens/auth/sign_in_screen.dart
- lib/providers/auth_provider.dart (add guest conversion logic)
- lib/screens/profile/leaderboard_screen.dart (guest state)

---

## P2 — Growth Features

Build these after P1 is stable. These drive external growth.

---

### P2-A: Seasonal Events Engine

**What to build:**

A simple events system that overlays seasonal content and UI changes.

Add to Supabase:
```sql
create table seasonal_events (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  start_date date not null,
  end_date date not null,
  theme_color text,
  bonus_xp_multiplier float default 1.0,
  featured_category text
);
```

Seasonal events to pre-populate:
| Event | Dates | XP Bonus | Featured |
|---|---|---|---|
| رمضان المبارک | Variable | 1.5x | روزہ/عبادت phrases |
| عید الفطر | Variable | 2x | خوشی phrases |
| یوم آزادی | Aug 14 | 1.5x | قومی phrases |
| موسم سرما | Dec 15–Jan 15 | 1.2x | موسم phrases |

During active event:
- Home screen gets a subtle themed banner (color, event name)
- Daily challenge shows event-specific phrases
- Session summary shows event bonus multiplier applied
- Phrase of the Day is drawn from the featured category

Files to create:
- lib/data/models/seasonal_event_model.dart
- lib/data/repositories/seasonal_event_repository.dart
- lib/widgets/common/seasonal_banner.dart

---

### P2-B: Mehfil Mode (Group Play)

**What to build:**

A local multiplayer mode designed for family gatherings.
No internet required after phrases load.

Entry point: Add "محفل موڈ" button on home screen (below main modes)
with a subtle "نیا!" badge for 30 days after launch.

Flow:
1. Host screen: Enter number of players (2–6), enter player names
2. Each player takes turns holding the phone
3. Same phrase shown to all — but each player has 10 seconds to answer
   (shorter timer than normal, creates pressure)
4. Phone is passed around the table after each question
5. Final screen: ranking of all players by score
6. Share button: generates a group result image for WhatsApp

This requires NO new backend — runs entirely on device using local state.

Files to create:
- lib/screens/game/mehfil_mode_screen.dart
- lib/providers/mehfil_game_provider.dart

---

### P2-C: WhatsApp Sticker Pack

**This is a marketing asset, not an in-app feature.**

Generate 10 sticker images from the most visually striking phrase images
in your library and publish as a WhatsApp Sticker Pack.

Sticker pack requirements:
- Each sticker: 512x512 px, WebP format, transparent background
- Include the Urdu phrase text overlaid in Nastaliq font
- Pack name: "جھٹ پٹ محاورے"

Submission: Use WhatsApp's Sticker Pack Creator tool (no API needed,
it's a simple desktop app).

Suggested phrases for stickers (choose visually strong images):
- طوطے اڑ جانا
- آگ بگولہ ہونا
- باغ باغ ہونا
- ناک میں دم کرنا
- آنکھوں کا تارا ہونا

In-app hook:
Add a small "واٹس ایپ اسٹیکر ڈاؤن لوڈ کریں" option in the Profile screen
that deep-links to the sticker pack.

---

## Global Changes — Apply Across All Screens

These apply everywhere and should be done as a single pass after P0.

---

### GLOBAL-A: Notification Framing (Loss Aversion)

Audit every notification, tooltip, and status message in the app.
Apply this rule: Frame as potential loss, not potential gain.

Find and replace:
| Current (gain framing) | Replace with (loss framing) |
|---|---|
| "آپ کی لڑی: 7 دن" | "آپ کی 7 روزہ لڑی آج رات خطرے میں ہے!" |
| "XP کمائیں" | "آج کا XP نہ گنوائیں" |
| "دوست کو چیلنج کریں" | "[Friend] آپ سے آگے نکل گئے!" |
| "کھیلیں اور سیکھیں" | "آج کا محاورہ صرف آج دستیاب ہے" |

---

### GLOBAL-B: Urdu Copy Audit

Audit all Urdu strings in app_strings.dart for tone.
The app's voice should be: warm, slightly teasing, like a clever older
sibling — not formal, not robotic, not overly enthusiastic.

Tone examples:
- ❌ "براہ کرم لاگ ان کریں" (too formal)
- ✅ "اندر آئیں، کھیل شروع ہونے والا ہے"

- ❌ "غلط جواب" (too blunt)  
- ✅ "اوہو! اگلی بار ہوگا"

- ❌ "آپ نے 500 پوائنٹ حاصل کیے" (robotic)
- ✅ "واہ! 500 پوائنٹ — آج آپ نے دکھا دیا"

---

### GLOBAL-C: Loading State Polish

Every network request currently shows a generic loading state.
Replace with contextually relevant Kela Sahab micro-animations:

- Phrases loading: Kela Sahab holding his magnifying glass to his eye,
  scanning left-right (simple Lottie animation)
- Score submitting: Kela Sahab dropping a letter in a postbox
- Leaderboard loading: Kela Sahab climbing a ladder

Commission these as 3 Lottie files (simple, 1-2 second loops).
Use the lottie package already in the dependency list.

Files to modify:
- lib/widgets/common/loading_shimmer.dart (add Lottie variants)

---

## Implementation Priority Summary

| Priority | Item | Effort | Impact |
|---|---|---|---|
| P0-A | Onboarding overhaul | Medium | Very High |
| P0-B | Home screen restructure | Medium | Very High |
| P0-C | Phrase of the Day + Share Card | High | Critical |
| P0-D | Session summary redesign | Medium | Very High |
| P0-E | Streak shield system | Medium | High |
| P1-A | Friend challenge | High | High |
| P1-B | Weekly leaderboard | Low | High |
| P1-C | Notification system | Medium | High |
| P1-D | Guest conversion flow | Low | Medium |
| P2-A | Seasonal events | Medium | Medium |
| P2-B | Mehfil mode | High | High |
| P2-C | WhatsApp sticker pack | Low | Medium |

---

## Notes for Cursor Sessions

- Paste the technical scope document at the start of every Cursor session
- Work one P0 item per session — do not combine multiple items
- After each item, run the app and test the full flow before moving on
- The Phrase of the Day (P0-C) and Session Summary (P0-D) should be
  built in the same session as they share the share card component
- All Supabase schema changes should be run manually in the dashboard
  before asking Cursor to write the corresponding Dart code



  OTHER:


  Session Summary — 4 critical fixes
The current screen opens with "0 fully correct (5)" — this is the most psychologically damaging line in the entire app. Per the Peak-End Rule, users remember how something made them feel at the end. Opening the summary by quantifying failure means the session ends on a negative emotional note no matter what happened before it. The redesign puts the score in a green celebration header first, so the emotional framing is success before the details.
The per-phrase list currently shows only red X marks with romanized English text ("Bagh bagh hona"). This is wrong on two levels. First, romanized English on a Urdu cultural app breaks immersion at the exact moment the user should feel most connected to the language. Second, showing only that they got something wrong without showing the correct answer wastes the best learning moment in the entire app flow. The redesign shows the correct Urdu answer in red below each missed phrase — the summary screen becomes a revision tool.
The share button is completely missing from the current summary. This is the highest-intent moment in the entire session — the user just finished something, emotions are fresh, they have a score to show. This is when people share. The share icon sits right next to the primary CTA in the redesign so it's always visible without taking space from anything.
The 0% accuracy display needs to be deprioritized but not hidden. In the redesign it's in a compact 3-column stats row alongside "1/5 correct" and "+35 XP" — so no single negative number dominates.

Leaderboard — 3 critical fixes
The current guest message ("Guests are not shown on the leaderboard. Sign up to compete globally") is a wall, not an invitation. It tells the guest they don't exist. The redesign uses loss aversion correctly — the guest sees themselves already on the board in 3rd place with their actual score. The message becomes "you have a rank, create an account to keep it" instead of "you have nothing, sign up." This is a completely different psychological proposition and will convert far better.
The empty bottom half of a leaderboard with only 2 players is the single biggest trust signal problem in the app. A new user sees 2 entries and a void and thinks "nobody plays this." The weekly reset progress bar fills that space with something useful and creates time urgency — users who see "resets Sunday" will play more before the week ends.
The motivator card ("you're 290 XP behind Shaheer — play one round!") applies Kahneman's anchoring principle. The gap is real but the reframe makes it feel closeable rather than discouraging. This single line will drive more sessions than any push notification you can send.