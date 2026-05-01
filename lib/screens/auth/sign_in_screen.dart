import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final List<String> _avatars = <String>['😀', '😎', '🤩', '🧠', '🔥', '🌟'];
  int _selectedAvatarIndex = 0;
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
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

  Future<void> _submitEmail() async {
    final UiStrings s = UiStrings.watch(ref);
    final String e = _email.text.trim();
    if (e.isEmpty || _password.text.isEmpty) {
      _snack(s.authSignInFailed);
      return;
    }
    setState(() => _submitting = true);
    final GoRouter router = GoRouter.of(context);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .signInWithEmail(email: e, password: _password.text);
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw StateError('sign-in-session-missing');
      }
      if (!mounted) return;
      await goHomeAfterAccountAuth(
        ref,
        router,
        preferredDisplayName: '',
        avatarIndex: _selectedAvatarIndex,
      );
    } catch (_) {
      _snack(s.authSignInFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openWelcomeGuest() async {
    context.go('/welcome');
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
      localizedTitle: s.authSignInTitle,
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
          const SizedBox(height: 20),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enabled: !_submitting,
            textDirection:
                lang == AppLang.en ? TextDirection.ltr : TextDirection.ltr,
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
            label: _submitting ? '...' : s.authSignInCta,
            onPressed: _submitting ? null : _submitEmail,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _submitting ? null : () => context.go('/sign-up'),
            child:
                s.isEnglish
                    ? Text(
                      s.authNeedAccount,
                      style: AppTextStyles.enBody.copyWith(
                        color: AppColors.orange,
                      ),
                    )
                    : UrduText(
                      s.authNeedAccount,
                      style: AppTextStyles.urduBody.copyWith(
                        color: AppColors.orange,
                      ),
                    ),
          ),
          JpButtonGhost(
            label: s.authContinueAsGuest,
            onPressed: _submitting ? null : _openWelcomeGuest,
          ),
        ],
      ),
    );
  }
}
