import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/bottom_inset.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/models/phrase_model.dart';
import '../../data/models/profile_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/card/photo_card.dart';
import '../../widgets/card/reveal_image_card.dart';
import '../../widgets/card/card_flip_animation.dart';
import '../../widgets/common/game_pop_scope.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/mcq/mcq_option_tile.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/streak_badge.dart' as jp;
import '../../widgets/timer/timer_bar.dart';

class RevealCardScreen extends ConsumerWidget {
  const RevealCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState game = ref.watch(gameNotifierProvider);
    final UiStrings s = UiStrings.watch(ref);
    final AsyncValue<ProfileModel?> profile = ref.watch(
      profileNotifierProvider,
    );

    ref.listen<GameState>(gameNotifierProvider, (_, GameState next) {
      if (next.phase == GamePhase.showingPhoto) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/game/photo-card');
        });
      }
      if (next.phase == GamePhase.sessionComplete &&
          next.sessionTotals != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/game/summary');
        });
      }
    });
    ref.listen<int?>(
      gameNotifierProvider.select((GameState g) => g.selectedMeaningIndex),
      (int? previous, int? nextSelected) {
        if (nextSelected == null || previous != null) return;
        final PhraseModel? current =
            ref.read(gameNotifierProvider).currentPhrase;
        if (current == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;
          await showModalBottomSheet<void>(
            context: context,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: AppColors.bgCard,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder:
                (BuildContext c) => Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInsetGap(c)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UrduText(
                        current.exampleSentence.isEmpty
                            ? '—'
                            : current.exampleSentence,
                        style: AppTextStyles.urduBody.copyWith(height: 2.0),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(c).pop(),
                        child: Text(s.summaryStartNextRound),
                      ),
                    ],
                  ),
                ),
          );
          if (!context.mounted) return;
          ref.read(gameNotifierProvider.notifier).proceedAfterMeaningExample();
        });
      },
    );

    switch (game.phase) {
      case GamePhase.idle:
      case GamePhase.loadingPhrases:
      case GamePhase.error:
        return GamePopScope(
          child: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: Text(s.gameBackHome),
              ),
            ),
          ),
        );
      default:
        break;
    }

    final PhraseModel? phrase = game.currentPhrase;
    if (phrase == null && game.phase != GamePhase.sessionComplete) {
      return const GamePopScope(
        child: Scaffold(body: Center(child: Text('—'))),
      );
    }

    if (phrase == null) {
      return const GamePopScope(
        child: Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    final int roundNo = game.currentIndex + 1;
    final int total = game.phrases.length;

    return GamePopScope(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Stack(
          children: <Widget>[
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
                  children: <Widget>[
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
                        Text(s.gameRevealProgress(roundNo, total)),
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
                    if (game.phase == GamePhase.showingReveal ||
                        game.phase == GamePhase.showingMeaningQuiz)
                      CardFlipAnimation(
                        key: ValueKey<String>('flip-${phrase.id}'),
                        frontWidget: PhotoCard(
                          imageUrl: phrase.imageUrl,
                          aspectRatio: 4 / 3,
                          fit: BoxFit.contain,
                        ),
                        backWidget: RevealImageCard(
                          urduPhrase: phrase.urduPhrase,
                          aspectRatio: 4 / 3,
                        ),
                      )
                    else
                      RevealImageCard(
                        urduPhrase: phrase.urduPhrase,
                        aspectRatio: 4 / 3,
                      ),
                    const SizedBox(height: 12),
                    if (game.phase == GamePhase.showingMeaningQuiz) ...<Widget>[
                      if (game.meaningHasTimer)
                        TimerBar(
                          value:
                              game.meaningTotalSeconds == 0
                                  ? 1
                                  : (game.meaningSecondsRemaining /
                                          game.meaningTotalSeconds)
                                      .clamp(0, 1),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        s.gameCoinsInline(profile.valueOrNull?.coins ?? 0),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.gamePickCorrectMeaning,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(game.meaningOptions.length, (int i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _meaningTile(ref, index: i, game: game),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _meaningTile(
  WidgetRef ref, {
  required int index,
  required GameState game,
}) {
  final int? sel = game.selectedMeaningIndex;

  McqTileAppearance appearance = McqTileAppearance.idle;
  VoidCallback? onTap =
      () => ref.read(gameNotifierProvider.notifier).submitMeaningAnswer(index);

  if (sel != null) {
    onTap = null;
    if (index == game.meaningCorrectIndex) {
      appearance = McqTileAppearance.correct;
    } else if (index == sel) {
      appearance = McqTileAppearance.wrong;
    }
  }

  return McqOptionTile(
    label: game.meaningOptions[index],
    appearance: appearance,
    onTap: onTap,
  );
}
