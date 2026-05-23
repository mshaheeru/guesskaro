import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/mastery_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/phrase_model.dart';
import '../common/supabase_phrase_image.dart';
import '../common/urdu_text.dart';

class LibraryPhraseCard extends StatelessWidget {
  const LibraryPhraseCard({
    super.key,
    required this.phrase,
    required this.masteryLevel,
    required this.onTap,
  });

  final PhraseModel phrase;
  final int masteryLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int level = masteryLevel.clamp(0, MasteryConstants.maxLevel);
    final Color borderColor = MasteryConstants.borderColorForLevel(level);
    final double borderWidth = MasteryConstants.borderWidthForLevel(level);

    return InkWell(
      onTap: onTap,
      child: Card(
        color: MasteryConstants.cardBackgroundForLevel(level),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ColoredBox(
                    color: Colors.grey.shade200,
                    child: SupabasePhraseImage(
                      imageUrl: phrase.imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: UrduText(
                          phrase.urduPhrase,
                          style: AppTextStyles.urduBody.copyWith(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _tierLabelUr(level),
                          style: AppTextStyles.urduCaption.copyWith(
                            fontSize: 10,
                            color: borderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (MasteryConstants.showCrownForLevel(level))
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _tierLabelUr(int level) {
    switch (level) {
      case 0:
        return AppStrings.masteryLabel0;
      case 1:
        return AppStrings.masteryLabel1;
      case 2:
        return AppStrings.masteryLabel2;
      case 3:
        return AppStrings.masteryLabel3;
      case 4:
        return AppStrings.masteryLabel4;
      case 5:
        return AppStrings.masteryLabel5;
      default:
        return AppStrings.masteryLabel0;
    }
  }
}
