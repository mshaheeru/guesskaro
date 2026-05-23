import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/bottom_inset.dart';
import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/scoring_constants.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/jp_card.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/home/game_instructions_sheet.dart';
import '../../widgets/home/home_mastery_strip.dart';
import '../../widgets/common/jp_pressable.dart';
import '../../widgets/common/jp_screen_background.dart';
import '../../widgets/common/urdu_text.dart';
import '../../providers/reverse_mode_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final UiStrings s = UiStrings.watch(ref);
    final AsyncValue<bool> reverseUnlocked = ref.watch(reverseModeUnlockedProvider);
    final bool reverseReady = reverseUnlocked.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: JpScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    s.isEnglish
                        ? Text(
                            s.homeTitle,
                            style: AppTextStyles.enTitle.copyWith(fontSize: 26),
                          )
                        : UrduText(
                            s.homeTitle,
                            style: AppTextStyles.urduTitle,
                            textAlign: TextAlign.start,
                          ),
                    CoinBadge(amount: profile?.coins ?? 0),
                  ],
                ),
                const SizedBox(height: 8),
                JpCard(
                  child: Row(
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
                ),
                const SizedBox(height: 12),
                const HomeMasteryStrip(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    s.homeModesSection,
                    style: AppTextStyles.enLabel.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.only(
                      bottom: bottomNavScrollPadding(context, gap: 8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _HomeModeGrid(
                          s: s,
                          reverseReady: reverseReady,
                          onQuickPlay:
                              () => _start(
                                context,
                                ref,
                                ScoringConstants.modeQuickPlay,
                              ),
                          onStory: () => context.push('/story'),
                          onReverse:
                              reverseReady
                                  ? () => _start(
                                        context,
                                        ref,
                                        ScoringConstants.modeReverse,
                                      )
                                  : () => _showReverseLocked(context, s),
                          onLibrary: () => context.push('/library'),
                          onLeaderboard: () => context.go('/leaderboard'),
                          onMeetActors: () => context.go('/meet-actors'),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            onPressed:
                                () => showGameInstructionsSheet(
                                  context,
                                  strings: s,
                                ),
                            icon: const Icon(Icons.help_outline_rounded, size: 18),
                            label: Text(s.homeHowToPlayLink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    int count = 5,
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
          count: count,
        );
    if (context.mounted) context.go('/game/photo-card');
  }

  void _showReverseLocked(BuildContext context, UiStrings s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: s.isEnglish
            ? Text(s.reverseModeLocked)
            : UrduText(
                s.reverseModeLocked,
                style: AppTextStyles.urduBody,
                textAlign: TextAlign.start,
              ),
      ),
    );
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

class _HomeModeGrid extends StatelessWidget {
  const _HomeModeGrid({
    required this.s,
    required this.reverseReady,
    required this.onQuickPlay,
    required this.onStory,
    required this.onReverse,
    required this.onLibrary,
    required this.onLeaderboard,
    required this.onMeetActors,
  });

  final UiStrings s;
  final bool reverseReady;
  final VoidCallback onQuickPlay;
  final VoidCallback onStory;
  final VoidCallback onReverse;
  final VoidCallback onLibrary;
  final VoidCallback onLeaderboard;
  final VoidCallback onMeetActors;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.12,
      children: <Widget>[
        _ModeTile(
          isEnglish: s.isEnglish,
          emoji: '⚡',
          accentColor: AppColors.modeQuick,
          label: s.quickPlay,
          enSubLabel: s.quickPlay,
          onTap: onQuickPlay,
        ),
        _ModeTile(
          isEnglish: s.isEnglish,
          emoji: '📖',
          accentColor: AppColors.teal,
          label: s.homeStoryModeTile,
          enSubLabel: s.homeStoryModeSubtitle,
          onTap: onStory,
        ),
        _ModeTile(
          isEnglish: s.isEnglish,
          emoji: '🔄',
          accentColor: AppColors.modeSpeed,
          label: s.homeReverseModeTile,
          enSubLabel: s.homeReverseModeSubtitle,
          isLocked: !reverseReady,
          lockedMessage: s.reverseModeLocked,
          onTap: onReverse,
        ),
        _ModeTile(
          isEnglish: s.isEnglish,
          emoji: '📚',
          accentColor: AppColors.purple,
          label: s.homeLibraryTile,
          enSubLabel: s.homeLibrarySubtitle,
          onTap: onLibrary,
        ),
        _ModeTile(
          isEnglish: s.isEnglish,
          emoji: '📁',
          accentColor: AppColors.modeCategory,
          label: s.leaderboardHomeTile,
          enSubLabel: s.leaderboardTileSubtitle,
          onTap: onLeaderboard,
        ),
        _ModeTile(
          isEnglish: s.isEnglish,
          emoji: '👋',
          leadingAssetPath: 'assets/images/hi.png',
          accentColor: AppColors.modeLearn,
          label: s.meetActorsCardTitle,
          enSubLabel: s.meetActorsCardSubtitle,
          onTap: onMeetActors,
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.isEnglish,
    required this.emoji,
    required this.label,
    required this.enSubLabel,
    required this.onTap,
    required this.accentColor,
    this.leadingAssetPath,
    this.isLocked = false,
    this.lockedMessage,
  });

  final bool isEnglish;
  final String emoji;
  final String? leadingAssetPath;
  final Color accentColor;
  final String label;
  final String enSubLabel;
  final VoidCallback onTap;
  final bool isLocked;
  final String? lockedMessage;

  @override
  Widget build(BuildContext context) {
    final Widget iconBox = _buildIconBox();

    final Widget content = Opacity(
      opacity: isLocked ? 0.45 : 1,
      child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          iconBox,
          SizedBox(height: AppSpacing.gapS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              isEnglish
                  ? Text(
                    label,
                    style: AppTextStyles.enTitle.copyWith(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                  : UrduText(
                    label,
                    style: AppTextStyles.urduHeadline.copyWith(fontSize: 16),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              const SizedBox(height: 4),
              isLocked && lockedMessage != null
                  ? (isEnglish
                      ? Text(
                          lockedMessage!,
                          style: AppTextStyles.enCaption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : UrduText(
                          lockedMessage!,
                          style: AppTextStyles.urduCaption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ))
                  : Text(
                      enSubLabel,
                      style: AppTextStyles.enCaption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ],
      ),
    ),
    );

    if (AppColors.isSunny) {
      return JpPressable(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppBorders.tile,
            border: AppBorders.ink(),
            boxShadow: AppShadows.lg,
          ),
          child: content,
        ),
      );
    }

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppSpacing.rTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.rTile),
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _buildIconBox() {
    final Widget iconChild =
        leadingAssetPath != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.rIconBox),
              child: Image.asset(
                leadingAssetPath!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, Object __, StackTrace? ___) => Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
              ),
            )
            : Text(emoji, style: const TextStyle(fontSize: 22));

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(AppSpacing.rIconBox),
        border:
            AppColors.isSunny
                ? AppBorders.ink(width: AppBorders.bThin)
                : Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: iconChild,
    );
  }
}
