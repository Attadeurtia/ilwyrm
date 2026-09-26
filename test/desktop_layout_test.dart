import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/database.dart';
import 'package:ilwyrm/data/repositories/books_repository.dart';
import 'package:ilwyrm/data/settings_repository.dart';
import 'package:ilwyrm/l10n/app_localizations.dart';
import 'package:ilwyrm/ui/adaptive.dart';
import 'package:ilwyrm/ui/home/home_page.dart';
import 'package:ilwyrm/ui/home/shelf_books_provider.dart';
import 'package:ilwyrm/ui/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Book _book(int id, String title) => Book(
  id: id,
  title: title,
  shelf: 'to_read',
  isFavorite: false,
  dateAdded: DateTime(2020),
  dateModified: DateTime(2020),
);

/// Accueil sur une fenêtre d'ordinateur Linux (1280 × 800), avec des données
/// fournies directement aux providers (sans base de données).
Future<void> _pumpDesktopHome(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final preferences = await SharedPreferences.getInstance();
  final navigatorKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        shelfBooksProvider.overrideWith(
          (ref, shelf) => Stream.value([
            for (var i = 1; i <= 12; i++) _book(i, 'Livre $i'),
          ]),
        ),
        allTagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
      ],
      // Même câblage clavier / souris que l'app (main.dart).
      child: escapeGoesBack(
        navigatorKey,
        MaterialApp(
          navigatorKey: navigatorKey,
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => mouseBackButton(navigatorKey, child),
          home: const HomePage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Tests exécutés comme sous Linux (la plateforme simulée est remise à zéro
/// par le framework à la fin de chaque test).
final _linux = TargetPlatformVariant.only(TargetPlatform.linux);

void main() {
  testWidgets(
    'fenêtre large : rail de navigation, pas de scanner, bouton de '
    'rafraîchissement',
    variant: _linux,
    (tester) async {
      await _pumpDesktopHome(tester);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(SpeedDial), findsNothing);
      expect(find.byIcon(Icons.qr_code_scanner), findsNothing);
      expect(find.byTooltip('Rafraîchir les couvertures (F5)'), findsOneWidget);

      // Changer d'onglet depuis le rail.
      await tester.tap(find.text('Lus'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        2,
      );
    },
  );

  testWidgets(
    'grille : plus de colonnes sur une fenêtre large',
    variant: _linux,
    (tester) async {
      await _pumpDesktopHome(tester, prefs: {'home_view_option': 'grid'});

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, greaterThan(3));
    },
  );

  testWidgets(
    'clavier : Ctrl+F ouvre la recherche, Échap revient en arrière',
    variant: _linux,
    (tester) async {
      await _pumpDesktopHome(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Rechercher un livre…'), findsOneWidget);

      // Échap ferme la recherche (le champ de saisie a le focus).
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Rechercher un livre…'), findsNothing);

      // Paramètres ouverts, puis Échap : retour à l'accueil.
      await tester.tap(find.byTooltip('Paramètres'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsNothing);
    },
  );

  testWidgets(
    'téléphone (fenêtre étroite Android) : barre du bas et scanner',
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            shelfBooksProvider.overrideWith(
              (ref, shelf) => Stream.value([_book(1, 'Dune')]),
            ),
            allTagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(SpeedDial), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    },
  );
}
