import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_search_api.dart';
import 'http_client.dart';

class InventaireApi implements BookSearchApi {
  InventaireApi({http.Client? client}) : _client = client ?? sharedHttpClient;

  final http.Client _client;

  static const String _baseUrl = 'https://inventaire.io';
  static const Map<String, String> _headers = {
    'User-Agent': 'Ilwyrm/1.0 (contact@example.com)',
  };

  /// Langues Wikidata les plus courantes (claim P407) → code ISO court.
  static const Map<String, String> _languages = {
    'wd:Q150': 'fr',
    'wd:Q1860': 'en',
    'wd:Q1321': 'es',
    'wd:Q188': 'de',
    'wd:Q652': 'it',
    'wd:Q5146': 'pt',
    'wd:Q7411': 'nl',
    'wd:Q5287': 'ja',
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

  /// Recherche d'une édition par ISBN via `entities/by-uris`. Le paramètre
  /// `relatives` ramène dans la même réponse l'œuvre (P629), ses auteurs (P50)
  /// et l'éditeur (P123) : un seul appel au lieu d'un par libellé.
  Future<List<ExternalBook>> _searchByIsbn(String isbn) async {
    final clean = cleanIsbn(isbn);
    final url = Uri.parse(
      '$_baseUrl/api/entities/by-uris'
      '?uris=${Uri.encodeQueryComponent('isbn:$clean')}'
      '&relatives=${Uri.encodeQueryComponent('wdt:P629|wdt:P50|wdt:P123')}',
    );

    final response = await _client.get(url, headers: _headers);
    // 400 = ISBN refusé (chiffre de contrôle invalide) : simplement introuvable.
    if (response.statusCode == 400 || response.statusCode == 404) return [];
    if (response.statusCode != 200) {
      throw Exception('Inventaire HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final entities = (data['entities'] as Map?)?.cast<String, dynamic>() ?? {};
    final editionUri = (data['redirects'] as Map?)?['isbn:$clean'] as String?;
    final edition = entities[editionUri] as Map<String, dynamic>? ??
        entities.values
            .whereType<Map<String, dynamic>>()
            .where((e) => e['type'] == 'edition')
            .firstOrNull;
    if (edition == null) return [];

    final claims = _claims(edition);
    final workUri = _first(claims, 'wdt:P629');
    final work = entities[workUri] as Map<String, dynamic>?;
    final authors = _all(_claims(work), 'wdt:P50')
        .map((uri) => _label(entities[uri]))
        .whereType<String>()
        .toList();
    final pages = _all(claims, 'wdt:P1104').firstOrNull;
    final date = _first(claims, 'wdt:P577');
    final imagePath = (edition['image'] as Map?)?['url'] as String?;
    final bnf = _first(claims, 'wdt:P268');
    final ids = _splitUri(edition['uri'] as String? ?? editionUri);

    return [
      ExternalBook(
        key: edition['uri'] as String? ?? 'isbn:$clean',
        title: _first(claims, 'wdt:P1476') ??
            _label(edition) ??
            _label(work) ??
            'Unknown Title',
        authorText: authors.isEmpty ? 'Unknown Author' : authors.join(', '),
        coverUrl: imagePath != null ? '$_baseUrl$imagePath' : null,
        firstPublishYear: (date != null && date.length >= 4)
            ? int.tryParse(date.substring(0, 4))
            : null,
        isbns: {
          clean,
          ..._all(claims, 'wdt:P212').map((e) => cleanIsbn('$e')),
          ..._all(claims, 'wdt:P957').map((e) => cleanIsbn('$e')),
        }.toList(),
        numberOfPages: pages is int ? pages : null,
        publisher: _label(entities[_first(claims, 'wdt:P123')]),
        // L'œuvre porte l'identifiant Wikidata : même clé que les résultats de
        // la recherche textuelle (qui renvoie des œuvres), pour le dédoublonnage.
        wikidata: _splitUri(workUri).wikidata ?? ids.wikidata,
        inventaireId: ids.inventaireId,
        openlibraryKey: _first(claims, 'wdt:P648'),
        bnfId: bnf != null ? 'cb$bnf' : null,
        language: _languages[_first(claims, 'wdt:P407')],
        source: 'inventaire',
      ),
    ];
  }

  static Map<String, dynamic> _claims(Map<String, dynamic>? entity) =>
      (entity?['claims'] as Map?)?.cast<String, dynamic>() ?? const {};

  /// Valeurs d'un claim (Inventaire renvoie des listes de valeurs brutes).
  static List<Object?> _all(Map<String, dynamic> claims, String property) =>
      (claims[property] as List?)?.cast<Object?>() ?? const [];

  static String? _first(Map<String, dynamic> claims, String property) =>
      _all(claims, property).firstOrNull?.toString();

  /// Libellé lisible d'une entité, en privilégiant le français.
  static String? _label(Object? entity) {
    if (entity is! Map) return null;
    final labels = entity['labels'];
    if (labels is! Map || labels.isEmpty) return null;
    return (labels['fr'] ??
            labels['en'] ??
            labels['fromclaims'] ??
            labels.values.first)
        ?.toString();
  }

  /// Recherche textuelle générique.
  ///
  /// L'endpoint /api/search ne renvoie qu'un label, une courte description et
  /// une image : pas d'auteur ni d'ISBN. La description (« roman de … ») sert à
  /// identifier le résultat (shortDescription), ce n'est pas un résumé ; la
  /// fusion croisée avec OpenLibrary / Google Books complète le reste.
  Future<List<ExternalBook>> _searchByText(String query) async {
    final url = Uri.parse(
      '$_baseUrl/api/search?search=${Uri.encodeComponent(query)}&types=works&limit=20',
    );

    final response = await _client.get(url, headers: _headers);

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
          shortDescription: json['description'] as String?,
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
