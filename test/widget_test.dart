import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/database.dart';
import 'package:ilwyrm/ui/books/book_cover.dart';

Book _book({String title = 'Titre Test', String? author}) => Book(
      id: 1,
      title: title,
      authorText: author,
      shelf: 'to_read',
      isFavorite: false,
      dateAdded: DateTime(2024),
      dateModified: DateTime(2024),
    );

void main() {
  testWidgets('BookCover affiche le titre en repli sans couverture',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 180,
            child: BookCover(book: _book(title: 'Le Guide du voyageur')),
          ),
        ),
      ),
    );
    await tester.pump();

    // Aucune couverture → le repli affiche le titre.
    expect(find.text('Le Guide du voyageur'), findsOneWidget);
  });

  testWidgets('BookCover montre aussi l\'auteur en repli', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 180,
            child: BookCover(book: _book(title: 'Dune', author: 'Frank Herbert')),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Frank Herbert'), findsOneWidget);
  });
}
