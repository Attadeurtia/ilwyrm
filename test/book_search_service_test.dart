import 'package:flutter_test/flutter_test.dart';
import 'package:ilwyrm/data/book_search_api.dart';
import 'package:ilwyrm/data/book_search_service.dart';

class _FakeApi implements BookSearchApi {
  _FakeApi(this.books);
  final List<ExternalBook> books;
  @override
  Future<List<ExternalBook>> searchBooks(String query) async => books;
}

class _ThrowingApi implements BookSearchApi {
  @override
  Future<List<ExternalBook>> searchBooks(String query) async =>
      throw Exception('Google Books HTTP 429');
}

BookSearchService _service({
  List<ExternalBook> ol = const [],
  List<ExternalBook> bnf = const [],
  List<ExternalBook> inv = const [],
  List<ExternalBook> google = const [],
}) {
  return BookSearchService(apis: {
    kOpenLibrary: _FakeApi(ol),
    kBnf: _FakeApi(bnf),
    kInventaire: _FakeApi(inv),
    kGoogleBooks: _FakeApi(google),
  });
}

void main() {
  test('fusionne les doublons par ISBN et réunit les sources', () async {
    final ol = [
      ExternalBook(
        key: '/works/OL1W',
        title: 'La Horde du Contrevent',
        authorText: 'Alain Damasio',
        isbns: ['9782707178954'],
        coverUrl: 'https://covers/ol.jpg',
        source: 'openlibrary',
      ),
    ];
    final google = [
      ExternalBook(
        key: 'g1',
        title: 'La Horde du Contrevent',
        authorText: 'Alain Damasio',
        isbns: ['978-2-7071-7895-4'],
        numberOfPages: 736,
        source: 'google_books',
      ),
    ];

    final res =
        await _service(ol: ol, google: google).search('la horde du contrevent');

    expect(res.merged.length, 1);
    expect(res.merged.first.sources, containsAll(['openlibrary', 'google_books']));
    expect(res.merged.first.numberOfPages, 736);
  });

  test('le bon roman passe devant le bruit plein-texte de Google', () async {
    final ol = [
      ExternalBook(
        key: '/works/OL2W',
        title: 'Le problème à trois corps',
        authorText: 'Liu Cixin',
        isbns: ['9782330113100'],
        firstPublishYear: 2016,
        coverUrl: 'https://covers/olly.jpg',
        source: 'openlibrary',
      ),
    ];
    final google = [
      ExternalBook(
        key: 'g2',
        title: 'Du problème des trois corps',
        authorText: 'Marquis de Condorcet',
        firstPublishYear: 1780,
        source: 'google_books',
      ),
    ];

    final res = await _service(ol: ol, google: google)
        .search('le probleme a trois corps');

    expect(res.merged.first.title, 'Le problème à trois corps');
    expect(res.merged.first.source, 'openlibrary');
  });

  test('un livre du domaine public est rétrogradé', () async {
    // Même correspondance de titre, mais le scan domaine public doit finir dernier.
    final google = [
      ExternalBook(
        key: 'pd',
        title: 'Du problème des trois corps',
        authorText: 'Condorcet',
        firstPublishYear: 1767,
        publicDomain: true,
        source: 'google_books',
      ),
      ExternalBook(
        key: 'modern',
        title: 'Le problème à trois corps',
        authorText: 'Liu Cixin',
        firstPublishYear: 2016,
        isbns: ['9782330113100'],
        source: 'google_books',
      ),
    ];
    final res = await _service(google: google)
        .search('le probleme a trois corps');
    expect(res.merged.first.key, 'modern');
    expect(res.merged.last.key, 'pd');
    // L'onglet Google est reclassé de la même façon.
    expect(res.bySource[kGoogleBooks]!.first.key, 'modern');
  });

  test('fusion par ISBN : la graphie latine de l’auteur est préférée', () async {
    final ol = [
      ExternalBook(
        key: 'ol',
        title: 'Le problème à trois corps',
        authorText: '刘慈欣',
        isbns: ['9782330113100'],
        source: 'openlibrary',
      ),
    ];
    final bnf = [
      ExternalBook(
        key: 'bnf:cb1',
        title: 'Le problème à trois corps',
        authorText: 'Liu Cixin',
        isbns: ['9782330113100'],
        bnfId: 'cb1',
        source: 'bnf',
      ),
    ];
    final res =
        await _service(ol: ol, bnf: bnf).search('le probleme a trois corps');
    expect(res.merged.length, 1);
    expect(res.merged.first.authorText, 'Liu Cixin');
    expect(res.merged.first.sources, containsAll(['openlibrary', 'bnf']));
  });

  test('pas de fusion cross-script par titre seul (œuvres homonymes)', () async {
    // Roman (auteur CJK) vs adaptation BD (auteur latin), même titre, sans
    // ISBN commun : on ne doit PAS adopter l'auteur de l'œuvre homonyme.
    final ol = [
      ExternalBook(key: 'ol', title: 'Le problème à trois corps', authorText: '刘慈欣', source: 'openlibrary'),
    ];
    final bnf = [
      ExternalBook(key: 'bnf', title: 'Le problème à trois corps', authorText: 'Qing song Wu', bnfId: 'cb', source: 'bnf'),
    ];
    final res =
        await _service(ol: ol, bnf: bnf).search('le probleme a trois corps');
    expect(res.merged.length, 2, reason: 'œuvres homonymes distinctes conservées');
  });

  test('OpenLibrary départage la BnF puis Google à pertinence égale', () async {
    final ol = [
      ExternalBook(key: 'ol', title: 'Dune', authorText: 'Frank Herbert', isbns: ['1'], coverUrl: 'c', firstPublishYear: 1965, source: 'openlibrary'),
    ];
    final bnf = [
      ExternalBook(key: 'bnf', title: 'Dune', authorText: 'Frank Herbert', isbns: ['2'], coverUrl: 'c', firstPublishYear: 1965, bnfId: 'cb', source: 'bnf'),
    ];
    // ISBN différents mais même titre+auteur → fusion (une œuvre).
    final res = await _service(ol: ol, bnf: bnf).search('dune');
    expect(res.merged.length, 1);
    expect(res.merged.first.source, 'openlibrary');
    expect(res.merged.first.sources, containsAll(['openlibrary', 'bnf']));
  });

  test('une erreur de source ne casse pas les autres', () async {
    final service = BookSearchService(apis: {
      kOpenLibrary: _FakeApi([
        ExternalBook(key: 'ol4', title: 'Fondation', authorText: 'Isaac Asimov', source: 'openlibrary'),
      ]),
      kGoogleBooks: _ThrowingApi(),
    });
    final res = await service.search('fondation');
    expect(res.errors[kGoogleBooks], isNotNull);
    expect(res.merged.length, 1);
  });

  test('recherche vide renvoie un résultat vide sans appel', () async {
    final res = await _service().search('   ');
    expect(res.merged, isEmpty);
  });

  test('à pertinence égale, l’édition dans la langue de l’app passe devant',
      () async {
    // Deux œuvres au titre distinct (donc non fusionnées) : l'édition française
    // doit être classée avant l'édition d'origine anglaise.
    final ol = [
      ExternalBook(
        key: 'en',
        title: 'Sapiens: A Brief History of Humankind',
        authorText: 'Yuval Noah Harari',
        firstPublishYear: 2011,
        language: 'en',
        source: 'openlibrary',
      ),
      ExternalBook(
        key: 'fr',
        title: 'Sapiens : Une brève histoire de l’humanité',
        authorText: 'Yuval Noah Harari',
        firstPublishYear: 2011,
        language: 'fr',
        source: 'openlibrary',
      ),
    ];
    final res = await _service(ol: ol).search('sapiens');
    expect(res.merged.length, 2, reason: 'titres différents → non fusionnés');
    expect(res.merged.first.key, 'fr');
  });

  test('normalizeLanguage mappe les codes/libellés vers un code court', () {
    expect(normalizeLanguage('fre'), 'fr');
    expect(normalizeLanguage('français'), 'fr');
    expect(normalizeLanguage('FR'), 'fr');
    expect(normalizeLanguage('eng'), 'en');
    expect(normalizeLanguage('anglais'), 'en');
    expect(normalizeLanguage(null), isNull);
    expect(normalizeLanguage(''), isNull);
  });
}
