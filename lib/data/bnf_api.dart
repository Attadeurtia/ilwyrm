import 'package:http/http.dart' as http;
import 'book_search_api.dart';

/// Catalogue général de la Bibliothèque nationale de France via l'API SRU
/// (Search/Retrieve via URL), réponses en Dublin Core.
///
/// Excellente couverture des livres publiés en France, avec des auteurs en
/// graphie latine et des ISBN fiables.
class BnfApi implements BookSearchApi {
  static const String _baseUrl = 'https://catalogue.bnf.fr/api/SRU';
  static const Map<String, String> _headers = {
    'User-Agent': 'Ilwyrm/1.0 (contact@example.com)',
  };

  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    final cql = isIsbn(query)
        ? 'bib.isbn all "${cleanIsbn(query)}"'
        : 'bib.anywhere all "${query.replaceAll('"', ' ').trim()}"';

    final url = Uri.parse(
      '$_baseUrl?version=1.2&operation=searchRetrieve'
      '&query=${Uri.encodeQueryComponent(cql)}'
      '&recordSchema=dublincore&maximumRecords=20',
    );

    final response = await http.get(url, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('BnF HTTP ${response.statusCode}');
    }
    return _parse(response.body);
  }

  List<ExternalBook> _parse(String xml) {
    final books = <ExternalBook>[];
    final recordRe = RegExp(r'<srw:record>([\s\S]*?)</srw:record>');

    for (final m in recordRe.allMatches(xml)) {
      final rec = m.group(1)!;
      final data = _between(rec, '<srw:recordData>', '</srw:recordData>') ?? rec;

      final titleRaw = _firstTag(data, 'dc:title');
      if (titleRaw == null) continue;
      // "Titre / auteur ; mentions" → on garde la partie titre.
      final title = _unescape(titleRaw.split(' / ').first.trim());

      final author =
          _cleanAuthor(_firstTag(data, 'dc:creator') ?? _firstTag(data, 'dc:contributor'));

      int? year;
      final dateRaw = _firstTag(data, 'dc:date');
      if (dateRaw != null) {
        final ym = RegExp(r'\d{4}').firstMatch(dateRaw);
        if (ym != null) year = int.tryParse(ym.group(0)!);
      }

      var publisher = _firstTag(data, 'dc:publisher');
      if (publisher != null) {
        // "Hachette (Vanves)" → "Hachette"
        publisher =
            _unescape(publisher.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim());
        if (publisher.isEmpty) publisher = null;
      }

      String? isbn;
      for (final id in _allTags(data, 'dc:identifier')) {
        final mm = RegExp(r'ISBN\s*([0-9Xx\-]{10,17})').firstMatch(id);
        if (mm != null) {
          isbn = cleanIsbn(mm.group(1)!);
          break;
        }
      }

      String? bnfId;
      final ark = _firstTag(rec, 'srw:recordIdentifier') ??
          _firstTag(data, 'dc:identifier');
      final am = RegExp(r'(cb\w+)').firstMatch(ark ?? '');
      if (am != null) bnfId = am.group(1);

      books.add(ExternalBook(
        key: bnfId != null ? 'bnf:$bnfId' : 'bnf:${books.length}',
        title: title,
        authorText: author ?? 'Unknown Author',
        // La BnF n'expose pas de vignette simple : on tente une couverture
        // OpenLibrary par ISBN (fallback icône si absente).
        coverUrl: isbn != null
            ? 'https://covers.openlibrary.org/b/isbn/$isbn-M.jpg'
            : null,
        firstPublishYear: year,
        isbns: isbn != null ? [isbn] : null,
        publisher: publisher,
        bnfId: bnfId,
        source: 'bnf',
      ));
    }
    return books;
  }

  /// Nettoie un auteur BnF : « Liu, Ci xin (1963-....). Auteur adapté »
  /// → « Ci xin Liu ».
  String? _cleanAuthor(String? raw) {
    if (raw == null) return null;
    var s = _unescape(raw);
    final paren = s.indexOf('(');
    if (paren > 0) s = s.substring(0, paren); // retire (dates…)
    // Retire une mention de rôle finale (« . Auteur », « . Traducteur »…).
    s = s.replaceAll(
      RegExp(
        r'\.\s*(Auteur|Traducteur|Éditeur|Editeur|Illustrateur|Adaptateur|Préfacier|Directeur de publication)[^.]*\.?\s*$',
        caseSensitive: false,
      ),
      '',
    );
    s = s.replaceAll(RegExp(r'[.\s]+$'), '').trim();
    if (s.isEmpty) return null;
    // « Nom, Prénom » → « Prénom Nom »
    final parts = s.split(',');
    if (parts.length == 2) s = '${parts[1].trim()} ${parts[0].trim()}';
    return s.trim();
  }

  String? _between(String s, String start, String end) {
    final i = s.indexOf(start);
    if (i < 0) return null;
    final j = s.indexOf(end, i + start.length);
    if (j < 0) return null;
    return s.substring(i + start.length, j);
  }

  String? _firstTag(String s, String tag) {
    final m = RegExp('<$tag[^>]*>([\\s\\S]*?)</$tag>').firstMatch(s);
    return m?.group(1)?.trim();
  }

  List<String> _allTags(String s, String tag) => RegExp('<$tag[^>]*>([\\s\\S]*?)</$tag>')
      .allMatches(s)
      .map((m) => m.group(1)!.trim())
      .toList();

  String _unescape(String s) {
    var out = s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'");
    out = out.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
