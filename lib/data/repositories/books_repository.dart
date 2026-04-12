import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import '../enums.dart';

class BooksRepository {
  final AppDatabase _db;

  BooksRepository(this._db);

  // Books
  Future<List<Book>> getAllBooks() => _db.getAllBooks();

  Future<Book> getBook(int id) {
    return (_db.select(
      _db.books,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Stream<Book> watchBook(int id) {
    return (_db.select(
      _db.books,
    )..where((tbl) => tbl.id.equals(id))).watchSingle();
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

  Future<int> deleteBook(int id) => _db.deleteBook(id);

  // Favorites
  Future<void> toggleFavorite(int bookId, bool isFavorite) {
    return (_db.update(_db.books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(isFavorite: Value(isFavorite)),
    );
  }

  // Status
  Future<void> updateStatus(int bookId, BookShelf status) async {
    final companion = BooksCompanion(
      shelf: Value(status.id),
      shelfName: Value(status.label),
      dateModified: Value(DateTime.now()),
      startDate: status == BookShelf.reading
          ? Value(DateTime.now())
          : const Value.absent(),
      finishDate: status == BookShelf.read
          ? Value(DateTime.now())
          : const Value.absent(),
    );

    await (_db.update(
      _db.books,
    )..where((tbl) => tbl.id.equals(bookId))).write(companion);
  }

  // Tags
  Future<List<Tag>> getAllTags() => _db.getAllTags();
  Future<List<Tag>> getTagsForBook(int bookId) => _db.getTagsForBook(bookId);
  Future<List<Book>> getBooksByTag(int tagId) => _db.getBooksByTag(tagId);

  Future<List<Book>> getBooksByTags(List<int> tagIds) async {
    if (tagIds.isEmpty) return [];

    // Custom SQL for AND logic (Intersection) to ensure HAVING support
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

    final rows = await _db
        .customSelect(
          sql,
          variables: [
            ...tagIds.map((id) => Variable.withInt(id)),
            Variable.withInt(tagIds.length),
          ],
          readsFrom: {_db.books, _db.bookTags},
        )
        .get();

    return rows.map((row) => _db.books.map(row.data)).toList();
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
