import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';

class InventaireApi implements BookSearchApi {
  static const String _baseUrl = 'https://inventaire.io';
  static const Map<String, String> _headers = {
    'User-Agent': 'Ilwyrm/1.0 (contact@example.com)',
  };

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    if (isIsbn(query)) {
      return _searchByIsbn(query);
    }
    return _searchByText(query);
  }

  /// Sépare une URI Inventaire (`wd:Q123`, `inv:abc`) en identifiants.
  static ({String? wikidata, String? inventaireId}) _splitUri(String? uri) {
    if (uri == null) return (wikidata: null, inventaireId: null);
    if (uri.startsWith('wd:')) return (wikidata: uri.substring(3), inventaireId: null);
    if (uri.startsWith('inv:')) return (wikidata: null, inventaireId: uri.substring(4));
    return (wikidata: null, inventaireId: null);
  }

  /// Recherche via l'endpoint entités avec URI isbn:XXXXXXXXXX
  Future<List<ExternalBook>> _searchByIsbn(String isbn) async {
    final clean = cleanIsbn(isbn);
    final url = Uri.parse(
      '$_baseUrl/api/entities?uris=${Uri.encodeComponent('isbn:$clean')}',
    );

    final response = await http.get(url, headers: _headers);

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

        // Auteur : P50 (référence à une autre entité)
        final authorClaim = claims?['wdt:P50'] as List?;
        final authorUri = authorClaim?.firstOrNull?['value'] as String?;
        String authorText = 'Unknown Author';
        if (authorUri != null) {
          authorText = await _resolveLabel(authorUri) ?? authorText;
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
        final year =
            dateStr != null ? int.tryParse(dateStr.substring(0, 4)) : null;

        // Éditeur : P123
        final publisherClaim = claims?['wdt:P123'] as List?;
        final publisherUri = publisherClaim?.firstOrNull?['value'] as String?;
        String? publisher;
        if (publisherUri != null) {
          publisher = await _resolveLabel(publisherUri);
        }

        final ids = _splitUri(entry.key);
        results.add(ExternalBook(
          key: entry.key,
          title: title,
          authorText: authorText,
          coverUrl: coverUrl,
          firstPublishYear: year,
          isbns: [clean],
          numberOfPages: pages,
          publisher: publisher,
          wikidata: ids.wikidata,
          inventaireId: ids.inventaireId,
          source: 'inventaire',
        ));
      }
      return results;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Inventaire HTTP ${response.statusCode}');
    }
  }

  /// Résout le label (nom lisible) d'une entité à partir de son URI.
  Future<String?> _resolveLabel(String uri) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/entities?uris=${Uri.encodeComponent(uri)}'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final entities = data['entities'] as Map<String, dynamic>?;
        if (entities != null && entities.isNotEmpty) {
          return entities.values.first['label'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Recherche textuelle générique.
  ///
  /// L'endpoint /api/search ne renvoie qu'un label, une description et une
  /// image : pas d'auteur ni d'ISBN. On mappe donc la description dans le
  /// champ dédié (et non dans l'auteur), la fusion croisée avec OpenLibrary /
  /// Google Books complétant les métadonnées manquantes.
  Future<List<ExternalBook>> _searchByText(String query) async {
    final url = Uri.parse(
      '$_baseUrl/api/search?search=${Uri.encodeComponent(query)}&types=works&limit=20',
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) {
        final imagePath = json['image'];
        final uri = json['uri'] as String?;
        final ids = _splitUri(uri);
        return ExternalBook(
          key: uri ?? '',
          title: json['label'] ?? 'Unknown Title',
          authorText: 'Unknown Author',
          coverUrl: imagePath != null ? '$_baseUrl$imagePath' : null,
          firstPublishYear: null,
          isbns: null,
          numberOfPages: null,
          description: json['description'] as String?,
          wikidata: ids.wikidata,
          inventaireId: ids.inventaireId,
          source: 'inventaire',
        );
      }).toList();
    } else {
      throw Exception('Inventaire HTTP ${response.statusCode}');
    }
  }
}
