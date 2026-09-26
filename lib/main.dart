import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'data/cover_storage.dart';
import 'data/database.dart';
//import 'data/seed_data.dart';
import 'data/settings_repository.dart';
import 'ui/home/home_page.dart';
import 'ui/theme_extensions.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisations indépendantes lancées en parallèle (démarrage plus court).
  final prefsFuture = SharedPreferences.getInstance();
  await Future.wait([_loadEnv(), initializeDateFormatting('fr_FR', null)]);
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

class IlwyrmApp extends StatelessWidget {
  const IlwyrmApp({super.key});

  // Default seed color used as fallback
  static const Color _seedColor = Color(0xFF006978);

  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
    },
  );

  static ThemeData _theme(ColorScheme scheme, SemanticColors semantic) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : null,
      ),
      extensions: [semantic],
      pageTransitionsTheme: _pageTransitions,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: 'Ilwyrm',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: _theme(lightColorScheme, SemanticColors.light),
          darkTheme: _theme(darkColorScheme, SemanticColors.dark),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'), // French default
            Locale('en'),
            Locale('es'),
            Locale('de'),
          ],
          home: const HomePage(),
        );
      },
    );
  }
}
