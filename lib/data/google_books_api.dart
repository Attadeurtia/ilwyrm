import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class GoogleBooksApi implements BookSearchApi {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    final url = Uri.parse(
      '$_baseUrl/volumes?q=${Uri.encodeComponent(query)}&maxResults=20',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['totalItems'] == 0 || data['items'] == null) {
        return [];
      }
      final items = data['items'] as List;
      return items.map((json) {
        final volumeInfo = json['volumeInfo'];
        final authors = (volumeInfo['authors'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final imageLinks = volumeInfo['imageLinks'];
        final industryIdentifiers = volumeInfo['industryIdentifiers'] as List?;
        final isbns = industryIdentifiers
            ?.where((e) => e['type'] == 'ISBN_13' || e['type'] == 'ISBN_10')
            .map((e) => e['identifier'].toString())
            .toList();

        return ExternalBook(
          key: json['id'],
          title: volumeInfo['title'] ?? 'Unknown Title',
          authorText: authors?.join(', ') ?? 'Unknown Author',
          coverUrl: imageLinks?['thumbnail']?.replaceAll('http://', 'https://'),
          firstPublishYear: volumeInfo['publishedDate'] != null
              ? int.tryParse(volumeInfo['publishedDate'].substring(0, 4))
              : null,
          isbns: isbns,
          numberOfPages: volumeInfo['pageCount'],
          publisher: volumeInfo['publisher'],
          source: 'google_books',
        );
      }).toList();
    } else {
      throw Exception('Failed to load books from Google Books');
    }
  }
}
