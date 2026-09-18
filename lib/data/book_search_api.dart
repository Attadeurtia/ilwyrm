abstract class BookSearchApi {
  Future<List<ExternalBook>> searchBooks(String query);
}

/// Nettoie un ISBN : retire tirets/espaces et met un éventuel « X » final en
/// majuscule (chiffre de contrôle valide d'un ISBN-10).
String cleanIsbn(String raw) =>
    raw.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

/// Détecte si la chaîne est un ISBN-10 (le dernier caractère peut être « X »)
/// ou un ISBN-13.
bool isIsbn(String query) {
  final s = cleanIsbn(query);
  return RegExp(r'^(\d{9}[\dX]|\d{13})$').hasMatch(s);
}

/// Normalise un code/nom de langue (ISO-639-1/2, MARC, libellé FR/EN) vers un
/// code court minuscule ('fr', 'en', …) pour comparer les éditions entre sources.
String? normalizeLanguage(String? raw) {
  if (raw == null) return null;
  final s = raw.trim().toLowerCase();
  if (s.isEmpty) return null;
  const map = {
    'fre': 'fr', 'fra': 'fr', 'french': 'fr', 'français': 'fr', 'francais': 'fr',
    'eng': 'en', 'english': 'en', 'anglais': 'en',
    'spa': 'es', 'espagnol': 'es',
    'ger': 'de', 'deu': 'de', 'allemand': 'de',
    'ita': 'it', 'italien': 'it',
    'jpn': 'ja', 'japonais': 'ja',
  };
  return map[s] ?? (s.length == 2 ? s : s);
}

class ExternalBook {
  final String key;
  final String title;
  final String authorText;
  final String? coverUrl;
  final int? firstPublishYear;
  final List<String>? isbns;
  final int? numberOfPages;
  final String? publisher;

  /// Source principale : 'openlibrary', 'google_books', 'inventaire'.
  final String source;

  /// Toutes les sources ayant produit cette fiche (après fusion des doublons).
  final Set<String> sources;

  final String? description;
  final String? wikidata;
  final String? inventaireId;

  /// Code langue ISO de l'édition ('fr', 'en', …) quand la source le fournit.
  /// Sert à privilégier une édition dans la langue de l'application.
  final String? language;

  /// Clé OpenLibrary courte (ex : `OL123W` ou `OL456M`), sans le préfixe.
  final String? openlibraryKey;

  /// Identifiant BnF (ark, ex : `cb474566399`).
  final String? bnfId;

  /// Vrai si la source signale un ouvrage du domaine public (typiquement de
  /// vieux scans Google Books peu pertinents pour un suivi de lecture).
  final bool publicDomain;

  ExternalBook({
    required this.key,
    required this.title,
    required this.authorText,
    this.coverUrl,
    this.firstPublishYear,
    this.isbns,
    this.numberOfPages,
    this.publisher,
    required this.source,
    Set<String>? sources,
    this.description,
    this.wikidata,
    this.inventaireId,
    this.openlibraryKey,
    this.bnfId,
    this.publicDomain = false,
    this.language,
  }) : sources = sources ?? {source};

  /// Premier ISBN-13 disponible (nettoyé), sinon null.
  String? get isbn13 {
    for (final e in isbns ?? const <String>[]) {
      final c = cleanIsbn(e);
      if (c.length == 13) return c;
    }
    return null;
  }

  /// Premier ISBN-10 disponible (nettoyé), sinon null.
  String? get isbn10 {
    for (final e in isbns ?? const <String>[]) {
      final c = cleanIsbn(e);
      if (c.length == 10) return c;
    }
    return null;
  }

  ExternalBook copyWith({
    String? key,
    String? title,
    String? authorText,
    String? coverUrl,
    int? firstPublishYear,
    List<String>? isbns,
    int? numberOfPages,
    String? publisher,
    String? source,
    Set<String>? sources,
    String? description,
    String? wikidata,
    String? inventaireId,
    String? openlibraryKey,
    String? bnfId,
    bool? publicDomain,
    String? language,
  }) {
    return ExternalBook(
      key: key ?? this.key,
      title: title ?? this.title,
      authorText: authorText ?? this.authorText,
      coverUrl: coverUrl ?? this.coverUrl,
      firstPublishYear: firstPublishYear ?? this.firstPublishYear,
      isbns: isbns ?? this.isbns,
      numberOfPages: numberOfPages ?? this.numberOfPages,
      publisher: publisher ?? this.publisher,
      source: source ?? this.source,
      sources: sources ?? this.sources,
      description: description ?? this.description,
      wikidata: wikidata ?? this.wikidata,
      inventaireId: inventaireId ?? this.inventaireId,
      openlibraryKey: openlibraryKey ?? this.openlibraryKey,
      bnfId: bnfId ?? this.bnfId,
      publicDomain: publicDomain ?? this.publicDomain,
      language: language ?? this.language,
    );
  }
}
