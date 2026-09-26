import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/database.dart';
import 'package:ilwyrm/data/library_stats.dart';

Book _book(
  int id, {
  String shelf = 'read',
  String? author,
  DateTime? start,
  DateTime? finish,
  int? pages,
  bool favorite = false,
}) => Book(
  id: id,
  title: 'Livre $id',
  authorText: author,
  shelf: shelf,
  startDate: start,
  finishDate: finish,
  pageCount: pages,
  isFavorite: favorite,
  dateAdded: DateTime(2020),
  dateModified: DateTime(2020),
);

void main() {
  test('compte les livres par statut et les favoris', () {
    final stats = LibraryStats.fromBooks([
      _book(1, shelf: 'to_read', favorite: true),
      _book(2, shelf: 'reading'),
      _book(3, finish: DateTime(2020, 3, 1)),
      _book(4, finish: DateTime(2020, 3, 9), favorite: true),
    ]);

    expect(stats.total, 4);
    expect(stats.toRead, 1);
    expect(stats.reading, 1);
    expect(stats.read, 2);
    expect(stats.favorites, 2);
  });

  test('année de lecture : par mois, pages connues, durée moyenne', () {
    final stats = LibraryStats.fromBooks([
      _book(1, start: DateTime(2020, 1, 1), finish: DateTime(2020, 1, 11), pages: 300),
      // Commencé et fini le même jour : compte pour 1 jour, comme sur la fiche.
      _book(2, start: DateTime(2020, 3, 5), finish: DateTime(2020, 3, 5)),
      _book(3, finish: DateTime(2020, 3, 20), pages: 150),
      _book(4, finish: DateTime(2019, 12, 31)),
    ]);

    final y = stats.yearStats(2020);
    expect(y.booksRead, 3);
    expect(y.perMonth[0], 1);
    expect(y.perMonth[2], 2);
    expect(y.perMonth.fold<int>(0, (a, b) => a + b), 3);
    expect(y.pagesRead, 450);
    expect(y.averageDays, 6, reason: '(10 + 1) / 2 arrondi');
    expect(stats.years, [2020, 2019]);
  });

  test('sans pages ni dates connues : valeurs absentes plutôt que 0', () {
    final y = LibraryStats.fromBooks([
      _book(1, finish: DateTime(2020, 6, 1)),
    ]).yearStats(2020);

    expect(y.pagesRead, isNull);
    expect(y.averageDays, isNull);
  });

  test('livres lus par année : années sans lecture comptées à 0', () {
    final stats = LibraryStats.fromBooks([
      _book(1, finish: DateTime(2017, 5, 1)),
      _book(2, finish: DateTime(2020, 5, 1)),
      _book(3, finish: DateTime(2020, 6, 1)),
    ]);

    expect(stats.booksPerYear, [(2017, 1), (2018, 0), (2019, 0), (2020, 2)]);
  });

  test('auteurs les plus lus : co-auteurs comptés, graphies fusionnées', () {
    final stats = LibraryStats.fromBooks([
      _book(1, author: 'Émile Zola', finish: DateTime(2020)),
      _book(2, author: 'Emile Zola', finish: DateTime(2020)),
      _book(3, author: 'Terry Pratchett, Neil Gaiman', finish: DateTime(2020)),
      _book(4, author: 'Unknown Author', finish: DateTime(2020)),
      // À lire : ne compte pas parmi les auteurs lus.
      _book(5, shelf: 'to_read', author: 'Neil Gaiman'),
    ]);

    expect(stats.topAuthors.first, ('Émile Zola', 2));
    expect(stats.topAuthors.map((e) => e.$1), [
      'Émile Zola',
      'Neil Gaiman',
      'Terry Pratchett',
    ]);
  });
}
