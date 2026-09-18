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

/// État immuable des paramètres, exposé de façon réactive pour que l'UI se mette
/// à jour instantanément partout quand un réglage change.
class AppSettings {
  final bool libraryAvailabilityEnabled;
  final String? libraryApiUrl;

  const AppSettings({
    required this.libraryAvailabilityEnabled,
    this.libraryApiUrl,
  });

  AppSettings copyWith({bool? libraryAvailabilityEnabled, String? libraryApiUrl}) {
    return AppSettings(
      libraryAvailabilityEnabled:
          libraryAvailabilityEnabled ?? this.libraryAvailabilityEnabled,
      libraryApiUrl: libraryApiUrl ?? this.libraryApiUrl,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.read(settingsRepositoryProvider);
    return AppSettings(
      libraryAvailabilityEnabled: repo.isLibraryAvailabilityEnabled,
      libraryApiUrl: repo.libraryApiUrl,
    );
  }

  Future<void> setLibraryAvailabilityEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setLibraryAvailabilityEnabled(enabled);
    state = state.copyWith(libraryAvailabilityEnabled: enabled);
  }

  Future<void> setLibraryApiUrl(String url) async {
    await ref.read(settingsRepositoryProvider).setLibraryApiUrl(url);
    state = state.copyWith(libraryApiUrl: url);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
