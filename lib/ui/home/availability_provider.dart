import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/library_availability_api.dart';
import '../../data/database.dart';

final availabilityProvider =
    NotifierProvider<
      AvailabilityNotifier,
      Map<int, LibraryAvailabilityResponse>
    >(AvailabilityNotifier.new);

class AvailabilityNotifier
    extends Notifier<Map<int, LibraryAvailabilityResponse>> {
  @override
  Map<int, LibraryAvailabilityResponse> build() {
    return {};
  }

  Future<void> checkAvailabilityForBooks(List<Book> books) async {
    final api = ref.read(libraryAvailabilityApiProvider);

    // Requêtes concurrentes ; une seule mise à jour d'état à la fin (évite N
    // reconstructions de l'UI).
    final entries = await Future.wait(
      books.map((book) async {
        try {
          final response = await api.checkAvailability(
            title: book.title,
            author: book.authorText ?? '',
            isbn: book.isbn13 ?? book.isbn10,
          );
          return response != null ? MapEntry(book.id, response) : null;
        } catch (_) {
          return null;
        }
      }),
    );

    final newState = Map<int, LibraryAvailabilityResponse>.from(state);
    for (final entry in entries) {
      if (entry != null) newState[entry.key] = entry.value;
    }
    state = newState;
  }

  void clear() {
    state = {};
  }
}
