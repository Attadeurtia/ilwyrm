import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'enums.dart';
import 'repositories/books_repository.dart';
import 'text_normalize.dart';

/// Chiffres d'une année de lecture (livres terminés cette année-là).
class ReadingYearStats {
  const ReadingYearStats({
    required this.year,
    required this.booksRead,
    required this.pagesRead,
    required this.averageDays,
    required this.perMonth,
  });

  final int year;
  final int booksRead;

  /// Somme des pages connues des livres lus (null si aucune n'est connue).
  final int? pagesRead;

  /// Durée moyenne de lecture en jours (null sans dates de début et de fin).
  final int? averageDays;

  /// Livres terminés par mois (index 0 = janvier).
  final List<int> perMonth;
}

/// Statistiques de la bibliothèque, calculées à partir de la liste des livres.
class LibraryStats {
  LibraryStats._({
    required this.total,
    required this.toRead,
    required this.reading,
    required this.read,
    required this.favorites,
    required Map<int, List<Book>> finishedByYear,
    required this.topAuthors,
  }) : _finishedByYear = finishedByYear;

  factory LibraryStats.fromBooks(List<Book> books) {
    var toRead = 0, reading = 0, read = 0, favorites = 0;
    final finishedByYear = <int, List<Book>>{};
    // Auteur normalisé → (graphie affichée, nombre de livres lus).
    final authors = <String, (String, int)>{};

    for (final book in books) {
      if (book.isFavorite) favorites++;
      switch (BookShelf.fromId(book.shelf)) {
        case BookShelf.toRead:
          toRead++;
        case BookShelf.reading:
          reading++;
        case BookShelf.read:
          read++;
          final finish = book.finishDate;
          if (finish != null) {
            finishedByYear.putIfAbsent(finish.year, () => []).add(book);
          }
          // « A, B » : chaque auteur compte.
          for (final name in (book.authorText ?? '').split(',')) {
            final display = name.trim();
            final key = normalizeText(display);
            if (key.isEmpty || key == 'unknown author') continue;
            final previous = authors[key];
            authors[key] = (previous?.$1 ?? display, (previous?.$2 ?? 0) + 1);
          }
      }
    }

    final topAuthors = authors.values.toList()
      ..sort((a, b) {
        final byCount = b.$2.compareTo(a.$2);
        return byCount != 0 ? byCount : a.$1.compareTo(b.$1);
      });

    return LibraryStats._(
      total: books.length,
      toRead: toRead,
      reading: reading,
      read: read,
      favorites: favorites,
      finishedByYear: finishedByYear,
      topAuthors: topAuthors,
    );
  }

  final int total;
  final int toRead;
  final int reading;
  final int read;
  final int favorites;
  final Map<int, List<Book>> _finishedByYear;

  /// Auteurs des livres lus, du plus lu au moins lu : (nom, nombre de livres).
  final List<(String, int)> topAuthors;

  /// Années où au moins un livre a été terminé, de la plus récente à la plus
  /// ancienne.
  List<int> get years => _finishedByYear.keys.toList()..sort((a, b) => b - a);

  /// Nombre de livres terminés par année, de la plus ancienne à la plus
  /// récente, sans trou (une année sans lecture compte 0).
  List<(int, int)> get booksPerYear {
    if (_finishedByYear.isEmpty) return const [];
    final sorted = years.reversed.toList();
    return [
      for (var y = sorted.first; y <= sorted.last; y++)
        (y, _finishedByYear[y]?.length ?? 0),
    ];
  }

  ReadingYearStats yearStats(int year) {
    final books = _finishedByYear[year] ?? const <Book>[];
    final perMonth = List<int>.filled(12, 0);
    var pages = 0;
    var hasPages = false;
    var totalDays = 0;
    var timed = 0;
    for (final book in books) {
      perMonth[book.finishDate!.month - 1]++;
      if (book.pageCount != null) {
        pages += book.pageCount!;
        hasPages = true;
      }
      final start = book.startDate;
      if (start != null) {
        final days = book.finishDate!.difference(start).inDays;
        // Même règle que la fiche : une lecture compte au moins un jour.
        totalDays += days < 1 ? 1 : days;
        timed++;
      }
    }
    return ReadingYearStats(
      year: year,
      booksRead: books.length,
      pagesRead: hasPages ? pages : null,
      averageDays: timed == 0 ? null : (totalDays / timed).round(),
      perMonth: perMonth,
    );
  }
}

/// Statistiques recalculées à chaque changement de la bibliothèque.
final libraryStatsProvider = StreamProvider.autoDispose<LibraryStats>(
  (ref) => ref
      .watch(booksRepositoryProvider)
      .watchAllBooks()
      .map(LibraryStats.fromBooks),
);
