# جھٹ پٹ (Jhat Pat) — Flutter Design Handoff
**Version 2.0 · "Sunny Quiz" theme · May 2026 · For use with Cursor / Claude Code**

> Reference the `Jhat Pat.html` prototype alongside this document.
> Every measurement is in logical pixels (dp/sp). All colors are sRGB hex.
>
> **What changed in v2.0:** Entire theme moved from dark/orange/navy ("corporate") to a warm cream + tomato + marigold + teal palette with chunky ink outlines and hard offset shadows. Typography moved from Poppins → **Nunito** (heavier weights, more friendly). The Urdu face stays **Noto Nastaliq Urdu**.

---

## 0. Aesthetic in one paragraph

Cream paper background. Chunky black-ink outlines (≈2.5 dp) on every card, button, badge, and input. Hard, opaque offset shadows (e.g. `Offset(4,4)`, no blur, ink-colored) replace soft drop shadows. Color blocks are flat — no gradients, no glows. Type is **Nunito** at heavy weights (800/900) for English/numbers, **Noto Nastaliq Urdu** for Urdu. Accents are a small primary set: **tomato** for CTA + brand, **marigold** for rewards + coins, **teal** for correct/success, **purple** for the meaning-quiz stage. The vibe is a friendly trivia game / kids' book — warm, confident, never corporate.

---

## 1. Design Tokens

### 1.1 Colors

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // ── Surfaces ──────────────────────────────────────────────────
  static const Color paper      = Color(0xFFFFF1D6); // primary screen bg
  static const Color paperWarm  = Color(0xFFFCE4B6); // input bg / track / muted surface
  static const Color card       = Color(0xFFFFFFFF); // card bg
  static const Color paperShade = Color(0xFFF3D89C); // imagery placeholder stripe

  // ── Ink (text + outlines + offset shadow) ─────────────────────
  static const Color ink        = Color(0xFF2A1810); // borders, primary text, offset shadow
  static const Color inkSoft    = Color(0xFF6B5D52); // secondary text
  static const Color inkMuted   = Color(0xFFA89580); // tertiary / disabled

  // ── Brand accents ─────────────────────────────────────────────
  static const Color tomato     = Color(0xFFE94F37); // primary CTA, brand red, wrong answer
  static const Color marigold   = Color(0xFFFFB627); // rewards, coins, daily goal, active nav
  static const Color teal       = Color(0xFF2A9D8F); // correct answer, XP fill, learn secondary
  static const Color purple     = Color(0xFF7E57C2); // meaning quiz stage 2, special
  static const Color sky        = Color(0xFF5DBBE8); // chill accent (rarely used)

  // ── Mode card colors (Home grid) ──────────────────────────────
  static const Color modeQuick     = tomato;
  static const Color modeLearn     = purple;
  static const Color modeSpeed     = marigold;
  static const Color modeCategory  = teal;

  // ── Tints (state surfaces, derived) ───────────────────────────
  static const Color correctSurface = Color(0xFFDFF3F0); // teal @ ~12% on paper
  static const Color wrongSurface   = Color(0xFFFBE0DC); // tomato @ ~12% on paper

  // ── Shadows ───────────────────────────────────────────────────
  // All "elevation" is a hard offset shadow in ink. No blur.
  // See AppShadows below.
}
```

### 1.2 Typography

```dart
// lib/core/constants/app_text_styles.dart
// Fonts:
//   - Nunito (English, numbers, UI labels) — weights 600, 700, 800, 900
//   - Noto Nastaliq Urdu (Urdu, RTL)        — weights 400, 500, 700
// Add via google_fonts package or bundled assets.

class AppTextStyles {
  // ── Urdu (Noto Nastaliq Urdu, RTL, textAlign: TextAlign.right) ──
  // height: 1.6 minimum (Nastaliq has tall ascenders/descenders)
  static const TextStyle urduDisplay = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 44, fontWeight: FontWeight.w700,
    color: AppColors.ink, height: 1.4,
  );
  static const TextStyle urduTitle = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 30, fontWeight: FontWeight.w700,
    color: AppColors.ink, height: 1.5,
  );
  static const TextStyle urduHeadline = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.ink, height: 1.7,
  );
  static const TextStyle urduBody = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 18,                     // MINIMUM — never go below 18sp for Urdu
    fontWeight: FontWeight.w500,
    color: AppColors.ink, height: 1.8,
  );
  static const TextStyle urduCaption = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 14, color: AppColors.inkSoft, height: 1.6,
  );

  // ── English / Numbers (Nunito, LTR) ─────────────────────────────
  static const TextStyle enDisplay = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 64, fontWeight: FontWeight.w900,
    color: AppColors.tomato,
    letterSpacing: -2, height: 1.0,
    // shadow handled by widget (textShadow w/ marigold + ink offset)
  );
  static const TextStyle enTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22, fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );
  static const TextStyle enLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13, fontWeight: FontWeight.w900,
    color: AppColors.ink,
    letterSpacing: 1.0,                       // for uppercase eyebrows
  );
  static const TextStyle enBody = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.inkSoft,
  );
  static const TextStyle enCaption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12, fontWeight: FontWeight.w800,
    color: AppColors.inkSoft,
    letterSpacing: 0.3,
  );
}
```

**Weights cheat-sheet (Nunito):**
| Use | Weight |
|---|---|
| Display numbers (scores), big headlines | 900 |
| Card titles, button text, primary labels | 800 |
| Secondary labels, eyebrows | 700–800 |
| Body / hint text | 600–700 |

Avoid weights below 600 in Nunito — the typeface looks anemic at lighter weights against the ink outlines.

### 1.3 Spacing & Radius

```dart
class AppSpacing {
  // Screen padding
  static const double screenPadding = 20.0;

  // Radius scale (everything is rounded — but never circular except avatars/dots)
  static const double rCard      = 24.0;  // Main content cards
  static const double rTile      = 20.0;  // MCQ option tiles
  static const double rButton    = 18.0;  // Buttons
  static const double rInput     = 16.0;  // Text fields
  static const double rChip      = 999.0; // Filter chips, badges, sticker pills
  static const double rIconBox   = 14.0;  // Square icon containers (mode card icons)
  static const double rAvatar    = 18.0;  // Squircle avatars (NOT circles; 28 for big)

