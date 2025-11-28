import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class OpenLibraryApi implements BookSearchApi {
  static const String _baseUrl = 'https://openlibrary.org';

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
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
      throw Exception('Failed to load books');
    }
  }
}

// Kept for backward compatibility during refactor if needed, but ideally should be removed
// or aliased if other files still depend on it before full migration.
// For now, I'm removing it as I will update consumers.
