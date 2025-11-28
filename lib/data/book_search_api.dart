abstract class BookSearchApi {
  Future<List<ExternalBook>> searchBooks(String query);
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
  final String source; // 'openlibrary', 'google_books', 'inventaire'

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
  });
}
