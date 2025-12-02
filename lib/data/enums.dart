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
}

enum SortOption { dateAdded, title, author }
