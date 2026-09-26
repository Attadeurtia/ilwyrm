import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/database.dart';
import 'package:ilwyrm/data/enums.dart';
import 'package:ilwyrm/data/text_normalize.dart';
import 'package:ilwyrm/ui/home/shelf_books_provider.dart';

Book _book(int id, String title, {String? author, DateTime? added}) => Book(
      id: id,
      title: title,
      authorText: author,
      shelf: 'to_read',
      isFavorite: false,
      dateAdded: added ?? DateTime(2024),
      dateModified: DateTime(2024),
    );

void main() {
  test('normalizeText : minuscules, sans accents ni ponctuation', () {
    expect(normalizeText('  L’Écume des jours ! '), 'l ecume des jours');
    expect(normalizeText('Œuvres — Tome 1'), 'oeuvres tome 1');
    expect(normalizeText('Łódź, Straße'), 'lodz strasse');
    // Accent combinant (texte décomposé) : ignoré, le mot reste entier.
    expect(normalizeText('Café noir'), 'cafe noir');
    expect(normalizeText('刘慈欣'), '');
  });

  test('titlesMatch : sous-titre accepté, suite homonyme refusée', () {
    expect(titlesMatch('La Horde du Contrevent', 'La horde du contrevent'), isTrue);
    expect(
      titlesMatch('Le problème à trois corps', 'Le Probleme a trois corps : roman'),
      isTrue,
    );
    expect(titlesMatch('Dune', 'Dune Messiah'), isFalse);
    expect(titlesMatch('Dune', 'Dune'), isTrue);
  });

  test('tri par titre insensible aux accents et à la casse', () {
    final sorted = sortBooks([
      _book(1, 'Zadig'),
      _book(2, 'Écume des jours'),
      _book(3, 'dune'),
      _book(4, 'À la recherche du temps perdu'),
    ], SortOption.title);

    expect(sorted.map((b) => b.id), [4, 3, 2, 1]);
  });

  test('tri par date d\'ajout : les plus récents d\'abord', () {
    final sorted = sortBooks([
      _book(1, 'A', added: DateTime(2024, 1, 1)),
      _book(2, 'B', added: DateTime(2025, 1, 1)),
    ], SortOption.dateAdded);

    expect(sorted.map((b) => b.id), [2, 1]);
  });
}
