# جھٹ پٹ (Jhat Pat) — Flutter Design Handoff
**Version 1.0 | April 2026 | For use with Cursor / Claude Code**

> Reference the `Jhat Pat.html` prototype alongside this document.
> Every measurement is in logical pixels (dp/sp). All colors are sRGB hex.

---

## 1. Design Tokens

### 1.1 Colors

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // Backgrounds
  static const Color bgPrimary    = Color(0xFF1A1A2E); // Main screen bg
  static const Color bgCard       = Color(0xFF16213E); // Card surfaces
  static const Color bgElevated   = Color(0xFF0F3460); // Elevated cards, modals

  // Brand
  static const Color orange       = Color(0xFFFF6B35); // Primary accent
  static const Color orangeGlow   = Color(0x40FF6B35); // Glow shadow (25% opacity)
  static const Color orangeDim    = Color(0x1FFF6B35); // Subtle tint (12% opacity)

  // Semantic
  static const Color correct      = Color(0xFF00D97E); // Correct answer green
  static const Color correctGlow  = Color(0x3300D97E);
  static const Color wrong        = Color(0xFFFF4757); // Wrong answer red
  static const Color wrongGlow    = Color(0x33FF4757);

  // Rewards
  static const Color gold         = Color(0xFFFFD700); // Coins, XP
  static const Color purple       = Color(0xFFC77DFF); // Learn mode, level 2 quiz

  // Text
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecondary= Color(0xFF8892A4);
  static const Color textMuted    = Color(0xFF4A5568);

  // Borders
  static const Color borderSubtle = Color(0x12FFFFFF); // 7% white
  static const Color borderOrange = Color(0x66FF6B35); // 40% orange
}
```

### 1.2 Typography

```dart
// lib/core/constants/app_text_styles.dart
// Fonts: Noto Nastaliq Urdu (Urdu), Poppins (English/numbers)
// Add to pubspec.yaml under google_fonts or asset fonts

class AppTextStyles {
  // ── Urdu (Noto Nastaliq Urdu, RTL, textAlign: TextAlign.right) ──
  static const TextStyle urduDisplay = TextStyle(
    fontFamily: 'Noto Nastaliq Urdu',
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static const TextStyle urduTitle = TextStyle(
    fontFamily: 'Noto Nastaliq Urdu',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle urduHeadline = TextStyle(
    fontFamily: 'Noto Nastaliq Urdu',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.6,
  );
  static const TextStyle urduBody = TextStyle(
    fontFamily: 'Noto Nastaliq Urdu',
    fontSize: 18, // MINIMUM — never go below 18sp for Urdu
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.8,
  );
  static const TextStyle urduCaption = TextStyle(
    fontFamily: 'Noto Nastaliq Urdu',
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  // ── English / Numbers (Poppins, LTR) ──
  static const TextStyle enDisplay = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 52,
    fontWeight: FontWeight.w900,
    color: AppColors.gold,
    letterSpacing: -1,
  );
  static const TextStyle enTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle enBody = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const TextStyle enCaption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
  static const TextStyle enLabel = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );
}
```

### 1.3 Spacing & Radius

```dart
class AppSpacing {
  static const double screenPadding = 20.0;  // Left/right padding on all screens
  static const double cardRadius    = 20.0;  // Main content cards
  static const double chipRadius    = 20.0;  // Filter chips, badges
  static const double btnRadius     = 16.0;  // Buttons
  static const double tileRadius    = 16.0;  // MCQ option tiles
  static const double gap           = 12.0;  // Standard gap between items
  static const double gapLarge      = 20.0;
}
```

### 1.4 Shadows / Glows

```dart
// Use BoxDecoration.boxShadow everywhere — no Material elevation
class AppShadows {
  static List<BoxShadow> cardGlow(Color color) => [
    BoxShadow(color: color.withOpacity(0.25), blurRadius: 20, spreadRadius: 0),
    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> orangeCard = cardGlow(AppColors.orange);
  static List<BoxShadow> correctGlow = cardGlow(AppColors.correct);
  static List<BoxShadow> wrongGlow = cardGlow(AppColors.wrong);
  static List<BoxShadow> goldGlow = cardGlow(AppColors.gold);
}
```

### 1.5 Theme Config

```dart
// lib/core/theme/app_theme.dart
ThemeData appTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bgPrimary,
  colorScheme: ColorScheme.dark(
    primary: AppColors.orange,
    secondary: AppColors.gold,
    surface: AppColors.bgCard,
    background: AppColors.bgPrimary,
    error: AppColors.wrong,
  ),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  // No default card elevation — handled per widget
);
```

---

## 2. Reusable Widget Specs

### 2.1 `JpCard` — Base card

```dart
// Equivalent: Container with rounded corners, border, optional glow
Container(
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderOrange, width: 1),
    boxShadow: AppShadows.orangeCard,
  ),
)
```

### 2.2 `JpButtonPrimary` — Orange CTA

```dart
SizedBox(
  width: double.infinity, height: 56,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      shadowColor: Colors.transparent,
    ).copyWith(
      overlayColor: MaterialStateProperty.all(Colors.white12),
    ),
    child: Text(label, style: AppTextStyles.urduBody.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
  ),
)
// Add glow via Container wrapper: boxShadow: [BoxShadow(color: AppColors.orangeGlow, blurRadius: 20)]
```

### 2.3 `JpButtonGhost` — Outline button

```dart
SizedBox(
  width: double.infinity, height: 54,
  child: OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      side: BorderSide(color: AppColors.borderSubtle, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: Text(label, style: AppTextStyles.urduBody),
  ),
)
```

### 2.4 `XpBar` widget

```dart
Row(children: [
  // Level badge
  Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: AppColors.orangeGlow, blurRadius: 10)],
    ),
    child: Center(child: Text('$level', style: AppTextStyles.enTitle.copyWith(fontSize: 14))),
  ),
  SizedBox(width: 10),
  // Bar
  Expanded(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: xpPct,          // 0.0 to 1.0
        minHeight: 8,
        backgroundColor: Colors.white.withOpacity(0.08),
        valueColor: AlwaysStoppedAnimation(AppColors.orange), // or gradient via CustomPainter
      ),
    ),
  ),
])
// For gradient bar, use CustomPainter drawing a LinearGradient from #FF6B35 to #FFD700
```

### 2.5 `CoinBadge` widget

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.gold.withOpacity(0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text('🪙', style: TextStyle(fontSize: 14)),
    SizedBox(width: 5),
    Text('$amount', style: AppTextStyles.enBody.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
  ]),
)
```

