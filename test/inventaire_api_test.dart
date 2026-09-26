import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ilwyrm/data/inventaire_api.dart';

/// Réponse réelle (abrégée) de `entities/by-uris` pour l'ISBN de « 1984 »
/// (Folio), avec l'œuvre, l'auteur et l'éditeur ramenés par `relatives`.
const _byUrisResponse = {
  'entities': {
    'inv:1917e3d8': {
      'type': 'edition',
      'uri': 'inv:1917e3d8',
      'labels': {'fromclaims': '1984'},
      'claims': {
        'wdt:P212': ['978-2-07-036822-8'],
        'wdt:P957': ['2-07-036822-X'],
        'wdt:P407': ['wd:Q150'],
        'wdt:P1476': ['1984'],
        'wdt:P629': ['wd:Q208460'],
        'wdt:P123': ['wd:Q273819'],
        'wdt:P1104': [438],
        'wdt:P577': ['1972-11-16'],
        'wdt:P648': ['OL8838059M'],
        'wdt:P268': ['37156630k'],
      },
      'image': {'url': '/img/entities/2b71f318'},
    },
    'wd:Q208460': {
      'type': 'work',
      'uri': 'wd:Q208460',
      'labels': {'fr': '1984', 'en': 'Nineteen Eighty-Four'},
      'claims': {
        'wdt:P50': ['wd:Q3335'],
      },
    },
    'wd:Q273819': {
      'type': 'publisher',
      'labels': {'fr': 'Éditions Gallimard'},
      'claims': <String, Object>{},
    },
    'wd:Q3335': {
      'type': 'human',
      'labels': {'fr': 'George Orwell'},
      'claims': <String, Object>{},
    },
  },
  'redirects': {'isbn:9782070368228': 'inv:1917e3d8'},
};

void main() {
  test('recherche par ISBN : édition, auteur de l\'œuvre, éditeur, langue',
      () async {
    late Uri requested;
    final api = InventaireApi(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode(_byUrisResponse),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final results = await api.searchBooks('978-2-07-036822-8');

    expect(requested.path, '/api/entities/by-uris');
    expect(requested.queryParameters['uris'], 'isbn:9782070368228');
    expect(requested.queryParameters['relatives'], contains('wdt:P50'));

    final book = results.single;
    expect(book.title, '1984');
    expect(book.authorText, 'George Orwell');
    expect(book.publisher, 'Éditions Gallimard');
    expect(book.firstPublishYear, 1972);
    expect(book.numberOfPages, 438);
    expect(book.language, 'fr');
    expect(book.isbns, containsAll(['9782070368228', '207036822X']));
    expect(book.wikidata, 'Q208460', reason: 'identifiant de l\'œuvre');
    expect(book.inventaireId, '1917e3d8');
    expect(book.openlibraryKey, 'OL8838059M');
    expect(book.bnfId, 'cb37156630k');
    expect(book.coverUrl, 'https://inventaire.io/img/entities/2b71f318');
  });

  test('ISBN inconnu ou refusé : aucun résultat, pas d\'erreur', () async {
    final notFound = InventaireApi(
      client: MockClient(
        (_) async => http.Response(
          '{"entities":{},"redirects":{},"notFound":["isbn:9791000001234"]}',
          200,
        ),
      ),
    );
    expect(await notFound.searchBooks('9791000001234'), isEmpty);

    final rejected = InventaireApi(
      client: MockClient(
        (_) async => http.Response('{"status":400}', 400),
      ),
    );
    expect(await rejected.searchBooks('2070368226'), isEmpty);
  });

  test('recherche texte : la description courte n\'est pas un résumé',
      () async {
    final api = InventaireApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'results': [
              {
                'uri': 'wd:Q190192',
                'label': 'Dune',
                'description': '1965 science fiction novel by Frank Herbert',
                'image': '/img/entities/a936e097',
              },
            ],
          }),
          200,
        ),
      ),
    );

    final book = (await api.searchBooks('dune')).single;

    expect(book.shortDescription, '1965 science fiction novel by Frank Herbert');
    expect(book.description, isNull);
    expect(book.wikidata, 'Q190192');
  });
}
