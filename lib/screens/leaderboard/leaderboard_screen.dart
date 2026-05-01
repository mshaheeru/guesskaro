import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/jp_card.dart';

bool _isAnonymousLeaderboardUser(User user) {
  if (user.isAnonymous) {
    return true;
  }
  final String? email = user.email?.trim();
  return email == null || email.isEmpty;
}

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiStrings s = UiStrings.watch(ref);
    final AsyncValue<LeaderboardScreenData> leaderboard = ref.watch(
      leaderboardScreenDataProvider,
    );
    final user = ref.watch(currentUserProvider);
    final bool guestGlobalBoard =
        kAuthEnabled &&
        (user == null || _isAnonymousLeaderboardUser(user));

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
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text(
                  'Leaderboard',
                  style: AppTextStyles.enTitle.copyWith(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (guestGlobalBoard) _GuestLeaderboardBanner(s: s),
            if (guestGlobalBoard) const SizedBox(height: 12),
            leaderboard.when(
              data: (LeaderboardScreenData data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (data.you != null) _MyRankCard(entry: data.you!),
                    if (data.you != null) const SizedBox(height: 12),
                    if (data.top.isEmpty)
                      const _EmptyLeaderboard()
                    else
                      Column(
                        children: data.top
                            .map((LeaderboardEntryModel row) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _LeaderboardRow(entry: row),
                              );
                            })
                            .toList(growable: false),
                      ),
                  ],
                );
              },
              loading:
                  () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
              error: (_, __) => const _EmptyLeaderboard(),
            ),
          ],
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
}

class _GuestLeaderboardBanner extends StatelessWidget {
  const _GuestLeaderboardBanner({required this.s});

  final UiStrings s;

  @override
  Widget build(BuildContext context) {
    return JpCard(
      glowColor: AppColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          s.isEnglish
              ? Text(
                s.authGuestLeaderboardNote,
                style: AppTextStyles.enBody.copyWith(height: 1.4),
              )
              : UrduText(
                s.authGuestLeaderboardNote,
                style: AppTextStyles.urduBody.copyWith(height: 1.5),
                textAlign: TextAlign.right,
              ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/sign-up'),
            child:
                s.isEnglish
                    ? Text(
                      s.authCreateAccountCta,
                      style: AppTextStyles.enBody.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                    : UrduText(
                      s.authCreateAccountCta,
                      style: AppTextStyles.urduBody.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _MyRankCard extends StatelessWidget {
  const _MyRankCard({required this.entry});

  final LeaderboardEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return JpCard(
      glowColor: AppColors.orange,
      child: Row(
        children: <Widget>[
          const Text('🧭', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your rank: #${entry.rank}',
              style: AppTextStyles.enBody.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '⭐ ${entry.xp}  •  🔥 ${entry.streak}  •  🪙 ${entry.coins}',
            style: AppTextStyles.enCaption.copyWith(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final bool topThree = entry.rank <= 3;
    return JpCard(
      glowColor: topThree ? AppColors.gold : AppColors.orange,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 56,
            child: Text(
              _rankBadge(entry.rank),
              textAlign: TextAlign.center,
              style: AppTextStyles.enBody.copyWith(
                fontWeight: FontWeight.w700,
                color: topThree ? AppColors.gold : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.displayName,
              style: AppTextStyles.enBody.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '⭐ ${entry.xp}',
            style: AppTextStyles.enCaption.copyWith(
              fontSize: 12,
              color: AppColors.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '🔥 ${entry.streak}',
            style: AppTextStyles.enCaption.copyWith(
              fontSize: 12,
              color: AppColors.orange.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '🪙 ${entry.coins}',
            style: AppTextStyles.enCaption.copyWith(
              fontSize: 12,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _rankBadge(int rank) {
    if (rank == 1) return '🥇 #1';
    if (rank == 2) return '🥈 #2';
    if (rank == 3) return '🥉 #3';
    return '#$rank';
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return JpCard(
      child: Text(
        'No leaderboard data yet.',
        style: AppTextStyles.enBody.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
