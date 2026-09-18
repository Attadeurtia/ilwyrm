import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/book_search_api.dart';
import 'package:ilwyrm/data/database.dart';
import 'package:ilwyrm/data/library_index.dart';

Book _book({
  required int id,
  required String title,
  String? author,
  String? isbn13,
  String? isbn10,
  String? openlibraryKey,
}) =>
    Book(
      id: id,
      title: title,
      authorText: author,
      isbn13: isbn13,
      isbn10: isbn10,
      openlibraryKey: openlibraryKey,
      shelf: 'to_read',
      isFavorite: false,
      dateAdded: DateTime(2024),
      dateModified: DateTime(2024),
    );

ExternalBook _external({
  required String title,
  String author = 'Unknown Author',
  List<String>? isbns,
  String? openlibraryKey,
}) =>
    ExternalBook(
      key: 'k',
      title: title,
      authorText: author,
      source: 'openlibrary',
      isbns: isbns,
      openlibraryKey: openlibraryKey,
    );

void main() {
  group('LibraryIndex — détection de doublon', () {
    test('correspondance par ISBN-13', () {
      final index = buildLibraryIndex([
        _book(id: 1, title: 'Dune', author: 'Frank Herbert', isbn13: '9780441172719'),
      ]);
      // Titre/auteur différents, mais même ISBN → doublon.
      final ext = _external(title: 'Autre titre', author: 'Autre', isbns: ['978-0-441-17271-9']);
      expect(index.contains(ext), isTrue);
      expect(index.findId(ext), 1);
    });

    test('correspondance par ISBN-10', () {
      final index = buildLibraryIndex([
        _book(id: 7, title: 'Dune', author: 'Frank Herbert', isbn10: '0441172717'),
      ]);
      final ext = _external(title: 'Dune', author: 'Frank Herbert', isbns: ['0441172717']);
      expect(index.findId(ext), 7);
    });

    test('correspondance par clé OpenLibrary', () {
      final index = buildLibraryIndex([
        _book(id: 3, title: 'Titre', author: 'Auteur', openlibraryKey: 'OL123W'),
      ]);
      final ext = _external(title: 'X', author: 'Y', openlibraryKey: 'OL123W');
      expect(index.findId(ext), 3);
    });

    test('correspondance titre + auteur sans ISBN', () {
      final index = buildLibraryIndex([
        _book(id: 5, title: "L'Étranger", author: 'Albert Camus'),
      ]);
      // Accents/casse différents, pas d'ISBN → toujours un doublon.
      final ext = _external(title: 'l etranger', author: 'ALBERT CAMUS');
      expect(index.contains(ext), isTrue);
      expect(index.findId(ext), 5);
    });

    test('tolère l\'ordre des tokens de l\'auteur', () {
      final index = buildLibraryIndex([
        _book(id: 9, title: 'Le Problème à trois corps', author: 'Liu Cixin'),
      ]);
      final ext = _external(title: 'Le Problème à trois corps', author: 'Cixin Liu');
      expect(index.findId(ext), 9);
    });

    test('titres identiques mais auteurs différents → pas un doublon', () {
      final index = buildLibraryIndex([
        _book(id: 2, title: 'Dune', author: 'Frank Herbert'),
      ]);
      final ext = _external(title: 'Dune', author: 'Nicolas Allard');
      expect(index.contains(ext), isFalse);
    });

    test('auteur inconnu sans identifiant → jamais un doublon', () {
      final index = buildLibraryIndex([
        _book(id: 4, title: 'Sans Auteur'),
      ]);
      final ext = _external(title: 'Sans Auteur'); // author = 'Unknown Author'
      expect(index.contains(ext), isFalse);
    });

    test('correspondance ISBN même si ce n\'est pas le premier de la liste', () {
      final index = buildLibraryIndex([
        _book(id: 11, title: 'Dune', author: 'Frank Herbert', isbn13: '9788373017238'),
      ]);
      // Une fiche fusionnée cumule plusieurs ISBN ; le bon n'est pas en tête.
      final ext = _external(
        title: 'Dune',
        author: 'Frank Herbert',
        isbns: ['9780441172719', '978-83-7301-723-8'],
      );
      expect(index.findId(ext), 11);
    });

    test('éditions différentes (ISBN différents), même titre+auteur → doublon', () {
      final index = buildLibraryIndex([
        _book(id: 12, title: 'Dune', author: 'Frank Herbert', isbn13: '9780441172719'),
      ]);
      final ext = _external(
        title: 'Dune',
        author: 'Frank Herbert',
        isbns: ['9782221252055'],
      );
      expect(index.contains(ext), isTrue);
      expect(index.findId(ext), 12);
    });

    test('index vide → aucun doublon', () {
      expect(LibraryIndex.empty.contains(_external(title: 'Dune', author: 'Frank Herbert')),
          isFalse);
    });
  });
}
