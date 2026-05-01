import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/local/local_player_prefs.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../providers/locale_provider.dart';
import '../../providers/local_guest_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/jp_button_ghost.dart';
import '../../widgets/jp_button_primary.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _avatars = <String>['😀', '😎', '🤩', '🧠', '🔥', '🌟'];
  int _selectedAvatarIndex = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final UiStrings s = UiStrings.watch(ref);
    final String trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.nameRequired,
            style: s.isEnglish ? AppTextStyles.latin16 : AppTextStyles.urdu16,
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(LocalPlayerPrefs.keyGuestReady, true);

      final LocalProfileRepository repo = ref.read(
        localProfileRepositoryProvider,
      );
      await repo.ensureProfile(
        displayName: trimmed,
        avatarIndex: _selectedAvatarIndex,
        inputMode: 'pick',
      );

      ref.invalidate(localGuestRegisteredProvider);
      ref.invalidate(profileNotifierProvider);

      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    final AppLang lang = ref.watch(appLangNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      resizeToAvoidBottomInset: false,
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
                            s.isEnglish ? 26 : 34,
                            20,
                            s.isEnglish ? 24 : 20,
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
                                    s.welcomeTitle,
                                    style: AppTextStyles.enTitle.copyWith(
                                      fontSize: 40,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  : UrduText(
                                    s.welcomeTitle,
                                    style: AppTextStyles.urduDisplay.copyWith(
                                      fontSize: 36,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              SizedBox(height: s.isEnglish ? 8 : 6),
                              s.isEnglish
                                  ? Text(
                                    s.welcomeSubtitle,
                                    style: AppTextStyles.enBody.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  : UrduText(
                                    s.welcomeSubtitle,
                                    style: AppTextStyles.urduBody.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            bottomInsetGap(context, gap: 20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
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
                                    child: _LangButton(
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
                                    child: _LangButton(
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
                              const SizedBox(height: 24),
                              s.isEnglish
                                  ? Text(
                                    s.chooseAvatar,
                                    style: AppTextStyles.enBody.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                  : UrduText(
                                    s.chooseAvatar,
                                    style: AppTextStyles.urduBody.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: List<
                                  Widget
                                >.generate(_avatars.length, (int index) {
                                  final bool selected =
                                      _selectedAvatarIndex == index;
                                  return GestureDetector(
                                    onTap:
                                        _submitting
                                            ? null
                                            : () => setState(
                                              () =>
                                                  _selectedAvatarIndex = index,
                                            ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            selected
                                                ? AppColors.orange.withValues(
                                                  alpha: 0.12,
                                                )
                                                : Colors.white.withValues(
                                                  alpha: 0.05,
                                                ),
                                        border: Border.all(
                                          color:
                                              selected
                                                  ? AppColors.orange
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                        boxShadow:
                                            selected
                                                ? const <BoxShadow>[
                                                  BoxShadow(
                                                    color: AppColors.orangeGlow,
                                                    blurRadius: 16,
                                                  ),
                                                ]
                                                : const <BoxShadow>[],
                                      ),
                                      child: Center(
                                        child: Text(
                                          _avatars[index],
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),
                              s.isEnglish
                                  ? Text(
                                    s.yourNameLabel,
                                    style: AppTextStyles.enBody.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                  : UrduText(
                                    s.yourNameLabel,
                                    style: AppTextStyles.urduBody.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _nameController,
                                onChanged: (_) => setState(() {}),
                                textAlign:
                                    lang == AppLang.en
                                        ? TextAlign.start
                                        : TextAlign.end,
                                textDirection:
                                    lang == AppLang.en
                                        ? TextDirection.ltr
                                        : TextDirection.rtl,
                                style:
                                    lang == AppLang.en
                                        ? AppTextStyles.enBody.copyWith(
                                          color: AppColors.textPrimary,
                                        )
                                        : AppTextStyles.urduBody,
                                decoration: InputDecoration(
                                  hintText:
                                      s.isEnglish
                                          ? 'Enter your name'
                                          : 'اپنا نام لکھیں',
                                  hintStyle:
                                      s.isEnglish
                                          ? AppTextStyles.enBody.copyWith(
                                            color: AppColors.textMuted,
                                          )
                                          : AppTextStyles.urduBody.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                  filled: true,
                                  fillColor: AppColors.bgCard,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color:
                                          _nameController.text.trim().isEmpty
                                              ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                              : AppColors.borderOrange,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderOrange,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Opacity(
                                opacity:
                                    _nameController.text.trim().isEmpty
                                        ? 0.5
                                        : 1,
                                child: JpButtonPrimary(
                                  label:
                                      _submitting ? '...' : s.continuePlaying,
                                  onPressed: _submitting ? null : _continue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              JpButtonGhost(
                                label: s.guestPlay,
                                onPressed:
                                    _submitting
                                        ? null
                                        : () {
                                          _nameController.text =
                                              s.isEnglish ? 'Guest' : 'مہمان';
                                          _continue();
                                        },
                              ),
                              if (kAuthEnabled) ...[
                                const SizedBox(height: 14),
                                TextButton(
                                  onPressed:
                                      _submitting
                                          ? null
                                          : () => context.go('/sign-in'),
                                  child:
                                      s.isEnglish
                                          ? Text(
                                            s.authAlreadyHaveAccount,
                                            style: AppTextStyles.enBody
                                                .copyWith(
                                                  color: AppColors.orange,
                                                ),
                                          )
                                          : UrduText(
                                            s.authAlreadyHaveAccount,
                                            style: AppTextStyles.urduBody
                                                .copyWith(
                                                  color: AppColors.orange,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                ),
                              ],
                              const SizedBox(height: 10),
                            ],
                          ),
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

class _LangButton extends StatelessWidget {
  const _LangButton({
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
