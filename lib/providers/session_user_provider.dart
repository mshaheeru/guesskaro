import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import 'auth_provider.dart';
import 'local_guest_provider.dart';

/// Supabase uid when [kAuthEnabled], else stable local guest id after registration.
final Provider<String?> activeUserIdProvider = Provider<String?>((Ref ref) {
  if (kAuthEnabled) {
    final String? uid = ref.watch(currentUserProvider)?.id;
    if (uid != null) return uid;
    final AsyncValue<bool> registered = ref.watch(localGuestRegisteredProvider);
    final bool ok = registered.valueOrNull ?? false;
    if (!ok) return null;
    return kLocalGuestUserId;
  }
  final AsyncValue<bool> registered = ref.watch(localGuestRegisteredProvider);
  final bool ok = registered.valueOrNull ?? false;
  if (!ok) return null;
  return kLocalGuestUserId;
});
