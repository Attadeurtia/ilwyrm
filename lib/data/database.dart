import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/books.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Destructive reset for v1 -> v2
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
          return;
        }

        if (from < 4) {
          try {
            await m.addColumn(books, books.pageCount);
          } catch (e) {
            print('Error adding pageCount column: $e');
          }
        }

        if (from < 5) {
          try {
            await m.addColumn(books, books.coverId);
          } catch (e) {
            print('Error adding coverId column: $e');
          }
        }

        if (from < 6) {
          try {
            await m.addColumn(books, books.currentPage);
          } catch (e) {
            print('Error adding currentPage column: $e');
          }
        }

        if (from < 7) {
          try {
            await m.addColumn(books, books.isFavorite);
          } catch (e) {
            print('Error adding isFavorite column: $e');
          }
        }
      },
    );
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
