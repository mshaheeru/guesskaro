import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/urdu_utils.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/library_mastery_provider.dart';
import '../common/jp_pressable.dart';
import '../common/urdu_text.dart';

/// Home card: mastery progress + tap opens library.
class HomeMasteryStrip extends ConsumerWidget {
  const HomeMasteryStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiStrings s = UiStrings.watch(ref);
    final AsyncValue<LibraryMasterySummary> summary =
        ref.watch(libraryMasterySummaryProvider);

    return summary.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 3),
          ),
      error: (_, __) => const SizedBox.shrink(),
      data: (LibraryMasterySummary data) {
        return JpPressable(
          onTap: () => context.push('/library'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: s.isEnglish
                          ? Text(
                              s.homeMasterySection,
                              style: AppTextStyles.enLabel.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : UrduText(
                              s.homeMasterySection,
                              style: AppTextStyles.urduBody.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.right,
                            ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                s.isEnglish
                    ? Text(
                        s.libraryMasteryProgress(
                          data.masteredCount,
                          data.totalPhrases,
                        ),
                        style: AppTextStyles.enCaption,
                      )
                    : UrduText(
                        s.libraryMasteryProgress(
                          data.masteredCount,
                          data.totalPhrases,
                        ),
                        style: AppTextStyles.urduCaption,
                        textAlign: TextAlign.right,
                      ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: data.masteredFraction,
                    backgroundColor: AppColors.borderSubtle,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.masteredCount > 0
                      ? (s.isEnglish
                          ? 'Tap to view your gold collection'
                          : 'سونے والے کارڈز دیکھنے کے لیے چھوئیں')
                      : (s.isEnglish
                          ? '${data.learningCount} idioms in progress — master one to unlock the library'
                          : '${toUrduNumerals(data.learningCount)} محاورے سیکھے جا رہے ہیں — مکمل کریں تو کتب خانہ کھلے گی'),
                  style: AppTextStyles.enCaption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: s.isEnglish ? TextAlign.start : TextAlign.end,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
