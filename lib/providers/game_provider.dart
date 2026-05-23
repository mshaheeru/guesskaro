import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_config.dart';
import '../core/constants/mastery_constants.dart';
import '../core/constants/scoring_constants.dart';
import '../core/services/game_sound_service.dart';
import '../core/utils/random_uuid.dart';
import '../data/models/phrase_model.dart';
import '../data/models/session_model.dart';
import '../data/repositories/phrase_repository.dart';
import '../data/repositories/session_repository.dart';
import 'profile_provider.dart';
import 'session_user_provider.dart';

enum GamePhase {
  idle,
  loadingPhrases,
  showingPhoto,
  showingResultFlash,
  showingReveal,
  showingMeaningQuiz,
  /// Index not advanced yet — photo screen commits the next card.
  preparingNextPhotoRound,
  /// Story mode bridge between cards.
  storyConnector,
  sessionComplete,
  error,
}

enum ResultFlashKind { correct, incorrect, timeout }

enum PhotoQuizMode { textMcq, imageGrid, scenarioMcq }

/// One completed phrase row for summary + persistence.
class PhraseRoundResult {
  const PhraseRoundResult({
    required this.phraseId,
    required this.romanised,
    required this.photoGuessCorrect,
    required this.photoTimeSeconds,
    required this.photoPointsEarned,
    required this.meaningGuessCorrect,
    required this.meaningTimeSeconds,
    required this.meaningPointsEarned,
    required this.totalPointsEarned,
  });

  final String phraseId;
  final String romanised;
  final bool photoGuessCorrect;
  final int photoTimeSeconds;
  final int photoPointsEarned;
  final bool meaningGuessCorrect;
  final int meaningTimeSeconds;
  final int meaningPointsEarned;
  final int totalPointsEarned;

  Map<String, dynamic> toProgressRow({required String userId}) {
    return <String, dynamic>{
      'userId': userId,
      'phraseId': phraseId,
      'photoGuessCorrect': photoGuessCorrect,
      'photoTimeSeconds': photoTimeSeconds,
      'photoPointsEarned': photoPointsEarned,
      'meaningGuessCorrect': meaningGuessCorrect,
      'meaningTimeSeconds': meaningTimeSeconds,
      'meaningPointsEarned': meaningPointsEarned,
      'totalPointsEarned': totalPointsEarned,
    };
  }
}

/// Aggregated totals after [endSession].
class SessionTotals {
  const SessionTotals({
    required this.totalPoints,
    required this.cardsFullyCorrect,
    required this.totalCards,
    required this.sessionXpEarned,
    required this.sessionCoinsEarned,
    required this.dailyGoalBonusApplied,
    required this.perfectSessionBonusApplied,
    required this.maxStreak,
  });

  final int totalPoints;
  final int cardsFullyCorrect;
  final int totalCards;
  final int sessionXpEarned;
  final int sessionCoinsEarned;
  final bool dailyGoalBonusApplied;
  final bool perfectSessionBonusApplied;

  /// Max per-answer streak reached this session.
  final int maxStreak;
}

class GameState {
  const GameState({
    required this.phase,
    required this.mode,
    this.category,
    this.difficulty,
    this.timedModeEnabled = false,
    required this.roundCount,
    this.errorMessage,
    this.phrases = const <PhraseModel>[],
    this.currentIndex = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.photoOptions = const <String>[],
    this.photoCorrectIndex = -1,
    this.meaningOptions = const <String>[],
    this.meaningCorrectIndex = -1,
    this.photoSecondsRemaining = 0,
    this.photoTotalSeconds = 0,
    this.meaningSecondsRemaining = 0,
    this.meaningTotalSeconds = 0,
    this.photoFrozen = false,
    this.freezeSecondsRemaining = 0,
    this.eliminatedPhotoIndices = const <int>{},
    this.eliminateUsed = false,
    this.freezeUsed = false,
    this.selectedPhotoIndex,
    this.selectedMeaningIndex,
    this.resultFlashKind,
    this.lastPhotoPointsEarned = 0,
    this.meaningRevealReady = false,
    this.completedRounds = const <PhraseRoundResult>[],
    this.sessionTotals,
    this.lastPhotoElapsedSeconds = 0,
    this.currentMasteryLevel = 0,
    this.photoQuizMode = PhotoQuizMode.textMcq,
    this.imageGridOptions = const <PhraseImageOption>[],
    this.useFillBlankOnReveal = false,
    this.blankWordOptions = const <String>[],
    this.blankWordCorrectIndex = -1,
    this.fillBlankSentenceDisplay,
    this.storyId,
    this.storyLinesUrdu = const <String>[],
    this.storyConnectorIndex = 0,
    this.sessionPhraseIds = const <String>[],
  });

  factory GameState.initial() {
    return const GameState(
      phase: GamePhase.idle,
      mode: ScoringConstants.modeQuickPlay,
      roundCount: 10,
      storyLinesUrdu: <String>[],
      sessionPhraseIds: <String>[],
    );
  }

  /// Whether the photo stage has a countdown timer.
  bool get photoHasTimer => photoTotalSeconds > 0;

  /// Whether meaning quiz has a timer.
  bool get meaningHasTimer => meaningTotalSeconds > 0;

  final GamePhase phase;
  final String mode;
  final String? category;
  final String? difficulty;
  final bool timedModeEnabled;
  final int roundCount;

  /// Number of phrases in this session.
  final List<PhraseModel> phrases;
  final int currentIndex;

  /// Streak increments on each correct MCQ answer; resets on wrong/timeout.
  final int streak;
  final int maxStreak;

  final List<String> photoOptions;
  final int photoCorrectIndex;

  final List<String> meaningOptions;
  final int meaningCorrectIndex;

  final int photoSecondsRemaining;
  final int photoTotalSeconds;

