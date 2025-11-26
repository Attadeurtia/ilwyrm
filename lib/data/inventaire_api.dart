import 'book_search_api.dart';

class InventaireApi implements BookSearchApi {
  @override
  Future<List<ExternalBook>> searchBooks(String query) async {
    // TODO: Implement actual Inventaire API search.
    // The API requires specific headers or authentication and the simple search endpoint
    // returned 400 Bad Request in initial tests.
    // For now, we return an empty list to allow the UI to function.
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    return [];
  }
}