  // Gaps
  static const double gapXS = 4.0;
  static const double gapS  = 8.0;
  static const double gapM  = 12.0;
  static const double gapL  = 16.0;
  static const double gapXL = 20.0;
}
```

### 1.4 Borders & Shadows

```dart
class AppBorders {
  // Every elevated surface gets a hairline ink outline. NO soft borders.
  static const double bThin    = 2.0;    // chips, small badges
  static const double bDefault = 2.5;    // cards, buttons, MCQ tiles
  static const double bThick   = 3.0;    // splash mark, result icon

  static Border ink({double width = bDefault}) =>
    Border.all(color: AppColors.ink, width: width);

  static BorderRadius card    = BorderRadius.circular(AppSpacing.rCard);
  static BorderRadius button  = BorderRadius.circular(AppSpacing.rButton);
  static BorderRadius tile    = BorderRadius.circular(AppSpacing.rTile);
}

class AppShadows {
  // HARD offset shadows — no blur, opaque ink. This is the signature look.
  // Use the appropriate offset for the perceived elevation:
  //   2px → small chip / badge
  //   3px → MCQ tile, secondary card
  //   4px → main card / button (default elevation)
  //   5–6px → splash mark, hero CTA
  //   7–8px → result flash icon

  static List<BoxShadow> sm = [
    BoxShadow(color: AppColors.ink, offset: Offset(2, 2), blurRadius: 0),
  ];
  static List<BoxShadow> md = [
    BoxShadow(color: AppColors.ink, offset: Offset(3, 3), blurRadius: 0),
  ];
  static List<BoxShadow> lg = [
    BoxShadow(color: AppColors.ink, offset: Offset(4, 4), blurRadius: 0),
  ];
  static List<BoxShadow> xl = [
    BoxShadow(color: AppColors.ink, offset: Offset(6, 6), blurRadius: 0),
  ];

  // State variants — when an element is colored to show state (correct/wrong),
  // the shadow takes the state color, not ink. E.g. correct MCQ tile:
  static List<BoxShadow> correctMd = [
    BoxShadow(color: AppColors.teal, offset: Offset(3, 3), blurRadius: 0),
  ];
  static List<BoxShadow> wrongMd = [
    BoxShadow(color: AppColors.tomato, offset: Offset(3, 3), blurRadius: 0),
  ];
}
```

> **Press feedback** — for any tappable surface with a hard offset shadow, the press animation translates the surface by `+ Offset(2, 2)` and reduces the shadow offset by 2px in each axis (so it appears to "push down into" the shadow). Use a stateful widget with a 100ms `easeOut` curve.

### 1.5 Theme Config

```dart
// lib/core/theme/app_theme.dart
ThemeData appTheme() => ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.paper,
  colorScheme: ColorScheme.light(
    primary:    AppColors.tomato,
    secondary:  AppColors.marigold,
    tertiary:   AppColors.teal,
    surface:    AppColors.card,
    background: AppColors.paper,
    error:      AppColors.tomato,    // we reuse tomato for errors
    onPrimary:  Colors.white,
    onSurface:  AppColors.ink,
  ),
  splashFactory: NoSplash.splashFactory,    // we drive press via translation
  highlightColor: Colors.transparent,
  fontFamily: 'Nunito',
);
```

---

## 2. Reusable Widget Specs

### 2.1 `JpCard` — Base elevated card

```dart
class JpCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Color background;
  final Widget child;
  final List<BoxShadow> shadow;          // default AppShadows.lg
  final double radius;                   // default AppSpacing.rCard

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: background,                 // usually AppColors.card
      borderRadius: BorderRadius.circular(radius),
      border: AppBorders.ink(),          // 2.5px ink
      boxShadow: shadow,
    ),
    child: child,
  );
}
```

### 2.2 `JpButtonPrimary` — Tomato CTA with offset shadow

```dart
// width: typically double.infinity (full-bleed CTAs)
// height: 56
SizedBox(
  width: double.infinity, height: 56,
  child: GestureDetector(
    onTapDown: (_) => _setPressed(true),
    onTapUp:   (_) => _setPressed(false),
    onTapCancel: () => _setPressed(false),
    onTap: onPressed,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 100),
      transform: Matrix4.translationValues(
        _pressed ? 2 : 0, _pressed ? 2 : 0, 0),
      decoration: BoxDecoration(
        color: AppColors.tomato,
        borderRadius: AppBorders.button,
        border: AppBorders.ink(),
        boxShadow: _pressed ? AppShadows.sm : AppShadows.lg,
      ),
      child: Center(
        child: Text(label, style: TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 17,
          color: Colors.white,
        )),
      ),
    ),
  ),
)
```

### 2.3 `JpButtonGhost` — White outlined version

Same scaffold as PrimaryButton but `color: AppColors.card`, `Text color: AppColors.ink`, `fontWeight: w800`. Same offset shadow.

### 2.4 `XpBar` widget

```dart
// Visual: [tomato level badge] [marigold-outlined teal-fill pill]
Row(children: [
  // Level badge — tomato squircle with thick ink border
  Container(
    width: 34, height: 34,
    decoration: BoxDecoration(
      color: AppColors.tomato,
      borderRadius: BorderRadius.circular(11),
      border: AppBorders.ink(width: 2),
      boxShadow: AppShadows.sm,
    ),
    alignment: Alignment.center,
    child: Text('$level',
      style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900,
        fontSize: 15, color: Colors.white)),
  ),
  SizedBox(width: 10),
  // Pill
  Expanded(
    child: Container(
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(999),
        border: AppBorders.ink(width: 2),
      ),
      clipBehavior: Clip.hardEdge,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: xpPct,        // 0.0 to 1.0
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.teal,
              border: Border(
                right: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
])
```

> **Animate the fill** — wrap the FractionallySizedBox in an `AnimatedFractionallySizedBox` (1000ms `easeOut`) on Profile / Summary screens so the bar fills in dramatically when the screen mounts.

### 2.5 `CoinBadge` widget

```dart
// White pill, 2px ink border, sm offset shadow, $-on-marigold-disc + count
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(999),
    border: AppBorders.ink(width: 2),
    boxShadow: AppShadows.sm,
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        color: AppColors.marigold,
        shape: BoxShape.circle,
        border: AppBorders.ink(width: 2),
      ),
      alignment: Alignment.center,
      child: Text(r'$', style: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w900,
        fontSize: 11, color: AppColors.ink,
      )),
    ),
    SizedBox(width: 6),
    Text('$amount', style: TextStyle(
      fontFamily: 'Nunito', fontWeight: FontWeight.w900,
      fontSize: 14, color: AppColors.ink)),
  ]),
)
```

### 2.6 `StreakBadge` widget

```dart
// Marigold pill, ink border, sm offset shadow, 🔥 + count
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.marigold,
    borderRadius: BorderRadius.circular(999),
    border: AppBorders.ink(width: 2),
    boxShadow: AppShadows.sm,
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text('🔥', style: TextStyle(fontSize: 14)),
    SizedBox(width: 4),
    Text('$count', style: TextStyle(
      fontFamily: 'Nunito', fontWeight: FontWeight.w900,
      fontSize: 14, color: AppColors.ink)),
  ]),
)
```

### 2.7 `McqOptionTile` widget

The hero gameplay widget. States: **idle**, **correct**, **wrong**, **disabled**.

```dart
// Layout: tile is white card, ink border, md shadow. When state is correct/wrong,
// the BACKGROUND tints, the BORDER and SHADOW take the state color, and a small
// circular ✓ or ✗ icon (state-colored) appears on the LEADING edge.
// The text color stays ink (NOT colored to match state) — readability matters.

AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
  decoration: BoxDecoration(
    color: _bgColor(),
    borderRadius: AppBorders.tile,
    border: Border.all(color: _borderColor(), width: 2.5),
    boxShadow: _shadow(),
  ),
  child: Row(children: [
    if (state == McqState.correct || state == McqState.wrong)
      Container(
        margin: EdgeInsets.only(right: 12),
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: state == McqState.correct ? AppColors.teal : AppColors.tomato,
          shape: BoxShape.circle,
          border: AppBorders.ink(width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          state == McqState.correct ? '✓' : '✗',
          style: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w900,
            fontSize: 16, color: Colors.white),
        ),
      ),
    Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(text, style: AppTextStyles.urduBody.copyWith(
          fontWeight: state == McqState.idle ? FontWeight.w500 : FontWeight.w700,
        )),
      ),
    ),
  ]),
)

Color _bgColor() => switch (state) {
  McqState.correct  => AppColors.correctSurface,
  McqState.wrong    => AppColors.wrongSurface,
  McqState.disabled => AppColors.card,    // disabled stays white, opacity comes from wrapper
  _                 => AppColors.card,
};
Color _borderColor() => switch (state) {
  McqState.correct  => AppColors.teal,
  McqState.wrong    => AppColors.tomato,
  _                 => AppColors.ink,
};
List<BoxShadow> _shadow() => switch (state) {
  McqState.correct => AppShadows.correctMd,
  McqState.wrong   => AppShadows.wrongMd,
  _                => AppShadows.md,
};
```

**Wrong-answer shake:** wrap the tile in a `TweenAnimationBuilder` that shakes ±6dp on the X axis with a 400ms curve when state transitions to `wrong`.

**Disabled tile:** add `Opacity(opacity: 0.45)` wrapper on top.

### 2.8 `TimerBar` widget

```dart
// Rounded pill (height: 14), ink border, color shifts with time remaining.
class TimerBar extends StatelessWidget {
  final double value;     // 0.0 (empty) to 1.0 (full)