  final int meaningSecondsRemaining;
  final int meaningTotalSeconds;

  final bool photoFrozen;
  final int freezeSecondsRemaining;

  /// Wrong options removed via eliminate hint (photo stage).
  final Set<int> eliminatedPhotoIndices;

  final bool eliminateUsed;
  final bool freezeUsed;

  final int? selectedPhotoIndex;
  final int? selectedMeaningIndex;

  final ResultFlashKind? resultFlashKind;
  final int lastPhotoPointsEarned;

  /// Reveal phase: user can open example; taps CTA to start meaning quiz.
  final bool meaningRevealReady;

  final List<PhraseRoundResult> completedRounds;

  /// Set when session ends successfully.
  final SessionTotals? sessionTotals;

  final String? errorMessage;

  /// Seconds used on photo round (persisted before phase changes hide the timer snapshot).
  final int lastPhotoElapsedSeconds;

  final int currentMasteryLevel;
  final PhotoQuizMode photoQuizMode;
  final List<PhraseImageOption> imageGridOptions;
  final bool useFillBlankOnReveal;
  final List<String> blankWordOptions;
  final int blankWordCorrectIndex;
  final String? fillBlankSentenceDisplay;
  final String? storyId;
  final List<String> storyLinesUrdu;
  final int storyConnectorIndex;
  final List<String> sessionPhraseIds;

  bool get reverseMode => mode == ScoringConstants.modeReverse;

  bool get storyMode => mode == ScoringConstants.modeStory;

  bool get _hasStoryLines => storyLinesUrdu.isNotEmpty;

  String? get currentStoryLine {
    if (!_hasStoryLines) return null;
    if (storyConnectorIndex < 0 ||
        storyConnectorIndex >= storyLinesUrdu.length) {
      return null;
    }
    return storyLinesUrdu[storyConnectorIndex];
  }

  bool get photoTextMcqEnabled => photoQuizMode == PhotoQuizMode.textMcq;

  PhraseModel? get currentPhrase {
    if (phrases.isEmpty || currentIndex < 0 || currentIndex >= phrases.length) {
      return null;
    }
    return phrases[currentIndex];
  }

  GameState copyWith({
    GamePhase? phase,
    String? mode,
    String? category,
    String? difficulty,
    bool? timedModeEnabled,
    bool clearCategory = false,
    int? roundCount,
    List<PhraseModel>? phrases,
    int? currentIndex,
    int? streak,
    int? maxStreak,
    List<String>? photoOptions,
    int? photoCorrectIndex,
    List<String>? meaningOptions,
    int? meaningCorrectIndex,
    int? photoSecondsRemaining,
    int? photoTotalSeconds,
    int? meaningSecondsRemaining,
    int? meaningTotalSeconds,
    bool? photoFrozen,
    int? freezeSecondsRemaining,
    Set<int>? eliminatedPhotoIndices,
    bool clearEliminated = false,
    bool? eliminateUsed,
    bool? freezeUsed,
    int? selectedPhotoIndex,
    bool clearSelectedPhoto = false,
    int? selectedMeaningIndex,
    bool clearSelectedMeaning = false,
    ResultFlashKind? resultFlashKind,
    bool clearResultFlash = false,
    int? lastPhotoPointsEarned,
    bool? meaningRevealReady,
    List<PhraseRoundResult>? completedRounds,
    SessionTotals? sessionTotals,
    bool clearSessionTotals = false,
    String? errorMessage,
    bool clearError = false,
    int? lastPhotoElapsedSeconds,
    int? currentMasteryLevel,
    PhotoQuizMode? photoQuizMode,
    List<PhraseImageOption>? imageGridOptions,
    bool? useFillBlankOnReveal,
    List<String>? blankWordOptions,
    int? blankWordCorrectIndex,
    String? fillBlankSentenceDisplay,
    bool clearFillBlankDisplay = false,
    String? storyId,
    bool clearStoryId = false,
    List<String>? storyLinesUrdu,
    bool clearStoryLines = false,
    int? storyConnectorIndex,
    List<String>? sessionPhraseIds,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      category: clearCategory ? null : (category ?? this.category),
      difficulty: difficulty ?? this.difficulty,
      timedModeEnabled: timedModeEnabled ?? this.timedModeEnabled,
      roundCount: roundCount ?? this.roundCount,
      phrases: phrases ?? this.phrases,
      currentIndex: currentIndex ?? this.currentIndex,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      photoOptions: photoOptions ?? this.photoOptions,
      photoCorrectIndex: photoCorrectIndex ?? this.photoCorrectIndex,
      meaningOptions: meaningOptions ?? this.meaningOptions,
      meaningCorrectIndex: meaningCorrectIndex ?? this.meaningCorrectIndex,
      photoSecondsRemaining:
          photoSecondsRemaining ?? this.photoSecondsRemaining,
      photoTotalSeconds: photoTotalSeconds ?? this.photoTotalSeconds,
      meaningSecondsRemaining:
          meaningSecondsRemaining ?? this.meaningSecondsRemaining,
      meaningTotalSeconds: meaningTotalSeconds ?? this.meaningTotalSeconds,
      photoFrozen: photoFrozen ?? this.photoFrozen,
      freezeSecondsRemaining:
          freezeSecondsRemaining ?? this.freezeSecondsRemaining,
      eliminatedPhotoIndices:
          clearEliminated
              ? <int>{}
              : (eliminatedPhotoIndices ?? this.eliminatedPhotoIndices),
      eliminateUsed: eliminateUsed ?? this.eliminateUsed,
      freezeUsed: freezeUsed ?? this.freezeUsed,
      selectedPhotoIndex:
          clearSelectedPhoto
              ? null
              : (selectedPhotoIndex ?? this.selectedPhotoIndex),
      selectedMeaningIndex:
          clearSelectedMeaning
              ? null
              : (selectedMeaningIndex ?? this.selectedMeaningIndex),
      resultFlashKind:
          clearResultFlash ? null : (resultFlashKind ?? this.resultFlashKind),
      lastPhotoPointsEarned:
          lastPhotoPointsEarned ?? this.lastPhotoPointsEarned,
      meaningRevealReady: meaningRevealReady ?? this.meaningRevealReady,
      completedRounds: completedRounds ?? this.completedRounds,
      sessionTotals:
          clearSessionTotals ? null : (sessionTotals ?? this.sessionTotals),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastPhotoElapsedSeconds:
          lastPhotoElapsedSeconds ?? this.lastPhotoElapsedSeconds,
      currentMasteryLevel: currentMasteryLevel ?? this.currentMasteryLevel,
      photoQuizMode: photoQuizMode ?? this.photoQuizMode,
      imageGridOptions: imageGridOptions ?? this.imageGridOptions,
      useFillBlankOnReveal: useFillBlankOnReveal ?? this.useFillBlankOnReveal,
      blankWordOptions: blankWordOptions ?? this.blankWordOptions,
      blankWordCorrectIndex:
          blankWordCorrectIndex ?? this.blankWordCorrectIndex,
      fillBlankSentenceDisplay: clearFillBlankDisplay
          ? null
          : (fillBlankSentenceDisplay ?? this.fillBlankSentenceDisplay),
      storyId: clearStoryId ? null : (storyId ?? this.storyId),
      storyLinesUrdu: clearStoryLines
          ? const <String>[]
          : (storyLinesUrdu ?? this.storyLinesUrdu),
      storyConnectorIndex: storyConnectorIndex ?? this.storyConnectorIndex,
      sessionPhraseIds: sessionPhraseIds ?? this.sessionPhraseIds,
    );
  }
}

