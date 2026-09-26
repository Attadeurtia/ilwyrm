import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';
import 'http_client.dart';

class GoogleBooksApi implements BookSearchApi {
  GoogleBooksApi({http.Client? client}) : _client = client ?? sharedHttpClient;

  final http.Client _client;

  static const String _baseUrl = 'https://www.googleapis.com/books/v1';

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    final apiKey = dotenv.maybeGet('GOOGLE_BOOKS_API_KEY');
    final keyParam = (apiKey != null && apiKey.isNotEmpty) ? '&key=$apiKey' : '';

    // Si la query ressemble à un ISBN, utiliser le préfixe isbn:
    final q = isIsbn(query) ? 'isbn:${cleanIsbn(query)}' : query;

    // country est requis par l'API Books depuis 2020 (sinon réponses vides
    // ou 403 selon la région) ; printType=books écarte les magazines.
    final url = Uri.parse(
      '$_baseUrl/volumes?q=${Uri.encodeComponent(q)}'
      '&maxResults=20&printType=books&country=FR&orderBy=relevance$keyParam',
    );

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['totalItems'] == 0 || data['items'] == null) {
        return [];
      }
      final items = data['items'] as List;
      return items.map((json) {
        final volumeInfo = json['volumeInfo'];
        final accessInfo = json['accessInfo'] as Map<String, dynamic>?;
        final authors = (volumeInfo['authors'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final imageLinks = volumeInfo['imageLinks'];
        final industryIdentifiers = volumeInfo['industryIdentifiers'] as List?;
        final isbns = industryIdentifiers
            ?.where((e) => e['type'] == 'ISBN_13' || e['type'] == 'ISBN_10')
            .map((e) => e['identifier'].toString())
            .toList();
        final publishedDate = volumeInfo['publishedDate'] as String?;
        final thumbnail = imageLinks?['thumbnail'] as String?;

        return ExternalBook(
          key: json['id'],
          title: volumeInfo['title'] ?? 'Unknown Title',
          authorText: authors?.join(', ') ?? 'Unknown Author',
          // HTTPS obligatoire, et sans l'effet « coin de page corné » (edge=curl)
          // que Google ajoute aux vignettes.
          coverUrl: thumbnail
              ?.replaceAll('http://', 'https://')
              .replaceAll('&edge=curl', ''),
          firstPublishYear: (publishedDate != null && publishedDate.length >= 4)
              ? int.tryParse(publishedDate.substring(0, 4))
              : null,
          isbns: isbns,
          numberOfPages: volumeInfo['pageCount'],
          publisher: volumeInfo['publisher'],
          description: volumeInfo['description'],
          publicDomain: accessInfo?['publicDomain'] == true,
          language: normalizeLanguage(volumeInfo['language'] as String?),
          source: 'google_books',
        );
      }).toList();
    } else {
      throw Exception('Google Books HTTP ${response.statusCode}');
    }
  }
}
