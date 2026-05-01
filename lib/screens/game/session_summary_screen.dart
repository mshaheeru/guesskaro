import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/bottom_inset.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/level_up_overlay.dart';
import '../../widgets/common/game_pop_scope.dart';
import '../../widgets/jp_button_ghost.dart';
import '../../widgets/jp_button_primary.dart';
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
                        ? Text(
                            game.errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          )
                        : const CircularProgressIndicator.adaptive(),
                  )
                : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInsetGap(context)),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const Center(child: Text('🏆', style: TextStyle(fontSize: 48))),
                Directionality(
                  textDirection: s.isEnglish ? TextDirection.ltr : TextDirection.rtl,
                  child: s.isEnglish
                      ? Text(
                          'Session Complete!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.enTitle.copyWith(fontSize: 28),
                        )
                      : Text(
                          'سیشن مکمل!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.urduTitle,
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.summaryTotalScore(totals.totalPoints),
                  style: AppTextStyles.enDisplay.copyWith(fontSize: 42),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  s.summaryFullyCorrect(
                    totals.cardsFullyCorrect,
                    totals.totalCards,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    _SummaryStatCard(
                      icon: '✅',
                      label: 'Correct',
                      value: '${totals.cardsFullyCorrect}/${totals.totalCards}',
                      color: AppColors.correct,
                    ),
                    const SizedBox(width: 10),
                    _SummaryStatCard(
                      icon: '⭐',
                      label: 'XP Earned',
                      value: '+${totals.sessionXpEarned}',
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 10),
                    _SummaryStatCard(
                      icon: '🎯',
                      label: 'Accuracy',
                      value:
                          '${((totals.cardsFullyCorrect / totals.totalCards) * 100).round()}%',
                      color: AppColors.purple,
                    ),
                  ],
                ),
                if (p != null) ...[
                  const SizedBox(height: 20),
                  XpBar(
                    level: p.level,
                    xpPct: p.xpBarFractionWithinCurrentLevel,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  s.summaryPerPhraseResult,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...game.completedRounds.map(
                  (PhraseRoundResult r) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            r.romanised,
                            style: AppTextStyles.urduBody,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text(r.photoGuessCorrect && r.meaningGuessCorrect ? '✅' : '❌'),
                            const SizedBox(width: 6),
                            Text(
                              '+${r.totalPointsEarned}',
                              style: AppTextStyles.enBody.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (totals.totalCards > 0)
                  Text(
                    s.summaryXpCoins(
                      totals.sessionXpEarned,
                      totals.sessionCoinsEarned,
                    ),
                    style: AppTextStyles.enBody.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                JpButtonPrimary(
                  label: s.summaryStartNextRound,
                  onPressed: () async {
                    await ref.read(gameNotifierProvider.notifier).resetSession();
                    await ref.read(gameNotifierProvider.notifier).startSession(
                          mode: game.mode,
                          category: game.category,
                          difficulty: game.difficulty,
                          count: game.roundCount,
                        );
                    if (context.mounted) {
                      context.go('/game/photo-card');
                    }
                  },
                ),
                const SizedBox(height: 8),
                JpButtonGhost(
                  label: s.gameHome,
                  onPressed: () async {
                    ref.read(levelUpProvider.notifier).state = false;
                    await ref.read(gameNotifierProvider.notifier).resetSession();
                    if (context.mounted) context.go('/home');
                  },
                ),
              ],
            ),
            if (ref.watch(levelUpProvider) && p != null)
              LevelUpOverlay(
                level: p.level,
                levelTitle: s.levelTitle(p.level, urUrduTitle: p.levelTitle),
                titleText: s.levelUpTitle,
                continueText: s.levelUpContinue,
                onDismiss: () => ref.read(levelUpProvider.notifier).state = false,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.enTitle.copyWith(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.enLabel.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
