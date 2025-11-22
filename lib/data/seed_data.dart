import 'package:drift/drift.dart';
import 'database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  final count = await db.select(db.books).get().then((l) => l.length);
  if (count > 0) return; // Already seeded

  await db.batch((batch) {
    batch.insertAll(db.books, [
      BooksCompanion(
        title: const Value('Le premier jour du reste de ma vie'),
        authorText: const Value('Virginie Grimaldi'),
        remoteId: const Value('https://bookwyrm.social/book/2160704'),
        openlibraryKey: const Value('OL39815586M'),
        isbn10: const Value('2253098469'),
        isbn13: const Value('9782253098461'),
        oclcNumber: const Value('953079987'),
        startDate: Value(DateTime(2025, 11, 20)),
        finishDate: Value(DateTime(2025, 11, 21)),
        shelf: const Value('read'),
        shelfName: const Value('Read'),
        shelfDate: Value(DateTime(2025, 11, 21)),
        rating: const Value(5), // Assuming a rating
      ),
      BooksCompanion(
        title: const Value('Propaganda'),
        authorText: const Value('Edward L. Bernays'),
        remoteId: const Value('https://bookwyrm.social/book/306835'),
        openlibraryKey: const Value('OL17764619M'),
        isbn10: const Value('2355220018'),
        isbn13: const Value('9782355220012'),
        startDate: Value(DateTime(2025, 10, 11)),
        shelf: const Value('reading'),
        shelfName: const Value('Currently Reading'),
        shelfDate: Value(DateTime(2025, 10, 13)),
      ),
      // Adding a "To Read" book for completeness
      const BooksCompanion(
        title: Value('Dune'),
        authorText: Value('Frank Herbert'),
        shelf: Value('to_read'),
        shelfName: Value('To Read'),
      ),
      const BooksCompanion(
        title: Value('Shin Zero'),
        authorText: Value('Frank Herbert'),
        shelf: Value('to_read'),
        shelfName: Value('To Read'),
      ),
      const BooksCompanion(
        title: Value('Shin Zero'),
        authorText: Value('Frank Herbert'),
        shelf: Value('to_read'),
        shelfName: Value('To Read'),
      ),
      const BooksCompanion(
        title: Value(' La Terre verte'),
        authorText: Value('Hervé Tanquerelle'),
        shelf: Value('to_read'),
        shelfName: Value('To Read'),
      ),
      const BooksCompanion(
        title: Value('Fantasy'),
        authorText: Value('Yoann Kavege'),
        shelf: Value('reading'),
        shelfName: Value('Currently Reading'),
      ),
      const BooksCompanion(
        title: Value('Wilbur - Electric Miles'),
        authorText: Value('Yoann Kavege'),
        shelf: Value('reading'),
        shelfName: Value('Currently Reading'),
      ),
    ]);
  });
}
