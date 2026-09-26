/// Normalisation de texte partagée par le dédoublonnage (index de la
/// bibliothèque, fusion des résultats de recherche), le classement et les
/// comparaisons de titres : minuscules, sans accents, ponctuation remplacée par
/// des espaces, espaces compactés.
///
/// Implémentée en une seule passe (sans expression régulière) : elle est
/// appelée des centaines de fois par recherche.
String normalizeText(String s) {
  final out = StringBuffer();
  var pendingSpace = false;
  for (final rune in s.toLowerCase().runes) {
    // Accents combinants (texte décomposé « e + ́ ») : ignorés, pas séparateurs.
    if (rune >= 0x300 && rune <= 0x36f) continue;
    final folded = _folded[rune];
    final String? chunk;
    if (folded != null) {
      chunk = folded;
    } else if ((rune >= 0x61 && rune <= 0x7a) || (rune >= 0x30 && rune <= 0x39)) {
      chunk = String.fromCharCode(rune);
    } else {
      chunk = null; // ponctuation, espace, autre script → séparateur
    }
    if (chunk == null) {
      pendingSpace = out.isNotEmpty;
    } else {
      if (pendingSpace) out.write(' ');
      pendingSpace = false;
      out.write(chunk);
    }
  }
  return out.toString();
}

/// Lettres latines accentuées → équivalent ASCII.
final Map<int, String> _folded = {
  for (final e in const {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
    'ç': 'c', 'ć': 'c', 'č': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ę': 'e', 'ě': 'e',
    'ì': 'i', 'î': 'i', 'ï': 'i', 'í': 'i', 'ī': 'i', 'ı': 'i',
    'ł': 'l',
    'ñ': 'n', 'ń': 'n', 'ň': 'n',
    'ò': 'o', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o', 'ø': 'o', 'ō': 'o',
    'ő': 'o',
    'ř': 'r',
    'š': 's', 'ś': 's', 'ß': 'ss',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u',
    'ÿ': 'y', 'ý': 'y',
    'ž': 'z', 'ź': 'z', 'ż': 'z',
    'œ': 'oe', 'æ': 'ae',
  }.entries)
    e.key.runes.single: e.value,
};

/// Le titre [candidate] désigne-t-il le livre intitulé [title] ? Égalité après
/// normalisation, ou (titres de plusieurs mots) [candidate] commence par
/// [title] suivi d'un sous-titre — sans confondre « Dune » et « Dune Messiah ».
bool titlesMatch(String title, String candidate) {
  final t = normalizeText(title);
  final c = normalizeText(candidate);
  if (t.isEmpty || c.isEmpty) return false;
  if (t == c) return true;
  return t.contains(' ') && c.startsWith('$t ');
}
