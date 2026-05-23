import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/models/phrase_model.dart';
import '../common/urdu_text.dart';
import '../mastery/mastery_badge.dart';

class LibraryPhraseDetailSheet extends ConsumerWidget {
  const LibraryPhraseDetailSheet({
    super.key,
    required this.phrase,
    required this.masteryLevel,
  });

  final PhraseModel phrase;
  final int masteryLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiStrings s = UiStrings.watch(ref);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInsetGap(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              MasteryBadge(level: masteryLevel, showLabel: true),
              const Spacer(),
              Text(
                '${s.libraryMasteryTierLabel}: ${s.masteryLabelForLevel(masteryLevel)}',
                style: AppTextStyles.enCaption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          UrduText(phrase.urduPhrase, style: AppTextStyles.urduTitle),
          const SizedBox(height: 6),
          Text(phrase.romanised, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          UrduText('معنی: ${phrase.meaningUrdu}'),
          if (phrase.exampleSentence.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            UrduText(
              phrase.exampleSentence,
              style: AppTextStyles.urduBody.copyWith(height: 2),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}
