import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/local/local_player_prefs.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const int _minimumSplashMs = 2700;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    unawaited(_boot());
  }

  Future<void> _boot() async {
    final Stopwatch sw = Stopwatch()..start();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        prefs.getBool('has_seen_onboarding') ?? false;
    final bool guestReady =
        prefs.getBool(LocalPlayerPrefs.keyGuestReady) ?? false;

    final int remainingMs = _minimumSplashMs - sw.elapsedMilliseconds;
    if (remainingMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: remainingMs));
    }

    if (!mounted) return;

    if (kAuthEnabled) {
      final User? user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        context.go('/home');
      } else if (guestReady) {
        context.go('/home');
      } else if (!hasSeenOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/sign-in');
      }
      return;
    }

    if (guestReady) {
      context.go('/home');
    } else if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            colors: <Color>[Color(0xFF0F3460), AppColors.bgPrimary],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _AnimatedLogo(controller: _logoController),
            const SizedBox(height: 24),
            Directionality(
              textDirection: TextDirection.rtl,
              child:
                  s.isEnglish
                      ? Text(
                        s.splashTitle,
                        style: AppTextStyles.enTitle.copyWith(fontSize: 42),
                      )
                      : Text(s.splashTitle, style: AppTextStyles.urduDisplay),
            ),
            const SizedBox(height: 6),
            Text(
              'GUESSKARO',
              style: AppTextStyles.enLabel.copyWith(
                color: AppColors.orange,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 22),
            Text('● ● ●', style: AppTextStyles.enBody),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeInOut.transform(controller.value);
        final double scale = 0.96 + (0.06 * t);
        final double dy = -6 + (12 * t);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Image.asset(
        'assets/images/GKLogo.png',
        width: 220,
        fit: BoxFit.contain,
      ),
    );
  }
}
