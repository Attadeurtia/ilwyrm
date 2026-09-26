import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../enums.dart';

class BooksRepository {
  final AppDatabase _db;

  BooksRepository(this._db);

  // Books
  Future<List<Book>> getAllBooks() => _db.getAllBooks();

  /// Flux de toute la bibliothèque (ré-émet à chaque ajout/suppression/édition).
  /// Sert notamment à repérer les doublons lors de la recherche.
  Stream<List<Book>> watchAllBooks() => _db.select(_db.books).watch();

  Future<Book> getBook(int id) {
    return (_db.select(
      _db.books,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  /// Flux d'un livre ; émet null s'il est supprimé (au lieu d'une erreur).
  Stream<Book?> watchBook(int id) {
    return (_db.select(
      _db.books,
    )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<Book>> watchBooks({
    required String status,
    required SortOption sortOption,
    required List<String> filters,
  }) {
    return (_db.select(_db.books)
          ..where((tbl) {
            final statusFilter = tbl.shelf.equals(status);
            if (filters.contains('Favoris')) {
              return statusFilter & tbl.isFavorite.equals(true);
            }
            return statusFilter;
          })
          ..orderBy([
            (t) {
              switch (sortOption) {
                case SortOption.title:
                  return OrderingTerm(
                    expression: t.title,
                    mode: OrderingMode.asc,
                  );
                case SortOption.author:
                  return OrderingTerm(
                    expression: t.authorText,
                    mode: OrderingMode.asc,
                  );
                case SortOption.dateAdded:
                  return OrderingTerm(
                    expression: t.dateAdded,
                    mode: OrderingMode.desc,
                  );
              }
            },
          ]))
        .watch();
  }

  Future<List<Book>> searchBooks(String query) => _db.searchBooks(query);

  /// Livres d'au moins un des [authors] (recherche sur le champ auteur),
  /// réactif : la liste suit les ajouts/suppressions.
  Stream<List<Book>> watchBooksByAuthors(List<String> authors) {
    if (authors.isEmpty) return Stream.value(const []);
    return (_db.select(_db.books)
          ..where(
            (t) => authors
                .map((a) => t.authorText.like('%$a%'))
                .reduce((a, b) => a | b),
          ))
        .watch();
  }

  Future<int> addBook(BooksCompanion book) {
    return _db.into(_db.books).insert(book);
  }

  Future<bool> updateBook(BooksCompanion book) {
    return _db.update(_db.books).replace(book);
  }

  Future<int> updateBookData(int id, BooksCompanion book) {
    return (_db.update(
      _db.books,
    )..where((tbl) => tbl.id.equals(id))).write(book);
  }

  /// Enregistre le résumé récupéré (mise en cache pour l'affichage hors-ligne).
  Future<int> updateDescription(int bookId, String description) {
    return (_db.update(_db.books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(description: Value(description)),
    );
  }

  /// Remplace la couverture par une URL (et efface une éventuelle couverture
  /// locale, pour que la nouvelle s'affiche partout).
  Future<int> updateCover(int bookId, String coverUrl) {
    return (_db.update(_db.books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(
        coverUrl: Value(coverUrl),
        coverPath: const Value(null),
        dateModified: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteBook(int id) => _db.deleteBook(id);

  // Favorites
  Future<void> toggleFavorite(int bookId, bool isFavorite) {
    return (_db.update(_db.books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(isFavorite: Value(isFavorite)),
    );
  }

  // Status
  Future<void> updateStatus(int bookId, BookShelf status) async {
    // Conserve les dates pertinentes déjà saisies, complète/efface le reste
    // selon la règle d'unification (voir datesForShelf).
    final book = await getBook(bookId);
    final dates = datesForShelf(
      status,
      currentStart: book.startDate,
      currentFinish: book.finishDate,
    );

    final companion = BooksCompanion(
      shelf: Value(status.id),
      shelfName: Value(status.label),
      dateModified: Value(DateTime.now()),
      startDate: Value(dates.start),
      finishDate: Value(dates.finish),
    );

    await (_db.update(
      _db.books,
    )..where((tbl) => tbl.id.equals(bookId))).write(companion);
  }

  // Opérations groupées (transaction : atomique + une seule notification de flux)
  Future<void> updateStatusForBooks(Iterable<int> ids, BookShelf status) {
    return _db.transaction(() async {
      for (final id in ids) {
        await updateStatus(id, status);
      }
    });
  }

  Future<void> deleteBooks(Iterable<int> ids) {
    return _db.transaction(() async {
      for (final id in ids) {
        await deleteBook(id);
      }
    });
  }

  Future<void> setFavoriteForBooks(Iterable<int> ids, bool isFavorite) {
    return _db.transaction(() async {
      for (final id in ids) {
        await toggleFavorite(id, isFavorite);
      }
    });
  }

  Future<void> addTagsToBooks(Iterable<int> bookIds, Iterable<int> tagIds) {
    return _db.transaction(() async {
      for (final bookId in bookIds) {
        for (final tagId in tagIds) {
          await addTagToBook(bookId, tagId);
        }
      }
    });
  }

  // Tags
  Future<List<Tag>> getAllTags() => _db.getAllTags();
  Future<List<Tag>> getTagsForBook(int bookId) => _db.getTagsForBook(bookId);

  /// Versions réactives : l'UI suit la création de tags et les (dé)associations
  /// sans rechargement manuel.
  Stream<List<Tag>> watchAllTags() => _db.select(_db.tags).watch();

  Stream<List<Tag>> watchTagsForBook(int bookId) {
    final query = _db.select(_db.tags).join([
      innerJoin(_db.bookTags, _db.bookTags.tagId.equalsExp(_db.tags.id)),
    ])..where(_db.bookTags.bookId.equals(bookId));
    return query.map((row) => row.readTable(_db.tags)).watch();
  }
  Future<List<Book>> getBooksByTag(int tagId) => _db.getBooksByTag(tagId);

  Future<List<Book>> getBooksByTags(List<int> tagIds) async {
    if (tagIds.isEmpty) return [];
    return _booksByTagsSelectable(tagIds).get();
  }

  /// Version réactive : ré-émet quand les livres ou les associations de tags
  /// changent (indispensable pour que la liste filtrée par tag se rafraîchisse
  /// après un ajout/suppression/changement de statut).
  Stream<List<Book>> watchBooksByTags(List<int> tagIds) {
    if (tagIds.isEmpty) return Stream.value(const []);
    return _booksByTagsSelectable(tagIds).watch();
  }

  Selectable<Book> _booksByTagsSelectable(List<int> tagIds) {
    // SQL custom pour la logique ET (intersection) via HAVING.
    final placeholders = tagIds.map((_) => '?').join(',');
    final sql =
        '''
      SELECT books.*
      FROM books
      JOIN book_tags ON books.id = book_tags.book_id
      WHERE book_tags.tag_id IN ($placeholders)
      GROUP BY books.id
      HAVING COUNT(DISTINCT book_tags.tag_id) = ?
    ''';

    return _db
        .customSelect(
          sql,
          variables: [
            ...tagIds.map((id) => Variable.withInt(id)),
            Variable.withInt(tagIds.length),
          ],
          readsFrom: {_db.books, _db.bookTags},
        )
        .map((row) => _db.books.map(row.data));
  }

  Future<void> addTagToBook(int bookId, int tagId) =>
      _db.addTagToBook(bookId, tagId);
  Future<void> removeTagFromBook(int bookId, int tagId) =>
      _db.removeTagFromBook(bookId, tagId);
  Future<int> createTag(String name, {int? color}) =>
      _db.createTag(name, color: color);
  Future<Tag?> getTagByName(String name) => _db.getTagByName(name);
  Future<int> deleteTag(int id) => _db.deleteTag(id);
  Future<int> updateTag(int id, String name, {int? color}) =>
      _db.updateTag(id, name, color: color);
}

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BooksRepository(db);
});

/// Un livre, suivi en temps réel (null une fois supprimé).
final bookProvider = StreamProvider.autoDispose.family<Book?, int>(
  (ref, id) => ref.watch(booksRepositoryProvider).watchBook(id),
);

/// Tous les tags (barre de filtres, fiche).
final allTagsProvider = StreamProvider<List<Tag>>(
  (ref) => ref.watch(booksRepositoryProvider).watchAllTags(),
);

/// Tags d'un livre.
final bookTagsProvider = StreamProvider.autoDispose.family<List<Tag>, int>(
  (ref, bookId) => ref.watch(booksRepositoryProvider).watchTagsForBook(bookId),
);

/// Livres partageant au moins un auteur de [authorText] (« A, B » → A ou B).
final authorBooksProvider =
    StreamProvider.autoDispose.family<List<Book>, String>((ref, authorText) {
  final authors = authorText
      .split(',')
      .map((a) => a.trim())
      .where((a) => a.isNotEmpty)
      .toList();
  return ref.watch(booksRepositoryProvider).watchBooksByAuthors(authors);
});
