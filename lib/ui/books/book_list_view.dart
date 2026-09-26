import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../data/book_search_api.dart';
import '../../data/database.dart';
import '../../data/google_books_api.dart';
import '../../data/inventaire_api.dart';
import '../../data/open_library_api.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/text_normalize.dart';
import '../../l10n/l10n.dart';
import '../home/availability_provider.dart';
import '../home/selection_provider.dart';
import '../home/shelf_books_provider.dart';
import '../home/tag_filter_provider.dart';
import '../home/view_provider.dart';
import '../adaptive.dart';
import '../theme_extensions.dart';
import 'book_cover.dart';
import 'bookshelf_detail_page.dart';

class BookListView extends ConsumerWidget {
  final String status;

  /// Apparition en cascade des livres (premier affichage uniquement : après un
  /// changement d'onglet ou d'affichage, le fondu enchaîné suffit).
  final bool animateEntrance;

  const BookListView({
    super.key,
    required this.status,
    this.animateEntrance = true,
  });

  /// Enveloppe d'un livre : clic droit (sélection, comme l'appui long), curseur
  /// « main » sur les couvertures, et apparition en cascade.
  Widget _entrance({
    required int index,
    required bool grid,
    required VoidCallback onSecondaryTap,
    int columns = 3,
    required Widget child,
  }) {
    Widget item = GestureDetector(onSecondaryTap: onSecondaryTap, child: child);
    if (grid) {
      item = MouseRegion(cursor: SystemMouseCursors.click, child: item);
    }
    if (!animateEntrance) return item;
    const duration = Duration(milliseconds: 375);
    return grid
        ? AnimationConfiguration.staggeredGrid(
            position: index,
            duration: duration,
            columnCount: columns,
            child: ScaleAnimation(child: FadeInAnimation(child: item)),
          )
        : AnimationConfiguration.staggeredList(
            position: index,
            duration: duration,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: item),
            ),
          );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(shelfBooksProvider(status));
    final hasTagFilter = ref.watch(selectedTagProvider).isNotEmpty;
    final selectionState = ref.watch(selectionProvider);
    final availabilityState = ref.watch(availabilityProvider);

    // Pendant un rechargement (changement de tri/filtre), on garde la liste
    // précédente plutôt qu'un indicateur de chargement.
    final books = booksAsync.value;
    if (books == null) {
      if (booksAsync.hasError) {
        return Center(
          child: Text(context.l10n.genericError('${booksAsync.error}')),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.emptyShelf,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    final viewOption = ref.watch(viewProvider);

    Widget buildContent(double width) {
    if (viewOption == ViewOption.list) {
      return RefreshIndicator(
        onRefresh: () => refreshBookCovers(ref, books),
        child: AnimationLimiter(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: centeredPadding(width, minimum: 8, top: 8, bottom: 8),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final availabilityResponse = hasTagFilter
                  ? availabilityState[book.id]
                  : null;
              IconData? statusIcon;
              Color? statusColor;

              if (availabilityResponse != null) {
                if (availabilityResponse.available) {
                  statusIcon = Icons.check_circle;
                  statusColor = context.semanticColors.success;
                } else {
                  statusIcon = Icons.cancel;
                  statusColor = Theme.of(context).colorScheme.error;
                }
              }

              return _entrance(
                index: index,
                grid: false,
                onSecondaryTap: () =>
                    ref.read(selectionProvider.notifier).toggle(book.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    selected: selectionState.selectedIds.contains(
                      book.id,
                    ),
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.2),
                    leading: Stack(
                      children: [
                        Hero(
                          tag: 'book_cover_${book.id}',
                          child: SizedBox(
                            width: 50,
                            height: 75,
                            child: BookCover(
                              book: book,
                              borderRadius: 4,
                              compact: true,
                            ),
                          ),
                        ),
                        if (selectionState.selectedIds.contains(
                          book.id,
                        ))
                          Positioned.fill(
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withValues(alpha: 0.45),
                              child: Icon(
                                Icons.check_circle,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      book.authorText ?? context.l10n.unknownAuthor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: statusIcon != null
                        ? Icon(statusIcon, color: statusColor)
                        : null,
                    onTap: () {
                      if (selectionState.isSelecting) {
                        ref
                            .read(selectionProvider.notifier)
                            .toggle(book.id);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookDetailsPage(bookId: book.id, initialBook: book),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      ref
                          .read(selectionProvider.notifier)
                          .select(book.id);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Colonnes de ~180 px (au moins 3) : plus de couvertures sur une
      // fenêtre d'ordinateur, sans les agrandir démesurément.
      final columns = math.max(3, (width / 180).floor());
      return RefreshIndicator(
        onRefresh: () => refreshBookCovers(ref, books),
        child: AnimationLimiter(
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: viewOption == ViewOption.grid ? 0.65 : 0.55,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final availabilityResponse = hasTagFilter
                  ? availabilityState[book.id]
                  : null;
              Color? borderColor;
              if (availabilityResponse != null) {
                if (availabilityResponse.available) {
                  borderColor = context.semanticColors.success;
                } else {
                  borderColor = Theme.of(context).colorScheme.error;
                }
              }

              return _entrance(
                index: index,
                grid: true,
                columns: columns,
                onSecondaryTap: () =>
                    ref.read(selectionProvider.notifier).toggle(book.id),
                child: GestureDetector(
                  onTap: () {
                    if (selectionState.isSelecting) {
                      ref
                          .read(selectionProvider.notifier)
                          .toggle(book.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetailsPage(bookId: book.id, initialBook: book),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    ref
                        .read(selectionProvider.notifier)
                        .select(book.id);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'book_cover_${book.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: borderColor != null
                                      ? Border.all(
                                          color: borderColor,
                                          width: 3,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .shadow
                                          .withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: BookCover(book: book),
                              ),
                            ),
                            if (selectionState.selectedIds.contains(
                              book.id,
                            ))
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .shadow
                                        .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (viewOption == ViewOption.gridWithDetails) ...[
                        const SizedBox(height: 4),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          book.authorText ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    }

    final content = LayoutBuilder(
      builder: (context, constraints) => buildContent(constraints.maxWidth),
    );

    // Changement d'affichage (liste / grilles) : fondu enchaîné.
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) =>
          FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            fillColor: Colors.transparent,
            child: child,
          ),
      child: KeyedSubtree(key: ValueKey(viewOption), child: content),
    );
  }
}

bool _isLowRes(String url) =>
    url.contains('zoom=1') ||
    url.contains('zoom=5') ||
    url.contains('-S.jpg') ||
    url.contains('-M.jpg');

bool _isHighRes(String url) =>
    url.contains('zoom=3') ||
    url.contains('-L.jpg') ||
    url.contains('inventaire.io');

/// Seuls les livres sans couverture, ou avec une simple vignette, méritent
/// une recherche (une photo locale ou une couverture large est conservée).
bool _needsBetterCover(Book book) {
  if (book.coverPath != null && book.coverPath!.isNotEmpty) return false;
  final url = book.coverUrl;
  return url == null || url.isEmpty || _isLowRes(url);
}

/// Cherche une meilleure couverture pour les livres qui en ont besoin
/// (« tirer pour rafraîchir », ou bouton sur ordinateur), quelques-uns à la
/// fois (bien plus rapide qu'un par un, sans saturer les API). Les autres ne
/// déclenchent aucune requête.
Future<void> refreshBookCovers(WidgetRef ref, List<Book> books) async {
  final apis = <BookSearchApi>[
    OpenLibraryApi(),
    GoogleBooksApi(),
    InventaireApi(),
  ];
  final repository = ref.read(booksRepositoryProvider);
  final toRefresh = books.where(_needsBetterCover).toList();

  const batchSize = 4;
  for (var i = 0; i < toRefresh.length; i += batchSize) {
    await Future.wait(
      toRefresh
          .skip(i)
          .take(batchSize)
          .map((book) => _refreshCover(book, apis, repository)),
    );
  }
}

Future<void> _refreshCover(
  Book book,
  List<BookSearchApi> apis,
  BooksRepository repository,
) async {
  final isbn = [book.isbn13, book.isbn10]
      .whereType<String>()
      .firstWhere((s) => s.isNotEmpty, orElse: () => '');
  // Sans ISBN : titre + auteur, et seuls les résultats au titre concordant
  // comptent (pas la couverture d'un autre livre).
  final query = isbn.isNotEmpty
      ? isbn
      : [book.title, book.authorText ?? '']
            .where((s) => s.trim().isNotEmpty)
            .join(' ');
  if (query.isEmpty) return;

  for (final api in apis) {
    try {
      final results = await api
          .searchBooks(query)
          .timeout(const Duration(seconds: 8));
      final match = results
          .where((r) => isbn.isNotEmpty || titlesMatch(book.title, r.title))
          .map((r) => r.coverUrl)
          .firstWhere((url) => url != null && url.isNotEmpty, orElse: () => null);
      if (match == null) continue;

      var newCoverUrl = match;
      if (newCoverUrl.contains('googleapis.com')) {
        newCoverUrl = newCoverUrl
            .replaceAll('&edge=curl', '')
            .replaceAll('zoom=1', 'zoom=3')
            .replaceAll('zoom=5', 'zoom=3');
      } else if (newCoverUrl.contains('covers.openlibrary.org')) {
        newCoverUrl = newCoverUrl
            .replaceAll('-S.jpg', '-L.jpg')
            .replaceAll('-M.jpg', '-L.jpg');
      }

      final current = book.coverUrl;
      final isBetter =
          current == null || current.isEmpty || _isHighRes(newCoverUrl);
      if (isBetter && newCoverUrl != current) {
        await repository.updateBookData(
          book.id,
          BooksCompanion(coverUrl: Value(newCoverUrl)),
        );
        return;
      }
    } catch (_) {
      // Source indisponible : on essaie la suivante.
    }
  }
}
