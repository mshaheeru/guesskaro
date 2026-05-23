import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/leaderboard_metric.dart';
import '../../core/constants/scoring_constants.dart';
import '../../core/constants/urdu_utils.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../../providers/locale_provider.dart';

/// UI chrome only (menus, settings). Game phrase content may stay Urdu for learning.
class UiStrings {
  UiStrings._(this.lang);
  final AppLang lang;

  bool get isEnglish => lang == AppLang.en;

  static UiStrings watch(WidgetRef ref) {
    return UiStrings._(ref.watch(appLangNotifierProvider));
  }

  static UiStrings ofLang(AppLang lang) => UiStrings._(lang);
  String tr({required String en, required String ur}) => isEnglish ? en : ur;

  // Splash (brand spelling stays recognizable in Latin script)
  String get splashTitle => isEnglish ? 'GuessKaro' : 'گیس کرو';
  String get splashSubtitle =>
      isEnglish ? 'Learn the language — have fun' : 'زبان سیکھو، مزہ کرو';

  // Onboarding slides
  String get onboardingSlide1Title =>
      isEnglish ? 'See the scene' : 'تصویر دیکھو';
  String get onboardingSlide1Body =>
      isEnglish
          ? 'First look at the image and grasp the hint.'
          : 'پہلے تصویر دیکھیں اور اشارہ سمجھیں۔';

  String get onboardingSlide2Title =>
      isEnglish ? 'Pick the meaning' : 'جواب چنو';
  String get onboardingSlide2Body =>
      isEnglish
          ? 'Choose the correct option out of four.'
          : 'چار آپشن میں سے صحیح جواب منتخب کریں۔';

  String get onboardingSlide3Title =>
      isEnglish ? 'Learn and level up' : 'سیکھو اور آگے بڑھو';
  String get onboardingSlide3Body =>
      isEnglish
          ? 'Play daily to grow XP, coins, and your streak.'
          : 'روزانہ کھیل کر XP، سکے اور سٹریک بڑھائیں۔';

  String get skip => isEnglish ? 'Skip' : 'اسکپ';
  String get nextBtn => isEnglish ? 'Next' : 'اگلا';
  String get startBtn => isEnglish ? 'Start' : 'شروع کریں';

  // Welcome / name
  String get welcomeTitle => isEnglish ? 'Welcome' : 'خوش آمدید';
  String get nameHint => isEnglish ? 'Your name' : 'اپنا نام';
  String get continuePlaying => isEnglish ? 'Continue' : 'آگے بڑھیں';
  String get welcomeSubtitle =>
      isEnglish
          ? 'Enter your name and start playing.'
          : 'اپنا نام درج کریں اور کھیلنا شروع کریں';
  String get chooseAvatar =>
      isEnglish ? 'Choose your avatar' : 'اپنا اوتار چنیں';
  String get guestPlay => isEnglish ? 'Play as guest' : 'مہمان کے طور پر کھیلو';
  String get googleSignIn =>
      isEnglish ? 'Sign in with Google' : 'Google سے سائن ان';
  String get yourNameLabel => isEnglish ? 'Your name' : 'اپنا نام';
  String get nameRequired =>
      isEnglish ? 'Please enter your name.' : 'براہِ کرم نام درج کریں۔';
  String get uiLanguage => isEnglish ? 'App language' : 'ایپ کی زبان';
  String get answerMode => isEnglish ? 'Answer mode' : 'جواب دینے کا طریقہ';
  String get preferPicking => isEnglish ? 'Prefer picking' : 'انتخاب سے جواب';
  String get preferSpeaking => isEnglish ? 'Prefer speaking' : 'بول کر جواب';

