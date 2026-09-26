import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/enums.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/text_normalize.dart';
import 'filter_provider.dart';
import 'sort_provider.dart';
import 'tag_filter_provider.dart';

/// Livres d'une étagère (`to_read`, `reading`, `read`), filtrés et triés selon
/// les réglages de l'accueil.
///
/// Le flux n'est recréé que si le tri ou un filtre change : sélectionner des
/// livres ou reconstruire l'écran ne relance plus la requête SQL, et chaque
/// onglet garde sa liste (pas d'affichage fugace de l'onglet précédent).
final shelfBooksProvider = StreamProvider.family<List<Book>, String>((
  ref,
  shelf,
) {
  final repository = ref.watch(booksRepositoryProvider);
  final sortOption = ref.watch(sortProvider);
  final favoritesOnly = ref.watch(filterProvider).contains('Favoris');
  final tagIds = ref.watch(selectedTagProvider);

  final Stream<List<Book>> books = tagIds.isEmpty
      ? repository.watchBooks(
          status: shelf,
          sortOption: SortOption.dateAdded,
          filters: favoritesOnly ? const ['Favoris'] : const [],
        )
      : repository
            .watchBooksByTags(tagIds.toList())
            .map(
              (books) => books
                  .where(
                    (b) => b.shelf == shelf && (!favoritesOnly || b.isFavorite),
                  )
                  .toList(),
            );
  return books.map((list) => sortBooks(list, sortOption));
});

/// Trie [books] selon [option]. Titre et auteur sont comparés sans casse ni
/// accents (« Écume » avec les E, pas après « Zola » comme en tri binaire).
List<Book> sortBooks(List<Book> books, SortOption option) {
  switch (option) {
    case SortOption.dateAdded:
      return [...books]..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    case SortOption.title:
    case SortOption.author:
      // Clés normalisées calculées une fois par livre (pas à chaque comparaison).
      final keyed = [
        for (final b in books)
          (
            b,
            normalizeText(
              option == SortOption.title ? b.title : (b.authorText ?? ''),
            ),
          ),
      ];
      keyed.sort((a, b) {
        final byKey = a.$2.compareTo(b.$2);
        return byKey != 0 ? byKey : b.$1.dateAdded.compareTo(a.$1.dateAdded);
      });
      return [for (final e in keyed) e.$1];
  }
}
