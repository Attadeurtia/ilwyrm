import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ilwyrm/data/database.dart';
import 'package:ilwyrm/data/library_stats.dart';
import 'package:ilwyrm/l10n/app_localizations.dart';
import 'package:ilwyrm/ui/stats/stats_page.dart';

Book _read(int id, DateTime finish, {String author = 'Ursula K. Le Guin'}) =>
    Book(
      id: id,
      title: 'Livre $id',
      authorText: author,
      shelf: 'read',
      startDate: finish.subtract(const Duration(days: 9)),
      finishDate: finish,
      pageCount: 250,
      isFavorite: false,
      dateAdded: DateTime(2019),
      dateModified: DateTime(2019),
    );

// Années passées fixes : l'année affichée par défaut (la plus récente) ne
// dépend pas de la date du jour.
final _books = [
  _read(1, DateTime(2019, 2, 3)),
  _read(2, DateTime(2020, 3, 14)),
  _read(3, DateTime(2020, 3, 20), author: 'Alain Damasio'),
  _read(4, DateTime(2020, 7, 1)),
];

Future<void> _pump(WidgetTester tester, Locale locale) async {
  // Téléphone étroit (360 dp) mais haut, pour que toute la page soit construite
  // et que le moindre débordement fasse échouer le test.
  tester.view.physicalSize = const Size(360, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final stats = LibraryStats.fromBooks(_books);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryStatsProvider.overrideWith((ref) => Stream.value(stats)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting());

  testWidgets('affiche les chiffres de l\'année la plus récente (français)', (
    tester,
  ) async {
    await _pump(tester, const Locale('fr'));

    expect(find.text('livres lus en 2020'), findsOneWidget);
    expect(find.text('+2 par rapport à 2019'), findsOneWidget);
    expect(find.text('750'), findsOneWidget, reason: 'pages lues en 2020');
    expect(find.text('Livres lus par mois'), findsOneWidget);
    expect(find.text('Auteurs les plus lus'), findsOneWidget);

    // Toucher la colonne de mars affiche sa valeur.
    await tester.tap(find.bySemanticsLabel(RegExp(r'^mars')));
    await tester.pumpAndSettle();
    expect(find.text('2 livres · mars', findRichText: true), findsOneWidget);

    // La vue tableau donne toutes les valeurs, sans toucher de barre.
    await tester.tap(find.byTooltip('Afficher en tableau').first);
    await tester.pumpAndSettle();
    expect(find.text('juillet'), findsOneWidget);
  });

  testWidgets('change d\'année et s\'affiche en anglais', (tester) async {
    await _pump(tester, const Locale('en'));

    expect(find.text('books read in 2020'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '2019'));
    await tester.pumpAndSettle();
    expect(find.text('book read in 2019'), findsOneWidget);
  });
}
