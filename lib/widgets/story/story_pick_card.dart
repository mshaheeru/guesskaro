import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/story_icon_theme.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/models/story_model.dart';
import '../common/jp_pressable.dart';
import '../common/urdu_text.dart';

class StoryPickCard extends StatelessWidget {
  const StoryPickCard({
    super.key,
    required this.story,
    required this.strings,
    required this.onTap,
  });

  final StoryModel story;
  final UiStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final StoryIconTheme theme = StoryIconTheme.forKey(
      story.iconKey.isEmpty ? 'book' : story.iconKey,
    );

    final Widget cardBody = Padding(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _StoryAccentIcon(emoji: theme.emoji, color: theme.accentColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UrduText(
                    story.titleUrdu,
                    style: AppTextStyles.urduHeadline.copyWith(fontSize: 24),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: strings.isEnglish
                        ? Text(
                            strings.storyPhraseCount(story.phraseIds.length),
                            style: AppTextStyles.enCaption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : UrduText(
                            strings.storyPhraseCount(story.phraseIds.length),
                            style: AppTextStyles.urduCaption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: 28,
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
          child: cardBody,
        ),
      );
    }

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppSpacing.rTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.rTile),
        onTap: onTap,
        child: cardBody,
      ),
    );
  }
}

class _StoryAccentIcon extends StatelessWidget {
  const _StoryAccentIcon({required this.emoji, required this.color});

  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.rIconBox),
        border: AppColors.isSunny
            ? AppBorders.ink(width: AppBorders.bThin)
            : Border.all(color: color.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}