### 2.6 `StreakBadge` widget

```dart
// Same structure as CoinBadge but orange
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.orangeDim,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderOrange),
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text('🔥', style: TextStyle(fontSize: 14)),
    SizedBox(width: 5),
    Text('$count', style: AppTextStyles.enBody.copyWith(color: AppColors.orange, fontWeight: FontWeight.w700)),
  ]),
)
```

### 2.7 `McqOptionTile` widget

```dart
// States: idle, correct, wrong, disabled
// Use AnimatedContainer for state transitions (duration: 200ms)
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  decoration: BoxDecoration(
    color: _bgColor(),        // see below
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _borderColor(), width: 1.5),
    boxShadow: _boxShadow(),
  ),
  child: InkWell(
    onTap: state == McqState.idle ? onTap : null,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(text, style: AppTextStyles.urduBody.copyWith(
          color: _textColor(),
          fontWeight: state != McqState.idle ? FontWeight.w700 : FontWeight.w400,
        )),
      ),
    ),
  ),
)

Color _bgColor() => switch(state) {
  McqState.correct  => AppColors.correct.withOpacity(0.15),
  McqState.wrong    => AppColors.wrong.withOpacity(0.15),
  McqState.disabled => AppColors.bgCard,
  _                 => AppColors.bgCard,
};
Color _borderColor() => switch(state) {
  McqState.correct  => AppColors.correct,
  McqState.wrong    => AppColors.wrong,
  McqState.disabled => AppColors.borderSubtle,
  _                 => Colors.white.withOpacity(0.1),
};
List<BoxShadow> _boxShadow() => switch(state) {
  McqState.correct => AppShadows.correctGlow,
  McqState.wrong   => AppShadows.wrongGlow,
  _                => [],
};
```

### 2.8 `TimerBar` widget