  // Auth (email + account)
  String get authSignInTitle => isEnglish ? 'Sign in' : 'سائن اِن';
  String get authSignUpTitle => isEnglish ? 'Create account' : 'نیا اکاؤنٹ';
  String get authSubtitle =>
      isEnglish
          ? 'Save progress and appear on the leaderboard.'
          : 'ترقی محفوظ کریں اور لیڈر بورڈ پر نظر آئیں۔';
  String get authEmailLabel => isEnglish ? 'Email' : 'ای میل';
  String get authPasswordLabel => isEnglish ? 'Password' : 'پاس ورڈ';
  String get authCreateAccountCta => isEnglish ? 'Sign up' : 'رجسٹر کریں';
  String get authSignInCta => isEnglish ? 'Sign in' : 'داخل ہوں';
  String get authAlreadyHaveAccount =>
      isEnglish
          ? 'Already have an account? Sign in'
          : 'پہلے اکاؤنٹ ہے؟ سائن اِن';
  String get authNeedAccount =>
      isEnglish ? 'Need an account? Sign up' : 'نیا اکاؤنٹ بنائیں';
  String get authContinueAsGuest =>
      isEnglish ? 'Play as guest' : 'مہمان کے طور پر کھیلو';
  String get authGuestLeaderboardNote =>
      isEnglish
          ? 'Guests are not shown on the leaderboard. Sign up to compete globally.'
          : 'مہمان کو لیڈر بورڈ پر نہیں دکھایا جاتا۔ عالمی مقابلے کے لیے سائن اپ کریں۔';
  String get authPasswordTooShort =>
      isEnglish ? 'Use at least 6 characters.' : 'کم از کم ۶ حروف۔';
  String get authInvalidEmail =>
      isEnglish ? 'Enter a valid email.' : 'درست ای میل لکھیں۔';
  String get authCheckEmailConfirm =>
      isEnglish
          ? 'This project requires email confirmation. Ask admin to disable it'
              ' under Supabase Dashboard → Authentication → Providers → Email'
              ' (turn off Confirm email); then tap Sign in.'
          : 'منتظم سے کہیں کہ Supabase ڈیش بورڈ میں ای میل تصدیق بند ہو؛'
              ' پھر \'سائن اِن\' کریں۔';
  String get authSignInFailed =>
      isEnglish
          ? 'Could not sign in. Check email and password.'
          : 'سائن اِن نہیں ہوا۔ ای میل اور پاس ورڈ چیک کریں۔';
  String get authSignUpFailed =>
      isEnglish
          ? 'Could not create account. Try another email.'
          : 'اکاؤنٹ نہیں بنا۔ کوئی دوسری ای میل آزمائیں۔';
  String get authSignedInIncomplete =>
      isEnglish
          ? 'Sign-in did not complete. Try again.'
          : 'سائن اِن مکمل نہیں ہوا۔ دوبارہ کوشش کریں۔';
  String get authSignUpSuccessNavigating =>
      isEnglish
          ? 'Account ready. Heading to GuessKaro home…'
          : 'اکاؤنٹ تیار۔ ہوم페이지 کھول رہے ہیں…';
  String get authSignUpSessionFailed =>
      isEnglish
          ? 'Could not sign you in on this device. Try Sign in.'
          : 'اس ڈیوائس پر سائن ان مکمل نہیں ہوا۔ سائن اِن آزمائیں۔';

  // Home
  String get playerFallback => isEnglish ? 'Player' : 'کھلاڑی';
  String get homeTitle => isEnglish ? 'GuessKaro' : 'گیس کرو';
  String get quickPlay => isEnglish ? 'Quick play' : 'فوری کھیل';

  String get homeModesSection =>
      isEnglish ? 'Pick a mode' : 'موڈ منتخب کریں';
  String get speedRound => isEnglish ? 'Speed round' : 'تیز راؤنڈ';
  String get categoryMode => isEnglish ? 'Category' : 'زمرہ';
  String speedLockedLabel(int levelNeeded) =>
      isEnglish
          ? 'Unlocks at level $levelNeeded'
          : 'لیول ${toUrduNumerals(levelNeeded)} پر کھلے گا';

  String get modeCardLockedFallback => isEnglish ? 'Locked' : 'بند';

  String get streakLabelPrefix => isEnglish ? '🔥 Streak:' : '🔥 سٹریک:';
  String get dailyGoalInline => isEnglish ? 'Today\'s goal:' : 'آج کا ہدف:';
  String get leaderboardTileSubtitle =>
      isEnglish ? 'Top 10 by XP' : '١٠ بڑے XP کھلاڑی';

  String get leaderboardHomeTile =>
      isEnglish ? 'Leaderboard' : 'لیڈر بورڈ';

  /// Leaderboard screen app bar / title (same word as tile).
  String get leaderboardScreenTitle => leaderboardHomeTile;

