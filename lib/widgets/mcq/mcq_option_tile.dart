import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_text_styles.dart';
import '../common/jp_pressable.dart';
import '../common/urdu_text.dart';

enum McqTileAppearance {
  idle,
  selected,
  correct,
  wrong,
  eliminated,
}

class McqOptionTile extends StatelessWidget {
  const McqOptionTile({
    super.key,
    required this.label,
    required this.appearance,
    required this.onTap,
  });

  final String label;
  final McqTileAppearance appearance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isSunny) {
      return _SunnyMcqTile(
        label: label,
        appearance: appearance,
        onTap: onTap,
      );
    }
    return _ClassicMcqTile(
      label: label,
      appearance: appearance,
      onTap: onTap,
    );
  }
}

class _ClassicMcqTile extends StatelessWidget {
  const _ClassicMcqTile({
    required this.label,
    required this.appearance,
    required this.onTap,
  });

  final String label;
  final McqTileAppearance appearance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled =
        appearance == McqTileAppearance.eliminated || onTap == null;

    BorderSide border = BorderSide(color: AppColors.borderSubtle, width: 1.5);
    Color bg = AppColors.bgCard;
    List<BoxShadow> boxShadow = <BoxShadow>[];

    switch (appearance) {
      case McqTileAppearance.idle:
        break;
      case McqTileAppearance.selected:
        border = BorderSide(color: AppColors.orange, width: 1.5);
        bg = AppColors.orangeDim;
        break;
      case McqTileAppearance.correct:
        border = BorderSide(color: AppColors.correct, width: 1.5);
        bg = AppColors.correct.withValues(alpha: 0.15);
        boxShadow = AppShadows.correctGlow;
        break;
      case McqTileAppearance.wrong:
        border = BorderSide(color: AppColors.wrong, width: 1.5);
        bg = AppColors.wrong.withValues(alpha: 0.15);
        boxShadow = AppShadows.wrongGlow;
        break;
      case McqTileAppearance.eliminated:
        border = BorderSide(color: AppColors.borderSubtle, width: 1.5);
        bg = AppColors.bgCard;
        break;
    }

    final Color textColor =
        appearance == McqTileAppearance.eliminated
            ? AppColors.textMuted
            : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.fromBorderSide(border),
            boxShadow: boxShadow,
          ),
          child: Opacity(
            opacity: appearance == McqTileAppearance.eliminated ? 0.55 : 1,
            child: UrduText(
              label,
              style: AppTextStyles.urduBody.copyWith(
                fontWeight:
                    appearance == McqTileAppearance.idle
                        ? FontWeight.w400
                        : FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _SunnyMcqTile extends StatelessWidget {
  const _SunnyMcqTile({
    required this.label,
    required this.appearance,
    required this.onTap,
  });

  final String label;
  final McqTileAppearance appearance;
  final VoidCallback? onTap;

  Color get _bg {
    switch (appearance) {
      case McqTileAppearance.correct:
        return AppColors.correctSurface;
      case McqTileAppearance.wrong:
        return AppColors.wrongSurface;
      default:
        return AppColors.card;
    }
  }

  Color get _borderColor {
    switch (appearance) {
      case McqTileAppearance.correct:
        return AppColors.teal;
      case McqTileAppearance.wrong:
        return AppColors.tomato;
      case McqTileAppearance.selected:
        return AppColors.tomato;
      default:
        return AppColors.ink;
    }
  }

  List<BoxShadow> get _shadow {
    switch (appearance) {
      case McqTileAppearance.correct:
        return AppShadows.correctMd;
      case McqTileAppearance.wrong:
        return AppShadows.wrongMd;
      default:
        return AppShadows.md;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled =
        appearance == McqTileAppearance.eliminated || onTap == null;
    final bool showIcon =
        appearance == McqTileAppearance.correct ||
        appearance == McqTileAppearance.wrong;

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppBorders.tile,
        border: Border.all(color: _borderColor, width: AppBorders.bDefault),
        boxShadow: _shadow,
      ),
      child: Row(
        children: <Widget>[
          if (showIcon) ...<Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color:
                    appearance == McqTileAppearance.correct
                        ? AppColors.teal
                        : AppColors.tomato,
                shape: BoxShape.circle,
                border: AppBorders.ink(width: AppBorders.bThin),
              ),
              alignment: Alignment.center,
              child: Text(
                appearance == McqTileAppearance.correct ? '✓' : '✗',
                style: AppTextStyles.enLabel.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: UrduText(
              label,
              style: AppTextStyles.urduBody.copyWith(
                fontWeight:
                    appearance == McqTileAppearance.idle
                        ? FontWeight.w500
                        : FontWeight.w700,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    if (appearance == McqTileAppearance.wrong) {
      tile = TweenAnimationBuilder<double>(
        key: ValueKey<String>('shake-$label'),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (BuildContext context, double t, Widget? child) {
          final double dx = (t < 0.25)
              ? -6 * (t / 0.25)
              : (t < 0.75)
              ? 6 * ((t - 0.25) / 0.5) - 6
              : -6 * ((t - 0.75) / 0.25) + 6;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: tile,
      );
    }

    tile = Opacity(
      opacity: appearance == McqTileAppearance.eliminated ? 0.45 : 1,
      child: tile,
    );

    if (disabled) {
      return tile;
    }

    return JpPressable(onTap: onTap, child: tile);
  }
}