class GameNotifier extends Notifier<GameState> {
  Timer? _photoTicker;
  Timer? _meaningTicker;
  Timer? _freezeTicker;
  Timer? _flashDelay;
  Timer? _revealDelay;
  bool _persistedSession = false;
  bool _endSessionBusy = false;
  bool _committingNextPhotoRound = false;
  static const String _timedModePrefKey = 'timed_mode_enabled';

  /// One RNG for all shuffles in a session — avoids multiple `Random()` seeds in same tick.
  final Random _rng = Random();

  SessionRepository get _sessions => ref.read(sessionRepositoryProvider);
  PhraseRepository get _phrases => ref.read(phraseRepositoryProvider);
  GameSoundService get _sounds => ref.read(gameSoundServiceProvider);

  String _requireActiveUserId() {
    final String? id = ref.read(activeUserIdProvider);
    if (id == null) {
      throw StateError('Active profile required for a session.');
    }
    return id;
  }

  void _cancelAllTimers() {
    _photoTicker?.cancel();
    _photoTicker = null;
    _meaningTicker?.cancel();
    _meaningTicker = null;
    _freezeTicker?.cancel();
    _freezeTicker = null;
    _flashDelay?.cancel();
    _flashDelay = null;
    _revealDelay?.cancel();
    _revealDelay = null;
  }