  String get leaderboardTabSessionStreak =>
      isEnglish ? 'Streak' : 'سٹرِیک';

  String get leaderboardTabDailyStreak =>
      isEnglish ? 'Daily streak' : 'روزانہ سٹرِیک';

  String get leaderboardTabTotalScore =>
      isEnglish ? 'Total score' : 'کل اسکور';

  String get leaderboardEmpty =>
      isEnglish ? 'No leaderboard data yet.' : 'ابھی لیڈر بورڈ خالی ہے۔';

  String leaderboardYourRank(int rank) =>
      isEnglish ? 'Your rank: #$rank' : 'آپ کی رینک: ${toUrduNumerals(rank)}';

  String leaderboardScoreLine(
    LeaderboardEntryModel entry,
    LeaderboardMetric metric,
  ) {
    final int score = entry.scoreFor(metric);
    switch (metric) {
      case LeaderboardMetric.sessionStreak:
        return isEnglish ? '🔥 $score' : '🔥 ${toUrduNumerals(score)}';
      case LeaderboardMetric.dailyStreak:
        return isEnglish ? '📅 $score' : '📅 ${toUrduNumerals(score)}';
      case LeaderboardMetric.totalScore:
        return isEnglish ? '⭐ $score' : '⭐ ${toUrduNumerals(score)}';
    }
  }

  String get helpInstructionsCardTitle =>
      isEnglish ? 'Game guide' : AppStrings.helpInstructionsCardTitleUr;

  String get helpInstructionsCardSubtitle =>
      isEnglish
          ? 'How it works • XP • streak • coins'
          : AppStrings.helpInstructionsCardSubtitleUr;

  String get meetActorsAppBarTitle =>
      isEnglish ? 'Meet our actors' : AppStrings.meetActorsCardTitleUr;

  String get meetActorsIntroEn =>
      'These characters show up again and again in our scenes. Each one has a clear personality so idioms and situations stick in memory.';

  String get meetActorsCardTitle =>
      isEnglish ? 'Meet our actors' : AppStrings.meetActorsCardTitleUr;

  String get meetActorsCardSubtitle =>
      isEnglish
          ? 'Recurring faces in your rounds'
          : AppStrings.meetActorsCardSubtitleUr;

  String get meetActorsPortraitSoon =>
      isEnglish ? 'Photo coming soon' : AppStrings.meetActorsPortraitSoonUr;

  String get helpSheetTitle =>
      isEnglish ? 'GuessKaro guide' : AppStrings.helpSheetTitleUr;

  String get helpMissionTitle =>
      isEnglish ? 'Why we built GuessKaro' : AppStrings.helpMissionTitle;

  String get helpMissionBodyEn =>
      'GuessKaro helps kids and families use screen time in a positive way—learning everyday Urdu idioms through play. '
      'Urdu is a beautiful language, yet it is often neglected and forgotten; this app is our attempt to bring it back with joy, not drills.';

  String get helpHowToSectionTitle =>
      isEnglish ? 'How a round flows' : AppStrings.helpHowToPlayTitle;

  String get helpHowToBodyEn =>
      'Each card shows a scene photo. Pick the phrase that fits (tap an option—or speak your answer if you chose speak mode). '
      'See whether you\'re correct, flip to reveal the phrase, answer a four-option meaning quiz, read an example sentence, then advance.';

  String get helpScoresSectionTitle =>
      isEnglish ? 'Points & timers' : AppStrings.helpScoresTitle;

  String get helpScoresBodyEn =>
      'In timed modes, faster correct guesses score higher. Consecutive correct answers in the same session multiply your earned points—that is separate from your daily streak on Home.';

  String get helpLevelsSectionTitle =>
      isEnglish ? 'Levels & XP' : AppStrings.helpLevelsTitle;

  String get helpLevelsBodyEn =>
      'You gain XP when you nail answers and complete cards.';

  String get helpStreakSectionTitle =>
      isEnglish ? 'Daily streak (Home)' : AppStrings.helpStreakTitle;

  String get helpStreakBodyEn =>
      'The flame on Home counts calendar days you play at least once. Playing more on the same day doesn\'t add extra streak days; skip a calendar day and the count resets from one.';

  String get helpCoinsSectionTitle =>
      isEnglish ? 'Coins & hints' : AppStrings.helpCoinsSectionTitle;

