import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyLibraryAvailabilityEnabled = 'library_availability_enabled';
  static const _keyLibraryApiUrl = 'library_api_url';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  bool get isLibraryAvailabilityEnabled =>
      _prefs.getBool(_keyLibraryAvailabilityEnabled) ?? false;

  Future<void> setLibraryAvailabilityEnabled(bool enabled) async {
    await _prefs.setBool(_keyLibraryAvailabilityEnabled, enabled);
  }

  String? get libraryApiUrl => _prefs.getString(_keyLibraryApiUrl);

  Future<void> setLibraryApiUrl(String url) async {
    await _prefs.setString(_keyLibraryApiUrl, url);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});
