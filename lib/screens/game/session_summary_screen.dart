import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/scoring_constants.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/level_up_overlay.dart';
import '../../widgets/common/game_pop_scope.dart';
import '../../widgets/jp_button_ghost.dart';
import '../../widgets/jp_button_primary.dart';
import '../../widgets/jp_card.dart';
import '../../widgets/xp_bar.dart';

class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState game = ref.watch(gameNotifierProvider);
    final UiStrings s = UiStrings.watch(ref);
    final profile = ref.watch(profileNotifierProvider);
    final p = profile.valueOrNull;
    final SessionTotals? totals = game.sessionTotals;

    return GamePopScope(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Stack(
          children: [
            totals == null
                ? Center(
                    child: game.errorMessage != null
                        ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            game.errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : const CircularProgressIndicator.adaptive(),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          bottomInsetGap(context, gap: 24),
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      onPressed:
                                          () => Navigator.of(context).maybePop(),
                                      icon: const Icon(Icons.arrow_back_rounded),
                                    ),
                                  ),
                                  _SummaryHeroSection(
                                    s: s,
                                    totals: totals,
                                  ),
                                  const SizedBox(height: 16),
                                  _SummaryStatGrid(totals: totals),
                                  if (p != null) ...<Widget>[
                                    const SizedBox(height: 18),
                                    JpCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Text(
                                            s.isEnglish ? 'Progress' : 'پیشرفت',
                                            style:
                                                AppTextStyles.enCaption.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 12),
                                          XpBar(
                                            level: p.level,
                                            xpPct:
                                                p.xpBarFractionWithinCurrentLevel,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 22),
                                  Text(
                                    s.summaryPerPhraseResult,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  ...game.completedRounds.map(
                                    (PhraseRoundResult r) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _RoundResultTile(result: r),
                                    ),
                                  ),
                                  if (totals.totalCards > 0)
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                      child: Text(
                                        s.summaryXpCoins(
                                          totals.sessionXpEarned,
                                          totals.sessionCoinsEarned,
                                        ),
                                        style: AppTextStyles.enBody.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  JpButtonPrimary(
                                    label: s.summaryStartNextRound,
                                    onPressed: () async {
                                      final String nextMode =
                                          ScoringConstants.sanitizeGameMode(
                                            game.mode,
                                          );
                                      await ref
                                          .read(gameNotifierProvider.notifier)
                                          .resetSession();
                                      await ref
                                          .read(gameNotifierProvider.notifier)
                                          .startSession(
                                            mode: nextMode,
                                            category: game.category,
                                            difficulty: game.difficulty,
                                            count: game.roundCount,
                                          );
                                      if (context.mounted) {
                                        context.go('/game/photo-card');
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  JpButtonGhost(
                                    label: s.gameHome,
                                    onPressed: () async {
                                      ref
                                          .read(levelUpProvider.notifier)
                                          .state = false;
                                      await ref
                                          .read(gameNotifierProvider.notifier)
                                          .resetSession();
                                      if (context.mounted) {
                                        context.go('/home');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            if (ref.watch(levelUpProvider) && p != null)
              LevelUpOverlay(
                level: p.level,
                levelTitle: s.levelTitle(p.level, urUrduTitle: p.levelTitle),
                titleText: s.levelUpTitle,
                continueText: s.levelUpContinue,
                onDismiss:
                    () => ref.read(levelUpProvider.notifier).state = false,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeroSection extends StatelessWidget {
  const _SummaryHeroSection({required this.s, required this.totals});

  final UiStrings s;
  final SessionTotals totals;

  @override
  Widget build(BuildContext context) {
    return JpCard(
      glowColor: AppColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            '🏆',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 44),
          ),
          const SizedBox(height: 6),
          Directionality(
            textDirection: s.isEnglish ? TextDirection.ltr : TextDirection.rtl,
            child: s.isEnglish
                ? Text(
                    'Session complete!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.enTitle.copyWith(fontSize: 22),
                  )
                : Text(
                    'سیشن مکمل!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.urduTitle,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            s.summaryTotalScore(totals.totalPoints),
            style: AppTextStyles.enDisplay.copyWith(
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            s.summaryFullyCorrect(
              totals.cardsFullyCorrect,
              totals.totalCards,
            ),
            style: AppTextStyles.enBody.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryStatGrid extends StatelessWidget {
  const _SummaryStatGrid({required this.totals});

  final SessionTotals totals;

  @override
  Widget build(BuildContext context) {
    final int pct = totals.totalCards > 0
        ? ((totals.cardsFullyCorrect / totals.totalCards) * 100).round()
        : 0;
    final List<Widget> tiles = <Widget>[
      _SummaryMiniStatCard(
        icon: '✅',
        label: 'Correct',
        value: '${totals.cardsFullyCorrect}/${totals.totalCards}',
        color: AppColors.correct,
      ),
      _SummaryMiniStatCard(
        icon: '⭐',
        label: 'XP earned',
        value: '+${totals.sessionXpEarned}',
        color: AppColors.gold,
      ),
      _SummaryMiniStatCard(
        icon: '🎯',
        label: 'Accuracy',
        value: '$pct%',
        color: AppColors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 400;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                tiles.map((Widget w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)).toList(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: tiles[0]),
            const SizedBox(width: 10),
            Expanded(child: tiles[1]),
            const SizedBox(width: 10),
            Expanded(child: tiles[2]),
          ],
        );
      },
    );
  }
}

class _SummaryMiniStatCard extends StatelessWidget {
  const _SummaryMiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final String icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.enTitle.copyWith(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.enLabel.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundResultTile extends StatelessWidget {
  const _RoundResultTile({required this.result});

  final PhraseRoundResult result;

  @override
  Widget build(BuildContext context) {
    final bool ok = result.photoGuessCorrect && result.meaningGuessCorrect;
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result.romanised,
                style: AppTextStyles.enBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '+${result.totalPointsEarned}',
              style: AppTextStyles.enBody.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