  String helpCoinsParagraph() {
    final int e = ScoringConstants.eliminateHintCost;
    final int f = ScoringConstants.freezeHintCost;
    if (isEnglish) {
      return 'You earn coins from strong rounds. Spend them on the photo round: Eliminate removes wrong options ($e coins) '
          'and Freeze pauses the timer ($f coins).';
    }
    return AppStrings.helpCoinsBodyUr(
      toUrduNumerals(e),
      toUrduNumerals(f),
    );
  }

  String get helpGotIt =>
      isEnglish ? 'Got it' : AppStrings.helpGotItUr;

  /// Bottom tab: keep Latin "Home" in Urdu UI (گھر means house, not app home).
  String get navHome => 'Home';
  String get navLibrary => isEnglish ? 'Library' : 'لائبریری';
  String get libraryTitle => isEnglish ? 'Idioms Library' : 'کتب خانہ';
  String get navProfile => isEnglish ? 'Profile' : 'پروفائل';

  /// Bottom bar (Roman script common for system-style labels in UR UI).
  String get navSettings => isEnglish ? 'Settings' : 'سیٹنگز';

  String profileTotalXp(int xp) =>
      isEnglish ? '$xp XP total' : 'کل ${toUrduNumerals(xp)} XP';

  /// Recent sessions row — maps stored mode keys to localized labels.
  String sessionModeDisplay(String rawMode) {
    final String m = ScoringConstants.sanitizeGameMode(rawMode);
    if (m == ScoringConstants.modeSpeedRound) {
      return speedRound;
    }
    if (m == ScoringConstants.modeQuickPlay) {
      return quickPlay;
    }
    return rawMode;
  }

  String get librarySearchHint =>
      isEnglish ? 'Search idiom…' : 'محاورہ تلاش کریں…';
  String libraryPhraseCountInline(int count) =>
      isEnglish ? '$count found' : '${toUrduNumerals(count)} محاورے ملے';
  String libraryMasteryProgress(int completed, int total) => isEnglish
      ? '$completed/$total idioms mastered'
      : AppStrings.libraryMasteryProgressUr(
          toUrduNumerals(completed),
          toUrduNumerals(total),
        );
  String get gamePickCorrectImage => isEnglish
      ? 'Pick the correct image'
      : AppStrings.gamePickCorrectImage;
  String get gameFillBlankPrompt => isEnglish
      ? 'Pick the word for the blank'
      : AppStrings.gameFillBlankPrompt;
  String masteryLabelForLevel(int level) {
    switch (level.clamp(0, 5)) {
      case 0:
        return isEnglish ? 'Stranger' : AppStrings.masteryLabel0;
      case 1:
        return isEnglish ? 'Acquaintance' : AppStrings.masteryLabel1;
      case 2:
        return isEnglish ? 'Familiar' : AppStrings.masteryLabel2;
      case 3:
        return isEnglish ? 'Recognition' : AppStrings.masteryLabel3;
      case 4:
        return isEnglish ? 'Strong' : AppStrings.masteryLabel4;
      case 5:
        return isEnglish ? 'Mastered' : AppStrings.masteryLabel5;
      default:
        return isEnglish ? 'Stranger' : AppStrings.masteryLabel0;
    }
  }

  String get homeLibraryTile =>
      isEnglish ? 'Idiom library' : AppStrings.homeLibraryTile;
  String get homeLibrarySubtitle => isEnglish
      ? 'Mastered idioms only'
      : AppStrings.homeLibrarySubtitle;
  String get librarySubtitle => isEnglish
      ? 'Only idioms you have fully mastered'
      : AppStrings.librarySubtitleUr;
  String get libraryEmptyMastered => isEnglish
      ? 'No mastered idioms yet.\nPlay Quick Play to unlock gold cards here.'
      : AppStrings.libraryEmptyMasteredUr;
  String libraryMasteredCountInline(int count) => isEnglish
      ? '$count mastered'
      : '${toUrduNumerals(count)} ${AppStrings.libraryMasteredCountUr}';
  String get homeMasterySection =>
      isEnglish ? 'Your progress' : AppStrings.homeMasterySection;
  String get profileOpenLibrary =>
      isEnglish ? 'Open library' : AppStrings.profileOpenLibrary;
  String gameMasteryTierLabel(int level) => isEnglish
      ? 'Tier ${toUrduNumerals(level)}'
      : '${AppStrings.gameMasteryTier} ${toUrduNumerals(level)}';
  String get libraryMasteryTierLabel => isEnglish
      ? 'Mastery'
      : AppStrings.libraryMasteryTierLabel;
  String get homeHowToPlayLink =>
      isEnglish ? 'How to play' : AppStrings.helpInstructionsCardTitleUr;
  String get libraryNoResults =>
      isEnglish ? 'No matches' : 'کوئی نتیجہ نہیں ملا';

