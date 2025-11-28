import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database.dart';
import 'data/seed_data.dart';
import 'data/settings_repository.dart';
import 'ui/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  await seedDatabase(db);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IlwyrmApp(),
    ),
  );
}

class IlwyrmApp extends StatelessWidget {
  const IlwyrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ilwyrm',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006978),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006978),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
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
  }
}
