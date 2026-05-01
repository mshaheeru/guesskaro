import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../common/urdu_text.dart';

Future<void> showGameInstructionsSheet(
  BuildContext context, {
  required UiStrings strings,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.bgPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      final double screenH = MediaQuery.sizeOf(sheetContext).height;
      return SafeArea(
        child: SizedBox(
          height: screenH * 0.92,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              bottomInsetGap(sheetContext, gap: 12),
            ),
            child: _GameInstructionsBody(strings: strings),
          ),
        ),
      );
    },
  );
}

class _GameInstructionsBody extends StatelessWidget {
  const _GameInstructionsBody({required this.strings});

  final UiStrings strings;

  Widget _heading(String text) {
    if (strings.isEnglish) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTextStyles.enTitle.copyWith(fontSize: 17),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: UrduText(
        text,
        style: AppTextStyles.urduHeadline.copyWith(fontSize: 21),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _body(String localized) {
    if (strings.isEnglish) {
      return Text(
        localized,
        style: AppTextStyles.enBody.copyWith(
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      );
    }
    return UrduText(
      localized,
      style: AppTextStyles.urduBody,
      textAlign: TextAlign.right,
    );
  }

  Widget _gap() => const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (strings.isEnglish)
          Text(
            strings.helpSheetTitle,
            style: AppTextStyles.enTitle.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          )
        else
          UrduText(
            strings.helpSheetTitle,
            style: AppTextStyles.urduTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        const Divider(height: 22),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              _heading(strings.helpMissionTitle),
              const SizedBox(height: 10),
              _body(
                strings.isEnglish
                    ? strings.helpMissionBodyEn
                    : AppStrings.helpMissionBody,
              ),
              _gap(),
              _heading(strings.helpHowToSectionTitle),
              const SizedBox(height: 10),
              _body(
                strings.isEnglish
                    ? strings.helpHowToBodyEn
                    : AppStrings.helpHowToPlayBody,
              ),
              _gap(),
              _heading(strings.helpScoresSectionTitle),
              const SizedBox(height: 10),
              _body(
                strings.isEnglish
                    ? strings.helpScoresBodyEn
                    : AppStrings.helpScoresBody,
              ),
              _gap(),
              _heading(strings.helpLevelsSectionTitle),
              const SizedBox(height: 10),
              _body(
                strings.isEnglish
                    ? strings.helpLevelsBodyEn
                    : AppStrings.helpLevelsBody,
              ),
              _gap(),
              _heading(strings.helpStreakSectionTitle),
              const SizedBox(height: 10),
              _body(
                strings.isEnglish
                    ? strings.helpStreakBodyEn
                    : AppStrings.helpStreakBody,
              ),
              _gap(),
              _heading(strings.helpCoinsSectionTitle),
              const SizedBox(height: 10),
              _body(strings.helpCoinsParagraph()),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
            ],
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: strings.isEnglish
              ? Text(strings.helpGotIt)
              : UrduText(
                  strings.helpGotIt,
                  style: AppTextStyles.urduBody.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}
