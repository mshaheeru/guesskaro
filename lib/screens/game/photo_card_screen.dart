import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../core/constants/app_colors.dart';
import '../../core/constants/scoring_constants.dart';
import '../../core/locale/ui_strings.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/services/phrase_guess_judge.dart';
import '../../data/models/phrase_model.dart';
import '../../data/models/profile_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/card/photo_card.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/mcq/mcq_option_tile.dart';
import '../../widgets/common/game_pop_scope.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/streak_badge.dart' as jp;
import '../../widgets/timer/timer_bar.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PhotoCardScreen extends ConsumerWidget {
  const PhotoCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState game = ref.watch(gameNotifierProvider);
    final UiStrings s = UiStrings.watch(ref);
    final AsyncValue<ProfileModel?> profile = ref.watch(
      profileNotifierProvider,
    );

    ref.listen<GameState>(gameNotifierProvider, (_, GameState next) {
      if (next.phase == GamePhase.showingReveal ||
          next.phase == GamePhase.showingMeaningQuiz) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/game/reveal-card');
        });
      }
      if (next.phase == GamePhase.sessionComplete &&
          next.sessionTotals != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/game/summary');
        });
      }
    });

    switch (game.phase) {
      case GamePhase.idle:
      case GamePhase.error:
      case GamePhase.loadingPhrases:
        return GamePopScope(
          child: Scaffold(
            appBar: AppBar(title: Text(s.gameCardTitle)),
            body: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInsetGap(context)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (game.phase == GamePhase.loadingPhrases) ...[
                      const PhraseCardShimmer(),
                      const SizedBox(height: 16),
                    ],
                    if (game.errorMessage != null)
                      ErrorState(
                        message: game.errorMessage!,
                        onRetry:
                            () => ref
                                .read(gameNotifierProvider.notifier)
                                .startSession(
                                  mode: game.mode,
                                  category: game.category,
                                  difficulty: game.difficulty,
                                  count: game.roundCount,
                                ),
                      ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      child: Text(context.canPop() ? s.gameBack : s.gameHome),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      default:
        break;
    }

    final PhraseModel? phrase = game.currentPhrase;
    if (phrase == null) {
      return GamePopScope(
        child: Scaffold(body: Center(child: Text(s.gameNoCard))),
      );
    }

    final int roundNo = game.currentIndex + 1;
    final int total = game.phrases.length;
    final bool speakingMode =
        (profile.valueOrNull?.inputMode ?? 'pick') == 'speak';

    return GamePopScope(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  bottomInsetGap(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          s.gameCardProgress(roundNo, total),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: <Widget>[
                            jp.StreakBadge(count: game.streak),
                            const SizedBox(width: 8),
                            CoinBadge(amount: profile.valueOrNull?.coins ?? 0),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (game.photoHasTimer)
                      TimerBar(
                        value:
                            game.photoTotalSeconds == 0
                                ? 1
                                : (game.photoSecondsRemaining /
                                        game.photoTotalSeconds)
                                    .clamp(0, 1),
                      ),
                    if (game.photoHasTimer && game.photoFrozen)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '❄️ Frozen',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    const SizedBox(height: 12),
                    PhotoCard(
                      imageUrl: phrase.imageUrl,
                      aspectRatio: 4 / 3,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        speakingMode
                            ? s.gameSpeakPhrasePrompt
                            : s.gamePickCorrectPhrase,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!speakingMode)
                      ...List.generate(game.photoOptions.length, (int i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _photoMcqTile(ref, index: i, game: game),
                        );
                      })
                    else
                      _VoiceGuessPanel(
                        phrase: phrase,
                        disabled: game.phase != GamePhase.showingPhoto,
                      ),
                    const SizedBox(height: 8),
                    if (!speakingMode) _HintButtonsRow(game: game),
                  ],
                ),
              ),
            ),
            if (game.phase == GamePhase.showingResultFlash)
              _PhotoResultFlash(game: game, s: s),
          ],
        ),
      ),
    );
  }
}