  String get homeStoryModeTile =>
      isEnglish ? 'Story mode' : AppStrings.homeStoryModeTile;
  String get homeStoryModeSubtitle => isEnglish
      ? 'Three-idiom stories'
      : AppStrings.homeStoryModeSubtitle;
  String get homeReverseModeTile =>
      isEnglish ? 'Reverse mode' : AppStrings.homeReverseModeTile;
  String get homeReverseModeSubtitle => isEnglish
      ? 'Meaning → idiom'
      : AppStrings.homeReverseModeSubtitle;
  String get reverseModeLocked => isEnglish
      ? 'Learn 3 idioms first (tier 3+)'
      : AppStrings.reverseModeLocked;
  String get storyModeTitle =>
      isEnglish ? 'Story mode' : AppStrings.storyModeTitle;
  String get storyModePickStory => isEnglish
      ? 'Pick a story'
      : AppStrings.storyModePickStory;
  String get storyModeSubtitle => isEnglish
      ? 'Three idioms per story, in order'
      : AppStrings.storyModeSubtitle;
  String storyPhraseCount(int count) => isEnglish
      ? '$count idioms'
      : '${toUrduNumerals(count)} ${AppStrings.storyPhraseCountUr}';
  String get gameReversePrompt =>
      isEnglish ? 'Pick the correct idiom' : AppStrings.gameReversePrompt;
  String get gameStoryConnectorHint => isEnglish
      ? 'Next card…'
      : AppStrings.gameStoryConnectorHint;
  String get storySessionEmpty => isEnglish
      ? 'Story phrases are not available.'
      : AppStrings.storySessionEmpty;
  String get reverseSessionEmpty => isEnglish
      ? 'Need at least three tier-3+ idioms for Reverse mode.'
      : AppStrings.reverseSessionEmpty;

  // Category sheet (values stay Urdu for phrase DB)
  String get pickCategory => isEnglish ? 'Choose category' : 'زمرہ چنیں';
  String get proverbLabel => isEnglish ? 'Proverb' : 'کہاوت';
  String get idiomLabel => isEnglish ? 'Idiom' : 'محاورہ';
  String diffLabelUr(String ur) {
    switch (ur) {
      case 'آسان':
        return isEnglish ? 'Easy' : 'آسان';
      case 'درمیانہ':
        return isEnglish ? 'Medium' : 'درمیانہ';
      case 'مشکل':
        return isEnglish ? 'Hard' : 'مشکل';
      default:
        return ur;
    }
  }

  // Settings
  String get settingsTitle => isEnglish ? 'Settings' : 'سیٹنگز';

  String get settingsSectionLanguage =>
      isEnglish ? 'Language' : 'زبان';

  String get settingsSectionAppearance =>
      isEnglish ? 'Appearance' : 'ظاہری شکل';

  String get appThemeLabel => isEnglish ? 'App theme' : 'ایپ تھیم';

  String get themeClassicLabel =>
      isEnglish ? 'Classic' : 'کلاسک';

  String get themeSunnyLabel =>
      isEnglish ? 'Sunny Quiz' : 'سنی کوئز';

  String get gameplaySection => isEnglish ? 'Gameplay' : 'گیم پلے';

  String get settingsSectionAbout => isEnglish ? 'About' : 'متعلق';

  String get timedModeTitle =>
      isEnglish ? 'Time based mode' : 'وقت پر مبنی موڈ';

