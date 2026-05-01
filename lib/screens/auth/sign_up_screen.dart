import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/jp_button_ghost.dart';
import '../../widgets/jp_button_primary.dart';
import 'auth_session_util.dart';
import 'auth_shell.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final List<String> _avatars = <String>['😀', '😎', '🤩', '🧠', '🔥', '🌟'];
  int _selectedAvatarIndex = 0;
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    final UiStrings s = UiStrings.watch(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            s.isEnglish
                ? Text(message, style: AppTextStyles.enBody)
                : UrduText(message, style: AppTextStyles.urduBody),
      ),
    );
  }

  Future<void> _submitSignUp() async {
    final UiStrings s = UiStrings.watch(ref);
    if (_name.text.trim().isEmpty) {
      _snack(s.nameRequired);
      return;
    }
    final String e = _email.text.trim();
    if (e.isEmpty || _password.text.isEmpty) {
      _snack(s.authSignUpFailed);
      return;
    }

    setState(() => _submitting = true);
    final GoRouter router = GoRouter.of(context);
    try {
      final SignUpFlowResult result =
          await ref.read(authNotifierProvider.notifier).completeEmailSignUp(
            email: e,
            password: _password.text,
            displayName: _name.text.trim(),
          );
      if (!mounted) return;
      switch (result) {
        case SignUpFlowResult.success:
          _snack(s.authSignUpSuccessNavigating);
          await goHomeAfterAccountAuth(
            ref,
            router,
            preferredDisplayName: _name.text.trim(),
            avatarIndex: _selectedAvatarIndex,
          );
          break;
        case SignUpFlowResult.emailConfirmationRequired:
          _snack(s.authCheckEmailConfirm);
          break;
        case SignUpFlowResult.noSession:
          _snack(s.authSignUpSessionFailed);
          break;
      }
    } on AuthException catch (ex) {
      if (!mounted) return;
      _snack(ex.message.isNotEmpty ? ex.message : s.authSignUpFailed);
    } catch (_) {
      if (!mounted) return;
      _snack(s.authSignUpFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    final AppLang lang = ref.watch(appLangNotifierProvider);

    if (!kAuthEnabled) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/welcome'),
            child: const Text('Auth off — use Welcome'),
          ),
        ),
      );
    }

    return AuthFlowLayout(
      localizedTitle: s.authSignUpTitle,
      localizedSubtitle: s.authSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
          const SizedBox(height: 10),
          AuthAvatarPicker(
            avatars: _avatars,
            selectedIndex: _selectedAvatarIndex,
            onSelect:
                _submitting
                    ? null
                    : (int i) => setState(() => _selectedAvatarIndex = i),
          ),
          const SizedBox(height: 16),
          s.isEnglish
              ? Text(s.yourNameLabel, style: AppTextStyles.enCaption)
              : UrduText(
                s.yourNameLabel,
                style: AppTextStyles.urduCaption,
                textAlign: TextAlign.right,
              ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            enabled: !_submitting,
            textAlign: lang == AppLang.en ? TextAlign.start : TextAlign.end,
            textDirection:
                lang == AppLang.en ? TextDirection.ltr : TextDirection.rtl,
            style: s.isEnglish ? AppTextStyles.enBody : AppTextStyles.urduBody,
            decoration: authFieldDecoration(
              context,
              hint: s.nameHint,
              isEnglish: s.isEnglish,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enabled: !_submitting,
            style: s.isEnglish ? AppTextStyles.enBody : AppTextStyles.urduBody,
            decoration: authFieldDecoration(
              context,
              hint: s.authEmailLabel,
              isEnglish: s.isEnglish,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            enabled: !_submitting,
            style: s.isEnglish ? AppTextStyles.enBody : AppTextStyles.urduBody,
            decoration: authFieldDecoration(
              context,
              hint: s.authPasswordLabel,
              isEnglish: s.isEnglish,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 20),
          JpButtonPrimary(
            label: _submitting ? '...' : s.authCreateAccountCta,
            onPressed: _submitting ? null : _submitSignUp,
          ),
          TextButton(
            onPressed: _submitting ? null : () => context.go('/sign-in'),
            child:
                s.isEnglish
                    ? Text(
                      s.authAlreadyHaveAccount,
                      style: AppTextStyles.enBody.copyWith(
                        color: AppColors.orange,
                      ),
                      textAlign: TextAlign.center,
                    )
                    : UrduText(
                      s.authAlreadyHaveAccount,
                      style: AppTextStyles.urduBody.copyWith(
                        color: AppColors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
          ),
          JpButtonGhost(
            label: s.authContinueAsGuest,
            onPressed: _submitting ? null : () => context.go('/welcome'),
          ),
        ],
      ),
    );
  }
}
