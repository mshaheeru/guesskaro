import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/scoring_constants.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../core/navigation/main_bottom_tab_nav.dart';
import '../../data/models/story_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/jp_screen_background.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/story/story_pick_card.dart';

class StoryModeScreen extends ConsumerWidget {
  const StoryModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiStrings s = UiStrings.watch(ref);
    final AsyncValue<List<StoryModel>> stories = ref.watch(activeStoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: JpScreenBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _StoryModeHeader(strings: s),
              Expanded(
                child: stories.when(
                  loading:
                      () => const Center(child: LoadingShimmer(height: 120)),
                  error:
                      (_, __) => Padding(
                        padding: EdgeInsets.all(bottomInsetGap(context, gap: 24)),
                        child: ErrorState(
                          message:
                              s.isEnglish
                                  ? 'Unable to load stories.'
                                  : 'کہانیاں لوڈ نہیں ہو سکیں',
                          onRetry: () => ref.invalidate(activeStoriesProvider),
                        ),
                      ),
                  data: (List<StoryModel> list) {
                    if (list.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(bottomInsetGap(context, gap: 24)),
                        child: ErrorState(
                          message: s.storySessionEmpty,
                          onRetry: () => ref.invalidate(activeStoriesProvider),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _StoryModeIntro(strings: s),
                          const SizedBox(height: 16),
                          ...list.map(
                            (StoryModel story) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StoryPickCard(
                                story: story,
                                strings: s,
                                onTap:
                                    () => _startStory(context, ref, story),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: bottomNavScrollPadding(context, gap: 8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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

  Future<void> _startStory(
    BuildContext context,
    WidgetRef ref,
    StoryModel story,
  ) async {
    final String? inputMode = await _askInputMode(context, ref);
    if (inputMode == null) return;

    await ref.read(profileNotifierProvider.notifier).setInputMode(inputMode);
    await ref.read(gameNotifierProvider.notifier).startSession(
          mode: ScoringConstants.modeStory,
          phraseIds: story.phraseIds,
          storyId: story.id,
          storyLinesUrdu: story.storyLinesUrdu,
          count: story.phraseIds.length,
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
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInsetGap(c)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(s.answerMode, style: AppTextStyles.enTitle),
                  const SizedBox(height: 12),
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
}

class _StoryModeHeader extends StatelessWidget {
  const _StoryModeHeader({required this.strings});

  final UiStrings strings;

  @override
  Widget build(BuildContext context) {
    if (strings.isEnglish) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                strings.storyModeTitle,
                style: AppTextStyles.enTitle.copyWith(fontSize: 26),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            Expanded(
              child: UrduText(
                strings.storyModeTitle,
                style: AppTextStyles.urduTitle.copyWith(fontSize: 28),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryModeIntro extends StatelessWidget {
  const _StoryModeIntro({required this.strings});

  final UiStrings strings;

  @override
  Widget build(BuildContext context) {
  if (strings.isEnglish) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            strings.storyModePickStory,
            style: AppTextStyles.enLabel.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.storyModeSubtitle,
            style: AppTextStyles.enCaption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          strings.isEnglish
              ? Text(
                  strings.storyModePickStory,
                  style: AppTextStyles.enLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                )
              : UrduText(
                  strings.storyModePickStory,
                  style: AppTextStyles.urduHeadline.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                ),
          const SizedBox(height: 6),
          strings.isEnglish
              ? Text(
                  strings.storyModeSubtitle,
                  style: AppTextStyles.enCaption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                )
              : UrduText(
                  strings.storyModeSubtitle,
                  style: AppTextStyles.urduCaption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
        ],
      ),
    );
  }
}