  Color get _color {
    if (value > 0.6) return AppColors.teal;
    if (value > 0.3) return AppColors.marigold;
    return AppColors.tomato;
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 14,
    decoration: BoxDecoration(
      color: AppColors.paperWarm,
      borderRadius: BorderRadius.circular(999),
      border: AppBorders.ink(width: 2),
    ),
    clipBehavior: Clip.hardEdge,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: _color,
            border: value > 0.05
              ? Border(right: BorderSide(color: AppColors.ink, width: 2))
              : null,
          ),
        ),
      ),
    ),
  );
}
```

**Danger pulse** — when `value < 0.3`, wrap the inner fill in an `AnimatedScale(scaleY: 1.4 ↔ 1.0)` pulsing on a 500ms loop.

### 2.9 `BottomNavBar` widget

```dart
// White pill, ink border, lg offset shadow. Active tab gets a marigold pill
// with ink border that grows in width (the active tab is flex:1.4, others 1.0).
// Active tab shows BOTH icon + label; inactive shows icon only.
Container(
  margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
  height: 60, padding: EdgeInsets.all(5),
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(999),
    border: AppBorders.ink(),
    boxShadow: AppShadows.lg,
  ),
  child: Row(children: [
    for (final tab in tabs)
      Expanded(
        flex: tab.active ? 14 : 10,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: tab.active ? AppColors.marigold : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: tab.active ? AppBorders.ink(width: 2) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              tab.iconWidget,                     // outline SVG, currentColor = ink
              if (tab.active) ...[
                SizedBox(width: 6),
                Text(tab.label, style: AppTextStyles.enLabel.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w900)),
              ],
            ],
          ),
        ),
      ),
  ]),
)
```

> **Icons must be outline SVGs** drawn in ink (`stroke: AppColors.ink, strokeWidth: 2`). No filled glyphs; the chunky outline matches every other element. Use Heroicons "outline" or hand-drawn equivalents.

### 2.10 `Sticker` widget

Used everywhere for small labels (category tags, "+5 streak!", reveal label, etc.). Slight rotation gives the surface its sticker-book personality — but **never rotate body content**, only ornaments.

```dart
class Sticker extends StatelessWidget {
  final String text;
  final Color color;            // background
  final Color textColor;        // default: ink — use white when bg is purple/tomato/teal
  final double rotateDeg;       // typically -8…8

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: rotateDeg * pi / 180,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: AppBorders.ink(width: 2),
        boxShadow: AppShadows.sm,
      ),
      child: Text(text, style: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w800,
        fontSize: 13, color: textColor)),
    ),
  );
}
```

### 2.11 `SunBlob` background ornament

A soft radial gradient circle, positioned off-screen on one corner of most screens, that gives the cream paper a warm "lit-from-above" feel without using a real photograph. Push behind everything else with `Stack`.

```dart
Positioned(
  top: -100, right: -120,
  child: IgnorePointer(
    child: Container(
      width: 320, height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.marigold.withOpacity(1.0),
            AppColors.marigold.withOpacity(0.33),
            Colors.transparent,
          ],
          stops: [0.0, 0.55, 0.78],
        ),
      ),
    ),
  ),
)
```

Use different accent colors per screen (marigold for home, tomato/teal for results, purple for meaning quiz) to subtly cue the screen's intent.

---

## 3. Screen-by-Screen Flutter Specs

### Screen 1 — Splash (`splash_screen.dart`)

**Background:** `AppColors.paper` + two `SunBlob`s (marigold top-right, tomato bottom-right).

**Layout:** `Column` centered.

**Logo mark (chunky squircle):**
- 140×140, `BorderRadius.circular(36)`, `color: AppColors.tomato`, 3dp ink border, **6dp offset shadow**, rotated -6°.
- Inside: Text 'J', Nunito w900, fontSize 92, color `AppColors.paper`, no margin, vertical centered (offset -8dp).
- Two stickers anchored to corners (positioned absolutely): top-right marigold "✦" rotated 12°, bottom-left teal "5" rotated -10°.

**App name (under mark):**
- `Text('جھٹ پٹ', AppTextStyles.urduDisplay)` (44sp)
- `Text('JHAT PAT', Nunito w900 13sp, color tomato, letterSpacing 4, uppercase)`

**Tagline:** `Text('اردو محاورے سیکھیں، مزہ کریں', urduHeadline.copyWith(color: inkSoft, fontSize: 18))`

**Loading dots:** three 10dp circles, tomato fill, 2dp ink border, sparkle-pulse animation staggered 0.2s apart.

**Animations / timing:**
- Mark: scale 0.3 → 1.0 + opacity 0 → 1, 600ms, `Curves.elasticOut`. Then loop `jp-float` (-6dp Y, 3s).
- Name + tagline: slide up 20dp + fade in, 600ms, delay 300ms.
- Loading dots: fade in at 1000ms.
- Screen exit: opacity 1 → 0, 500ms, **after 2200ms** total.

---

### Screen 2 — Onboarding (`onboarding_screen.dart`)

**Per-slide accent + background tint:**
| Slide | Accent | Bg tint |
|---|---|---|
| 1 — تصویر دیکھو | tomato | `#FFE0D5` |
| 2 — جواب چنو | teal | `#D5EFEA` |
| 3 — سیکھو اور آگے بڑھو | purple | `#E8DDF4` |

Each slide overlays a SunBlob in the current accent color (top-right, 300×300, 0.5 opacity).

**Layout:**
```
Column
 ├ Row(end) → "Skip" text button (underlined, ink color, w800)
 ├ Expanded → Column(center, padding 0×28)
 │   ├ FloatingIcon (140×140 squircle, accent bg, 3dp ink border, 6dp offset shadow, rotate -4°, fontSize 64 icon inside, jp-float loop)
 │   ├ SizedBox(30)
 │   ├ Text(title,    urduTitle 32sp w700 center)
 │   ├ Text(subtitle, urduHeadline 19sp inkOpacity 85% center)
 │   └ Text(detail,   urduBody 16sp inkSoft center)
 └ Padding(0×24, 0 0 40 0)
     ├ DotsIndicator (active: 28×12 ink-filled, inactive: 12×12 ink-outlined)
     └ JpButtonPrimary ('اگلا' / 'شروع کریں')
```

**Slide transitions:** PageView with custom builder; new slide content uses `jp-slide-up` (24dp Y + fade, 400ms).

---

### Screen 3 — Sign In (`sign_in_screen.dart`)

**Background:** paper + marigold SunBlob top-right.

```
SingleChildScrollView
 ├ Header (padding 54 top, center)
 │   ├ Text('خوش آمدید', urduDisplay 38sp)
 │   └ Text(subtitle, urduHeadline 17sp inkSoft)
 └ Padding(0 24, gap 22)
     ├ Section: Language selector (Row of 2 toggle pills, full-width, h:50)
     │   Selected: marigold bg, ink border, sm offset shadow
     │   Unselected: white bg, ink border, no shadow
     ├ Section: Avatar picker (Row of 6 squircles 50×50)
     │   Selected: tomato bg, ink border, sm offset shadow, scale 1.08 + rotate -6°
     │   Unselected: white bg, ink border
     ├ Section: Name input (full-width TextField)
     │   Padding 16×18, white bg, 2.5dp ink border, md offset shadow,
     │   radius 16, font: NotoNastaliqUrdu 18 w500, rtl, right-align,
     │   placeholder 'اپنا نام لکھیں' at inkMuted
     └ Column of CTAs
         ├ JpButtonPrimary ('آگے بڑھیں') — disabled (opacity 0.4) when name empty
         └ JpButtonGhost   ('مہمان کے طور پر کھیلو')
```

**No Google sign-in button in v2.0** (the dark-theme version had one; remove from this layout — if needed, add later as a 3rd ghost button styled with a Google logo SVG).

---

### Screen 4 — Home (`home_screen.dart`)

**Background:** paper + marigold SunBlob top-right.

