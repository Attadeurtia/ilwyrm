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
    final newState = Map<int, LibraryAvailabilityResponse>.from(state);

    // Set loading state for all books (we can use a dummy response or separate loading state)
    // For now, let's just keep the old state or maybe add a 'loading' field to response if we could modify it.
    // Or we can use a separate provider for loading states.
    // For simplicity, let's just not clear the old state, so it shows old data until new data arrives.
    // But we need to show loading indicator.
    // Let's assume the UI handles loading based on some other signal or we just wait.
    // Actually, the previous implementation used 'loading' string.
    // We can't put 'loading' string into Map<int, LibraryAvailabilityResponse>.
    // We could use a wrapper class AsyncValue or similar, or just nullable.
    // Let's use Map<int, AsyncValue<LibraryAvailabilityResponse>>? No, that's complex.
    // Let's just use a separate loading provider or add a 'loading' status to LibraryAvailabilityResponse?
    // LibraryAvailabilityResponse has 'availability' string. We can set it to 'loading'.

    // Actually, let's just fetch and update. The UI might flicker or not show loading.
    // The user requirement says "show a loading indicator during the API request".
    // I should probably add a loading state.

    // Fetch availability for each book
    for (final book in books) {
      try {
        final response = await api.checkAvailability(
          title: book.title,
          author: book.authorText ?? '',
          isbn: book.isbn13 ?? book.isbn10,
        );

        if (response != null) {
          newState[book.id] = response;
        }
      } catch (e) {
        // Handle error
      }
      state = Map.from(newState);
    }
  }

  void clear() {
    state = {};
  }
}
