import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/bottom_inset.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/scoring_constants.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/repositories/session_repository.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/session_user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/jp_card.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/xp_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final String? userId = ref.watch(activeUserIdProvider);
    final UiStrings s = UiStrings.watch(ref);

    final int level = profile?.level ?? 1;
    final String tierUr = profile?.levelTitle ?? '';
    final String tierLabel =
        s.isEnglish ? s.levelTitle(level, urUrduTitle: tierUr) : tierUr;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          bottomInsetGap(context, gap: 16),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.hardEdge,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                s.isEnglish
                    ? Text(
                      s.homeTitle,
                      style: AppTextStyles.enTitle.copyWith(fontSize: 26),
                    )
                    : Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(s.homeTitle, style: AppTextStyles.urduTitle),
                    ),
                CoinBadge(amount: profile?.coins ?? 0),
              ],
            ),
            const SizedBox(height: 12),
            JpCard(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: AppColors.bgElevated,
                        child: Text(_avatarFor(profile?.avatarIndex ?? 0)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          profile?.displayName ?? s.playerFallback,
                          style: AppTextStyles.enTitle,
                        ),
                      ),
                      StreakBadge(count: profile?.dayStreak ?? 0),
                    ],
                  ),
                  const SizedBox(height: 14),
                  XpBar(
                    level: level,
                    xpPct: profile?.xpBarFractionWithinCurrentLevel ?? 0,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.levelBarLabel(level: level, localizedTitle: tierLabel),
                    style: AppTextStyles.enCaption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            JpCard(
              glowColor: AppColors.gold,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FutureBuilder<int>(
                  future:
                      userId == null
                          ? Future<int>.value(0)
                          : ref
                              .read(sessionRepositoryProvider)
                              .getTodayCardCount(userId),
                  builder: (context, snap) {
                    final int count = snap.data ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Text('🎯'),
                                const SizedBox(width: 8),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    s.dailyGoalInline.replaceAll(':', ''),
                                    style:
                                        s.isEnglish
                                            ? AppTextStyles.enBody
                                            : AppTextStyles.urduBody,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$count/5',
                              style: AppTextStyles.enBody.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: (count / 5).clamp(0, 1),
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ModeCard(
                  emoji: '⚡',
                  label: s.quickPlay,
                  enSubLabel: s.quickPlay,
                  onTap:
                      () =>
                          _start(context, ref, ScoringConstants.modeQuickPlay),
                ),
                _ModeCard(
                  emoji: '📚',
                  label: s.learnMode,
                  enSubLabel: s.learnMode,
                  onTap: () => _start(context, ref, ScoringConstants.modeLearn),
                ),
                _ModeCard(
                  emoji: '🔥',
                  label: s.speedRound,
                  enSubLabel: s.speedRound,
                  locked: (profile?.level ?? 1) < 5,
                  lockText: s.speedLockedLabel(5),
                  onTap:
                      () =>
                          _start(context, ref, ScoringConstants.modeSpeedRound),
                ),
                _ModeCard(
                  emoji: '📁',
                  label: 'Leaderboard',
                  enSubLabel: 'Top streak + coins',
                  onTap: () => context.go('/leaderboard'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (i) {
          if (i == 1) context.go('/library');
          if (i == 2) context.go('/profile');
          if (i == 0) {}
        },
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    String mode, {
    String? category,
    String? difficulty,
  }) async {
    final String? inputMode = await _askInputMode(context, ref);
    if (inputMode == null) return;
    await ref.read(profileNotifierProvider.notifier).setInputMode(inputMode);
    await ref
        .read(gameNotifierProvider.notifier)
        .startSession(
          mode: mode,
          category: category,
          difficulty: difficulty,
          count: 5,
        );
    if (context.mounted) context.go('/game/photo-card');
  }

  Future<String?> _askInputMode(BuildContext context, WidgetRef ref) async {
    final UiStrings s = UiStrings.watch(ref);
    String selected =
        ref.read(profileNotifierProvider).valueOrNull?.inputMode ?? 'pick';
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext c) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInsetGap(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(s.answerMode, style: AppTextStyles.enBody),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ChoiceChip(
                          label: Text(s.preferPicking),
                          selected: selected == 'pick',
                          onSelected: (_) => setState(() => selected = 'pick'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(s.preferSpeaking),
                          selected: selected == 'speak',
                          onSelected: (_) => setState(() => selected = 'speak'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    child: Text(s.startBtn),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _avatarFor(int index) {
    const avatars = ['😀', '😎', '🤩', '🧠', '🔥', '🌟'];
    return avatars[index % avatars.length];
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji,
    required this.label,
    required this.enSubLabel,
    required this.onTap,
    this.locked = false,
    this.lockText,
  });

  final String emoji;
  final String label;
  final String enSubLabel;
  final VoidCallback onTap;
  final bool locked;
  final String? lockText;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = switch (emoji) {
      '⚡' => AppColors.orange,
      '📚' => AppColors.purple,
      '🔥' => AppColors.wrong,
      _ => AppColors.gold,
    };

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.urduHeadline.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 2),
              if (!locked) Text(enSubLabel, style: AppTextStyles.enCaption),
              if (locked)
                Text(
                  lockText ?? 'Locked',
                  style: AppTextStyles.enCaption.copyWith(
                    color: AppColors.wrong,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