```
Column (paddingBottom: 96 for bottom nav clearance)
 ├ TopBar (16 20 0)
 │   ├ Left:
 │   │   Text('سلام · Wednesday', enCaption 13 w700 inkSoft)
 │   │   Text('Hey, $name!', enTitle 26 w900 ink — '!' colored tomato)
 │   └ Right:
 │       Row(gap 8): CoinBadge + SettingsButton (38×38 white squircle w/ gear icon)
 ├ ProfileCard (margin 16 20 0)
 │   JpCard(padding 18)
 │   ├ Row(gap 14)
 │   │   ├ Avatar (60×60 tomato squircle r18, 2.5dp ink border, md offset shadow, rotate -4°, fontSize 30 emoji)
 │   │   ├ Column (flex: 1)
 │   │   │   Text('LEVEL $level', enLabel 12 w800 inkSoft uppercase tracking 1)
 │   │   │   Text(name, 20 w900 ink)
 │   │   │   Text(levelTitle, urduCaption 14 inkSoft)
 │   │   └ StreakBadge (only if streak > 0)
 │   └ XpBar + Row of caption text below ('XP$xp / $xpNext', 'X to Level Y')
 ├ DailyGoalCard (margin 14 20 0)
 │   Container(teal bg, white text, 2.5dp ink border, lg offset shadow, radius 18, padding 14×16)
 │   Row: 🎯 (32sp) + Column(label + sub) + Pill('2/5', white bg, ink border)
 ├ Section eyebrow: 'Pick a mode' (16 20 8, 13 w900 ink opacity 0.6 uppercase tracking 1)
 └ Grid(2×2, gap 12, padding 0×20)
     For each mode:
       Container(card bg or paperWarm if locked,
                 2.5dp ink border, lg offset shadow (md if locked))
       Padding 14
       ├ IconBox (44×44 squircle r14, mode color bg, 2px ink border, 22sp icon)
       ├ Text(urdu label, 17 w700 ink)
       └ Text(en hint, 12 w700 inkSoft)
       Press: translate +2/+2, shadow → md
       Locked: opacity 0.7, icon bg inkMuted, lock-icon overlay
```

**Mode card entrance stagger:** each card `jp-slide-up` 350ms, delay `i * 70ms`.

---

### Screen 5 — Photo Card (`photo_card_screen.dart`)

**The most important screen. Nail every detail.**

```
Column
 ├ Header (14 20 10)
 │   ├ Card pill ('Card 1/5') — white bg, 2dp ink border, radius 999, '1' in tomato, '/5' inkSoft
 │   └ Row(gap 8): StreakBadge (if ≥3) + CoinBadge
 ├ Timer (0 20 12)
 │   ├ TimerBar
 │   └ Row(end): '${seconds}s' (12 w900, color shifts tomato when < 5s)
 ├ CardImage (0 20 14)
 │   Container(radius 22, 2.5dp ink border, 5dp offset shadow)
 │   ├ ImagePlaceholder (height 200) — or CachedNetworkImage
 │   └ Positioned(top 10 right 10) → Sticker(category, marigold, rotate 6°)
 ├ Prompt (0 20 12): Text('اس تصویر کا کیا مطلب ہے؟', urduHeadline 17 w600)
 ├ Expanded → Column(gap 10, padding 0×20) of 4 McqOptionTiles
 │   Each tile entrance: jp-slide-up 350ms, stagger i*70ms
 └ HintRow (12 20 22, Row gap 10)
     ├ Button('➖ Eliminate · 10🪙') — white bg, 2dp ink border, sm offset shadow
     └ Button('❄️ Freeze · 15🪙')   — same styling, alt content
```

**Timer logic:** `AnimationController(duration: Duration(seconds: 15))`. Reverse from 1.0 → 0.0. On tick: `setState`. On hit zero (`controller.value <= 0`) → call `_onTimeout(null)`.

**On answer tap (correct):**
1. Stop timer.
2. Tile state → `correct` (background tints, border + shadow → teal, ✓ icon slides in).
3. Wait 900ms → push ResultFlash.

**On answer tap (wrong):**
1. Tapped tile → `wrong` (background tints, shake animation 400ms), correct tile → `correct` simultaneously.
2. Wait 900ms → push ResultFlash.

**Hint: Eliminate** (cost 10 coins) — remove 2 random wrong options: set their state to `disabled` (opacity 0.45, pointerEvents none). Bookkeeping: store the eliminated option indices in screen state.

**Hint: Freeze** (cost 15 coins) — stop the `AnimationController` for 5 seconds, then resume `reverse()` from current value. Show '❄️ Frozen' label in the seconds slot during the freeze period. Disable the Freeze button after one use.

---

### Screen 6 — Result Flash (`result_flash_screen.dart`)

**Auto-advance after 1600ms.** No user input needed (but tap anywhere can advance early).

**Background:**
- Correct: surface `#D5EFEA` + teal SunBlob top + marigold SunBlob bottom
- Wrong: surface `#FBE0DC` + tomato SunBlob top + purple SunBlob bottom

**Layout:** Column centered.
```
ResultIcon (130×130 squircle r36, state color bg, 3.5dp ink border, 8dp offset shadow, rotate -6°)
  Text(state == correct ? '✓' : '✗', Nunito w900 76sp white)

Text(state == correct ? 'شاباش!' : 'غلط جواب',
     urduDisplay 38sp ink w700)

If correct && points > 0:
  Text('+$points', Nunito w900 38sp tomato
       textShadow: 3px 3px 0 marigold)

If correct && streak >= 3:
  Sticker('🔥 $streak streak!', marigold, rotate -4°)

Footer:
  Text('جاری ہے...', urduCaption 14 inkSoft, position absolute bottom 50)
```

**Animations:**
- Icon: scale 0 → 1.2 → 0.95 → 1.0, `Curves.elasticOut`, 500ms.
- Label: slide up + fade, delay 200ms.
- Points: scale 0 → 1.25 → 1.0 + translate Y +20 → 0, delay 300ms.
- Streak sticker: slide up, delay 500ms.

**Confetti (correct only):** use the `confetti` package. Palette: `[tomato, marigold, teal, purple, sky]`. 22 particles, 1.4–2.6s duration, each particle has a 1.5dp ink border (renders even for tiny pieces).

---

### Screen 7 — Reveal Card (`reveal_card_screen.dart`)

```
Column
 ├ Header: Card pill + Sticker('انکشاف ✦', marigold, rotate 4°)
 ├ Image (0 20 16): 170dp tall, 2.5dp ink border, lg offset shadow
 ├ PhraseRevealCard (0 20 14) — JpCard
 │   Padding 22 20, textAlign right
 │   ├ Text(urdu, urduTitle 30 w700)
 │   ├ Text(roman, enBody 15 w700 inkSoft, mt 4)
 │   ├ Divider (2dp ink @ 10% opacity, my 14)
 │   └ Text('معنی: $meaning', urduHeadline 19 tomato w600)
 ├ Example button (0 20 14)
 │   Outline (white bg, 2.5dp ink border, md offset shadow, radius 16, padding 14)
 │   Row(center, gap 10): '👁' (18sp) + Text('مثال دیکھیں', urduHeadline 16 w800)
 └ Spacer → JpButtonPrimary('معنی کوئز ←') with urduHeadline 18 (margin 0 20 28)
```

