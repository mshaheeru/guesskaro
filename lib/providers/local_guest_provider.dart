import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/local_player_prefs.dart';

/// Whether the user completed `/welcome` (name saved).
final FutureProvider<bool> localGuestRegisteredProvider = FutureProvider<bool>(
  (Ref ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(LocalPlayerPrefs.keyGuestReady) ?? false;
  },
);
