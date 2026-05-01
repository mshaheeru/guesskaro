import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/locale/ui_strings.dart';
import '../../providers/game_provider.dart';
import 'urdu_text.dart';

/// Blocks accidental back-without-save; resets game state when exiting to home.
class GamePopScope extends ConsumerWidget {
  const GamePopScope({super.key, required this.child});

  final Widget child;

  Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final UiStrings s = UiStrings.watch(ref);
    final bool? exit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
            title: s.isEnglish
                ? Text('Leave game?', style: AppTextStyles.enTitle.copyWith(fontSize: 22))
                : const UrduText('کھیل چھوڑنا'),
            content: s.isEnglish
                ? Text(
                    'Are you sure you want to leave this game?',
                    style: AppTextStyles.enBody,
                  )
                : const UrduText('کیا آپ واقعی چھوڑنا چاہتے ہیں؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: s.isEnglish
                    ? Text('No', style: AppTextStyles.enBody)
                    : const UrduText('نہیں'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: s.isEnglish
                    ? Text('Yes', style: AppTextStyles.enBody)
                    : const UrduText('ہاں'),
              ),
            ],
          ),
        );

    if (exit != true || !context.mounted) return;
    await ref.read(gameNotifierProvider.notifier).resetSession();
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic _) async {
        if (!didPop) await _confirmExit(context, ref);
      },
      child: child,
    );
  }
}
