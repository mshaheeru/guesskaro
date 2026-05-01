import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/local_player_prefs.dart';

enum AppLang { ur, en }

final appLangNotifierProvider = NotifierProvider<AppLangNotifier, AppLang>(
  AppLangNotifier.new,
);

class AppLangNotifier extends Notifier<AppLang> {
  bool _hydrated = false;

  @override
  AppLang build() {
    if (!_hydrated) {
      _hydrated = true;
      unawaited(_load());
    }
    return AppLang.ur;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(LocalPlayerPrefs.keyAppLocale);
    final AppLang next = code == 'en' ? AppLang.en : AppLang.ur;
    state = next;
  }

  Future<void> setLang(AppLang lang) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      LocalPlayerPrefs.keyAppLocale,
      lang == AppLang.en ? 'en' : 'ur',
    );
    state = lang;
  }

  Locale get materialLocale {
    return Locale(state == AppLang.en ? 'en' : 'ur');
  }
}
