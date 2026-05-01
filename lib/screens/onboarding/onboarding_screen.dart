import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/local/cache_service.dart';
import '../../widgets/jp_button_ghost.dart';
import '../../widgets/jp_button_primary.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _page = 0;
  late final AnimationController _waveController;

  List<_SlideData> _slides(UiStrings s) {
    return <_SlideData>[
      _SlideData(
        title: 'See the Image',
        description: 'Understand the clue from the visual first.',
        emoji: '🖼️',
        color: AppColors.orange,
      ),
      _SlideData(
        title: 'Pick the Right Meaning',
        description: 'Choose one correct option from four answers.',
        emoji: '✅',
        color: AppColors.correct,
      ),
      _SlideData(
        title: 'Learn and Level Up',
        description: 'Earn coins, build streaks, and grow daily.',
        emoji: '🚀',
        color: AppColors.purple,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final CacheService cacheService = ref.read(cacheServiceProvider);
    await cacheService.saveOnboardingSeen();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    if (kAuthEnabled) {
      context.go('/sign-in');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final UiStrings s = UiStrings.watch(ref);
    final List<_SlideData> slides = _slides(s);
    final bool isLast = _page == slides.length - 1;
    final MediaQueryData mq = MediaQuery.of(context);
    final double screenW = mq.size.width;
    final double mascotBox = (screenW * 0.30).clamp(96.0, 128.0);
    final double mascotTop = mq.padding.top + 6;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (int value) => setState(() => _page = value),
            itemBuilder: (context, index) {
              final _SlideData slide = slides[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      slide.color.withValues(alpha: 0.2),
                      AppColors.bgPrimary,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slide.color.withValues(alpha: 0.1),
                        border: Border.all(color: slide.color.withValues(alpha: 0.27)),
                      ),
                      child: Center(
                        child: Text(slide.emoji, style: const TextStyle(fontSize: 56)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        slide.title,
                        style: AppTextStyles.urduTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        slide.description,
                        style: AppTextStyles.urduHeadline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (!isLast)
            Positioned(
              right: 16,
              top: mascotTop,
              child: SizedBox(
                width: math.min(120.0, screenW * 0.32),
                child: JpButtonGhost(label: 'Skip', onPressed: _completeOnboarding),
              ),
            ),
          Positioned(
            left: 8,
            top: mascotTop,
            width: mascotBox,
            height: mascotBox * 1.12,
            child: IgnorePointer(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (BuildContext context, Widget? child) {
                    final double t =
                        Curves.easeInOut.transform(_waveController.value);
                    final double angle = -0.10 + (0.20 * t);
                    return Transform.rotate(
                      angle: angle,
                      alignment: const Alignment(0.25, 0.85),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/hi.png',
                    width: mascotBox,
                    height: mascotBox,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInsetGap(context, gap: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    slides.length,
                    (int i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? slides[_page].color : AppColors.textMuted,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    width: double.infinity,
                    child: JpButtonPrimary(
                      label: isLast ? 'Get Started' : 'Next',
                      onPressed: () async {
                        if (isLast) {
                          await _completeOnboarding();
                        } else {
                          await _controller.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });

  final String title;
  final String description;
  final String emoji;
  final Color color;
}
