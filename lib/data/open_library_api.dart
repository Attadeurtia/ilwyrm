import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class OpenLibraryApi implements BookSearchApi {
  static const String _baseUrl = 'https://openlibrary.org';

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    if (isIsbn(query)) {
      return _searchByIsbn(query);
    }
    return _searchByText(query);
  }

  /// Couvertures des différentes ÉDITIONS d'une œuvre (modèle OpenLibrary
  /// Work → Editions) : chaque édition peut avoir sa propre couverture, ce qui
  /// donne un choix de couvertures alternatives bien plus riche qu'une seule.
  ///
  /// Résout la clé d'œuvre depuis [openlibraryKey] (clé d'œuvre `OL…W`, clé
  /// d'édition `OL…M`) ou, à défaut, depuis un [isbn], puis interroge
  /// `/works/{id}/editions.json`.
  Future<List<String>> fetchEditionCovers({
    String? openlibraryKey,
    String? isbn,
    int limit = 50,
  }) async {
    final workKey = await _resolveWorkKey(openlibraryKey, isbn);
    if (workKey == null) return const [];
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl$workKey/editions.json?limit=$limit'));
      if (res.statusCode != 200) return const [];
      final data = json.decode(res.body);
      final entries = data['entries'] as List? ?? const [];
      final coverIds = <int>{};
      for (final e in entries) {
        final covers = (e as Map)['covers'] as List?;
        if (covers != null) {
          for (final c in covers) {
            if (c is int && c > 0) coverIds.add(c);
          }
        }
      }
      return coverIds
          .map((id) => 'https://covers.openlibrary.org/b/id/$id-M.jpg')
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Renvoie la clé d'œuvre (`/works/OL…W`) à partir d'une clé OL ou d'un ISBN.
  Future<String?> _resolveWorkKey(String? openlibraryKey, String? isbn) async {
    final k = openlibraryKey?.trim();
    if (k != null && k.isNotEmpty) {
      if (k.contains('/works/')) return k;
      if (k.endsWith('W')) return '/works/$k';
      if (k.endsWith('M')) {
        final work = await _workFromEdition('/books/${k.split('/').last}');
        if (work != null) return work;
      }
    }
    if (isbn != null && isbn.trim().isNotEmpty) {
      return _workFromEdition('/isbn/${cleanIsbn(isbn)}');
    }
    return null;
  }

  Future<String?> _workFromEdition(String editionPath) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl$editionPath.json'));
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body);
      final works = data['works'] as List?;
      if (works != null && works.isNotEmpty) {
        return (works.first as Map)['key'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Recherche via l'endpoint ISBN dédié : /isbn/{isbn}.json
  Future<List<ExternalBook>> _searchByIsbn(String isbn) async {
    final clean = cleanIsbn(isbn);
    final url = Uri.parse('$_baseUrl/isbn/$clean.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Récupérer les auteurs via /authors/{key}.json si disponible
      String authorText = 'Unknown Author';
      final authorRefs = data['authors'] as List?;
      if (authorRefs != null && authorRefs.isNotEmpty) {
        final authorKey = authorRefs.first['key'] as String?;
        if (authorKey != null) {
          try {
            final authorRes =
                await http.get(Uri.parse('$_baseUrl$authorKey.json'));
            if (authorRes.statusCode == 200) {
              final authorData = json.decode(authorRes.body);
              authorText = authorData['name'] ?? authorText;
            }
          } catch (_) {}
        }
      }

      // Récupérer la cover via covers ou ISBN
      final covers = data['covers'] as List?;
      String? coverUrl;
      if (covers != null && covers.isNotEmpty) {
        coverUrl = 'https://covers.openlibrary.org/b/id/${covers.first}-M.jpg';
      } else {
        coverUrl = 'https://covers.openlibrary.org/b/isbn/$clean-M.jpg';
      }

      final isbns = <String>[clean];
      final isbn13 = data['isbn_13'] as List?;
      final isbn10 = data['isbn_10'] as List?;
      if (isbn13 != null) isbns.addAll(isbn13.map((e) => e.toString()));
      if (isbn10 != null) isbns.addAll(isbn10.map((e) => e.toString()));

      final publishDate = data['publish_date'] as String?;
      int? year;
      if (publishDate != null) {
        final match = RegExp(r'\d{4}').firstMatch(publishDate);
        if (match != null) year = int.tryParse(match.group(0)!);
      }

      final publishers = (data['publishers'] as List?)
          ?.map((e) => e.toString())
          .toList();

      final key = data['key'] as String? ?? '/isbn/$clean';

      final languages = data['languages'] as List?;
      final langCode = (languages != null && languages.isNotEmpty)
          ? (languages.first['key'] as String?)?.split('/').last
          : null;

      return [
        ExternalBook(
          key: key,
          title: data['title'] ?? 'Unknown Title',
          authorText: authorText,
          coverUrl: coverUrl,
          firstPublishYear: year,
          isbns: isbns.toSet().toList(),
          numberOfPages: data['number_of_pages'],
          publisher: publishers?.firstOrNull,
          openlibraryKey: key.split('/').last,
          language: normalizeLanguage(langCode),
          source: 'openlibrary',
        ),
      ];
    } else if (response.statusCode == 404) {
      return []; // Livre non trouvé sur OpenLibrary
    } else {
      throw Exception('OpenLibrary HTTP ${response.statusCode}');
    }
  }

  /// Recherche textuelle générique
  Future<List<ExternalBook>> _searchByText(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search.json?q=${Uri.encodeComponent(query)}&fields=key,title,author_name,cover_i,first_publish_year,isbn,number_of_pages_median,publisher,language&limit=20',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final docs = data['docs'] as List;
      return docs.map((json) {
        final authors = (json['author_name'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final coverId = json['cover_i'];
        final isbns = (json['isbn'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final publishers = (json['publisher'] as List?)
            ?.map((e) => e.toString())
            .toList();
        // `language` de search.json est au niveau œuvre (peut lister plusieurs
        // langues d'éditions) : on ne s'y fie que s'il n'y en a qu'une, sinon on
        // ne peut pas savoir la langue de CE résultat.
        final languages = (json['language'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final singleLanguage =
            (languages != null && languages.length == 1) ? languages.first : null;
        final key = json['key'] as String?;

        return ExternalBook(
          key: key ?? '',
          title: json['title'] ?? 'Unknown Title',
          authorText: authors?.join(', ') ?? 'Unknown Author',
          coverUrl: coverId != null
              ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
              : null,
          firstPublishYear: json['first_publish_year'],
          isbns: isbns,
          numberOfPages: json['number_of_pages_median'],
          publisher: publishers?.firstOrNull,
          openlibraryKey: key?.split('/').last,
          language: normalizeLanguage(singleLanguage),
          source: 'openlibrary',
        );
      }).toList();
    } else {
      throw Exception('OpenLibrary HTTP ${response.statusCode}');
    }
  }
}
