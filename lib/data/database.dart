import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/books.dart';
import 'tables/tags.dart';
import 'tables/book_tags.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Books, Tags, BookTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: _upgrade,
  );

  Future<void> _upgrade(Migrator m, int from, int to) async {
    if (from < 2) {
      // Destructive reset for v1 -> v2
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
      return;
    }

    if (from < 4) {
      await _tryAddColumn(m, books, books.pageCount);
    }

    if (from < 5) {
      await _tryAddColumn(m, books, books.coverId);
    }

    if (from < 6) {
      await _tryAddColumn(m, books, books.currentPage);
    }

    if (from < 7) {
      await _tryAddColumn(m, books, books.isFavorite);
    }

    if (from < 8) {
      await _tryAddColumn(m, books, books.coverPath);
    }

    if (from < 9) {
      try {
        await m.createTable(tags);
        await m.createTable(bookTags);
      } catch (e) {
        print('Error creating tags tables: $e');
      }
    }

    if (from < 11) {
      await _tryAddColumn(m, books, books.publisher);
      await _tryAddColumn(m, books, books.publicationYear);
    }
  }

  Future<void> _tryAddColumn(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    try {
      await m.addColumn(table, column);
    } catch (e) {
      print('Error adding column ${column.name}: $e');
    }
  }

  Future<int> deleteBook(int id) {
    return (delete(books)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Book>> searchBooks(String query) {
    return (select(books)..where(
          (tbl) => tbl.title.like('%$query%') | tbl.authorText.like('%$query%'),
        ))
        .get();
  }

  Future<List<Book>> getAllBooks() => select(books).get();

  // Tag Methods
  Future<int> createTag(String name, {int? color}) {
    return into(
      tags,
    ).insert(TagsCompanion(name: Value(name), color: Value(color)));
  }

  Future<List<Tag>> getAllTags() => select(tags).get();

  Future<List<Book>> getBooksByTag(int tagId) {
    final query = select(books).join([
      innerJoin(bookTags, bookTags.bookId.equalsExp(books.id)),
    ])..where(bookTags.tagId.equals(tagId));

    return query.map((row) => row.readTable(books)).get();
  }

  Future<List<Tag>> getTagsForBook(int bookId) {
    final query = select(tags).join([
      innerJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])..where(bookTags.bookId.equals(bookId));

    return query.map((row) => row.readTable(tags)).get();
  }

  Future<void> addTagToBook(int bookId, int tagId) {
    return into(bookTags).insert(
      BookTagsCompanion(bookId: Value(bookId), tagId: Value(tagId)),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeTagFromBook(int bookId, int tagId) {
    return (delete(bookTags)
          ..where((tbl) => tbl.bookId.equals(bookId) & tbl.tagId.equals(tagId)))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Riverpod Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