```dart
// Custom widget — LinearProgressIndicator doesn't support color transitions well
class TimerBar extends StatelessWidget {
  final double value; // 0.0 (empty) to 1.0 (full)

  Color get _color {
    if (value > 0.6) return AppColors.correct;
    if (value > 0.3) return AppColors.gold;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 6,
      backgroundColor: Colors.white.withOpacity(0.08),
      valueColor: AlwaysStoppedAnimation(_color),
    ),
  );
  // Add danger pulse when value < 0.3:
  // Wrap in AnimatedScale that pulses 1.0→1.3→1.0 on a 400ms loop
}
```

### 2.9 `BottomNavBar` widget

```dart
// Use a custom widget, NOT BottomNavigationBar — we need precise control
Container(
  height: 72,
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    border: Border(top: BorderSide(color: AppColors.borderSubtle)),
  ),
  child: Row(children: [
    _NavItem(icon: Icons.home_rounded, label: 'Home', active: activeTab == 'home', onTap: ...),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Library', active: activeTab == 'library', onTap: ...),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', active: activeTab == 'profile', onTap: ...),
  ]),
)
// Active tab: icon color = AppColors.orange, add drop shadow filter for glow
// Inactive: icon color = AppColors.textSecondary
// Label fontSize = 10sp, fontWeight: w600
```

---

## 3. Screen-by-Screen Flutter Specs

---

### Screen 1 — Splash (`splash_screen.dart`)

**Background:** `RadialGradient(center: Alignment(0, -0.3), colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)])`

**Layout:** `Column` centered with `MainAxisAlignment.center`

**Robot mascot widget (top):**
```
Container (140×140, circular border: 2px orange@27%)
  └ Container (110×110, circular, border: 2px orange@40%)
      └ Container (76×76, borderRadius: 20, gradient: #C0C0C0 → #909090)
          ├ Two circles (12×12, orange, glow shadow)  ← eyes
          ├ Container (28×4, #666, radius 2)          ← mouth
          └ Antenna: Container (3×14, #999) + dot (8×8, orange, glow) at top
```

**Animations:**
- Mascot: `ScaleTransition` 0.3→1.0, `CurvedAnimation(Curves.elasticOut)`, 600ms
- App name: `SlideTransition` Y+20→0 + `FadeTransition`, 600ms, delay 300ms
- Tagline: `FadeTransition`, delay 600ms
- Loading dots: `FadeTransition` + pulsing `AnimatedOpacity` on loop, delay 1000ms
- Mascot loop: `Transform.translate` Y 0→-6→0, 3s infinite, `Curves.easeInOut`
- Screen exit: `FadeTransition` out, 500ms, after 2200ms

**App name:** `Text('جھٹ پٹ', style: urduDisplay)` + `Text('Jhat Pat', style: enLabel.copyWith(color: orange, letterSpacing: 3))`

---

### Screen 2 — Onboarding (`onboarding_screen.dart`)

**Background per slide (animated with `AnimatedContainer`):**
- Slide 1 (orange): `LinearGradient([Color(0x33FF6B35), bgPrimary])`
- Slide 2 (green): `LinearGradient([Color(0x3300D97E), bgPrimary])`
- Slide 3 (purple): `LinearGradient([Color(0x33C77DFF), bgPrimary])`

**Layout:**
```
Column
  ├ Row(mainAxisAlignment: end) → Skip button (jp-btn-ghost style, top-right)
  ├ Expanded → Column(center)
  │   ├ FloatingIcon (140×140 circle, bg: accent@10%, border: accent@27%)
  │   │   └ Text(icon emoji, fontSize: 56) + float animation
  │   ├ SizedBox(32)
  │   ├ Text(title, urduTitle, textAlign: center)
  │   ├ SizedBox(12)
  │   ├ Text(subtitle, urduHeadline.copyWith(color: textSecondary))
  │   └ Text(detail, urduCaption)
  └ Padding(bottom: 40)
      ├ DotsIndicator (animated width: active=24, inactive=8, height=8, radius=4)
      ├ SizedBox(24)
      └ JpButtonPrimary ('اگلا' / 'شروع کریں')
```

**Slide transitions:** `PageView` with `PageController`, custom `PageTransitionsTheme` or manual `AnimatedSwitcher` with `SlideTransition`.

**Dots:** Active dot width animates 8→24 with `AnimatedContainer(duration: 300ms)`. Active color = current slide accent. Inactive = `textMuted`.

---

