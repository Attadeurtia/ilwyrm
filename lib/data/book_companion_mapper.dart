import 'package:drift/drift.dart';

import 'book_search_api.dart';
import 'database.dart';

extension ExternalBookCompanion on ExternalBook {
  /// Construit un [BooksCompanion] prêt à insérer à partir d'une fiche externe,
  /// en conservant un maximum d'identifiants (ISBN 10/13, OpenLibrary,
  /// Inventaire, Wikidata) pour enrichir la base.
  BooksCompanion toBooksCompanion({
    String shelf = 'to_read',
    String shelfName = 'À lire',
  }) {
    final now = DateTime.now();
    return BooksCompanion(
      title: Value(title),
      authorText: Value(authorText),
      publisher:
          publisher != null ? Value(publisher) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      publicationYear: firstPublishYear != null
          ? Value(firstPublishYear)
          : const Value.absent(),
      pageCount:
          numberOfPages != null ? Value(numberOfPages) : const Value.absent(),
      shelf: Value(shelf),
      shelfName: Value(shelfName),
      openlibraryKey:
          openlibraryKey != null ? Value(openlibraryKey) : const Value.absent(),
      bnfId: bnfId != null ? Value(bnfId) : const Value.absent(),
      inventaireId:
          inventaireId != null ? Value(inventaireId) : const Value.absent(),
      wikidata: wikidata != null ? Value(wikidata) : const Value.absent(),
      isbn13: isbn13 != null ? Value(isbn13) : const Value.absent(),
      isbn10: isbn10 != null ? Value(isbn10) : const Value.absent(),
      coverUrl: coverUrl != null ? Value(coverUrl) : const Value.absent(),
      dateAdded: Value(now),
      dateModified: Value(now),
    );
  }
}
