import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/csv_service.dart';
import 'package:ilwyrm/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addBook(BooksCompanion book) => db.into(db.books).insert(book);

  test('aller-retour CSV : ISBN-10 à zéro initial, titre numérique, résumé '
      'multiligne et tags conservés', () async {
    final id = await addBook(
      const BooksCompanion(
        title: Value('007'),
        authorText: Value('Ian Fleming'),
        isbn10: Value('0441013597'),
        isbn13: Value('9780441013593'),
        description: Value('Première ligne.\nSeconde ligne, avec "guillemets".'),
        shelf: Value('read'),
      ),
    );
    final tagId = await db.createTag('SF', color: 0xFF00FF00);
    await db.addTagToBook(id, tagId);

    final csv = await CsvService(db).buildCsv();

    // Import dans une base vierge.
    final other = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(other.close);
    final result = await CsvService(other).importFromCsvString(csv);

    expect(result.importedCount, 1);
    expect(result.errors, isEmpty);
    final book = (await other.getAllBooks()).single;
    expect(book.title, '007');
    expect(book.isbn10, '0441013597');
    expect(book.isbn13, '9780441013593');
    expect(book.description, 'Première ligne.\nSeconde ligne, avec "guillemets".');
    final tags = await other.getTagsForBook(book.id);
    expect(tags.map((t) => t.name), ['SF']);
    expect(tags.single.color, 0xFF00FF00);
  });

  test('ré-importer le même CSV met à jour au lieu de dupliquer', () async {
    await addBook(
      const BooksCompanion(
        title: Value('Dune'),
        authorText: Value('Frank Herbert'),
        isbn13: Value('9782266320481'),
      ),
    );
    final service = CsvService(db);
    final csv = await service.buildCsv();

    final result = await service.importFromCsvString(csv);

    expect(result.importedCount, 1);
    expect(await db.getAllBooks(), hasLength(1));
  });

  test('une ligne au mauvais nombre de colonnes est ignorée, pas le reste',
      () async {
    const csv = 'title,author_text\r\n'
        'Fondation,Isaac Asimov\r\n'
        'Ligne cassée\r\n';

    final result = await CsvService(db).importFromCsvString(csv);

    expect(result.importedCount, 1);
    expect(result.skippedCount, 1);
    expect((await db.getAllBooks()).single.title, 'Fondation');
  });
}
