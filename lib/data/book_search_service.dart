import 'dart:async';
import 'dart:math';

import 'bnf_api.dart';
import 'book_search_api.dart';
import 'google_books_api.dart';
import 'inventaire_api.dart';
import 'open_library_api.dart';
import 'text_normalize.dart';

/// Libellés d'onglets exposés à l'UI.
const kOpenLibrary = 'OpenLibrary';
const kBnf = 'BnF';
const kInventaire = 'Inventaire';
const kGoogleBooks = 'Google Books';

/// Résultat agrégé d'une recherche : une liste unifiée reclassée + les listes
/// par source (déjà reclassées) + les erreurs éventuelles par source.
class AggregatedResults {
  final List<ExternalBook> merged;
  final Map<String, List<ExternalBook>> bySource;
  final Map<String, String?> errors;

  const AggregatedResults({
    required this.merged,
    required this.bySource,
    required this.errors,
  });

  factory AggregatedResults.empty() => const AggregatedResults(
        merged: [],
        bySource: {kOpenLibrary: [], kBnf: [], kInventaire: [], kGoogleBooks: []},
        errors: {kOpenLibrary: null, kBnf: null, kInventaire: null, kGoogleBooks: null},
      );
}

/// Interroge OpenLibrary, la BnF, Inventaire et Google Books en parallèle, puis
/// fusionne et reclasse les résultats côté client.
///
/// Le classement combine la pertinence textuelle (similarité entre la requête
/// et « titre + auteur »), la complétude des métadonnées, une pénalité pour les
/// ouvrages du domaine public (vieux scans peu pertinents), et un bonus de
/// source (OpenLibrary > BnF > Inventaire > Google Books) qui départage les
/// résultats proches. Ce reclassement est aussi appliqué à chaque onglet de
/// source : même l'onglet Google Books n'affiche plus la pertinence brute de
/// l'API (dominée par de vieux ouvrages), mais nos résultats reclassés.
class BookSearchService {
  BookSearchService({
    Map<String, BookSearchApi>? apis,
    this.targetLanguage = 'fr',
  }) : _apis = apis ??
            {
              kOpenLibrary: OpenLibraryApi(),
              kBnf: BnfApi(),
              kInventaire: InventaireApi(),
              kGoogleBooks: GoogleBooksApi(),
            };

  final Map<String, BookSearchApi> _apis;

  /// Langue de l'application : à pertinence comparable, une édition dans cette
  /// langue est classée devant les autres, pour afficher les titres en français.
  final String targetLanguage;

  static const Duration _timeout = Duration(seconds: 8);

  /// Bonus additif appliqué au score selon la source (départage à pertinence
  /// égale ; ne prime jamais sur une meilleure correspondance textuelle).
  static const Map<String, double> _sourceBoost = {
    'openlibrary': 0.15,
    'bnf': 0.13,
    'inventaire': 0.10,
    'google_books': 0.0,
  };

  /// Rang de source pour choisir la fiche « de base » lors d'une fusion.
  static const Map<String, int> _sourceRank = {
    'openlibrary': 4,
    'bnf': 3,
    'inventaire': 2,
    'google_books': 1,
  };

  Future<AggregatedResults> search(String query,
      {bool authorSearch = false}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return AggregatedResults.empty();

    final bySource = <String, List<ExternalBook>>{
      kOpenLibrary: [],
      kBnf: [],
      kInventaire: [],
      kGoogleBooks: [],
    };
    final errors = <String, String?>{
      kOpenLibrary: null,
      kBnf: null,
      kInventaire: null,
      kGoogleBooks: null,
    };

    await Future.wait(_apis.entries.map((entry) async {
      final label = entry.key;
      final q = _effectiveQuery(label, trimmed, authorSearch);
      try {
        final books = await entry.value.searchBooks(q).timeout(_timeout);
        // Reclasse aussi chaque onglet de source avec notre scorer.
        bySource[label] = _rankByScore(books, trimmed);
      } on TimeoutException {
        errors[label] = 'Délai dépassé';
      } catch (e) {
        errors[label] = _friendlyError(e);
      }
    }));

    // Ordre d'entrée = priorité de source, pour que la fiche « de base » d'un
    // doublon vienne de la source la plus fiable.
    final all = <ExternalBook>[
      ...bySource[kOpenLibrary]!,
      ...bySource[kBnf]!,
      ...bySource[kInventaire]!,
      ...bySource[kGoogleBooks]!,
    ];

    return AggregatedResults(
      merged: _mergeAndRank(all, trimmed),
      bySource: bySource,
      errors: errors,
    );
  }