### Screen 3 — Sign In (`sign_in_screen.dart`)

**Background:** Plain `bgPrimary` + top gradient overlay `LinearGradient([Color(0x330F3460), transparent])`

**Layout:**
```
SingleChildScrollView
  └ Column
      ├ Header (padding: 48 top, 28 sides)
      │   ├ Text('خوش آمدید', urduDisplay.copyWith(fontSize: 36))
      │   └ Text(subtitle, urduCaption)
      └ Padding(24 sides, 40 bottom)
          ├ Language selector: Row of 2 ToggleButtons
          ├ SizedBox(24)
          ├ Avatar picker: Row of 6 GestureDetector circles (52×52)
          │   Selected: border 2px orange, scale 1.15, glow shadow
          │   Unselected: border 2px transparent, bg white@5%
          ├ SizedBox(24)
          ├ Text('اپنا نام', urduCaption)
          ├ SizedBox(10)
          ├ TextField (urduBody style, rtl, underline → OutlineInputBorder radius 16)
          │   focusedBorder: orange@40%, unfocused: white@10%
          ├ SizedBox(32)
          ├ JpButtonPrimary (disabled opacity 0.5 when name empty)
          ├ SizedBox(12)
          ├ JpButtonGhost ('مہمان کے طور پر کھیلو')
          └ SizedBox(12) + Google button (white bg, #333 text, Google SVG logo)
```

**Avatar circles:** `AnimatedScale` + `AnimatedContainer` for border. On tap, scale from 1.0→1.15 with `Curves.elasticOut`.

---

### Screen 4 — Home (`home_screen.dart`)

**Structure:** `Scaffold(backgroundColor: bgPrimary)` with custom bottom nav.

```
Column
  ├ TopBar: Row(between) → Text('جھٹ پٹ', urduTitle) + CoinBadge
  ├ ProfileCard (margin: 16 top, 20 sides)
  │   └ JpCard(padding: 16)
  │       ├ Row: Avatar(50×50 circle) + Name/Level column + StreakBadge
  │       ├ SizedBox(14)
  │       └ XpBar
  ├ DailyGoalCard (margin: 12 top, 20 sides)
  │   └ Container(bgCard, radius 14, border: gold@20%)
  │       ├ Row: 🎯 + 'آج کا ہدف' + progress text (gold)
  │       └ LinearProgressIndicator(gold, height 6, margin-top 10)
  ├ SizedBox(16)
  ├ Expanded → GridView.count(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, padding: 20 sides)
  │   └ 4x ModeCard widgets (see below)
  └ BottomNavBar
```

**ModeCard:**
```dart
GestureDetector(
  onTap: locked ? null : onTap,
  child: AnimatedContainer(
    duration: Duration(milliseconds: 150),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: locked ? borderSubtle : accentColor.withOpacity(0.27), width: 1.5),
      boxShadow: locked ? [] : AppShadows.cardGlow(accentColor),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(44, 44, radius: 12, bg: accentColor@10%) → icon emoji (22sp)
      SizedBox(12)
      Text(urduLabel, urduHeadline.copyWith(fontSize: 18))
      Text(enLabel OR lockMsg, enCaption OR enCaption.copyWith(color: wrong))
    ]),
  ),
)
```
Mode colors: Quick=orange, Learn=#C77DFF, Speed=wrong, Category=gold.

**Entrance animation:** Each card slides up with `SlideTransition` + `FadeTransition`, staggered by `index * 70ms`.

---

### Screen 5 — Photo Card (`photo_card_screen.dart`)

**This is the most important screen. Nail every detail.**

```
Column
  ├ HeaderRow (padding: 14 top, 20 sides)
  │   └ Row(between): 'Card X/Y' (enBody) + Row[StreakBadge?, CoinBadge]
  ├ TimerSection (padding: 0 sides 12 bottom)
  │   ├ TimerBar(value: timeLeft/totalTime)
  │   └ Row(end): countdown text (enCaption, color→wrong when <5s)
  ├ CardImage (margin: 0 20 16)
  │   └ ClipRRect(radius: 20) wrapping CachedNetworkImage
  │       Decoration: border 2px orange@40%, boxShadow: black@40% blur 32
  │       Category badge: Positioned(top:10, right:10) Container(orange, radius:8, urduCaption)
  ├ PromptText (padding: 0 20 14)
  │   └ Text('اس تصویر کا کیا مطلب ہے؟', urduCaption, textAlign: right)
  ├ Expanded → Column of 4 McqOptionTiles (padding: 0 20, gap: 10)
  │   Each tile entrance: SlideTransition Y+30→0, stagger index*70ms
  └ HintRow (padding: 12 20 20)
      └ Row(gap: 10): EliminateBtn + FreezeBtn (see below)
```