**Sequential entrance:** image at 0ms, phrase card at 100ms, example button at 200ms, CTA at 300ms.

**Example sheet (modal bottom sheet):**
- Sheet bg: card white, top-radius 24, 2.5dp ink border, no bottom border
- Padding 24 24 40
- Header row: ✕ close button (36×36 paper squircle r10 with sm offset shadow) on left, Sticker('مثال', tomato, white text, rotate 4°) on right
- Body: Text(example, urduHeadline 22 ink w600 rtl) + Text(roman, enBody 14 w700 inkSoft)

---

### Screen 7b — Meaning Quiz (second stage)

Identical mechanics to **Photo Card** but with these deltas:
- Timer = **8 seconds** total (vs 15)
- No card image — show **phrase card** at top instead
- Prompt: `'اس فقرے کا صحیح مفہوم کیا ہے؟'`
- Stage label: Sticker(`'مرحلہ ۲/۲'`, **purple**, white text, rotate 4°)
- No hint buttons
- SunBlob accent: **purple**
- Points: 200 / 150 / 100 / 50 (time-based)

**Phrase card** (replaces image):
```
JpCard(padding 22 20)
 ├ Text(phrase.urdu,  urduTitle 28 w700, textAlign center)
 └ Text(phrase.roman, enBody 14 w700 inkSoft, textAlign center, mt 4)
```

---

### Screen 8 — Session Summary (`session_summary_screen.dart`)

```
SingleChildScrollView
 ├ Hero (40 24 16, center, marigold SunBlob bg)
 │   🏆 (60sp, rotate -8°)
 │   Text('سیشن مکمل!', urduTitle 30 w700)
 │   Text(totalScore.toString(), Nunito w900 64sp tomato
 │        textShadow: '4px 4px 0 marigold, 5px 5px 0 ink')
 │   Text('Total Points', enLabel uppercase tracking 1)
 ├ StatsRow (0 20 18, Row gap 10) — 3 cards
 │   Each: card bg, 2.5dp ink border, md offset shadow, radius 18, padding 14×8 center
 │     icon (22sp), value (18 w900 colored), label (11 w800 inkSoft uppercase)
 │   Cards: Correct (teal), XP (marigold), Accuracy (purple)
 ├ Section eyebrow: 'Card Breakdown' (0 20 10, enLabel w900 opacity 0.6 uppercase)
 ├ For each result:
 │   Container (card bg, 2dp ink border, sm offset shadow, radius 16, padding 12×16)
 │   Row(between):
 │     Text(urdu, urduHeadline 17 w600 ink rtl, flex 1)
 │     Row(gap 8): icon (24dp circle, teal/tomato fill, ink border, ✓/✗ white) +
 │                 Text('+$pts', Nunito w900 14 tomato) (only if pts > 0)
 │   Stagger entrance: jp-slide-up 300ms, delay i*60ms
 └ Footer (14 20 36, Column gap 12)
     ├ JpButtonPrimary ('دوبارہ کھیلو')
     └ JpButtonGhost   ('گھر جاؤ')
```

**Animated score count-up:**
```dart
TweenAnimationBuilder<int>(
  tween: IntTween(begin: 0, end: totalScore),
  duration: Duration(milliseconds: 1200),
  curve: Curves.easeOut,
  builder: (_, value, __) => Text('${NumberFormat('#,###').format(value)}',
    style: heroStyle),
)
```

**Stats cards entrance:** all three at once, 400ms, `jp-slide-up` (24dp Y + fade).

**Confetti** (only if `correct >= results.length / 2`) — fire at screen mount.

---

### Screen 9 — Phrase Library (`phrase_library_screen.dart`)

```
Column (paddingBottom 96)
 ├ Header (16 20 12)
 │   ├ Text('Library', enTitle 26 w900)
 │   ├ Text('کتب خانہ — سارے محاورے', urduCaption 16 inkSoft mt 4 w500)
 │   ├ SearchField (12 mt, position: relative)
 │   │     TextField with: white bg, 2.5dp ink border, md offset shadow,
 │   │       padding 13×16 with 42dp left for icon, radius 16,
 │   │       font NotoNastaliqUrdu 16 ink, rtl, placeholder 'محاورہ تلاش کریں...'
 │   │     '🔍' positioned left 14, top 50% center vertically
 │   ├ Filters (Row wrap gap 8, mb 4) — two groups:
 │   │     Category: ['سب', 'محاورہ', 'کہاوت'] → selected = tomato fill white text
 │   │     Difficulty: ['سب', 'آسان', 'درمیانہ', 'مشکل'] → selected = purple fill white text
 │   │     All chips: 7×14 padding, radius 999, 2dp ink border, white bg, NotoNastaliqUrdu 14 w700,
 │   │       selected adds sm offset shadow
 │   └ Text('$count phrases', enCaption 13 w800 inkSoft mt 10)
 └ Expanded → GridView.builder(2 columns, gap 12, padding 0×20)
     LibraryCard:
       Container(card bg, 2.5dp ink border, md offset shadow, radius 18, overflow hidden)
       ├ Image (height 110, cover fit)
       └ Padding(10 12 14)
           ├ Text(urdu, urduHeadline 17 w600 ink rtl)
           └ Row(gap 6, mt 8):
               Chip(category, marigold bg, ink border 1.5dp, fontSize 11 w700, padding 3×8 radius 999)
               Chip(difficulty, paperWarm bg, ink border 1.5dp, fontSize 11 w700)
     Stagger: jp-slide-up 300ms, delay i*50ms.
```

---

### Screen 10 — Profile (`profile_screen.dart`)

