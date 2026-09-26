import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'enums.dart';
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
    'description',
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
    final csvData = await buildCsv();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ilwyrm_export.csv');
    await file.writeAsString(csvData);
    return file;
  }

  /// Contenu CSV de toute la bibliothèque (livres + tags).
  Future<String> buildCsv() async {
    final books = await _db.getAllBooks();
    final tagsByBook = await _db.getTagsByBook();
    final rows = <List<dynamic>>[_headers];

    for (final book in books) {
      final bookTags = tagsByBook[book.id] ?? const <Tag>[];
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
        book.description ?? '',
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

    // Neutralise l'injection de formule (cellules commençant par = + - @…).
    final safeRows = rows
        .map((r) => r.map((c) => c is String ? _csvSafe(c) : c).toList())
        .toList();
    return const ListToCsvConverter().convert(safeRows);
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
    return importFromCsvString(
      await file.readAsString(),
      fetchCovers: fetchCovers,
      onProgress: onProgress,
    );
  }

  /// Importe depuis le contenu CSV [input] (voir [importFromCsv]).
  ///
  /// En deux temps : lecture des lignes (et, si demandé, recherche réseau des
  /// couvertures manquantes), puis écriture de tout dans UNE transaction —
  /// bien plus rapide qu'une écriture par ligne, et l'UI n'est rafraîchie
  /// qu'une fois au lieu d'après chaque livre.
  Future<CsvImportResult> importFromCsvString(
    String input, {
    bool fetchCovers = false,
    void Function(int current, int total)? onProgress,
  }) async {
    // Sans conversion des nombres : sinon l'ISBN-10 « 0441013597 » deviendrait
    // 441013597 et un titre « 007 » deviendrait « 7 ». Les fins de ligne \r\n
    // (celles de l'export) sont ramenées à \n.
    final rows = const CsvToListConverter(shouldParseNumbers: false).convert(
      input.replaceAll('\r\n', '\n'),
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

    // 1) Lecture des lignes + couvertures manquantes (réseau, hors transaction).
    final parsed = <({int line, Map<String, String> map, String? coverUrl})>[];
    final openLibraryApi = fetchCovers ? OpenLibraryApi() : null;
    for (int i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      if (row.length != headers.length) {
        skippedCount++;
        errors.add('Ligne ${i + 2} : nombre de colonnes incorrect.');
        continue;
      }

      final map = <String, String>{};
      for (int j = 0; j < headers.length; j++) {
        map[headers[j]] = _stripCsvGuard(row[j].toString());
      }

      String? coverUrl = _nonEmpty(map['cover_url']);
      if (openLibraryApi != null) {
        // Phase lente (réseau) : c'est elle qui fait avancer la progression.
        onProgress?.call(i + 1, totalCount);
        coverUrl ??= await _fetchCoverUrl(map, openLibraryApi);
      }
      parsed.add((line: i + 2, map: map, coverUrl: coverUrl));
    }

    // 2) Écriture groupée.
    // Cache des tags existants pour éviter les requêtes en double
    final tagCache = <String, int>{};
    await _db.transaction(() async {
      for (final (index, entry) in parsed.indexed) {
        final map = entry.map;
        final coverUrl = entry.coverUrl;
        if (openLibraryApi == null) onProgress?.call(index + 1, parsed.length);

        try {
          // Statut normalisé + dates cohérentes avec le statut (même règle que
          // le reste de l'app).
          final shelf = BookShelf.fromId(_normalizeShelf(map['shelf']));
          final dates = datesForShelf(
            shelf,
            currentStart: _parseDate(map['start_date']),
            currentFinish: _parseDate(map['finish_date']),
          );

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
            description: drift.Value(_nonEmpty(map['description'])),
            publicationYear: drift.Value(_parseInt(map['publication_year'])),
            startDate: drift.Value(dates.start),
            finishDate: drift.Value(dates.finish),
            stoppedDate: drift.Value(_parseDate(map['stopped_date'])),
            coverId: drift.Value(_parseInt(map['cover_id'])),
            coverUrl: drift.Value(coverUrl),
            coverPath: drift.Value(_nonEmpty(map['cover_path'])),
            rating: drift.Value(_parseInt(map['rating'])),
            reviewName: drift.Value(_nonEmpty(map['review_name'])),
            reviewCw: drift.Value(_nonEmpty(map['review_cw'])),
            reviewContent: drift.Value(_nonEmpty(map['review_content'])),
            reviewPublished: drift.Value(_parseDate(map['review_published'])),
            shelf: drift.Value(shelf.id),
            shelfName: drift.Value(shelf.label),
            shelfDate: drift.Value(_parseDate(map['shelf_date'])),
            isFavorite: drift.Value(map['is_favorite'] == 'true'),
            dateAdded: drift.Value(
              _parseDate(map['date_added']) ?? DateTime.now(),
            ),
            dateModified: drift.Value(
              _parseDate(map['date_modified']) ?? DateTime.now(),
            ),
          );

          // Déduplication : si un livre partage l'ISBN-13/10 ou le remote_id,
          // on le met à jour plutôt que de créer un doublon (import
          // ré-exécutable).
          final existing = await _findExistingBook(map);
          final int bookId;
          if (existing != null) {
            await (_db.update(_db.books)
                  ..where((t) => t.id.equals(existing.id)))
                .write(book);
            bookId = existing.id;
          } else {
            bookId = await _db.into(_db.books).insert(book);
          }

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
            'Ligne ${entry.line} (${map['title'] ?? '?'}) : ${e.toString()}',
          );
        }
      }
    });

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

  /// Normalise la valeur de statut importée : tolère l'ancien `to-read` (tiret),
  /// les valeurs vides ou inconnues → `to_read`.
  String _normalizeShelf(String? value) {
    switch (_nonEmpty(value)) {
      case 'reading':
        return 'reading';
      case 'read':
        return 'read';
      default:
        return 'to_read';
    }
  }

  static const _formulaLead = '=+-@\t\r';

  /// Préfixe une apostrophe aux cellules commençant par un caractère de formule
  /// pour éviter leur exécution dans un tableur (CSV injection).
  String _csvSafe(String v) =>
      (v.isNotEmpty && _formulaLead.contains(v[0])) ? "'$v" : v;

  /// Retire l'apostrophe de garde ajoutée à l'export (round-trip propre).
  String _stripCsvGuard(String v) =>
      (v.length >= 2 && v[0] == "'" && _formulaLead.contains(v[1]))
          ? v.substring(1)
          : v;

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

  /// Cherche un livre existant partageant l'ISBN-13, l'ISBN-10 ou le remote_id,
  /// pour rendre l'import idempotent (mise à jour au lieu de doublon).
  Future<Book?> _findExistingBook(Map<String, String> map) async {
    final isbn13 = _nonEmpty(map['isbn_13']);
    final isbn10 = _nonEmpty(map['isbn_10']);
    final remoteId = _nonEmpty(map['remote_id']);
    if (isbn13 == null && isbn10 == null && remoteId == null) return null;

    return (_db.select(_db.books)
          ..where((t) {
            drift.Expression<bool>? cond;
            void add(drift.Expression<bool> c) =>
                cond = cond == null ? c : cond! | c;
            if (isbn13 != null) add(t.isbn13.equals(isbn13));
            if (isbn10 != null) add(t.isbn10.equals(isbn10));
            if (remoteId != null) add(t.remoteId.equals(remoteId));
            return cond!;
          })
          ..limit(1))
        .getSingleOrNull();
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
