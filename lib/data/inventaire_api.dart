import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class InventaireApi implements BookSearchApi {
  static const String _baseUrl = 'https://inventaire.io';

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

  /// Recherche via l'endpoint entités avec URI isbn:XXXXXXXXXX
  Future<List<ExternalBook>> _searchByIsbn(String isbn) async {
    final cleanIsbn = isbn.replaceAll('-', '');
    final url = Uri.parse(
      '$_baseUrl/api/entities?uris=${Uri.encodeComponent('isbn:$cleanIsbn')}',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'Ilwyrm/1.0 (contact@example.com)'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final entities = data['entities'] as Map<String, dynamic>?;
      if (entities == null || entities.isEmpty) return [];

      final results = <ExternalBook>[];
      for (final entry in entities.entries) {
        final entity = entry.value as Map<String, dynamic>;
        final claims = entity['claims'] as Map<String, dynamic>?;

        // Titre : P1476 ou label
        final titleClaim = claims?['wdt:P1476'] as List?;
        final title = titleClaim?.firstOrNull?['value'] as String? ??
            entity['label'] as String? ??
            'Unknown Title';

        // Auteur : P50 (référence à une autre entité, on garde le texte brut si possible)
        final authorClaim = claims?['wdt:P50'] as List?;
        final authorUri = authorClaim?.firstOrNull?['value'] as String?;
        String authorText = entity['description'] as String? ?? 'Unknown Author';
        if (authorUri != null) {
          try {
            final authorRes = await http.get(
              Uri.parse('$_baseUrl/api/entities?uris=${Uri.encodeComponent(authorUri)}'),
              headers: {'User-Agent': 'Ilwyrm/1.0 (contact@example.com)'},
            );
            if (authorRes.statusCode == 200) {
              final authorData = json.decode(authorRes.body);
              final authorEntities = authorData['entities'] as Map<String, dynamic>?;
              if (authorEntities != null && authorEntities.isNotEmpty) {
                authorText = authorEntities.values.first['label'] as String? ?? authorText;
              }
            }
          } catch (_) {}
        }

        // Couverture image
        final imagePath = entity['image']?['url'] as String?;
        final coverUrl = imagePath != null ? '$_baseUrl$imagePath' : null;

        // Pages : P1104
        final pagesClaim = claims?['wdt:P1104'] as List?;
        final pages = pagesClaim?.firstOrNull?['value'] as int?;

        // Année de publication : P577
        final dateClaim = claims?['wdt:P577'] as List?;
        final dateStr = dateClaim?.firstOrNull?['value'] as String?;
        final year = dateStr != null
            ? int.tryParse(dateStr.substring(0, 4))
            : null;

        // Éditeur : P123
        final publisherClaim = claims?['wdt:P123'] as List?;
        final publisherUri = publisherClaim?.firstOrNull?['value'] as String?;
        String? publisher;
        if (publisherUri != null) {
          try {
            final pubRes = await http.get(
              Uri.parse('$_baseUrl/api/entities?uris=${Uri.encodeComponent(publisherUri)}'),
              headers: {'User-Agent': 'Ilwyrm/1.0 (contact@example.com)'},
            );
            if (pubRes.statusCode == 200) {
              final pubData = json.decode(pubRes.body);
              final pubEntities = pubData['entities'] as Map<String, dynamic>?;
              if (pubEntities != null && pubEntities.isNotEmpty) {
                publisher = pubEntities.values.first['label'] as String?;
              }
            }
          } catch (_) {}
        }

        results.add(ExternalBook(
          key: entry.key,
          title: title,
          authorText: authorText,
          coverUrl: coverUrl,
          firstPublishYear: year,
          isbns: [cleanIsbn],
          numberOfPages: pages,
          publisher: publisher,
          source: 'inventaire',
        ));
      }
      return results;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load book from Inventaire');
    }
  }

  /// Recherche textuelle générique
  Future<List<ExternalBook>> _searchByText(String query) async {
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
          authorText: json['description'] ?? 'Unknown Author',
          coverUrl: imagePath != null ? '$_baseUrl$imagePath' : null,
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