```
SingleChildScrollView (paddingBottom 96)
 ├ Hero (24 20 16, center, marigold SunBlob bg)
 │   Avatar (90×90 tomato squircle r28, 3dp ink border, 5dp offset shadow, rotate -5°, jp-float 3s,
 │           fontSize 44 emoji)
 │   Text(name, 24 w900 ink)
 │   Text(levelTitle, urduHeadline 16 tomato w600, mb 16)
 │   XpBar
 │   Text('$xp / $xpNext XP to Level ${level+1}', enCaption 12 w800 inkSoft mt 8)
 ├ Stats grid (12 20 0, GridView 2×2 gap 10)
 │   Each card: card bg, 2.5dp ink border, md offset shadow, radius 16, padding 14×16
 │   Row(gap 12): IconBox(38×38 r12, color bg, 2dp ink border, 18sp icon) +
 │                Column(value 22 w900 ink + label 11 w800 inkSoft uppercase tracking 0.5)
 │   Cards: Streak (tomato), Best (marigold), Coins (marigold), Correct% (teal)
 └ Recent sessions (20 20 0)
     Eyebrow 'Recent Sessions' (enLabel w900 opacity 0.6 uppercase tracking 1 mb 12)
     For each session: card bg, 2dp ink border, sm offset shadow, radius 14, padding 12×14
       Row(between):
         Column(mode 15 w900 + date 12 w700 inkSoft)
         Column(end): Text('+$pts', 16 w900 tomato) + Text('$correct/$cards correct', 11 w700 inkSoft)
     Stagger: jp-slide-up 300ms, delay i*80ms.
```

---

### Screen 11 — Settings (`settings_screen.dart`)

```
Column
 ├ Header (16 20)
 │   Row(gap 12): BackButton (38×38 white squircle r12, 2dp ink border, sm offset shadow, '←' 18 w900 ink)
 │              + Text('Settings', enTitle 22 w900)
 ├ Section('Language')
 │   Padding 12: Row(gap 10) of two large toggle pills (12 padding, 14 radius, 2dp ink border,
 │     selected: marigold bg + sm offset shadow, unselected: paperWarm bg)
 ├ Section('Gameplay')
 │   Rows:
 │     Sound Effects (Toggle)
 │     Haptic Feedback (Toggle)
 │     Daily Reminders (Toggle)
 ├ Section('Account')
 │   Rows:
 │     Change Name (sublabel: $name) → '›' tomato 22 w900 chevron
 │     Change Avatar (sublabel: $emoji) → '›' chevron
 ├ Section('About')
 │   Rows:
 │     App Version → Text('1.0.0+1', enCaption 13 w800 inkSoft)
 │     Clear Cache → '›' chevron
 └ SignOutButton (8 20 36)
     Outline: white bg, 2.5dp tomato border, md tomato offset shadow, radius 16, padding 14,
     Text('Sign Out', Nunito 15 w900 tomato, center)
```

**Section wrapper:**
```dart
Padding(
  padding: EdgeInsets.only(bottom: 18),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(title, style: AppTextStyles.enLabel.copyWith(
        fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
    ),
    Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: AppBorders.ink(),
        boxShadow: AppShadows.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),     // rows separated by Divider(2dp ink @ 7% opacity)
    ),
  ]),
)
```

**Custom Toggle switch** — replaces Flutter's default Switch (which doesn't suit the chunky aesthetic):
```dart
GestureDetector(
  onTap: () => setState(() => value = !value),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
    width: 52, height: 30,
    decoration: BoxDecoration(
      color: value ? AppColors.teal : AppColors.paperWarm,
      borderRadius: BorderRadius.circular(999),
      border: AppBorders.ink(width: 2.5),
      boxShadow: AppShadows.sm,
    ),
    child: AnimatedAlign(
      duration: Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(2),
        width: 22, height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: AppBorders.ink(width: 2),
        ),
      ),
    ),
  ),
)
```

---

## 4. Game State Machine

Same as v1.0 — see implementation in `game_provider.dart`.

```dart
enum GamePhase { idle, loadingPhrases, showingPhoto, resultFlash, showingReveal, showingMeaningQuiz, sessionComplete }

class GameState {
  final GamePhase phase;
  final List<Phrase> phrases;
  final int cardIndex;
  final int streak;
  final int coins;
  final bool photoCorrect;
  final int photoPoints;
  final List<CardResult> results;
  final bool eliminated;
}
```

Navigation flow unchanged from v1.0:
```
idle → startSession() → loadingPhrases → showingPhoto
showingPhoto → onAnswer() → resultFlash (auto 1600ms) → showingReveal
showingReveal → onStartMeaning() → showingMeaningQuiz
showingMeaningQuiz → onAnswer()
  → cardIndex < total: showingPhoto (next card)
  → cardIndex == total: sessionComplete
sessionComplete → onDismiss() → idle
```

---

## 5. Navigation (GoRouter)

Routes unchanged from v1.0. Update page transitions to **fade + slide-up 16dp** for a softer, less aggressive feel than the v1.0 horizontal slide:

```dart
CustomTransitionPage(
  transitionsBuilder: (_, animation, __, child) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(begin: Offset(0, 0.04), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(animation),
      child: child,
    ),
  ),
)
```

For Result Flash specifically, use a pure **fade** (no slide) — the screen needs to feel like a flash.

---

## 6. Animation Timings Reference

| Animation | Duration | Curve | Notes |
|---|---|---|---|
| Screen transition | 350ms | `easeOut` | Fade + 16dp slide-up |
| Result flash icon | 500ms | `elasticOut` | Scale 0 → 1.2 → 0.95 → 1.0 |
| Score count-up | 1200ms | `easeOut` | Tween int 0 → total |
| MCQ correct/wrong | 200ms | `easeOut` | Color + shadow transition |
| MCQ wrong shake | 400ms | `easeOut` | Translate X ±6dp |
| MCQ entrance stagger | 70ms per tile | `easeOut` | jp-slide-up |
| XP bar fill | 1000ms | `easeOut` | On Profile / Summary mount |
| Toggle switch knob | 300ms | `elasticOut` | + 300ms color crossfade |
| Press feedback | 100ms | `easeOut` | Translate +2/+2, shadow → sm |
| Mascot / avatar float | 3000ms | `easeInOut` | Y 0 ↔ -6dp loop |
| Bottom sheet | 300ms | `easeOutCubic` | Default Flutter |
| Confetti | mount-on | — | `confetti` package, 22 particles |
| Timer danger pulse | 500ms | `easeInOut` | ScaleY 1 ↔ 1.4 when value < 0.3 |
| Sticker rotation idle | 0ms (static) | — | Don't animate rotations; they're static personality |

