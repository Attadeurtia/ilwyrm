import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book_search_api.dart';
import 'database.dart';
import 'repositories/books_repository.dart';

/// Index des identités des livres déjà présents en bibliothèque, pour repérer
/// (et empêcher) un doublon lors de la recherche.
///
/// Une fiche de recherche est considérée comme déjà présente si elle partage un
/// identifiant fort (ISBN 10/13, clé OpenLibrary, BnF, Inventaire, Wikidata)
/// avec un livre local, ou, à défaut, le même couple titre + auteur normalisé.
/// Cette logique reste cohérente avec la fusion des résultats de recherche
/// (voir BookSearchService), qui dédoublonne selon les mêmes critères.
class LibraryIndex {
  final Map<String, int> _keyToId;

  const LibraryIndex(this._keyToId);

  static const LibraryIndex empty = LibraryIndex(<String, int>{});

  /// Identifiant du livre local correspondant à [book], ou null s'il est absent.
  int? findId(ExternalBook book) {
    for (final key in _keysForExternal(book)) {
      final id = _keyToId[key];
      if (id != null) return id;
    }
    return null;
  }

  /// Vrai si [book] est déjà dans la bibliothèque.
  bool contains(ExternalBook book) => findId(book) != null;
}

/// Construit l'index à partir de la liste complète des livres.
LibraryIndex buildLibraryIndex(List<Book> books) {
  final keyToId = <String, int>{};
  for (final b in books) {
    final keys = _keysForFields(
      isbns: [b.isbn13, b.isbn10].whereType<String>(),
      openlibraryKey: b.openlibraryKey,
      bnfId: b.bnfId,
      inventaireId: b.inventaireId,
      wikidata: b.wikidata,
      remoteId: b.remoteId,
      title: b.title,
      author: b.authorText,
    );
    for (final key in keys) {
      keyToId[key] = b.id;
    }
  }
  return LibraryIndex(keyToId);
}

Set<String> _keysForExternal(ExternalBook b) => _keysForFields(
      isbns: b.isbns,
      openlibraryKey: b.openlibraryKey,
      bnfId: b.bnfId,
      inventaireId: b.inventaireId,
      wikidata: b.wikidata,
      remoteId: null,
      title: b.title,
      author: b.authorText,
    );

Set<String> _keysForFields({
  Iterable<String>? isbns,
  String? openlibraryKey,
  String? bnfId,
  String? inventaireId,
  String? wikidata,
  String? remoteId,
  required String title,
  String? author,
}) {
  final keys = <String>{};

  // ISBN : on indexe TOUS les ISBN (10 et 13) de chaque côté, nettoyés. Un seul
  // ISBN commun suffit à reconnaître le même livre, quel que soit son rang dans
  // la liste (une fiche fusionnée peut en cumuler plusieurs).
  for (final raw in isbns ?? const <String>[]) {
    final c = cleanIsbn(raw);
    if (c.length == 10 || c.length == 13) keys.add('isbn:${c.toLowerCase()}');
  }

  void addId(String prefix, String? value) {
    final s = value?.trim().toLowerCase();
    if (s != null && s.isNotEmpty) keys.add('$prefix:$s');
  }

  addId('ol', openlibraryKey);
  addId('bnf', bnfId);
  addId('inv', inventaireId);
  addId('wd', wikidata);
  addId('rid', remoteId);

  // Repli titre + auteur (uniquement si l'auteur est connu, pour ne pas
  // confondre deux livres homonymes sans identifiant).
  if (_isKnownAuthor(author)) {
    final normTitle = _normalize(title);
    if (normTitle.isNotEmpty) {
      // Tokens d'auteur triés → tolère « Cixin Liu » vs « Liu Cixin ».
      final authorTokens = _normalize(author!)
          .split(' ')
          .where((e) => e.isNotEmpty)
          .toList()
        ..sort();
      keys.add('ta:$normTitle|${authorTokens.join(' ')}');
    }
  }

  return keys;
}

bool _isKnownAuthor(String? a) {
  final n = a?.trim().toLowerCase() ?? '';
  return n.isNotEmpty && n != 'unknown author';
}

const Map<String, String> _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a',
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'î': 'i', 'ï': 'i', 'í': 'i',
  'ò': 'o', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
  'ñ': 'n', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae', 'ß': 'ss',
};

/// Normalise pour comparaison : minuscules, sans accents, sans ponctuation.
String _normalize(String s) {
  var out = s.toLowerCase();
  _accents.forEach((k, v) => out = out.replaceAll(k, v));
  out = out.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  return out;
}

/// Index réactif : ré-émis à chaque changement de la bibliothèque, pour que la
/// page de recherche marque immédiatement un livre qui vient d'être ajouté.
final libraryIndexProvider = StreamProvider<LibraryIndex>((ref) {
  final repo = ref.watch(booksRepositoryProvider);
  return repo.watchAllBooks().map(buildLibraryIndex);
});
