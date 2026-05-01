/// SharedPreferences keys for offline guest profile and locale.
class LocalPlayerPrefs {
  LocalPlayerPrefs._();

  /// User finished `/welcome` (name entry).
  static const String keyGuestReady = 'local_player_ready_v1';

  /// JSON map for [ProfileModel].
  static const String keyProfileJson = 'local_profile_json_v1';

  /// `'ur'` | `'en'`.
  static const String keyAppLocale = 'app_locale_v1';
}
