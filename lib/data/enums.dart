enum BookShelf {
  toRead('to_read', 'À lire'),
  reading('reading', 'En cours'),
  read('read', 'Lu');

  final String id;
  final String label;

  const BookShelf(this.id, this.label);

  static BookShelf fromId(String id) {
    return BookShelf.values.firstWhere(
      (e) => e.id == id,
      orElse: () => BookShelf.toRead,
    );
  }

  /// Vrai si ce statut utilise une date de début.
  bool get usesStartDate => this != BookShelf.toRead;

  /// Vrai si ce statut utilise une date de fin.
  bool get usesFinishDate => this == BookShelf.read;
}

/// Règle unique d'unification statut ↔ dates (source de vérité : le statut).
///
/// - À lire  : aucune date.
/// - En cours: date de début seule (aujourd'hui si absente).
/// - Lu      : date de début + date de fin (aujourd'hui si absentes), fin ≥ début.
///
/// Les dates existantes pertinentes sont conservées ; celles devenues
/// incohérentes avec le statut sont effacées.
({DateTime? start, DateTime? finish}) datesForShelf(
  BookShelf status, {
  DateTime? currentStart,
  DateTime? currentFinish,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  switch (status) {
    case BookShelf.toRead:
      return (start: null, finish: null);
    case BookShelf.reading:
      return (start: currentStart ?? today, finish: null);
    case BookShelf.read:
      final start = currentStart ?? currentFinish ?? today;
      var finish = currentFinish ?? today;
      if (finish.isBefore(start)) finish = start;
      return (start: start, finish: finish);
  }
}

enum SortOption { dateAdded, title, author }
