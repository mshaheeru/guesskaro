import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme_variant.dart';
import '../data/local/local_player_prefs.dart';

final appThemeVariantProvider =
    NotifierProvider<AppThemeVariantNotifier, AppThemeVariant>(
  AppThemeVariantNotifier.new,
);

class AppThemeVariantNotifier extends Notifier<AppThemeVariant> {
  bool _hydrated = false;

  @override
  AppThemeVariant build() {
    if (!_hydrated) {
      _hydrated = true;
      unawaited(_load());
    }
    AppColors.activeVariant = AppThemeVariant.classic;
    return AppThemeVariant.classic;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(LocalPlayerPrefs.keyAppTheme);
    final AppThemeVariant next =
        code == 'sunny' ? AppThemeVariant.sunny : AppThemeVariant.classic;
    AppColors.activeVariant = next;
    state = next;
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      LocalPlayerPrefs.keyAppTheme,
      variant == AppThemeVariant.sunny ? 'sunny' : 'classic',
    );
    AppColors.activeVariant = variant;
    state = variant;
  }
}
