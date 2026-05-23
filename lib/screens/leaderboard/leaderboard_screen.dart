import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/leaderboard_metric.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart' show
    leaderboardMetricProvider,
    leaderboardScreenDataProvider;
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

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<LeaderboardMetric> _metrics = <LeaderboardMetric>[
    LeaderboardMetric.sessionStreak,
    LeaderboardMetric.dailyStreak,
    LeaderboardMetric.totalScore,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _metrics.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(leaderboardMetricProvider.notifier).state =
          _metrics[_tabController.index];
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final LeaderboardMetric metric = _metrics[_tabController.index];
    ref.read(leaderboardMetricProvider.notifier).state = metric;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    final User? user = ref.watch(currentUserProvider);
    final bool guestGlobalBoard =
        kAuthEnabled && (user == null || _isAnonymousLeaderboardUser(user));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: s.isEnglish
                        ? Text(
                            s.leaderboardScreenTitle,
                            style: AppTextStyles.enTitle.copyWith(fontSize: 24),
                          )
                        : UrduText(
                            s.leaderboardScreenTitle,
                            style: AppTextStyles.urduTitle.copyWith(fontSize: 22),
                            textAlign: TextAlign.start,
                          ),
                  ),
                ],
              ),
            ),
            if (guestGlobalBoard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _GuestLeaderboardBanner(s: s),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.orange,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.orange,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: <Widget>[
                  Tab(text: s.leaderboardTabSessionStreak),
                  Tab(text: s.leaderboardTabDailyStreak),
                  Tab(text: s.leaderboardTabTotalScore),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List<Widget>.generate(
                  _metrics.length,
                  (_) => _LeaderboardTabBody(strings: s),
                ),
              ),
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

class _LeaderboardTabBody extends ConsumerWidget {
  const _LeaderboardTabBody({required this.strings});

  final UiStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LeaderboardMetric metric = ref.watch(leaderboardMetricProvider);
    final AsyncValue<LeaderboardScreenData> leaderboard = ref.watch(
      leaderboardScreenDataProvider,
    );

    return leaderboard.when(
      data: (LeaderboardScreenData data) {
        if (data.top.isEmpty) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              bottomInsetGap(context, gap: 16),
            ),
            child: _EmptyLeaderboard(message: strings.leaderboardEmpty),
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            bottomInsetGap(context, gap: 16),
          ),
          children: <Widget>[
            if (data.you != null) ...<Widget>[
              _MyRankCard(entry: data.you!, metric: metric, strings: strings),
              const SizedBox(height: 12),
            ],
            ...data.top.map((LeaderboardEntryModel row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LeaderboardRow(
                  entry: row,
                  metric: metric,
                  strings: strings,
                ),
              );
            }),
          ],
        );
      },
      loading:
          () => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              bottomInsetGap(context, gap: 16),
            ),
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
      error:
          (_, __) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              bottomInsetGap(context, gap: 16),
            ),
            child: _EmptyLeaderboard(message: strings.leaderboardEmpty),
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
            child: s.isEnglish
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
  const _MyRankCard({
    required this.entry,
    required this.metric,
    required this.strings,
  });

  final LeaderboardEntryModel entry;
  final LeaderboardMetric metric;
  final UiStrings strings;

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
              strings.leaderboardYourRank(entry.rank),
              style: AppTextStyles.enBody.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            strings.leaderboardScoreLine(entry, metric),
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
  const _LeaderboardRow({
    required this.entry,
    required this.metric,
    required this.strings,
  });

  final LeaderboardEntryModel entry;
  final LeaderboardMetric metric;
  final UiStrings strings;

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
          const SizedBox(width: 8),
          Text(
            strings.leaderboardScoreLine(entry, metric),
            style: AppTextStyles.enCaption.copyWith(
              fontSize: 13,
              color: AppColors.orange,
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
  const _EmptyLeaderboard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return JpCard(
      child: Text(
        message,
        style: AppTextStyles.enBody.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
