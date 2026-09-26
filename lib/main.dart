import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'data/cover_storage.dart';
import 'data/database.dart';
//import 'data/seed_data.dart';
import 'data/settings_repository.dart';
import 'l10n/l10n.dart';
import 'ui/home/home_page.dart';
import 'ui/theme_extensions.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisations indépendantes lancées en parallèle (démarrage plus court).
  final prefsFuture = SharedPreferences.getInstance();
  // Formats de date de toutes les langues de l'app.
  await Future.wait([_loadEnv(), initializeDateFormatting()]);
  final prefs = await prefsFuture;

  final db = AppDatabase();
  //await seedDatabase(db);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IlwyrmApp(),
    ),
  );

  // En tâche de fond, sans retarder le démarrage.
  unawaited(maintainLocalCovers(db));
}

/// Ne pas planter au démarrage si .env est absent (clone/build sans secret) :
/// la recherche Google se dégrade, le reste de l'app fonctionne.
Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Initialise dotenv à vide pour que maybeGet() renvoie null sans planter.
    dotenv.loadFromString(isOptional: true);
  }
}

class IlwyrmApp extends ConsumerWidget {
  const IlwyrmApp({super.key});

  // Default seed color used as fallback
  static const Color _seedColor = Color(0xFF006978);

  static ThemeData _theme(ColorScheme scheme, SemanticColors semantic) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : null,
      ),
      extensions: [semantic],
      // Transitions de page natives de chaque plateforme (défaut Flutter) :
      // sur Android, celle d'Android 14+ qui suit le geste « retour prédictif »
      // (et un fondu vers l'avant sinon) ; glissement horizontal sur iOS.
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Langue choisie dans les paramètres ; null = celle du téléphone.
    final locale = ref.watch(localeProvider);
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Use dynamic color schemes if available (Android 12+)
        // Otherwise fall back to seed color
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // Dynamic colors are available, use them
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Dynamic colors not available, use seed color
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: _theme(lightColorScheme, SemanticColors.light),
          darkTheme: _theme(darkColorScheme, SemanticColors.dark),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        );
      },
    );
  }
}