  Future<bool> _loadTimedModeEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_timedModePrefKey) ?? false;
  }

  @override
  GameState build() {
    ref.onDispose(_cancelAllTimers);
    return GameState.initial();
  }

  /// Clear mid-game progress (exit to home).
  Future<void> resetSession() async {
    _cancelAllTimers();
    _persistedSession = false;
    unawaited(_sounds.startAmbientLoop());
    state = GameState.initial();
  }

  Future<void> startSession({
    required String mode,
    String? category,
    String? difficulty,
    int count = 10,
    List<String>? phraseIds,
    String? storyId,
    List<String>? storyLinesUrdu,
  }) async {
    final String normalizedMode = ScoringConstants.sanitizeGameMode(mode);
    _cancelAllTimers();
    _persistedSession = false;
    unawaited(_sounds.startTensionLoop());
    final bool timedModeEnabled = await _loadTimedModeEnabled();
    final bool isStory = normalizedMode == ScoringConstants.modeStory;
    final bool isReverse = normalizedMode == ScoringConstants.modeReverse;
    final int sessionCount =
        phraseIds != null && phraseIds.isNotEmpty ? phraseIds.length : count;

    state = state.copyWith(
      phase: GamePhase.loadingPhrases,
      mode: normalizedMode,
      category: category,
      difficulty: difficulty,
      timedModeEnabled: timedModeEnabled,
      roundCount: sessionCount,
      storyId: storyId,
      storyLinesUrdu: storyLinesUrdu ?? const <String>[],
      clearStoryLines: storyLinesUrdu == null || storyLinesUrdu.isEmpty,
      storyConnectorIndex: 0,
      sessionPhraseIds: phraseIds ?? const <String>[],
      clearStoryId: storyId == null && !isStory,
      clearError: true,
      clearSessionTotals: true,
      completedRounds: const <PhraseRoundResult>[],
    );

    try {
      final String userId = ref.read(activeUserIdProvider) ?? kLocalGuestUserId;
      late final List<PhraseModel> session;

      if (phraseIds != null && phraseIds.isNotEmpty) {
        session = await _phrases.fetchPhrasesByIds(phraseIds);
      } else if (isReverse) {
        session = await _phrases.getReverseSessionPhrases(
          userId: userId,
          count: sessionCount,
        );
      } else {
        session = await _phrases.getSessionPhrases(
          mode: normalizedMode,
          category: category,
          difficulty: difficulty,
          count: sessionCount,
        );
      }

      if (session.isEmpty) {
        unawaited(_sounds.stopAmbientLoop());
        final String emptyMessage = isReverse
            ? 'الٹا موڈ کے لیے کم از کم تین محاورے سطح ۳ پر ہوں۔'
            : isStory
                ? 'کہانی کے جملے دستیاب نہیں۔'
                : 'کوئی جملہ دستیاب نہیں۔';
        state = state.copyWith(
          phase: GamePhase.error,
          errorMessage: emptyMessage,
        );
        return;
      }

      state = state.copyWith(
        phrases: session,
        currentIndex: 0,
        streak: 0,
        maxStreak: 0,
        completedRounds: const <PhraseRoundResult>[],
      );

      if (isStory && (storyLinesUrdu?.isNotEmpty ?? false)) {
        final int expectedLines = session.length + 1;
        if (storyLinesUrdu!.length != expectedLines) {
          unawaited(_sounds.stopAmbientLoop());
          state = state.copyWith(
            phase: GamePhase.error,
            errorMessage:
                'کہانی کی سطور غلط ہیں ($expectedLines متوقع، ${storyLinesUrdu.length} ملے)۔',
          );
          return;
        }
        state = state.copyWith(
          phase: GamePhase.storyConnector,
          storyConnectorIndex: 0,
        );
        return;
      }

      await _setupCurrentCard();
    } catch (e) {
      unawaited(_sounds.stopAmbientLoop());
      state = state.copyWith(
        phase: GamePhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _setupCurrentCard() async {
    _cancelAllTimers();
    final PhraseModel? phrase = state.currentPhrase;
    if (phrase == null) {
      state = state.copyWith(
        phase: GamePhase.error,
        errorMessage: 'کارڈ نہیں ملا۔',
      );
      return;
    }

    final String userId = ref.read(activeUserIdProvider) ?? kLocalGuestUserId;
    final int storedLevel = await _phrases.getMasteryLevel(
      userId: userId,
      phraseId: phrase.id,
    );
    final int playLevel = MasteryConstants.playLevelForPhrase(
      storedLevel: storedLevel,
      hasScenarioUrdu: phrase.hasScenarioUrdu,
    );

    final bool isReverse = state.reverseMode;
    final bool useImageGrid =
        !isReverse && MasteryConstants.shouldUseImageGrid(playLevel);
    final bool useFillBlank =
        !isReverse && MasteryConstants.shouldUseFillBlankOnReveal(playLevel);

    List<String> photoOpts = const <String>[];
    List<PhraseImageOption> gridOpts = const <PhraseImageOption>[];
    int photoCorrectIdx = 0;
    PhotoQuizMode quizMode = PhotoQuizMode.textMcq;

    if (useImageGrid) {
      gridOpts = _buildImageGridOptions(phrase, state.phrases);
      photoCorrectIdx = gridOpts.indexWhere(
        (PhraseImageOption o) => o.phraseId == phrase.id,
      );
      if (photoCorrectIdx < 0) photoCorrectIdx = 0;
      quizMode = PhotoQuizMode.imageGrid;
    } else {
      final int optionCount = isReverse
          ? 4
          : MasteryConstants.photoOptionCountForLevel(playLevel);
      photoOpts = _buildPhotoPhraseChoices(phrase, optionCount: optionCount);
      photoCorrectIdx = photoOpts.indexWhere(
        (String o) => o == phrase.urduPhrase,
      );
      if (photoCorrectIdx < 0) photoCorrectIdx = 0;
      quizMode = PhotoQuizMode.textMcq;
    }

    state = state.copyWith(
      phase: GamePhase.showingPhoto,
      currentMasteryLevel: playLevel,
      photoQuizMode: quizMode,
      photoOptions: photoOpts,
      imageGridOptions: gridOpts,
      photoCorrectIndex: photoCorrectIdx,
      useFillBlankOnReveal: useFillBlank,
      meaningOptions: const <String>[],
      meaningCorrectIndex: -1,
      blankWordOptions: const <String>[],
      blankWordCorrectIndex: -1,
      clearFillBlankDisplay: true,
      meaningRevealReady: false,
      eliminatedPhotoIndices: {},
      eliminateUsed: false,
      freezeUsed: false,
      lastPhotoElapsedSeconds: 0,
      photoFrozen: false,
      freezeSecondsRemaining: 0,
      clearSelectedPhoto: true,
      clearSelectedMeaning: true,
      clearResultFlash: true,
      meaningSecondsRemaining: 0,
      meaningTotalSeconds: 0,
    );

    _startPhotoTimer();
  }

  List<String> _buildMeaningChoices(PhraseModel phrase) {
    final List<String> wrong = List<String>.from(phrase.wrongOptions)
      ..shuffle(_rng);
    final List<String> pool = <String>[phrase.meaningUrdu];
    int i = 0;
    while (pool.length < 4 && i < wrong.length) {
      if (!pool.contains(wrong[i])) {
        pool.add(wrong[i]);
      }
      i++;
    }
    while (pool.length < 4) {
      pool.add('${phrase.meaningUrdu} ($pool.length)');
    }
    pool.shuffle(_rng);
    return pool.take(4).toList();
  }

  List<String> _buildPhotoPhraseChoices(
    PhraseModel phrase, {
    int optionCount = 4,
  }) {
    final int target = optionCount.clamp(2, 4);
    final List<String> wrong = List<String>.from(phrase.photoWrongOptions)
      ..shuffle(_rng);
    final List<String> pool = <String>[phrase.urduPhrase];
    int i = 0;
    while (pool.length < target && i < wrong.length) {
      if (!pool.contains(wrong[i])) {
        pool.add(wrong[i]);
      }
      i++;
    }
    while (pool.length < target) {
      pool.add('${phrase.urduPhrase} ${pool.length}');
    }
    pool.shuffle(_rng);
    return pool.take(target).toList();
  }

  List<PhraseImageOption> _buildImageGridOptions(
    PhraseModel current,
    List<PhraseModel> sessionPhrases,
  ) {
    final List<PhraseModel> others =
        sessionPhrases
            .where(
              (PhraseModel p) =>
                  p.id != current.id && p.imageUrl.trim().isNotEmpty,
            )
            .toList()
          ..shuffle(_rng);

    final List<PhraseImageOption> pool = <PhraseImageOption>[
      PhraseImageOption(
        phraseId: current.id,
        imageUrl: current.imageUrl,
      ),
    ];

    for (final PhraseModel p in others) {
      if (pool.length >= 4) break;
      pool.add(PhraseImageOption(phraseId: p.id, imageUrl: p.imageUrl));
    }

    while (pool.length < 4) {
      pool.add(
        PhraseImageOption(
          phraseId: '${current.id}_pad${pool.length}',
          imageUrl: current.imageUrl,
        ),
      );
    }

    pool.shuffle(_rng);
    return pool.take(4).toList();
  }

  List<String> _buildBlankWordChoices(PhraseModel phrase) {
    final List<String> tokens = phrase.exampleTokens;
    if (tokens.isEmpty) {
      return _buildMeaningChoices(phrase);
    }

    final int rawIdx = phrase.blankWordIndex ?? 0;
    final int blankIdx = rawIdx.clamp(0, tokens.length - 1);
    final String correctWord = tokens[blankIdx];

    final List<String> wrong = List<String>.from(phrase.blankWordWrongOptions)
      ..shuffle(_rng);
    final List<String> pool = <String>[correctWord];
    int i = 0;
    while (pool.length < 4 && i < wrong.length) {
      if (!pool.contains(wrong[i])) {
        pool.add(wrong[i]);
      }
      i++;
    }
    while (pool.length < 4) {
      pool.add('${correctWord}_${pool.length}');
    }
    pool.shuffle(_rng);
    return pool.take(4).toList();
  }

  String _buildFillBlankDisplay(PhraseModel phrase) {
    final List<String> tokens = phrase.exampleTokens;
    if (tokens.isEmpty) return phrase.exampleSentence;

    final int rawIdx = phrase.blankWordIndex ?? 0;
    final int blankIdx = rawIdx.clamp(0, tokens.length - 1);
    return tokens
        .asMap()
        .entries
        .map(
          (MapEntry<int, String> e) => e.key == blankIdx ? '___' : e.value,
        )
        .join(' ');
  }

  void _startPhotoTimer() {
    if (!state.timedModeEnabled) {
      state = state.copyWith(
        photoSecondsRemaining: 0,
        photoTotalSeconds: 0,
        photoFrozen: false,
      );
      return;
    }
    final int total = ScoringConstants.photoDurationSecondsForMode(state.mode);
    if (total <= 0) {
      state = state.copyWith(photoSecondsRemaining: 0, photoTotalSeconds: 0);
      return;
    }
    state = state.copyWith(
      photoSecondsRemaining: total,
      photoTotalSeconds: total,
      photoFrozen: false,
    );
    _photoTicker?.cancel();
    _photoTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != GamePhase.showingPhoto) return;
      if (state.photoFrozen) return;

      final int next = state.photoSecondsRemaining - 1;
      if (next < 0) return;

      if (next == 0) {
        _photoTicker?.cancel();
        onPhotoTimeout();
        return;
      }
      state = state.copyWith(photoSecondsRemaining: next);
      if (next <= 3) {
        unawaited(_sounds.playTick());
      }
    });
  }

  void _pausePhotoTimerVisual() {
    _photoTicker?.cancel();
    _photoTicker = null;
  }

  void _startMeaningTimer() {
    if (!state.timedModeEnabled) {
      state = state.copyWith(
        meaningSecondsRemaining: 0,
        meaningTotalSeconds: 0,
      );
      return;
    }
    final int total = ScoringConstants.meaningDurationSecondsForMode(
      state.mode,
    );
    if (total <= 0) {
      state = state.copyWith(
        meaningSecondsRemaining: 0,
        meaningTotalSeconds: 0,
      );
      return;
    }
    state = state.copyWith(
      meaningSecondsRemaining: total,
      meaningTotalSeconds: total,
    );
    _meaningTicker?.cancel();
    _meaningTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != GamePhase.showingMeaningQuiz) return;

      final int next = state.meaningSecondsRemaining - 1;
      if (next < 0) return;

      if (next == 0) {
        _meaningTicker?.cancel();
        onMeaningTimeout();
        return;
      }
      state = state.copyWith(meaningSecondsRemaining: next);
      if (next <= 3) {
        unawaited(_sounds.playTick());
      }
    });
  }

  Future<void> useEliminateHint() async {
    if (state.phase != GamePhase.showingPhoto ||
        state.eliminateUsed ||
        state.selectedPhotoIndex != null) {
      return;
    }
    _requireActiveUserId();
    final ProfileNotifier profile = ref.read(profileNotifierProvider.notifier);
    try {
      await profile.spendCoins(ScoringConstants.eliminateHintCost);
    } catch (_) {
      return;
    }

    final List<int> wrongIndices = <int>[];
    for (int i = 0; i < state.photoOptions.length; i++) {
      if (i != state.photoCorrectIndex) {
        wrongIndices.add(i);
      }
    }
    wrongIndices.shuffle(_rng);
    if (wrongIndices.isEmpty) return;

    final int eliminate = wrongIndices.first;
    final Set<int> nextElim = <int>{...state.eliminatedPhotoIndices, eliminate};
    state = state.copyWith(
      eliminatedPhotoIndices: nextElim,
      eliminateUsed: true,
    );
  }

  Future<void> useFreezeHint() async {
    if (state.phase != GamePhase.showingPhoto ||
        state.freezeUsed ||
        state.selectedPhotoIndex != null ||
        !state.photoHasTimer ||
        state.photoFrozen) {
      return;
    }
    _requireActiveUserId();
    final ProfileNotifier profile = ref.read(profileNotifierProvider.notifier);
    try {
      await profile.spendCoins(ScoringConstants.freezeHintCost);
    } catch (_) {
      return;
    }

    state = state.copyWith(
      freezeUsed: true,
      photoFrozen: true,
      freezeSecondsRemaining: ScoringConstants.freezeDurationSeconds,
    );

    _photoTicker?.cancel();
    _photoTicker = null;

    _freezeTicker?.cancel();
    _freezeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != GamePhase.showingPhoto || !state.photoFrozen) {
        _freezeTicker?.cancel();
        return;
      }
      final int next = state.freezeSecondsRemaining - 1;
      if (next <= 0) {
        _freezeTicker?.cancel();
        state = state.copyWith(photoFrozen: false, freezeSecondsRemaining: 0);
        _startPhotoTimerContinuation();
        return;
      }
      state = state.copyWith(freezeSecondsRemaining: next);
    });
  }

  void _startPhotoTimerContinuation() {
    if (!state.photoHasTimer || state.photoSecondsRemaining <= 0) {
      return;
    }
    _photoTicker?.cancel();
    _photoTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != GamePhase.showingPhoto || state.photoFrozen) return;
      final int n = state.photoSecondsRemaining - 1;
      if (n <= 0) {
        _photoTicker?.cancel();
        onPhotoTimeout();
        return;
      }
      state = state.copyWith(photoSecondsRemaining: n);
      if (n <= 3) {
        unawaited(_sounds.playTick());
      }
    });
  }

  void submitPhotoAnswer(int index) {
    if (state.phase != GamePhase.showingPhoto) return;
    if (state.eliminatedPhotoIndices.contains(index)) return;

    final int remainingSnap = state.photoSecondsRemaining;
    final bool ranOut =
        state.photoHasTimer && remainingSnap <= 0 && !state.photoFrozen;
    if (ranOut) return;

    _pausePhotoTimerVisual();
    _freezeTicker?.cancel();

    final bool isCorrect = index == state.photoCorrectIndex;
    final int elapsed =
        state.photoHasTimer
            ? (state.photoTotalSeconds - remainingSnap).clamp(
              0,
              state.photoTotalSeconds,
            )
            : 0;

    _finishPhotoStage(
      selectedIndex: index,
      timedOutFromTimer: false,
      remainingAtDecision: remainingSnap,
      elapsedSeconds: elapsed,
      isCorrectGuess: isCorrect,
    );
  }

  void submitPhotoSpokenGuess({required bool isCorrect}) {
    if (state.phase != GamePhase.showingPhoto) return;
    final int remainingSnap = state.photoSecondsRemaining;
    final bool ranOut =
        state.photoHasTimer && remainingSnap <= 0 && !state.photoFrozen;
    if (ranOut) return;

    _pausePhotoTimerVisual();
    _freezeTicker?.cancel();

    final int elapsed =
        state.photoHasTimer
            ? (state.photoTotalSeconds - remainingSnap).clamp(
              0,
              state.photoTotalSeconds,
            )
            : 0;

    _finishPhotoStage(
      selectedIndex: null,
      timedOutFromTimer: false,
      remainingAtDecision: remainingSnap,
      elapsedSeconds: elapsed,
      isCorrectGuess: isCorrect,
    );
  }

  void onPhotoTimeout() {
    if (state.phase != GamePhase.showingPhoto) return;
    if (!state.photoHasTimer) return;

    _pausePhotoTimerVisual();
    _freezeTicker?.cancel();

    final int elapsed = state.photoTotalSeconds.clamp(0, 999999);

    _finishPhotoStage(
      selectedIndex: null,
      timedOutFromTimer: true,
      remainingAtDecision: 0,
      elapsedSeconds: elapsed,
      isCorrectGuess: false,
    );
  }

  void _finishPhotoStage({
    required int? selectedIndex,
    required bool timedOutFromTimer,
    required int remainingAtDecision,
    required int elapsedSeconds,
    required bool isCorrectGuess,
  }) {
    final PhraseModel? phrase = state.currentPhrase;
    if (phrase == null) return;

    final bool isCorrect = isCorrectGuess && !timedOutFromTimer;

    final int secsForTier =
        !state.photoHasTimer && isCorrect
            ? ScoringConstants.quickPlayDurationSeconds - 1
            : remainingAtDecision;

    final int basePts = ScoringConstants.calculatePoints(
      secsForTier,
      isCorrect,
    );
    final int streakForMultiplier = isCorrect ? state.streak + 1 : state.streak;
    final int newStreak = isCorrect ? state.streak + 1 : 0;

    final int earned =
        isCorrect
            ? ScoringConstants.applyStreakMultiplier(
              basePts,
              streakForMultiplier.clamp(1, 99),
            )
            : 0;

    final ResultFlashKind kind =
        timedOutFromTimer
            ? ResultFlashKind.timeout
            : (isCorrect ? ResultFlashKind.correct : ResultFlashKind.incorrect);
    if (isCorrect) {
      unawaited(_sounds.playCorrect());
    } else {
      unawaited(_sounds.playWrong());
    }

    final String userId = ref.read(activeUserIdProvider) ?? kLocalGuestUserId;
    unawaited(
      _phrases.updateMastery(
        userId: userId,
        phraseId: phrase.id,
        wasCorrect: isCorrect,
      ),
    );

    state = state.copyWith(
      phase: GamePhase.showingResultFlash,
      streak: newStreak,
      maxStreak: newStreak > state.maxStreak ? newStreak : state.maxStreak,
      selectedPhotoIndex: selectedIndex,
      clearSelectedPhoto: timedOutFromTimer,
      resultFlashKind: kind,
      lastPhotoPointsEarned: earned,
      lastPhotoElapsedSeconds: elapsedSeconds,
    );

    _flashDelay?.cancel();
    _flashDelay = Timer(
      const Duration(milliseconds: 1800),
      proceedAfterPhotoFlash,
    );
  }

  void proceedAfterPhotoFlash() {
    if (state.phase != GamePhase.showingResultFlash) return;
    final PhraseModel? phrase = state.currentPhrase;
    if (phrase == null) return;

    List<String> opts;
    int cIdx;
    String? fillDisplay;

    if (state.useFillBlankOnReveal) {
      opts = _buildBlankWordChoices(phrase);
      final List<String> tokens = phrase.exampleTokens;
      final int rawIdx = phrase.blankWordIndex ?? 0;
      final int blankIdx =
          tokens.isEmpty ? 0 : rawIdx.clamp(0, tokens.length - 1);
      final String correctWord =
          tokens.isEmpty ? phrase.meaningUrdu : tokens[blankIdx];
      cIdx = opts.indexWhere((String o) => o == correctWord);
      fillDisplay = _buildFillBlankDisplay(phrase);
    } else {
      opts = _buildMeaningChoices(phrase);
      cIdx = opts.indexWhere((String o) => o == phrase.meaningUrdu);
    }

    state = state.copyWith(
      phase: GamePhase.showingReveal,
      meaningRevealReady: true,
      meaningOptions: opts,
      meaningCorrectIndex: cIdx >= 0 ? cIdx : 0,
      blankWordOptions: state.useFillBlankOnReveal ? opts : const <String>[],
      blankWordCorrectIndex: cIdx >= 0 ? cIdx : 0,
      fillBlankSentenceDisplay: fillDisplay,
      clearSelectedMeaning: true,
    );

    _revealDelay?.cancel();
    _revealDelay = Timer(
      const Duration(milliseconds: 2800),
      _beginMeaningQuizAfterRevealPause,
    );
  }

  void _beginMeaningQuizAfterRevealPause() {
    if (state.phase != GamePhase.showingReveal) return;
    if (!state.meaningRevealReady) return;
    _startMeaningTimer();
    state = state.copyWith(phase: GamePhase.showingMeaningQuiz);
  }

  void startMeaningQuiz() {
    if (state.phase != GamePhase.showingReveal || !state.meaningRevealReady) {
      return;
    }
    _revealDelay?.cancel();
    _revealDelay = null;
    _beginMeaningQuizAfterRevealPause();
  }

  void proceedAfterMeaningExample() {
    _advanceToNextCardOrEnd();
  }

  void _advanceToNextCardOrEnd() {
    final bool last = state.currentIndex >= state.phrases.length - 1;
    _cancelAllTimers();

    if (state.storyMode && state.storyLinesUrdu.isNotEmpty) {
      if (last) {
        state = state.copyWith(
          phase: GamePhase.storyConnector,
          storyConnectorIndex: state.phrases.length,
          clearSelectedMeaning: true,
        );
        return;
      }
      state = state.copyWith(
        phase: GamePhase.storyConnector,
        storyConnectorIndex: state.currentIndex + 1,
        clearSelectedMeaning: true,
      );
      return;
    }

    if (last) {
      unawaited(endSession());
      return;
    }
    state = state.copyWith(
      phase: GamePhase.preparingNextPhotoRound,
      clearSelectedMeaning: true,
    );
  }

  /// Story bridge: intro, between-card lines, or closing beat before summary.
  Future<void> advanceFromStoryConnector() async {
    if (state.phase != GamePhase.storyConnector || _committingNextPhotoRound) {
      return;
    }
    _committingNextPhotoRound = true;
    try {
      final int lineIdx = state.storyConnectorIndex;
      if (lineIdx >= state.phrases.length) {
        await endSession();
        return;
      }
      if (lineIdx > 0) {
        state = state.copyWith(currentIndex: state.currentIndex + 1);
      }
      await _setupCurrentCard();
    } finally {
      _committingNextPhotoRound = false;
    }
  }

  /// Called only from [PhotoCardScreen] after route is visible — advances index then loads photo MCQ.
  Future<void> commitNextPhotoRound() async {
    if (state.phase != GamePhase.preparingNextPhotoRound ||
        _committingNextPhotoRound) {
      return;
    }
    _committingNextPhotoRound = true;
    try {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      await _setupCurrentCard();
    } finally {
      _committingNextPhotoRound = false;
    }
  }

  void submitMeaningAnswer(int index) {
    if (state.phase != GamePhase.showingMeaningQuiz) return;
    if (state.selectedMeaningIndex != null) return;
    final int remainingSnap = state.meaningSecondsRemaining;
    _meaningTicker?.cancel();
    final bool ok = index == state.meaningCorrectIndex;
    _finishMeaningAnswer(
      selectedIndex: index,
      timedOut: false,
      remainingSecs: remainingSnap,
      guessCorrect: ok,
    );
  }

  void onMeaningTimeout() {
    if (state.phase != GamePhase.showingMeaningQuiz) return;
    if (!state.meaningHasTimer) return;
    _meaningTicker?.cancel();

    final int bogus = state.meaningCorrectIndex == 0 ? 1 : 0;

    _finishMeaningAnswer(
      selectedIndex: bogus,
      timedOut: true,
      remainingSecs: 0,
      guessCorrect: false,
    );
  }

  void _finishMeaningAnswer({
    required int selectedIndex,
    required bool timedOut,
    required int remainingSecs,
    required bool guessCorrect,
  }) {
    final PhraseModel? phrase = state.currentPhrase;
    if (phrase == null) return;

    final bool photoCorrect = state.resultFlashKind == ResultFlashKind.correct;
    final int photoElapsed = state.lastPhotoElapsedSeconds;
    final int photoPts = state.lastPhotoPointsEarned;

    final bool meaningCorrect =
        !timedOut && guessCorrect && selectedIndex == state.meaningCorrectIndex;
    if (meaningCorrect) {
      unawaited(_sounds.playCorrect());
    } else {
      unawaited(_sounds.playWrong());
    }

    final int meaningSecsForTier =
        !state.meaningHasTimer && meaningCorrect
            ? ScoringConstants.meaningQuickPlaySeconds - 1
            : remainingSecs;

    final int baseMeaning = ScoringConstants.calculatePoints(
      meaningSecsForTier,
      meaningCorrect,
    );
    final int streakForMultiplier =
        meaningCorrect ? state.streak + 1 : state.streak;
    final int newStreakAfterMeaning = meaningCorrect ? state.streak + 1 : 0;

    final int meaningPts =
        meaningCorrect
            ? ScoringConstants.applyStreakMultiplier(
              baseMeaning,
              streakForMultiplier.clamp(1, 99),
            )
            : 0;

    int meaningSecsUsed = 0;
    if (state.meaningHasTimer) {
      if (timedOut) {
        meaningSecsUsed = state.meaningTotalSeconds;
      } else {
        meaningSecsUsed = (state.meaningTotalSeconds - remainingSecs).clamp(
          0,
          state.meaningTotalSeconds,
        );
      }
    }

    final PhraseRoundResult row = PhraseRoundResult(
      phraseId: phrase.id,
      romanised: phrase.romanised,
      photoGuessCorrect: photoCorrect,
      photoTimeSeconds: photoElapsed,
      photoPointsEarned: photoPts,
      meaningGuessCorrect: meaningCorrect,
      meaningTimeSeconds: meaningSecsUsed,
      meaningPointsEarned: meaningPts,
      totalPointsEarned: photoPts + meaningPts,
    );

    final List<PhraseRoundResult> next = <PhraseRoundResult>[
      ...state.completedRounds,
      row,
    ];
    final int maxSeen =
        newStreakAfterMeaning > state.maxStreak
            ? newStreakAfterMeaning
            : state.maxStreak;

    state = state.copyWith(
      completedRounds: next,
      streak: newStreakAfterMeaning,
      maxStreak: maxSeen,
      selectedMeaningIndex: timedOut ? null : selectedIndex,
      clearSelectedMeaning: timedOut,
    );

    if (timedOut) {
      _advanceToNextCardOrEnd();
    }
  }

  Future<void> endSession() async {
    if (_persistedSession || _endSessionBusy) return;

    final List<PhraseRoundResult> rounds = List<PhraseRoundResult>.from(
      state.completedRounds,
    );
    if (rounds.isEmpty) return;

    final String userId = ref.read(activeUserIdProvider) ?? kLocalGuestUserId;
    _endSessionBusy = true;

    if (kAuthEnabled) {
      await ref
          .read(profileNotifierProvider.notifier)
          .bootstrapRemoteProfileIfMissing();
    }

    final int totalPts = rounds.fold(
      0,
      (int a, PhraseRoundResult r) => a + r.totalPointsEarned,
    );
    final int fullyCorrect =
        rounds
            .where(
              (PhraseRoundResult r) =>
                  r.photoGuessCorrect && r.meaningGuessCorrect,
            )
            .length;

    try {
      final int beforeCount = await _sessions.getTodayCardCount(userId);
      final bool dailyHit = beforeCount + rounds.length >= 5;

      final int xp = ScoringConstants.calculateSessionXp(
        correctCount: fullyCorrect,
        totalCards: rounds.length,
        dailyGoalHit: dailyHit,
      );

      final int coins =
          rounds.fold<int>(
            0,
            (int a, PhraseRoundResult r) =>
                a +
                (r.photoGuessCorrect ? 1 : 0) +
                (r.meaningGuessCorrect ? 1 : 0),
          ) *
          ScoringConstants.coinsPerCorrect;

      final SessionTotals totals = SessionTotals(
        totalPoints: totalPts,
        cardsFullyCorrect: fullyCorrect,
        totalCards: rounds.length,
        sessionXpEarned: xp,
        sessionCoinsEarned: coins,
        dailyGoalBonusApplied: dailyHit,
        perfectSessionBonusApplied:
            rounds.isNotEmpty && fullyCorrect == rounds.length,
        maxStreak: state.maxStreak,
      );

      final SessionModel session = SessionModel(
        id: randomUuidV4(),
        userId: userId,
        mode: state.mode,
        category: state.category,
        totalCards: rounds.length,
        correctCount: fullyCorrect,
        totalPoints: totalPts,
        xpEarned: xp,
        maxStreak: state.maxStreak,
        completedAt: DateTime.now(),
      );

      final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
      for (final PhraseRoundResult r in rounds) {
        final Map<String, dynamic> row = r.toProgressRow(userId: userId);
        final Map<String, dynamic>? mastery =
            await _phrases.getMasteryFieldsForPhrase(
              userId: userId,
              phraseId: r.phraseId,
            );
        if (mastery != null) {
          row.addAll(mastery);
        }
        rows.add(row);
      }

      await _sessions.saveFullSession(session: session, phraseResults: rows);
      _persistedSession = true;

      final ProfileNotifier profile = ref.read(
        profileNotifierProvider.notifier,
      );
      await profile.awardXpAndCoins(xp: xp, coins: coins);
      await profile.syncDayStreak();

      state = state.copyWith(
        sessionTotals: totals,
        phase: GamePhase.sessionComplete,
      );
      unawaited(_sounds.playWin());
      unawaited(_sounds.startAmbientLoop());
    } catch (e) {
      unawaited(_sounds.startAmbientLoop());
      state = state.copyWith(
        phase: GamePhase.error,
        errorMessage: e.toString(),
      );
    } finally {
      _endSessionBusy = false;
    }
  }
}

final NotifierProvider<GameNotifier, GameState> gameNotifierProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
