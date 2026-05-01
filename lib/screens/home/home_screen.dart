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
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/jp_card.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/home/game_instructions_sheet.dart';
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
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            64,
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
            const SizedBox(height: 8),
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
                  const SizedBox(height: 10),
                  XpBar(
                    level: level,
                    xpPct: profile?.xpBarFractionWithinCurrentLevel ?? 0,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.levelBarLabel(level: level, localizedTitle: tierLabel),
                    style: AppTextStyles.enCaption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            JpCard(
              glowColor: AppColors.gold,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        const SizedBox(height: 6),
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
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _ModeCard(
                  emoji: '⚡',
                  label: s.quickPlay,
                  enSubLabel: s.quickPlay,
                  onTap:
                      () =>
                          _start(context, ref, ScoringConstants.modeQuickPlay),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                _ModeCard(
                  emoji: '📁',
                  label: s.leaderboardHomeTile,
                  enSubLabel: s.leaderboardTileSubtitle,
                  onTap: () => context.go('/leaderboard'),
                ),
                const SizedBox(height: 8),
                _ModeCard(
                  emoji: '📖',
                  label: s.helpInstructionsCardTitle,
                  enSubLabel: s.helpInstructionsCardSubtitle,
                  onTap: () =>
                      showGameInstructionsSheet(context, strings: s),
                ),
                const SizedBox(height: 8),
                _ModeCard(
                  emoji: '👋',
                  leadingAssetPath: 'assets/images/hi.png',
                  accentColor: AppColors.purple,
                  label: s.meetActorsCardTitle,
                  enSubLabel: s.meetActorsCardSubtitle,
                  onTap: () => context.go('/meet-actors'),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        labelHome: s.navHome,
        labelProfile: s.navProfile,
        labelSettings: s.navSettings,
        onTap: (int i) => navigateMainBottomTab(context, i),
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
    this.leadingAssetPath,
    this.accentColor,
    this.locked = false,
    this.lockText,
  });

  final String emoji;
  final String? leadingAssetPath;
  final Color? accentColor;
  final String label;
  final String enSubLabel;
  final VoidCallback onTap;
  final bool locked;
  final String? lockText;

  @override
  Widget build(BuildContext context) {
    final Color resolvedAccent =
        accentColor ??
        switch (emoji) {
          '⚡' => AppColors.orange,
          '🔥' => AppColors.wrong,
          _ => AppColors.gold,
        };

    final Widget leading =
        leadingAssetPath != null
            ? SizedBox(
              width: 36,
              height: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  leadingAssetPath!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, Object __, StackTrace? ___) => ColoredBox(
                        color: resolvedAccent.withValues(alpha: 0.15),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                ),
              ),
            )
            : Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: resolvedAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 19)),
              ),
            );

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      label,
                      style: AppTextStyles.urduHeadline.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    if (!locked)
                      Text(
                        enSubLabel,
                        style: AppTextStyles.enCaption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (locked)
                      Text(
                        lockText ?? 'Locked',
                        style: AppTextStyles.enCaption.copyWith(
                          color: AppColors.wrong,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
