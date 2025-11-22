import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenLibraryApi {
  static const String _baseUrl = 'https://openlibrary.org';

  Future<List<OpenLibraryBook>> searchBooks(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search.json?q=${Uri.encodeComponent(query)}&fields=key,title,author_name,cover_i,first_publish_year,isbn&limit=20',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final docs = data['docs'] as List;
      return docs.map((json) => OpenLibraryBook.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}

class OpenLibraryBook {
  final String key;
  final String title;
  final List<String>? authors;
  final int? coverId;
  final int? firstPublishYear;
  final List<String>? isbns;

  OpenLibraryBook({
    required this.key,
    required this.title,
    this.authors,
    this.coverId,
    this.firstPublishYear,
    this.isbns,
  });

  factory OpenLibraryBook.fromJson(Map<String, dynamic> json) {
    return OpenLibraryBook(
      key: json['key'],
      title: json['title'],
      authors: (json['author_name'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      coverId: json['cover_i'],
      firstPublishYear: json['first_publish_year'],
      isbns: (json['isbn'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  String get authorText => authors?.join(', ') ?? 'Unknown Author';
  String? get coverUrl => coverId != null
      ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
      : null;
}
