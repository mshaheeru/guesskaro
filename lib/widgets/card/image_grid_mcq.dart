import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/phrase_model.dart';
import '../common/jp_pressable.dart';
import '../common/supabase_phrase_image.dart';
import '../mcq/mcq_option_tile.dart';

class ImageGridMcq extends StatelessWidget {
  const ImageGridMcq({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.onTap,
    this.eliminatedIndices = const <int>{},
  });

  final List<PhraseImageOption> options;
  final int? selectedIndex;
  final int correctIndex;
  final ValueChanged<int> onTap;
  final Set<int> eliminatedIndices;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        return _ImageGridCell(
          imageUrl: options[index].imageUrl,
          appearance: _appearanceFor(index),
          onTap: eliminatedIndices.contains(index)
              ? null
              : () => onTap(index),
        );
      },
    );
  }

  McqTileAppearance _appearanceFor(int index) {
    if (eliminatedIndices.contains(index)) {
      return McqTileAppearance.eliminated;
    }
    final int? sel = selectedIndex;
    if (sel == null) return McqTileAppearance.idle;
    if (index == correctIndex) return McqTileAppearance.correct;
    if (index == sel) return McqTileAppearance.wrong;
    return McqTileAppearance.idle;
  }
}

class _ImageGridCell extends StatelessWidget {
  const _ImageGridCell({
    required this.imageUrl,
    required this.appearance,
    required this.onTap,
  });

  final String imageUrl;
  final McqTileAppearance appearance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = switch (appearance) {
      McqTileAppearance.correct => AppColors.correct,
      McqTileAppearance.wrong => AppColors.wrong,
      McqTileAppearance.selected => AppColors.orange,
      McqTileAppearance.eliminated => AppColors.textMuted,
      McqTileAppearance.idle => AppColors.borderSubtle,
    };

    final double width = appearance == McqTileAppearance.idle ? 1 : 2.5;

    return JpPressable(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppBorders.tile,
          border: Border.all(color: border, width: width),
        ),
        child: ClipRRect(
          borderRadius: AppBorders.tile,
          child: Opacity(
            opacity:
                appearance == McqTileAppearance.eliminated ? 0.35 : 1,
            child: SupabasePhraseImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