  String get timedModeSubtitle =>
      isEnglish
          ? 'Show countdowns in game rounds'
          : 'راؤنڈز میں الٹی گنتی دکھائیں';
  String get sound => isEnglish ? 'Sound' : 'آواز';
  String get haptic => isEnglish ? 'Haptics' : 'ہاپٹک';
  String get accountSection => isEnglish ? 'Account' : 'اکاؤنٹ';
  String get changeName => isEnglish ? 'Change name' : 'نام تبدیل کریں';
  String get changeAvatar => isEnglish ? 'Change avatar' : 'اوتار تبدیل کریں';
  String get appVersion => isEnglish ? 'App version' : 'ایپ ورژن';
  String get clearCache => isEnglish ? 'Clear cache' : 'کیش صاف کریں';
  String get clearCacheTitle => isEnglish ? 'Clear cache?' : 'کیش صاف کریں';
  String get clearCacheBody =>
      isEnglish
          ? 'All cached data on this device will be removed.'
          : 'تمام لوکل کیش ڈیٹا صاف ہو جائے گا۔';
  String get no => isEnglish ? 'No' : 'نہیں';
  String get yes => isEnglish ? 'Yes' : 'ہاں';
  String get cacheCleared => isEnglish ? 'Cache cleared' : 'کیش صاف ہو گیا';
  String get signOut => isEnglish ? 'Sign out' : 'سائن آؤٹ';
  String get signOutConfirmTitle => isEnglish ? 'Sign out?' : 'سائن آؤٹ';
  String signOutConfirmBody({required bool remoteAuth}) {
    if (remoteAuth) {
      return isEnglish
          ? 'Are you sure you want to sign out?'
          : 'کیا آپ واقعی سائن آؤٹ کرنا چاہتے ہیں؟';
    }
    return isEnglish
        ? 'Return to welcome? Your name and local progress on this device will be cleared.'
        : 'ویلکم اسکرین پر واپس جانا ہے؟ آپ کا مقامی ڈیٹا صاف ہو جائے گا۔';
  }

  String get cancel => isEnglish ? 'Cancel' : 'منسوخ';
  String get save => isEnglish ? 'Save' : 'محفوظ';

  // Game chrome (phrase content/options remain Urdu by design).
  String get gameCardTitle => isEnglish ? 'Card' : 'کارڈ';
  String gameCardProgress(int current, int total) =>
      isEnglish
          ? 'Card $current / $total'
          : 'کارڈ ${toUrduNumerals(current)} / ${toUrduNumerals(total)}';
  String gameRevealProgress(int current, int total) =>
      isEnglish
          ? 'Item $current / $total'
          : 'شے ${toUrduNumerals(current)} / ${toUrduNumerals(total)}';
  String get gameCoinsLabel => isEnglish ? 'Coins' : 'سکے';
  String gameCoinsInline(int coins) =>
      isEnglish ? '$gameCoinsLabel: $coins' : 'سکے: ${toUrduNumerals(coins)}';
  String get gameBackHome => isEnglish ? 'Back to home' : 'ہوم پر واپس';
  String get gameBack => isEnglish ? 'Back' : 'واپس';
  String get gameHome => isEnglish ? 'Home' : 'ہوم';
  String get gameNoCard => isEnglish ? 'No card found' : 'کوئی کارڈ نہیں';
  String gameFrozenForSeconds(int seconds) =>
      isEnglish
          ? 'Frozen: $seconds sec'
          : 'منجمد: ${toUrduNumerals(seconds)} سیکنڈ';
  String get gamePickCorrectMeaning =>
      isEnglish ? 'Pick the correct meaning' : 'درست معنی منتخب کریں';
  String get gamePickCorrectPhrase =>
      isEnglish ? 'Pick the correct phrase' : 'درست محاورہ منتخب کریں';
  String get gameSpeakPhrasePrompt =>
      isEnglish
          ? 'Speak the phrase you think matches this photo'
          : 'جو محاورہ درست لگے، اسے بولیں';
  String get gameTapToSpeak =>
      isEnglish ? 'Tap to speak' : 'بولنے کے لئے دبائیں';
  String get gameTapAgainIfNeeded =>
      isEnglish
          ? 'If it does not respond, tap again.'
          : 'اگر جواب نہ آئے تو دوبارہ دبائیں۔';
  String get gameListening => isEnglish ? 'Listening...' : 'سن رہا ہے...';
  String get gameRecognizedText => isEnglish ? 'Recognized' : 'سنا گیا';
  String get gameVoiceRetry => isEnglish ? 'Try again' : 'دوبارہ کوشش کریں';
  String get gameHintEliminate => isEnglish ? 'Eliminate' : 'حذف';
  String get gameHintFreeze => isEnglish ? 'Freeze' : 'جم';

