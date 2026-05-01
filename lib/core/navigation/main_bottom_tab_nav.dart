import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Tabs: Home (0), Profile (1), Settings (2). Library route kept but hidden from bar.
void navigateMainBottomTab(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/home');
      return;
    case 1:
      context.go('/profile');
      return;
    case 2:
      context.go('/settings');
      return;
    default:
      return;
  }
}
