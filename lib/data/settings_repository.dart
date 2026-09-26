import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class SettingsRepository {
  static const _keyLibraryAvailabilityEnabled = 'library_availability_enabled';
  static const _keyLibraryApiUrl = 'library_api_url';
  static const _keyLanguageCode = 'app_language_code';

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

  /// Langue choisie dans les paramètres (`fr`, `en`…), null = celle du système.
  String? get languageCode => _prefs.getString(_keyLanguageCode);

  Future<void> setLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_keyLanguageCode);
    } else {
      await _prefs.setString(_keyLanguageCode, code);
    }
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

/// Langue imposée par l'utilisateur, ou null pour suivre le système.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(settingsRepositoryProvider).languageCode;
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    await ref
        .read(settingsRepositoryProvider)
        .setLanguageCode(locale?.languageCode);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// Langue effective de l'app (code ISO court) : celle choisie, sinon celle du
/// système si elle est traduite, sinon la langue de repli. Sert notamment à
/// privilégier les éditions dans cette langue lors des recherches.
final appLanguageProvider = Provider<String>((ref) {
  final chosen = ref.watch(localeProvider);
  if (chosen != null) return chosen.languageCode;
  return basicLocaleListResolution(
    WidgetsBinding.instance.platformDispatcher.locales,
    AppLocalizations.supportedLocales,
  ).languageCode;
});