**Timer logic:**
```dart
// In initState
_controller = AnimationController(vsync: this, duration: Duration(seconds: totalTime));
_controller.addListener(() {
  if (_controller.value <= 0 && !_answered) _onTimeout();
});
_controller.reverse(from: 1.0); // Start full, drain to 0

// Timer bar value = _controller.value (auto-animated)
```

**Hint buttons styling:**
```dart
// Eliminate
Container(
  decoration: BoxDecoration(
    color: AppColors.wrong.withOpacity(0.10),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.wrong.withOpacity(0.40), width: 1.5),
  ),
  child: TextButton(
    onPressed: canEliminate ? onEliminate : null,
    child: Text('➖ Eliminate (10🪙)', style: enBody.copyWith(color: wrong)),
  ),
)
// Freeze: same pattern but ice blue (#64C8FF)
```

**On answer tap (correct):**
1. Stop timer: `_controller.stop()`
2. Set tile state to `McqState.correct` → `AnimatedContainer` triggers
3. Wait 900ms → navigate to ResultFlash

**On answer tap (wrong):**
1. Set tapped tile → `McqState.wrong`, correct tile → `McqState.correct`
2. Wait 900ms → navigate to ResultFlash

**Eliminate hint:**
- Cost: 10 coins
- Remove 2 wrong options: set them to `McqState.disabled`, `AnimatedOpacity` to 0.5

**Time Freeze hint:**
- Cost: 15 coins
- `_controller.stop()` for 5s, then `_controller.forward()` — no, `_controller.reverse()` continuation:
  ```dart
  _controller.stop();
  await Future.delayed(Duration(seconds: 5));
  _controller.reverse(); // continues from current value
  ```

---

### Screen 6 — Result Flash (`result_flash_screen.dart`)

**Auto-advance after 1600ms.** No user input needed.

**Background:**
```dart
correct
  ? RadialGradient(colors: [Color(0x5500D97E), bgPrimary])
  : RadialGradient(colors: [Color(0x55FF4757), bgPrimary])
```

**Layout:**
```
Stack
  ├ Confetti overlay (if correct): see below
  └ Column(center)
      ├ ResultIcon (110×110 circle, animated)
      │   border 3px: correct=green / wrong=red
      │   bg: accent@13%
      │   child: Text('✓' / '✗', fontSize: 50, color: accent)
      │   boxShadow: glow 40px blur
      ├ SizedBox(24)
      ├ Text('شاباش!' / 'غلط جواب', urduTitle.copyWith(color: accent))
      ├ if correct && points > 0:
      │   Text('+$points', enDisplay, color: gold) — animated scale-in
      └ if streak >= 3:
          StreakBadge(count: streak)
```

**Animations:**
- Icon: `ScaleTransition` 0→1.2→1.0, `Curves.elasticOut`, 500ms
- Label: `SlideTransition` Y+20→0 + `FadeTransition`, delay 200ms
- Points: Custom keyframe: scale 0→1.3→1.0 + Y+20→0, delay 300ms
- Streak badge: `SlideTransition`, delay 500ms

**Confetti (if correct):**
```dart
// Use the `confetti` Flutter package
ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive,
  colors: [AppColors.orange, AppColors.gold, AppColors.correct, Color(0xFFC77DFF)],
  numberOfParticles: 18,
  gravity: 0.3,
)
// Fire _confettiController.play() in initState if correct
```

---

### Screen 7 — Reveal Card (`reveal_card_screen.dart`)

