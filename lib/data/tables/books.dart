import 'package:drift/drift.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Core Info
  TextColumn get title => text()();
  TextColumn get authorText => text().named('author_text').nullable()();

  // Identifiers
  TextColumn get remoteId => text().named('remote_id').nullable().unique()();
  TextColumn get openlibraryKey => text().named('openlibrary_key').nullable()();
  TextColumn get finnaKey => text().named('finna_key').nullable()();
  TextColumn get inventaireId => text().named('inventaire_id').nullable()();
  TextColumn get librarythingKey =>
      text().named('librarything_key').nullable()();
  TextColumn get goodreadsKey => text().named('goodreads_key').nullable()();
  TextColumn get bnfId => text().named('bnf_id').nullable()();
  TextColumn get viaf => text().nullable()();
  TextColumn get wikidata => text().nullable()();
  TextColumn get asin => text().nullable()();
  TextColumn get aasin => text().nullable()();
  TextColumn get isfdb => text().nullable()();
  TextColumn get isbn10 => text().named('isbn_10').nullable()();
  TextColumn get isbn13 => text().named('isbn_13').nullable()();
  TextColumn get oclcNumber => text().named('oclc_number').nullable()();
  IntColumn get pageCount => integer().named('page_count').nullable()();

  // Reading Status & Dates
  DateTimeColumn get startDate => dateTime().named('start_date').nullable()();
  DateTimeColumn get finishDate => dateTime().named('finish_date').nullable()();
  DateTimeColumn get stoppedDate =>
      dateTime().named('stopped_date').nullable()();

  // Review & Rating
  IntColumn get rating => integer().nullable()(); // Assuming 1-5 stars
  TextColumn get reviewName => text().named('review_name').nullable()();
  TextColumn get reviewCw =>
      text().named('review_cw').nullable()(); // Content Warning
  TextColumn get reviewContent => text().named('review_content').nullable()();
  DateTimeColumn get reviewPublished =>
      dateTime().named('review_published').nullable()();

  // Shelf Info
  TextColumn get shelf =>
      text().withDefault(const Constant('to-read'))(); // read, reading, to-read
  TextColumn get shelfName => text().named('shelf_name').nullable()();
  DateTimeColumn get shelfDate => dateTime().named('shelf_date').nullable()();

  // Local Metadata
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateModified =>
      dateTime().withDefault(currentDateAndTime)();
}