---

## 7. pubspec.yaml additions

```yaml
dependencies:
  google_fonts: ^6.x.x       # Nunito + Noto Nastaliq Urdu
  cached_network_image: ^3.x.x
  confetti: ^0.7.x
  flutter_animate: ^4.x.x    # Score count-up, entrance helpers
  intl: ^0.19.x              # NumberFormat for score thousands separator

flutter:
  fonts:
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
        - asset: assets/fonts/Nunito-ExtraBold.ttf
          weight: 800
        - asset: assets/fonts/Nunito-Black.ttf
          weight: 900
    - family: NotoNastaliqUrdu
      fonts:
        - asset: assets/fonts/NotoNastaliqUrdu-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoNastaliqUrdu-Medium.ttf
          weight: 500
        - asset: assets/fonts/NotoNastaliqUrdu-Bold.ttf
          weight: 700
```

(Or use `google_fonts` and skip the asset bundling — both families are on Google Fonts.)

---

## 8. Gotchas & Flutter-Specific Notes

| Issue | Solution |
|---|---|
| **Urdu text RTL** | Wrap Urdu `Text` widgets in `Directionality(textDirection: TextDirection.rtl)` or set `textDirection: TextDirection.rtl` directly on the Text. |
| **Nastaliq line height** | Always set `height: 1.6` minimum on Nastaliq text — the script has tall ascenders/descenders. For body text go to 1.8. |
| **Offset shadows + clip** | A `Container` with `boxShadow` AND `clipBehavior: Clip.antiAlias` will clip its own shadow. Either don't clip, or wrap the shadow Container outside a separate clipping Container. |
| **Press animation** | Don't use `InkWell` ripple — it fights the chunky outline aesthetic. Use a `GestureDetector` + `AnimatedContainer` translation as shown in §2.2. Set `splashFactory: NoSplash.splashFactory` at the theme level. |
| **Sticker rotation** | Use `Transform.rotate(angle: deg * pi / 180)`. Don't pre-rotate via SVG (loses crispness on layout). |
| **Outline SVG icons** | Make sure `stroke-width` is set to 2 in viewport units, `stroke-linejoin: round`, `fill: none` (or fill the same as bg for active states). Render via `flutter_svg`. |
| **Timer cancellation** | Always cancel `AnimationController` in `dispose()`. |
| **MCQ shuffle** | Shuffle once in `initState`, store result. Never re-shuffle on rebuild. |
| **Bottom nav + keyboard** | `resizeToAvoidBottomInset: false` on Scaffold for Sign In, otherwise the input jumps when the keyboard appears. |
| **Image loading** | Use `CachedNetworkImage` with a placeholder that matches the cream-stripe ImgPlaceholder (warm tones, NOT a dark shimmer). |
| **Coin deduction** | Deduct coins optimistically in UI, then sync to backend. |
| **Back button on game** | `PopScope(canPop: false)` on the game screens — game session shouldn't be dismissible by accident. Show a "Quit game?" confirmation if back is pressed. |
| **Score number commas** | Use `NumberFormat('#,###').format(score)` from the `intl` package. The Hero score on Session Summary needs commas; small `+pts` values do not. |
| **`!` after greeting** | The Home greeting `Hey, $name!` colors only the `!` in tomato. Use `Text.rich` with a TextSpan for the `!`. |
| **SunBlob bleed** | SunBlobs are positioned with negative top/right and rely on the parent Stack to clip. Use `ClipRRect` at the screen level if the device safe area doesn't clip naturally. |

---

## 9. What changed from v1.0 — checklist for migration

1. **Replace ALL color references** in `app_colors.dart`. There are no dark-theme analogues in v2.0 — this is a light theme. Search the codebase for any hardcoded `#FF6B35`, `#1A1A2E`, `#16213E`, `#0F3460` and route them through `AppColors`.
2. **Replace `Poppins` → `Nunito`** in `app_text_styles.dart`. Increase weights by one step (w600 → w700, w700 → w800, etc.) to match the chunky aesthetic.
3. **Add `border` and `boxShadow` to every elevated surface.** v1.0 relied on glow + dark bg; v2.0 relies on outline + offset shadow. Cards without an ink outline will look flat and wrong.
4. **Replace `BoxShadow` blur-radius shadows with hard offset shadows.** Search for `blurRadius: 20` (or any blurRadius > 0) — most should become `Offset(N, N), blurRadius: 0`.
5. **Replace `LinearGradient` decorations with flat colors** (except for the `SunBlob` ornament). v1.0 had `linear-gradient(135deg, #FF6B35, #FF4500)` on the primary button — v2.0 uses flat tomato.
6. **Replace `BottomNavigationBar` with custom widget** — see §2.9. The floating pill nav needs full control over the active-tab pill animation.
7. **Replace `Switch` with custom Toggle** — see Settings §11.
8. **Add `Sticker` widget to your widget kit** — it's used in 6 of the 11 screens.
9. **Re-test all icon SVGs** to confirm they render as outline strokes (not filled glyphs).
10. **Confetti palette swap** — old: `[orange, gold, green, pink, purple]`; new: `[tomato, marigold, teal, purple, sky]` with a 1.5dp ink border on each particle.

---

## 10. File map (this handoff)

```
handoff/
├── DESIGN_HANDOFF.md           ← this file
├── Jhat Pat.html               ← runnable prototype (open in browser)
├── jhatpat-components.jsx      ← reference: tokens + primitives (BottomNav, MCQ, XpBar, etc.)
├── jhatpat-screens.jsx         ← reference: all 11 screens
└── tweaks-panel.jsx            ← in-prototype tweak controls (Brand colors, Urdu size, etc.)
```

The JSX is **reference only** — translate it to Flutter widgets using the specs above. The HTML prototype is the source of truth for visual decisions; when something in this doc conflicts with the prototype, the prototype wins.

---

*Handoff generated May 2026 · v2.0 "Sunny Quiz" · For جھٹ پٹ Flutter app*
