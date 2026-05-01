import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ResultFlashScreen extends StatefulWidget {
  const ResultFlashScreen({super.key});

  @override
  State<ResultFlashScreen> createState() => _ResultFlashScreenState();
}

class _ResultFlashScreenState extends State<ResultFlashScreen> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(milliseconds: 1200))
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const <Color>[
                AppColors.orange,
                AppColors.gold,
                AppColors.correct,
                AppColors.purple,
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.correct, width: 3),
                    color: AppColors.correct.withValues(alpha: 0.13),
                  ),
                  child: const Center(
                    child: Text('✓', style: TextStyle(fontSize: 50, color: AppColors.correct)),
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'شاباش!',
                    style: AppTextStyles.urduTitle.copyWith(color: AppColors.correct),
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