```
SingleChildScrollView
  └ Column
      ├ HeaderRow: 'Card X/Y · Reveal' + 'انکشاف' (orange)
      ├ CardImage (same as PhotoCard but height: 180)
      ├ PhraseRevealCard (margin: 0 20 16) — JpCard
      │   ├ Text(urdu, urduTitle, textAlign: right)
      │   ├ Text(roman, enBody.copyWith(color: textSecondary))
      │   ├ Divider(color: borderSubtle, height: 32)
      │   └ Text('معنی: $meaning', urduBody.copyWith(color: orange))
      ├ ExampleButton (margin: 0 20 16)
      │   Container(border: borderSubtle, radius: 14)
      │   Row(center): '👁' + Text('مثال دیکھیں', urduBody)
      └ JpButtonPrimary('معنی کوئز →', margin: 0 20 28)
```

**Entrance animations:** All three sections slide up with `SlideTransition`, staggered 0ms / 100ms / 200ms.

**Example bottom sheet:**
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: AppColors.bgCard,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (_) => Padding(
    padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
    child: Column(children: [
      Row(between): [CloseButton styled, Text('مثال', urduBody.copyWith(color: orange))],
      SizedBox(20),
      Text(example, urduHeadline, textAlign: right, height: 2.0),
      Text(roman, enBody),
    ]),
  ),
);
```

---

### Screen 7b — Meaning Quiz (second stage, same `reveal_card_screen.dart`)

Identical to **Photo Card** but:
- Timer = 8 seconds total (vs 15)
- Show phrase card at top instead of image
- Prompt: `'اس فقرے کا صحیح مفہوم کیا ہے؟'`
- Stage label: `'مرحلہ ۲/۲'` in purple (`AppColors.purple`)
- No hint buttons
- Points: 200 / 150 / 100 / 50 (time-based)

```dart
// Phrase display card
Container(
  margin: EdgeInsets.fromLTRB(20, 4, 20, 20),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(20)),
  child: Column(children: [
    Text(phrase.urdu, urduTitle, textAlign: center),
    SizedBox(4),
    Text(phrase.roman, enBody),
  ]),
)
```

---

### Screen 8 — Session Summary (`session_summary_screen.dart`)

```
SingleChildScrollView
  └ Column
      ├ HeaderSection (bg gradient: gold@15% → transparent, padding: 40 top)
      │   ├ Text('🏆', fontSize: 48)
      │   ├ Text('سیشن مکمل!', urduTitle)
      │   ├ AnimatedCountUp score (enDisplay, color: gold, glow)
      │   └ Text('Total Points', enCaption)
      ├ StatsRow (padding: 0 20 16): 3 cards
      │   Each: Container(bgCard, radius:16, border: color@20%)
      │     icon + value (color, w800, 18sp) + label (muted, 11sp)
      │   Cards: Correct (green), XP Earned (gold), Accuracy (purple)
      ├ Text('Card Breakdown', enBody, padding: 0 20 10)
      ├ List of CardResultTile per phrase played
      │   Row(between): urduBody(phrase) + Row[emoji + pts(gold)]
      └ ButtonSection (padding: 8 20 36)
          ├ JpButtonPrimary('دوبارہ کھیلو')
          └ JpButtonGhost('گھر جاؤ')
```

**Animated score count-up:**
```dart
// flutter_animate package or manual Tween
TweenAnimationBuilder<int>(
  tween: IntTween(begin: 0, end: totalScore),
  duration: Duration(milliseconds: 1200),
  curve: Curves.easeOut,
  builder: (_, value, __) => Text('${value.toLocaleString()}', style: enDisplay),
)
```

**Stats cards entrance:** `SlideTransition` Y+20→0, `FadeTransition`, all 3 animate together at 400ms.

**Card result tiles:** Staggered `SlideTransition`, delay = `index * 60ms`.

---

### Screen 9 — Phrase Library (`phrase_library_screen.dart`)

```
Column
  ├ Header (padding: 16 top, 20 sides)
  │   ├ Text('کتب خانہ', urduTitle)
  │   ├ SearchField (radius: 14, bg: bgCard, border: borderSubtle)
  │   │   prefixIcon: search icon (left side, despite RTL — keep it left)
  │   ├ FilterChips row (wrap): category chips + difficulty chips
  │   └ Text('$count phrases found', enCaption)
  └ Expanded → GridView.builder(crossAxisCount: 2, childAspectRatio: 0.75)
      └ LibraryCard (bgCard, radius: 16, overflow: hidden)
          ├ CachedNetworkImage (height: 120, fit: BoxFit.cover)
          ├ Padding(10)
          │   ├ Text(urduPhrase, urduBody.copyWith(fontSize: 16), height: 1.6)
          │   └ Row of chips: category(orange) + difficulty(muted)