  String get gameFrozenLabel =>
      isEnglish ? 'Frozen' : 'منجمد';
  String get gameListenExample => isEnglish ? 'See example' : 'مثال دیکھیں';
  String get gameMeaningQuiz => isEnglish ? 'Meaning quiz' : 'معنی کا کوئز';

  String get gameRevealPhraseLabel =>
      isEnglish ? 'The phrase was' : 'یہ محاورہ تھا';

  String get gameRevealAutoMeaningHint =>
      isEnglish
          ? 'Meaning quiz starts in a moment…'
          : 'معنی کا کوئز تھوڑی دیر میں شروع ہوگا…';
  String get resultCorrect => isEnglish ? 'Correct!' : 'درست!';
  String get resultIncorrect => isEnglish ? 'Wrong' : 'غلط';
  String get resultTimeout => isEnglish ? 'Time up' : 'وقت ختم';
  String get summaryTitle => isEnglish ? 'Session summary' : 'نشست کا خلاصہ';
  String summaryTotalScore(int score) =>
      isEnglish ? 'Total score: $score' : 'کل سکور: ${toUrduNumerals(score)}';
  String summaryFullyCorrect(int correct, int total) =>
      isEnglish
          ? '$correct fully correct ($total)'
          : '${toUrduNumerals(correct)} بامکمل درست (${toUrduNumerals(total)})';
  String summaryXpCoins(int xp, int coins) =>
      isEnglish
          ? '+$xp XP   ·   +$coins Coins'
          : '+${toUrduNumerals(xp)} XP   ·   +${toUrduNumerals(coins)} سکے';
  String get summaryPerPhraseResult =>
      isEnglish ? 'Per-phrase results' : 'ہر جملے کا نتیجہ';
  String summaryRoundBreakdown({
    required bool photoCorrect,
    required int photoPoints,
    required bool meaningCorrect,
    required int meaningPoints,
  }) {
    if (isEnglish) {
      return 'Photo: ${photoCorrect ? "✓" : "✗"} $photoPoints'
          '  ·  Meaning: ${meaningCorrect ? "✓" : "✗"} $meaningPoints';
    }
    return 'تصویر: ${photoCorrect ? "✓" : "✗"} ${toUrduNumerals(photoPoints)}'
        '  ·  مطلب: ${meaningCorrect ? "✓" : "✗"} ${toUrduNumerals(meaningPoints)}';
  }

  String summaryRoundTotal(int total) =>
      isEnglish ? '= $total' : '= ${toUrduNumerals(total)}';
  String get summaryStartNextRound =>
      isEnglish ? 'Start next round' : 'اگلے راؤنڈ کا آغاز';

  // Profile
  String get profileTitle => isEnglish ? 'Profile' : 'پروفائل';
  String get profileLoadFailed =>
      isEnglish ? 'Could not load profile' : 'پروفائل لوڈ نہیں ہوا';
  String get emptySessions =>
      isEnglish ? 'No sessions yet' : 'ابھی کوئی سیشن موجود نہیں';
  String get recentSessions => isEnglish ? 'Recent sessions' : 'حالیہ سیشنز';
  String get statStreak => isEnglish ? 'Streak' : 'سٹریک';
  String get statBest => isEnglish ? 'Best' : 'بہترین';
  String get statCoins => isEnglish ? 'Coins' : 'سکے';

  String get statCorrectRate =>
      isEnglish ? 'Correct' : 'درست';

  /// Level ribbon for XP bar (numeric level uses Latin in EN UI).
  String levelBarLabel({required int level, required String localizedTitle}) {
    if (isEnglish) {
      return 'Level $level — $localizedTitle';
    }
    return 'لیول ${toUrduNumerals(level)} - $localizedTitle';
  }

  String levelTitle(int level, {required String urUrduTitle}) {
    if (!isEnglish) return urUrduTitle;
    if (level >= 30) return 'Language king';
    if (level >= 20) return 'Master';
    if (level >= 15) return 'Phrase expert';
    if (level >= 10) return 'Polyglot';
    if (level >= 5) return 'Fluent learner';
    return 'New learner';
  }
}
