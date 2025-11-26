import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class InventaireApi implements BookSearchApi {
  static const String _baseUrl = 'https://inventaire.io';

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    final url = Uri.parse(
      '$_baseUrl/api/search?search=${Uri.encodeComponent(query)}&types=works&limit=20',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'Ilwyrm/1.0 (contact@example.com)'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) {
        final imagePath = json['image'];
        return ExternalBook(
          key: json['uri'],
          title: json['label'] ?? 'Unknown Title',
          // Description often contains author info e.g. "novel by J.K. Rowling"
          authorText: json['description'] ?? 'Unknown Author',
          coverUrl: imagePath != null ? '$_baseUrl$imagePath' : null,
          // Inventaire "works" don't usually have a single publish year or page count in the search result
          firstPublishYear: null,
          isbns: null,
          numberOfPages: null,
          source: 'inventaire',
        );
      }).toList();
    } else {
      throw Exception('Failed to load books from Inventaire');
    }
  }
}