```

**Filter chips:**
```dart
FilterChip(
  label: Text(label, style: urduCaption),
  selected: isSelected,
  backgroundColor: bgCard,
  selectedColor: filterColor.withOpacity(0.22),
  side: BorderSide(color: isSelected ? filterColor : borderSubtle),
  labelStyle: TextStyle(color: isSelected ? filterColor : textSecondary),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
)
```

**Card hover/tap:** Scale 1.0→1.02 with `GestureDetector` + `AnimatedScale`.

---

### Screen 10 — Profile (`profile_screen.dart`)

```
SingleChildScrollView
  └ Column
      ├ HeaderSection (bg gradient: bgElevated → transparent, padding: 24 top)
      │   ├ Avatar (80×80, border 3px orange, glow, float animation)
      │   ├ Text(name, enTitle)
      │   ├ Text(levelTitle, urduBody.copyWith(color: orange))
      │   ├ SizedBox(16)
      │   └ XpBar + xp progress text
      ├ StatsRow (padding: 16 20 0): 4 cards
      │   Streak(orange) | Best(gold) | Coins(gold) | Correct%(green)
      ├ SectionLabel('Recent Sessions')
      ├ List of SessionTile
      │   Row(between): [mode name + date] + [pts(gold) + correct ratio]
      └ SignOutButton (red ghost button, padding: 12 20)
```

---

### Screen 11 — Settings (`settings_screen.dart`)

```
Column
  ├ Text('Settings', enTitle, padding: 16 top)
  └ ListView
      ├ SettingsSection('Language')
      │   └ SettingsRow → Row of 2 ToggleButtons (ur/en)
      ├ SettingsSection('Gameplay')
      │   ├ SettingsRow('Sound Effects') → custom Toggle switch
      │   ├ SettingsRow('Haptic Feedback') → Toggle
      │   └ SettingsRow('Daily Reminders') → Toggle
      ├ SettingsSection('Account')
      │   ├ SettingsRow('Change Name', sublabel: currentName) → edit icon
      │   └ SettingsRow('Change Avatar') → emoji display
      ├ SettingsSection('About')
      │   ├ SettingsRow('App Version') → Text('1.0.0+1')
      │   └ SettingsRow('Clear Cache') → broom icon
      └ SignOutButton (red, full-width, margin: 8 20)
```

**Custom Toggle switch:**
```dart
// Do NOT use Flutter's Switch — style it manually for dark theme
GestureDetector(
  onTap: () => setState(() => value = !value),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 300),
    width: 50, height: 28,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: value ? LinearGradient(colors: [orange, Color(0xFFFF4500)]) : null,
      color: value ? null : Colors.white.withOpacity(0.1),
      boxShadow: value ? [BoxShadow(color: orangeGlow, blurRadius: 12)] : [],
    ),
    child: AnimatedAlign(
      duration: Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(3),
        width: 22, height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)]),
      ),
    ),
  ),
)
```

**Section wrapper:**
```dart
Padding(
  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: enLabel)),
    Container(
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle)),
      child: Column(children: rows),
    ),
  ]),
)
```

---

## 4. Game State Machine

Implement in `game_provider.dart` using Riverpod `StateNotifier`:

```dart
enum GamePhase { idle, loadingPhrases, showingPhoto, resultFlash, showingReveal, showingMeaningQuiz, sessionComplete }

class GameState {
  final GamePhase phase;
  final List<Phrase> phrases;
  final int cardIndex;         // current card (0-based)
  final int streak;
  final int coins;
  final bool photoCorrect;     // result of photo guess
  final int photoPoints;
  final List<CardResult> results;
  final bool eliminated;       // hint: eliminate used
  // ...
}
```

**Navigation flow:**
```
idle → startSession() → loadingPhrases → showingPhoto
showingPhoto → onAnswer() → resultFlash (1600ms auto) → showingReveal
showingReveal → onStartMeaning() → showingMeaningQuiz
showingMeaningQuiz → onAnswer()
  → cardIndex < total: showingPhoto (next card)
  → cardIndex == total: sessionComplete
