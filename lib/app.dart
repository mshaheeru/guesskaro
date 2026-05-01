import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'widgets/common/phrase_photo_prefetch_host.dart';

class JhatPatApp extends ConsumerWidget {
  const JhatPatApp({super.key});

  /// Keep Material localizations tied to English. Urdu/Punjabi strings use [UiStrings] + Urdu widgets.
  static const Locale _materialLocale = Locale('en');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLang lang = ref.watch(appLangNotifierProvider);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp.router(
        title: lang == AppLang.en ? 'GuessKaro' : 'گیس کرو',
        debugShowCheckedModeBanner: false,
        locale: _materialLocale,
        supportedLocales: const <Locale>[_materialLocale],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              if (child != null) child,
              const PhrasePhotoPrefetchHost(),
            ],
          );
        },
      ),
    );
  }
}
