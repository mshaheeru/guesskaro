import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_config.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/urdu_text.dart';

/// Header + language picker for Sign in / Sign up flows.
class AuthFlowLayout extends ConsumerWidget {
  const AuthFlowLayout({
    super.key,
    required this.child,
    required this.localizedTitle,
    required this.localizedSubtitle,
  });

  final Widget child;
  final String localizedTitle;
  final String localizedSubtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiStrings s = UiStrings.watch(ref);
    final AppLang lang = ref.watch(appLangNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewport) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            20,
                            s.isEnglish ? 16 : 20,
                            20,
                            10,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0x330F3460),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              s.isEnglish
                                  ? Text(
                                    localizedTitle,
                                    style: AppTextStyles.enTitle.copyWith(
                                      fontSize: 32,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  : UrduText(
                                    localizedTitle,
                                    style: AppTextStyles.urduTitle.copyWith(
                                      fontSize: 30,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              const SizedBox(height: 6),
                              s.isEnglish
                                  ? Text(
                                    localizedSubtitle,
                                    style: AppTextStyles.enBody.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  : UrduText(
                                    localizedSubtitle,
                                    style: AppTextStyles.urduBody.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              const SizedBox(height: 16),
                              if (kAuthEnabled) ...<Widget>[
                                s.isEnglish
                                    ? Text(
                                      s.uiLanguage,
                                      style: AppTextStyles.enBody.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                    : UrduText(
                                      s.uiLanguage,
                                      style: AppTextStyles.urduBody.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                const SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _AuthLangChip(
                                        label: 'English',
                                        active: lang == AppLang.en,
                                        onTap:
                                            () => ref
                                                .read(
                                                  appLangNotifierProvider
                                                      .notifier,
                                                )
                                                .setLang(AppLang.en),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _AuthLangChip(
                                        label: 'اردو',
                                        active: lang == AppLang.ur,
                                        onTap:
                                            () => ref
                                                .read(
                                                  appLangNotifierProvider
                                                      .notifier,
                                                )
                                                .setLang(AppLang.ur),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            8,
                            24,
                            bottomInsetGap(context, gap: 20),
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthLangChip extends StatelessWidget {
  const _AuthLangChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isUrduLabel = RegExp(r'[\u0600-\u06FF]').hasMatch(label);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color:
              active
                  ? AppColors.orange.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color:
                active ? AppColors.orange : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child:
              isUrduLabel
                  ? UrduText(
                    label,
                    style: AppTextStyles.urduBody.copyWith(
                      color:
                          active ? AppColors.orange : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  )
                  : Text(
                    label,
                    style: AppTextStyles.enBody.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          active ? AppColors.orange : AppColors.textSecondary,
                    ),
                  ),
        ),
      ),
    );
  }
}

/// Emoji avatar strip (matches Welcome / Sign-in styling).
class AuthAvatarPicker extends StatelessWidget {
  const AuthAvatarPicker({
    super.key,
    required this.avatars,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> avatars;
  final int selectedIndex;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(avatars.length, (int index) {
        final bool isSel = selectedIndex == index;
        return GestureDetector(
          onTap: onSelect == null ? null : () => onSelect!(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSel
                      ? AppColors.orange.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSel ? AppColors.orange : Colors.transparent,
                width: 2,
              ),
              boxShadow:
                  isSel
                      ? const <BoxShadow>[
                        BoxShadow(color: AppColors.orangeGlow, blurRadius: 16),
                      ]
                      : const <BoxShadow>[],
            ),
            child: Center(
              child: Text(avatars[index], style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      }),
    );
  }
}

InputDecoration authFieldDecoration(
  BuildContext context, {
  required String hint,
  required bool isEnglish,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle:
        isEnglish
            ? AppTextStyles.enBody.copyWith(color: AppColors.textMuted)
            : AppTextStyles.urduBody.copyWith(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.bgCard,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderOrange, width: 1.5),
    ),
  );
}