class _VoiceGuessPanel extends ConsumerStatefulWidget {
  const _VoiceGuessPanel({required this.phrase, required this.disabled});

  final PhraseModel phrase;
  final bool disabled;

  @override
  ConsumerState<_VoiceGuessPanel> createState() => _VoiceGuessPanelState();
}

class _VoiceGuessPanelState extends ConsumerState<_VoiceGuessPanel> {
  final SpeechToText _speech = SpeechToText();
  bool _listening = false;
  bool _checking = false;
  String _heardText = '';
  bool _isFinalizing = false;
  bool _speechInitialized = false;
  String? _urduLocaleId;
  Timer? _listenWatchdog;

  @override
  void didUpdateWidget(covariant _VoiceGuessPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phrase.id != widget.phrase.id) {
      _hardResetListeningState();
    }
  }

  @override
  void dispose() {
    _listenWatchdog?.cancel();
    _speech.stop();
    super.dispose();
  }

  Future<void> _hardResetListeningState() async {
    _listenWatchdog?.cancel();
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _checking = false;
      _heardText = '';
      _isFinalizing = false;
    });
  }

  Future<String?> _resolveUrduLocale() async {
    if (_urduLocaleId != null) return _urduLocaleId;
    final List<LocaleName> locales = await _speech.locales();
    final LocaleName? urdu = locales.cast<LocaleName?>().firstWhere(
      (LocaleName? l) => l != null && l.localeId.toLowerCase().startsWith('ur'),
      orElse: () => null,
    );
    _urduLocaleId = urdu?.localeId;
    return _urduLocaleId;
  }

  Future<void> _toggleRecordAndCheck() async {
    if (_checking || widget.disabled) return;
    if (_listening) {
      _listenWatchdog?.cancel();
      await _speech.stop();
      if (mounted) {
        setState(() => _listening = false);
      }
      await _finalizeAndCheck();
      return;
    }
    if (!_speechInitialized) {
      final bool available = await _speech.initialize(
        onStatus: (String status) async {
          if (!mounted) return;
          debugPrint('stt-status: $status');
          if (status == 'done' || status == 'notListening') {
            _listenWatchdog?.cancel();
            await _finalizeAndCheck();
          }
        },
        onError: (error) {
          if (!mounted) return;
          debugPrint('stt-error: ${error.errorMsg}');
          setState(() {
            _listening = false;
          });
          _isFinalizing = false;
        },
      );
      _speechInitialized = available;
      if (!available) return;
    }
    final String? localeId = await _resolveUrduLocale();
    setState(() {
      _listening = true;
      _heardText = '';
      _isFinalizing = false;
    });
    debugPrint(
      localeId == null ? 'stt-locale: default' : 'stt-locale: $localeId',
    );
    await _speech.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (result) {
        final String words = result.recognizedWords.trim();
        if (!mounted || words.isEmpty) return;
        setState(() {
          _heardText = words;
        });
        if (result.finalResult) {
          debugPrint('stt-result: final');
          _listenWatchdog?.cancel();
          _finalizeAndCheck();
        }
      },
    );
    _listenWatchdog?.cancel();
    _listenWatchdog = Timer(const Duration(seconds: 12), () async {
      debugPrint('stt-watchdog: force finalize');
      if (_listening) {
        await _speech.stop();
        if (mounted) {
          setState(() => _listening = false);
        }
        await _finalizeAndCheck();
      }
    });
  }

  Future<void> _finalizeAndCheck() async {
    if (_isFinalizing) return;
    _isFinalizing = true;
    if (!mounted) return;
    setState(() => _listening = false);
    if (_heardText.isEmpty) {
      _isFinalizing = false;
      return;
    }
    setState(() => _checking = true);
    final decision = await ref
        .read(phraseGuessJudgeProvider)
        .evaluateGuess(
          spokenText: _heardText,
          correctPhrase: widget.phrase.urduPhrase,
        );
    if (!mounted) return;
    ref
        .read(gameNotifierProvider.notifier)
        .submitPhotoSpokenGuess(isCorrect: decision.isCorrect);
    setState(() {
      _checking = false;
    });
    debugPrint('voice-eval-source: ${decision.source}');
    _isFinalizing = false;
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            _heardText.isEmpty ? '...' : '${s.gameRecognizedText}: $_heardText',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed:
                widget.disabled || _checking ? null : _toggleRecordAndCheck,
            icon: Icon(_listening ? Icons.graphic_eq : Icons.mic_rounded),
            label: Text(
              _checking
                  ? '...'
                  : _listening
                  ? '${s.gameListening} (tap to stop)'
                  : s.gameTapToSpeak,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.gameTapAgainIfNeeded,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _HintButtonsRow extends ConsumerWidget {
  const _HintButtonsRow({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.wrong.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.wrong.withValues(alpha: 0.40),
                width: 1.5,
              ),
            ),
            child: TextButton(
              onPressed:
                  game.phase == GamePhase.showingPhoto && !game.eliminateUsed
                      ? () =>
                          ref
                              .read(gameNotifierProvider.notifier)
                              .useEliminateHint()
                      : null,
              child: Text(
                '➖ Eliminate (${ScoringConstants.eliminateHintCost}🪙)',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.wrong),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF64C8FF).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF64C8FF).withValues(alpha: 0.40),
                width: 1.5,
              ),
            ),
            child: TextButton(
              onPressed:
                  game.phase == GamePhase.showingPhoto &&
                          !game.freezeUsed &&
                          game.photoHasTimer
                      ? () =>
                          ref
                              .read(gameNotifierProvider.notifier)
                              .useFreezeHint()
                      : null,
              child: Text(
                '❄️ Freeze (${ScoringConstants.freezeHintCost}🪙)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64C8FF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _photoMcqTile(
  WidgetRef ref, {
  required int index,
  required GameState game,
}) {
  McqTileAppearance appearance = McqTileAppearance.idle;
  VoidCallback? onTap;

  if (game.phase == GamePhase.showingPhoto) {
    if (game.eliminatedPhotoIndices.contains(index)) {
      appearance = McqTileAppearance.eliminated;
      onTap = null;
    } else {
      onTap =
          () =>
              ref.read(gameNotifierProvider.notifier).submitPhotoAnswer(index);
    }
  } else if (game.phase == GamePhase.showingResultFlash) {
    onTap = null;
    final int? sel = game.selectedPhotoIndex;
    if (index == game.photoCorrectIndex) {
      appearance = McqTileAppearance.correct;
    } else if (game.resultFlashKind == ResultFlashKind.timeout) {
      appearance = McqTileAppearance.idle;
    } else if (sel != null && sel == index) {
      appearance = McqTileAppearance.wrong;
    } else {
      appearance = McqTileAppearance.idle;
    }
  }

  return McqOptionTile(
    label: game.photoOptions[index],
    appearance: appearance,
    onTap: onTap,
  );
}

class _PhotoResultFlash extends StatelessWidget {
  const _PhotoResultFlash({required this.game, required this.s});

  final GameState game;
  final UiStrings s;

  @override
  Widget build(BuildContext context) {
    final ResultFlashKind? k = game.resultFlashKind;

    IconData icon;
    Color fg;
    String title;

    switch (k) {
      case ResultFlashKind.correct:
        icon = Icons.check_circle_rounded;
        fg = AppColors.correct;
        title = s.resultCorrect;
        break;
      case ResultFlashKind.incorrect:
        icon = Icons.cancel_rounded;
        fg = AppColors.wrong;
        title = s.resultIncorrect;
        break;
      case ResultFlashKind.timeout:
        icon = Icons.timer_off_rounded;
        fg = AppColors.timerRed;
        title = s.resultTimeout;
        break;
      case null:
        icon = Icons.help_outline;
        fg = Colors.white;
        title = '';
        break;
    }

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: fg.withValues(alpha: 0.18),
              child: Icon(icon, color: fg, size: 48),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (game.lastPhotoPointsEarned > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${game.lastPhotoPointsEarned}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