sessionComplete → onDismiss() → idle
```

---

## 5. Navigation (GoRouter)

```dart
// All routes
GoRoute(path: '/splash',   builder: (_,__) => SplashScreen())
GoRoute(path: '/onboarding', builder: (_,__) => OnboardingScreen())
GoRoute(path: '/signin',   builder: (_,__) => SignInScreen())
GoRoute(path: '/home',     builder: (_,__) => HomeScreen())
GoRoute(path: '/game',     builder: (_,__) => PhotoCardScreen())
GoRoute(path: '/result',   builder: (_,__) => ResultFlashScreen())
GoRoute(path: '/reveal',   builder: (_,__) => RevealCardScreen())
GoRoute(path: '/summary',  builder: (_,__) => SessionSummaryScreen())
GoRoute(path: '/library',  builder: (_,__) => PhraseLibraryScreen())
GoRoute(path: '/profile',  builder: (_,__) => ProfileScreen())
GoRoute(path: '/settings', builder: (_,__) => SettingsScreen())

// Page transitions — custom slide
CustomTransitionPage(
  transitionsBuilder: (_, animation, __, child) =>
    SlideTransition(position: Tween(begin: Offset(1,0), end: Offset.zero).animate(animation), child: child),
)
// For result flash: FadeTransition instead of slide
```

---

## 6. Key Animation Timings Reference

| Animation | Duration | Curve | Notes |
|---|---|---|---|
| Screen slide in | 300ms | `easeOutCubic` | All screen push transitions |
| Result flash icon | 500ms | `elasticOut` | Scale 0→1 bounce |
| Score count-up | 1200ms | `easeOut` | Tween int 0→total |
| MCQ tile correct/wrong | 200ms | `easeInOut` | Color + shadow transition |
| MCQ tile entrance stagger | 70ms per tile | `easeOut` | Slide Y+30→0 |
| XP bar fill | 1000ms | `easeOut` | On profile/summary load |
| Toggle switch | 300ms | `elasticOut` | Knob movement |
| Mode card hover | 150ms | `easeInOut` | Scale + shadow |
| Mascot float | 3000ms | `easeInOut` | Y 0→-6→0, infinite |
| Bottom sheet | 300ms | `easeOutCubic` | Default Flutter |
| Confetti | Start immediately | — | `confetti` package |
| Timer danger pulse | 400ms | `easeInOut` | Y scale 1→1.3, when <30% |

---

## 7. pubspec.yaml additions

```yaml
dependencies:
  google_fonts: ^6.x.x       # Poppins + Noto Nastaliq Urdu
  cached_network_image: ^3.x.x
  confetti: ^0.7.x           # Result flash confetti
  flutter_animate: ^4.x.x    # Score count-up, stagger helpers
  lottie: ^3.x.x             # Optional: swap confetti for Lottie

flutter:
  fonts:
    - family: NotoNastaliqUrdu
      fonts:
        - asset: assets/fonts/NotoNastaliqUrdu-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoNastaliqUrdu-Bold.ttf
          weight: 700
  # OR use google_fonts package dynamically (requires internet on first load)
```

---

## 8. Gotchas & Flutter-Specific Notes

| Issue | Solution |
|---|---|
| Urdu text RTL | Wrap all Urdu Text in `Directionality(textDirection: TextDirection.rtl, child: ...)` or set `textDirection: TextDirection.rtl` on Text widget |
| Noto Nastaliq line height | Always set `height: 1.6` minimum — Nastaliq glyphs have tall ascenders |
| Timer cancellation | Always cancel `AnimationController` in `dispose()` to avoid setState after unmount |
| MCQ shuffle | Shuffle once in `initState`, store result — never re-shuffle on rebuild |
| Bottom nav + keyboard | Wrap scaffold in `resizeToAvoidBottomInset: false` to prevent layout jump when keyboard opens on Sign In |
| Image loading | Use `CachedNetworkImage` with a `ShimmerPlaceholder` (dark shimmer, not white) |
| Dark shimmer | Use `shimmer` package with `baseColor: bgCard, highlightColor: bgElevated` |
| Coin deduction | Deduct coins optimistically in UI, sync to Supabase after |
| Back button on game | Override with `PopScope(canPop: false)` — game should not be accidentally dismissed |

---

*Handoff generated from `Jhat Pat.html` prototype | April 2026*