  String _effectiveQuery(String label, String query, bool authorSearch) {
    if (!authorSearch) return query;
    switch (label) {
      case kOpenLibrary:
        return 'author:$query';
      case kGoogleBooks:
        return 'inauthor:$query';
      default:
        return query; // BnF / Inventaire trouvent les auteurs sans préfixe
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('429')) return 'Quota API dépassé';
    if (s.contains('403')) return 'Accès refusé';
    return 'Indisponible';
  }

  // ---------------------------------------------------------------------------
  // Fusion + classement
  // ---------------------------------------------------------------------------

  List<ExternalBook> _mergeAndRank(List<ExternalBook> all, String query) {
    final clusters = <ExternalBook>[];
    final byIsbn = <String, int>{};
    final byTitleAuthor = <String, int>{};

    for (final book in all) {
      final isbnKeys = _isbnKeys(book);
      int? idx;
      for (final k in isbnKeys) {
        final hit = byIsbn[k];
        if (hit != null) {
          idx = hit;
          break;
        }
      }
      final taKey = _titleAuthorKey(book);
      idx ??= taKey != null ? byTitleAuthor[taKey] : null;

      if (idx == null) {
        clusters.add(book);
        final i = clusters.length - 1;
        for (final k in isbnKeys) {
          byIsbn[k] = i;
        }
        if (taKey != null) byTitleAuthor[taKey] = i;
      } else {
        final merged = _merge(clusters[idx], book);
        clusters[idx] = merged;
        for (final k in _isbnKeys(merged)) {
          byIsbn[k] = idx;
        }
        final mergedKey = _titleAuthorKey(merged);
        if (mergedKey != null) byTitleAuthor[mergedKey] = idx;
      }
    }

    return _rankByScore(clusters, query);
  }

  /// Trie par score décroissant. Chaque score est calculé UNE fois (et non à
  /// chaque comparaison du tri) ; à score égal, l'ordre d'entrée est conservé
  /// (priorité de source), pour un classement stable.
  List<ExternalBook> _rankByScore(List<ExternalBook> books, String query) {
    final q = _QueryTerms(_scoreTitle(query));
    final scored = [
      for (var i = 0; i < books.length; i++) (books[i], _score(books[i], q), i),
    ];
    scored.sort((a, b) {
      final c = b.$2.compareTo(a.$2);
      return c != 0 ? c : a.$3.compareTo(b.$3);
    });
    return [for (final e in scored) e.$1];
  }

  List<String> _isbnKeys(ExternalBook b) => (b.isbns ?? const [])
      .map(cleanIsbn)
      .where((e) => e.length == 10 || e.length == 13)
      .toList();

  /// Clé titre+auteur, uniquement si l'auteur est connu (sinon on ne fusionne
  /// que par ISBN, pour éviter de fondre deux livres homonymes).
  String? _titleAuthorKey(ExternalBook b) {
    if (!_isKnownAuthor(b.authorText)) return null;
    final title = _norm(b.title);
    if (title.isEmpty) return null;
    // Tokens d'auteur triés → tolère « Cixin Liu » vs « Liu Cixin ».
    final authorTokens =
        _norm(b.authorText).split(' ').where((e) => e.isNotEmpty).toList()..sort();
    return '$title::${authorTokens.join(' ')}';
  }

  ExternalBook _merge(ExternalBook a, ExternalBook b) {
    final base = _rank(a) >= _rank(b) ? a : b;
    final other = identical(base, a) ? b : a;
    final isbns =
        <String>{...?a.isbns, ...?b.isbns}.where((e) => e.isNotEmpty).toList();

    return base.copyWith(
      authorText: _bestAuthor(base.authorText, other.authorText),
      coverUrl: base.coverUrl ?? other.coverUrl,
      firstPublishYear: base.firstPublishYear ?? other.firstPublishYear,
      numberOfPages: base.numberOfPages ?? other.numberOfPages,
      publisher: base.publisher ?? other.publisher,
      isbns: isbns.isEmpty ? null : isbns,
      description: base.description ?? other.description,
      shortDescription: base.shortDescription ?? other.shortDescription,
      wikidata: base.wikidata ?? other.wikidata,
      inventaireId: base.inventaireId ?? other.inventaireId,
      openlibraryKey: base.openlibraryKey ?? other.openlibraryKey,
      bnfId: base.bnfId ?? other.bnfId,
      publicDomain: base.publicDomain && other.publicDomain,
      language: base.language ?? other.language,
      sources: {...base.sources, ...other.sources},
    );
  }

  /// Choisit le meilleur auteur : privilégie une graphie latine connue, puis un
  /// auteur connu, sinon garde celui de la fiche de base.
  String _bestAuthor(String base, String other) {
    final baseLatin = _isKnownLatinAuthor(base);
    final otherLatin = _isKnownLatinAuthor(other);
    if (baseLatin) return base;
    if (otherLatin) return other;
    if (_isKnownAuthor(base)) return base;
    if (_isKnownAuthor(other)) return other;
    return base;
  }

