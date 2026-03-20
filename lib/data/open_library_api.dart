import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class OpenLibraryApi implements BookSearchApi {
  static const String _baseUrl = 'https://openlibrary.org';

  /// Détecte si la query est un ISBN pur (10 ou 13 chiffres)
  static bool _isIsbn(String query) =>
      RegExp(r'^\d{10}(\d{3})?$').hasMatch(query.replaceAll('-', ''));

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    if (_isIsbn(query)) {
      return _searchByIsbn(query);
    }
    return _searchByText(query);
  }

  /// Recherche via l'endpoint ISBN dédié : /isbn/{isbn}.json
  Future<List<ExternalBook>> _searchByIsbn(String isbn) async {
    final cleanIsbn = isbn.replaceAll('-', '');
    final url = Uri.parse('$_baseUrl/isbn/$cleanIsbn.json');
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
            final authorRes = await http.get(Uri.parse('$_baseUrl$authorKey.json'));
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
        coverUrl = 'https://covers.openlibrary.org/b/isbn/$cleanIsbn-M.jpg';
      }

      final isbns = <String>[isbn];
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

      return [
        ExternalBook(
          key: data['key'] ?? '/isbn/$cleanIsbn',
          title: data['title'] ?? 'Unknown Title',
          authorText: authorText,
          coverUrl: coverUrl,
          firstPublishYear: year,
          isbns: isbns.toSet().toList(),
          numberOfPages: data['number_of_pages'],
          publisher: publishers?.firstOrNull,
          source: 'openlibrary',
        ),
      ];
    } else if (response.statusCode == 404) {
      return []; // Livre non trouvé sur OpenLibrary
    } else {
      throw Exception('Failed to load book from OpenLibrary');
    }
  }

  /// Recherche textuelle générique
  Future<List<ExternalBook>> _searchByText(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search.json?q=${Uri.encodeComponent(query)}&fields=key,title,author_name,cover_i,first_publish_year,isbn,number_of_pages_median,publisher&limit=20',
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

        return ExternalBook(
          key: json['key'],
          title: json['title'],
          authorText: authors?.join(', ') ?? 'Unknown Author',
          coverUrl: coverId != null
              ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
              : null,
          firstPublishYear: json['first_publish_year'],
          isbns: isbns,
          numberOfPages: json['number_of_pages_median'],
          publisher: publishers?.firstOrNull,
          source: 'openlibrary',
        );
      }).toList();
    } else {
      throw Exception('Failed to load books from OpenLibrary');
    }
  }
}
