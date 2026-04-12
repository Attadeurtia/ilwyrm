import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'open_library_api.dart';

/// Résultat d'une opération d'import CSV.
class CsvImportResult {
  final int importedCount;
  final int skippedCount;
  final int totalCount;
  final List<String> errors;

  CsvImportResult({
    required this.importedCount,
    required this.skippedCount,
    required this.totalCount,
    this.errors = const [],
  });
}

/// Service pour l'import et l'export de données au format CSV.
///
/// Le CSV exporté contient toutes les colonnes de la table `books`,
/// plus deux colonnes supplémentaires `tags` et `tag_colors` qui encodent
/// les tags associés à chaque livre (séparés par `|`).
class CsvService {
  final AppDatabase _db;

  CsvService(this._db);

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  static const _headers = [
    'title',
    'author_text',
    'remote_id',
    'openlibrary_key',
    'finna_key',
    'inventaire_id',
    'librarything_key',
    'goodreads_key',
    'bnf_id',
    'viaf',
    'wikidata',
    'asin',
    'aasin',
    'isfdb',
    'isbn_10',
    'isbn_13',
    'oclc_number',
    'page_count',
    'current_page',
    'publisher',
    'publication_year',
    'start_date',
    'finish_date',
    'stopped_date',
    'cover_id',
    'cover_url',
    'cover_path',
    'rating',
    'review_name',
    'review_cw',
    'review_content',
    'review_published',
    'shelf',
    'shelf_name',
    'shelf_date',
    'is_favorite',
    'date_added',
    'date_modified',
    'tags',
    'tag_colors',
  ];