  int _rank(ExternalBook b) => _sourceRank[b.source] ?? 0;

  double _score(ExternalBook b, _QueryTerms query) {
    final q = query.text;
    final title = _scoreTitle(b.title);
    final combined = '$title ${_norm(b.authorText)}'.trim();

    double s = _coverage(query, combined) * 0.6 + _coverage(query, title) * 0.4;

    if (title == q) {
      s += 0.5;
    } else if (title.startsWith(q)) {
      s += 0.3;
    } else if (title.contains(q)) {
      s += 0.15;
    }

    if (b.coverUrl != null) s += 0.05;
    if (b.isbns?.isNotEmpty ?? false) s += 0.05;
    if (b.firstPublishYear != null) s += 0.03;
    if (_isKnownAuthor(b.authorText)) {
      s += 0.03;
      // Préférence pour une graphie latine de l'auteur (ex. « Liu Cixin »
      // plutôt que « 刘慈欣 ») quand deux fiches du même livre coexistent.
      if (_isKnownLatinAuthor(b.authorText)) s += 0.04;
    }

    // Pénalise les vieux ouvrages obscurs (scans du domaine public).
    if (b.publicDomain) s -= 0.6;
    final year = b.firstPublishYear;
    if (year != null && year < 1900) s -= 0.3;

    double boost = 0;
    for (final src in b.sources) {
      boost = max(boost, _sourceBoost[src] ?? 0);
    }
    s += boost;

    // Léger bonus si plusieurs sources concordent sur ce livre.
    if (b.sources.length > 1) s += 0.05;

    // Privilégie une édition dans la langue de l'application : à pertinence
    // proche, l'édition française passe devant l'édition d'origine (titre en
    // français). Trop faible pour promouvoir un livre hors-sujet.
    if (b.language != null && b.language == targetLanguage) s += 0.2;

    return s;
  }

  /// Couverture : fraction des tokens de la requête présents dans [text]
  /// (0 → 1). Asymétrique, pour ne pas pénaliser les tokens d'auteur/titre
  /// supplémentaires (ex. un auteur en graphie latine « ci xin liu »).
  double _coverage(_QueryTerms query, String text) {
    final q = query.tokens;
    if (q.isEmpty) return 0;
    final t = text.split(' ').toSet();
    return q.where(t.contains).length / q.length;
  }

  bool _isKnownAuthor(String a) {
    final n = a.trim().toLowerCase();
    return n.isNotEmpty && n != 'unknown author';
  }

  /// Détecte les scripts non latins (CJK, etc.) pour préférer une graphie latine.
  static final RegExp _nonLatin =
      RegExp(r'[぀-ヿ㐀-䶿一-鿿가-힯Ѐ-ӿ؀-ۿ]');

  bool _isKnownLatinAuthor(String a) =>
      _isKnownAuthor(a) && !_nonLatin.hasMatch(a);

  /// Normalise pour comparaison : minuscules, sans accents, sans ponctuation.
  String _norm(String s) => normalizeText(s);

  static final RegExp _genreWords = RegExp(
      r'\b(roman|recit|recits|nouvelle|nouvelles|essai|integrale|edition)\b');
  static final RegExp _tomeNumber = RegExp(r'\btome\s*\d+\b');
  static final RegExp _volumeNumber = RegExp(r'\bvol(ume)?\s*\d+\b');
  static final RegExp _shortTomeNumber = RegExp(r'\bt\s*\d+\b');
  static final RegExp _trailingNumber = RegExp(r'\s+\d+\s*$');
  static final RegExp _spaces = RegExp(r'\s+');

  /// Normalise un titre pour le SCORING uniquement (pas pour le dédoublonnage) :
  /// retire les marqueurs de genre ajoutés par les catalogues (« roman »,
  /// « récit »…) et les numéros de tome, pour qu'une édition « Titre : roman.
  /// 1 » corresponde à la requête « Titre ».
  String _scoreTitle(String s) {
    var t = _norm(s);
    t = t.replaceAll(_genreWords, ' ');
    t = t.replaceAll(_tomeNumber, ' ');
    t = t.replaceAll(_volumeNumber, ' ');
    t = t.replaceAll(_shortTomeNumber, ' ');
    t = t.replaceAll(_trailingNumber, ' '); // numéro de tome isolé en fin
    t = t.replaceAll(_spaces, ' ').trim();
    return t;
  }
}

/// Requête normalisée une seule fois pour tout un classement.
class _QueryTerms {
  _QueryTerms(this.text)
      : tokens = text.split(' ').where((e) => e.isNotEmpty).toSet();

  /// Titre de requête normalisé (voir `_scoreTitle`).
  final String text;
  final Set<String> tokens;
}
