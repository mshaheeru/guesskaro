import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'data/local/cache_service.dart';
import 'data/repositories/session_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Must be the same instance [cacheServiceProvider] resolves to — PhraseRepository uses the provider.
  final CacheService cacheService = CacheService();
  await cacheService.init();

  if (kClearPhraseCacheOnLaunch) {
    await cacheService.clearPhraseCacheOnly();
    // ignore: avoid_print — dev-only cache bust
    print('CLEAR_PHRASE_CACHE: phrase Hive cleared; phrases refetch next.');
  }

  if (kAuthEnabled) {
    await SessionRepository().retryPendingSessions();
  }

  runApp(
    ProviderScope(
      overrides: [
        cacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const JhatPatApp(),
    ),
  );
}