  /// Exporte tous les livres et leurs tags au format CSV.
  ///
  /// Retourne le [File] contenant le CSV exporté, prêt à être partagé.
  Future<File> exportToCsv() async {
    final books = await _db.getAllBooks();
    final rows = <List<dynamic>>[_headers];

    for (final book in books) {
      // Récupérer les tags de chaque livre
      final bookTags = await _db.getTagsForBook(book.id);
      final tagNames = bookTags.map((t) => t.name).join('|');
      final tagColors =
          bookTags.map((t) => t.color?.toString() ?? '').join('|');

      rows.add([
        book.title,
        book.authorText ?? '',
        book.remoteId ?? '',
        book.openlibraryKey ?? '',
        book.finnaKey ?? '',
        book.inventaireId ?? '',
        book.librarythingKey ?? '',
        book.goodreadsKey ?? '',
        book.bnfId ?? '',
        book.viaf ?? '',
        book.wikidata ?? '',
        book.asin ?? '',
        book.aasin ?? '',
        book.isfdb ?? '',
        book.isbn10 ?? '',
        book.isbn13 ?? '',
        book.oclcNumber ?? '',
        book.pageCount ?? '',
        book.currentPage ?? '',
        book.publisher ?? '',
        book.publicationYear ?? '',
        book.startDate?.toIso8601String() ?? '',
        book.finishDate?.toIso8601String() ?? '',
        book.stoppedDate?.toIso8601String() ?? '',
        book.coverId ?? '',
        book.coverUrl ?? '',
        book.coverPath ?? '',
        book.rating ?? '',
        book.reviewName ?? '',
        book.reviewCw ?? '',
        book.reviewContent ?? '',
        book.reviewPublished?.toIso8601String() ?? '',
        book.shelf,
        book.shelfName ?? '',
        book.shelfDate?.toIso8601String() ?? '',
        book.isFavorite ? 'true' : 'false',
        book.dateAdded.toIso8601String(),
        book.dateModified.toIso8601String(),
        tagNames,
        tagColors,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ilwyrm_export.csv');
    await file.writeAsString(csvData);

    return file;
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Importe des livres et leurs tags depuis un fichier CSV.
  ///
  /// [file] — le fichier CSV à importer.
  /// [fetchCovers] — si `true`, recherche les couvertures via l'API OpenLibrary
  ///   pour les livres qui n'ont pas de `cover_url` dans le CSV.
  /// [onProgress] — callback optionnel appelé avec `(livreActuel, totalLivres)`.
  Future<CsvImportResult> importFromCsv(
    File file, {
    bool fetchCovers = false,
    void Function(int current, int total)? onProgress,
  }) async {
    final input = await file.readAsString();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(
      input,
      eol: '\n',
    );

    if (rows.isEmpty) {
      return CsvImportResult(
        importedCount: 0,
        skippedCount: 0,
        totalCount: 0,
        errors: ['Le fichier CSV est vide.'],
      );
    }

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final dataRows = rows.skip(1).toList();
    final totalCount = dataRows.length;

    int importedCount = 0;
    int skippedCount = 0;
    final errors = <String>[];

    // Cache des tags existants pour éviter les requêtes en double
    final tagCache = <String, int>{};

    final openLibraryApi = fetchCovers ? OpenLibraryApi() : null;

    for (int i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      onProgress?.call(i + 1, totalCount);

      if (row.length != headers.length) {
        skippedCount++;
        errors.add('Ligne ${i + 2} : nombre de colonnes incorrect.');
        continue;
      }

      final map = <String, String>{};
      for (int j = 0; j < headers.length; j++) {
        map[headers[j]] = row[j].toString();
      }

      try {
        // Recherche optionnelle de couverture
        String? coverUrl = _nonEmpty(map['cover_url']);
        if (coverUrl == null && fetchCovers && openLibraryApi != null) {
          coverUrl = await _fetchCoverUrl(map, openLibraryApi);
        }

        // Construire le companion avec TOUS les champs
        final book = BooksCompanion(
          title: drift.Value(map['title'] ?? ''),
          authorText: drift.Value(_nonEmpty(map['author_text'])),
          remoteId: drift.Value(_nonEmpty(map['remote_id'])),
          openlibraryKey: drift.Value(_nonEmpty(map['openlibrary_key'])),
          finnaKey: drift.Value(_nonEmpty(map['finna_key'])),
          inventaireId: drift.Value(_nonEmpty(map['inventaire_id'])),
          librarythingKey: drift.Value(_nonEmpty(map['librarything_key'])),
          goodreadsKey: drift.Value(_nonEmpty(map['goodreads_key'])),
          bnfId: drift.Value(_nonEmpty(map['bnf_id'])),
          viaf: drift.Value(_nonEmpty(map['viaf'])),
          wikidata: drift.Value(_nonEmpty(map['wikidata'])),
          asin: drift.Value(_nonEmpty(map['asin'])),
          aasin: drift.Value(_nonEmpty(map['aasin'])),
          isfdb: drift.Value(_nonEmpty(map['isfdb'])),
          isbn10: drift.Value(_nonEmpty(map['isbn_10'])),
          isbn13: drift.Value(_nonEmpty(map['isbn_13'])),
          oclcNumber: drift.Value(_nonEmpty(map['oclc_number'])),
          pageCount: drift.Value(_parseInt(map['page_count'])),
          currentPage: drift.Value(_parseInt(map['current_page'])),
          publisher: drift.Value(_nonEmpty(map['publisher'])),
          publicationYear: drift.Value(_parseInt(map['publication_year'])),
          startDate: drift.Value(_parseDate(map['start_date'])),
          finishDate: drift.Value(_parseDate(map['finish_date'])),
          stoppedDate: drift.Value(_parseDate(map['stopped_date'])),
          coverId: drift.Value(_parseInt(map['cover_id'])),
          coverUrl: coverUrl != null
              ? drift.Value(coverUrl)
              : drift.Value(_nonEmpty(map['cover_url'])),
          coverPath: drift.Value(_nonEmpty(map['cover_path'])),
          rating: drift.Value(_parseInt(map['rating'])),
          reviewName: drift.Value(_nonEmpty(map['review_name'])),
          reviewCw: drift.Value(_nonEmpty(map['review_cw'])),
          reviewContent: drift.Value(_nonEmpty(map['review_content'])),
          reviewPublished: drift.Value(_parseDate(map['review_published'])),
          shelf: drift.Value(map['shelf'] ?? 'to-read'),
          shelfName: drift.Value(_nonEmpty(map['shelf_name'])),
          shelfDate: drift.Value(_parseDate(map['shelf_date'])),
          isFavorite: drift.Value(map['is_favorite'] == 'true'),
          dateAdded: drift.Value(
            _parseDate(map['date_added']) ?? DateTime.now(),
          ),
          dateModified: drift.Value(
            _parseDate(map['date_modified']) ?? DateTime.now(),
          ),
        );

        // Insérer le livre
        final bookId = await _db.into(_db.books).insertOnConflictUpdate(book);

        // Gérer les tags
        final tagsStr = _nonEmpty(map['tags']);
        final tagColorsStr = _nonEmpty(map['tag_colors']);
        if (tagsStr != null) {
          final tagNames = tagsStr.split('|').where((s) => s.isNotEmpty);
          final tagColors = tagColorsStr?.split('|') ?? [];

          int tagIndex = 0;
          for (final tagName in tagNames) {
            int? color;
            if (tagIndex < tagColors.length) {
              color = int.tryParse(tagColors[tagIndex]);
            }

            // Récupérer ou créer le tag
            int tagId;
            if (tagCache.containsKey(tagName)) {
              tagId = tagCache[tagName]!;
            } else {
              final existingTag = await _db.getTagByName(tagName);
              if (existingTag != null) {
                tagId = existingTag.id;
              } else {
                tagId = await _db.createTag(tagName, color: color);
              }
              tagCache[tagName] = tagId;
            }

            // Associer le tag au livre
            await _db.addTagToBook(bookId, tagId);
            tagIndex++;
          }
        }

        importedCount++;
      } catch (e) {
        skippedCount++;
        errors.add(
          'Ligne ${i + 2} (${map['title'] ?? '?'}) : ${e.toString()}',
        );
      }
    }

    return CsvImportResult(
      importedCount: importedCount,
      skippedCount: skippedCount,
      totalCount: totalCount,
      errors: errors,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers privés
  // ---------------------------------------------------------------------------

  /// Retourne `null` si la chaîne est vide ou "null".
  String? _nonEmpty(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    return value;
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  int? _parseInt(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    return int.tryParse(value);
  }

  Future<String?> _fetchCoverUrl(
    Map<String, String> map,
    OpenLibraryApi api,
  ) async {
    final isbn13 = _nonEmpty(map['isbn_13']);
    final isbn10 = _nonEmpty(map['isbn_10']);
    final title = _nonEmpty(map['title']);
    final author = _nonEmpty(map['author_text']);

    final query = isbn13 ?? isbn10 ?? (title != null ? '$title $author' : null);

    if (query == null) return null;

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final results = await api.searchBooks(query);
      if (results.isNotEmpty) {
        final match = results.firstWhere(
          (b) => b.coverUrl != null,
          orElse: () => results.first,
        );
        return match.coverUrl;
      }
    } catch (_) {
      // Ignorer les erreurs API
    }
    return null;
  }
}
