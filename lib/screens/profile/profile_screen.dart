import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_config.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/constants/urdu_utils.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/local_guest_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/session_user_provider.dart';
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/jp_button_ghost.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/urdu_text.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final profileAsync = ref.watch(profileNotifierProvider);
    final String? userId = ref.watch(activeUserIdProvider);
    final UiStrings s = UiStrings.watch(ref);

    final int level = profile?.level ?? 1;
    final String tierUr = profile?.levelTitle ?? '';
    final String tierLabel =
        s.isEnglish ? s.levelTitle(level, urUrduTitle: tierUr) : tierUr;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: RefreshIndicator(
        onRefresh:
            () => ref.read(profileNotifierProvider.notifier).refreshProfile(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInsetGap(context)),
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            if (profileAsync.hasError) ...[
              ErrorState(
                message: s.profileLoadFailed,
                onRetry:
                    () =>
                        ref
                            .read(profileNotifierProvider.notifier)
                            .refreshProfile(),
              ),
            ] else if (profileAsync.isLoading) ...[
              const ProfileShimmer(),
            ] else if (profile == null) ...[
              EmptyState(
                message:
                    s.isEnglish
                        ? 'No profile yet. Play as guest or sign in first.'
                        : 'ابھی پروفائل موجود نہیں۔ پہلے مہمان کے طور پر کھیلیں یا سائن اِن کریں۔',
                emoji: '👤',
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[AppColors.bgElevated, Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.orangeDim,
                        border: Border.all(color: AppColors.orange, width: 3),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: AppColors.orangeGlow,
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _avatar(profile.avatarIndex),
                          style: const TextStyle(fontSize: 38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(profile.displayName, style: AppTextStyles.enTitle),
                    Text(
                      tierLabel,
                      style:
                          s.isEnglish
                              ? AppTextStyles.enBody.copyWith(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                )
                              : AppTextStyles.urduBody.copyWith(
                                  color: AppColors.orange,
                                ),
                    ),
                    const SizedBox(height: 16),
                    XpBar(
                      level: level,
                      xpPct: profile.xpBarFractionWithinCurrentLevel,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.xp} / ${profile.xp + profile.xpForNextLevel} XP to next level',
                      style: AppTextStyles.enCaption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      s,
                      emoji: '🔥',
                      valueRaw: profile.dayStreak,
                      label: s.statStreak,
                      color: AppColors.orange,
                    ),
                  ),
                  Expanded(
                    child: _stat(
                      s,
                      emoji: '🏆',
                      valueRaw: profile.longestStreak,
                      label: s.statBest,
                      color: AppColors.gold,
                    ),
                  ),
                  Expanded(
                    child: _stat(
                      s,
                      emoji: '🪙',
                      valueRaw: profile.coins,
                      label: s.statCoins,
                      color: AppColors.gold,
                    ),
                  ),
                  Expanded(
                    child: _stat(
                      s,
                      emoji: '✅',
                      valueRaw: 87,
                      label: s.statCorrectRate,
                      color: AppColors.correct,
                      suffix: '%',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              s.recentSessions,
              style: AppTextStyles.enTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<SessionModel>>(
              future:
                  userId == null
                      ? Future<List<SessionModel>>.value(const [])
                      : ref
                          .read(sessionRepositoryProvider)
                          .getRecentSessions(userId: userId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Column(
                    children: [
                      SessionRowShimmer(),
                      SessionRowShimmer(),
                      SessionRowShimmer(),
                    ],
                  );
                }
                final rows = snap.data ?? const <SessionModel>[];
                if (rows.isEmpty) {
                  return EmptyState(message: s.emptySessions, emoji: '🗂️');
                }
                return Column(
                  children:
                      rows
                          .map(
                            (sess) => ListTile(
                              tileColor: AppColors.bgCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              title:
                                  s.isEnglish
                                      ? Text(
                                        s.sessionModeDisplay(sess.mode),
                                        style: AppTextStyles.enBody.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      )
                                      : UrduText(
                                        s.sessionModeDisplay(sess.mode),
                                        style: AppTextStyles.urduBody.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                              subtitle: Text(
                                '${sess.completedAt.toLocal()}'
                                    .split('.')
                                    .first,
                                maxLines: 1,
                                style: AppTextStyles.enCaption,
                              ),
                              trailing: Text(
                                _pointsLine(s, sess),
                                style: AppTextStyles.enBody.copyWith(
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 14),
            JpButtonGhost(
              label: s.signOut,
              onPressed: () => _signOut(context, ref, s),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        labelHome: s.navHome,
        labelProfile: s.navProfile,
        labelSettings: s.navSettings,
        onTap: (int i) => navigateMainBottomTab(context, i),
      ),
    );
  }

  String _pointsLine(UiStrings s, SessionModel sess) {
    final int pct = sess.accuracy.round();
    final int pts = sess.totalPoints;
    if (s.isEnglish) {
      return '$pts ($pct%)';
    }
    return '${toUrduNumerals(pts)} (${toUrduNumerals(pct)}%)';
  }

  Widget _stat(
    UiStrings s, {
    required String emoji,
    required int valueRaw,
    required String label,
    required Color color,
    String suffix = '',
  }) {
    final String value = s.isEnglish ? '$valueRaw' : toUrduNumerals(valueRaw);
    return Card(
      color: AppColors.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            Text(
              '$value$suffix',
              style: AppTextStyles.enTitle.copyWith(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.enCaption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _avatar(int i) {
    const avatars = ['😀', '😎', '🤩', '🧠', '🔥', '🌟'];
    return avatars[i % avatars.length];
  }

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
    UiStrings s,
  ) async {
    final bool ok =
        await showDialog<bool>(
          context: context,
          builder:
              (c) => AlertDialog(
                title: Text(s.signOutConfirmTitle),
                content: Text(s.signOutConfirmBody(remoteAuth: kAuthEnabled)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(c).pop(false),
                    child: Text(s.no),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(c).pop(true),
                    child: Text(s.yes),
                  ),
                ],
              ),
        ) ??
        false;
    if (!ok) return;

    if (kAuthEnabled) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) context.go('/sign-in');
    } else {
      await ref.read(localProfileRepositoryProvider).clearGuestData();
      ref.invalidate(localGuestRegisteredProvider);
      ref.invalidate(profileNotifierProvider);
      if (context.mounted) context.go('/welcome');
    }
  }
}
