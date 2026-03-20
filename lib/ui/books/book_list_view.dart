import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/books_repository.dart';
import 'bookshelf_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/sort_provider.dart';
import '../../data/enums.dart';
import '../home/view_provider.dart';
import '../home/filter_provider.dart';
import '../../data/database.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../home/selection_provider.dart';
import '../home/availability_provider.dart';
import '../theme_extensions.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/google_books_api.dart';
import '../../data/open_library_api.dart';
import '../../data/inventaire_api.dart';
import '../../data/book_search_api.dart';

class BookListView extends ConsumerWidget {
  final String status;
  final Set<int> tagIds;

  const BookListView({super.key, required this.status, required this.tagIds});

  Future<void> _refreshCovers(
    BuildContext context,
    WidgetRef ref,
    List<Book> books,
  ) async {
    final apis = <BookSearchApi>[
      OpenLibraryApi(),
      GoogleBooksApi(),
      InventaireApi(),
    ];
    final repository = ref.read(booksRepositoryProvider);

    for (final book in books) {
      String query = '';
      if (book.isbn13 != null && book.isbn13!.isNotEmpty) {
        query = book.isbn13!;
      } else if (book.isbn10 != null && book.isbn10!.isNotEmpty) {
        query = book.isbn10!;
      } else {
        query = book.title;
      }

      if (query.isEmpty) continue;

      for (final api in apis) {
        try {
          final results = await api.searchBooks(query);
          if (results.isNotEmpty) {
            final resultWithCover = results.cast<ExternalBook?>().firstWhere(
              (r) => r != null && r.coverUrl != null && r.coverUrl!.isNotEmpty,
              orElse: () => null,
            );

            if (resultWithCover != null && resultWithCover.coverUrl != null) {
              String newCoverUrl = resultWithCover.coverUrl!;

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

              bool shouldUpdate = false;
              if (book.coverUrl == null || book.coverUrl!.isEmpty) {
                shouldUpdate = true;
              } else {
                bool oldIsLowRes =
                    book.coverUrl!.contains('zoom=1') ||
                    book.coverUrl!.contains('zoom=5') ||
                    book.coverUrl!.contains('-S.jpg') ||
                    book.coverUrl!.contains('-M.jpg');
                bool newIsHighRes =
                    newCoverUrl.contains('zoom=3') ||
                    newCoverUrl.contains('-L.jpg') ||
                    newCoverUrl.contains('inventaire.io');

                if (oldIsLowRes && newIsHighRes) {
                  shouldUpdate = true;
                }
              }

              if (shouldUpdate && newCoverUrl != book.coverUrl) {
                await repository.updateBookData(
                  book.id,
                  BooksCompanion(coverUrl: Value(newCoverUrl)),
                );
                break;
              }
            }
          }
        } catch (e) {
          // Ignore
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(booksRepositoryProvider);

    // Map tab status to database shelf values
    String dbStatus;
    if (status == 'to_read') {
      dbStatus = 'to_read';
    } else if (status == 'reading') {
      dbStatus = 'reading';
    } else {
      dbStatus = 'read';
    }

    final sortOption = ref.watch(sortProvider);
    final filters = ref.watch(filterProvider);
    final selectionState = ref.watch(selectionProvider);
    final availabilityState = ref.watch(availabilityProvider);

    Stream<List<Book>> bookStream;

    if (tagIds.isNotEmpty) {
      // If filtering by tag, we first get books by tag, then filter by status/sort in memory
      // (Drift doesn't easily support complex joins + where + sort in a single fluent stream without custom SQL)
      // For simplicity and performance on small datasets, this is fine.
      bookStream = repository.getBooksByTags(tagIds.toList()).asStream().map((
        books,
      ) {
        var filtered = books.where((b) {
          final statusFilter = b.shelf == dbStatus;
          if (filters.contains('Favoris')) {
            return statusFilter && b.isFavorite;
          }
          return statusFilter;
        }).toList();

        // Sort
        filtered.sort((a, b) {
          switch (sortOption) {
            case SortOption.title:
              return a.title.compareTo(b.title);
            case SortOption.author:
              return (a.authorText ?? '').compareTo(b.authorText ?? '');
            case SortOption.dateAdded:
              return b.dateAdded.compareTo(a.dateAdded);
          }
        });
        return filtered;
      });
    } else {
      // Standard stream
      bookStream = repository.watchBooks(
        status: dbStatus,
        sortOption: sortOption,
        filters: filters.toList(),
      );
    }

    return StreamBuilder<List<Book>>(
      stream: bookStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final books = snapshot.data!;

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
                  'Aucun livre ici',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        final viewOption = ref.watch(viewProvider);

        if (viewOption == ViewOption.list) {
          return RefreshIndicator(
            onRefresh: () => _refreshCovers(context, ref, books),
            child: AnimationLimiter(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final availabilityResponse = tagIds.isNotEmpty
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

                  bool hasCover =
                      book.coverUrl != null ||
                      book.coverId != null ||
                      book.openlibraryKey != null;
                  ImageProvider? coverProvider;
                  if (book.coverUrl != null) {
                    coverProvider = CachedNetworkImageProvider(book.coverUrl!);
                  } else if (book.coverId != null) {
                    coverProvider = CachedNetworkImageProvider(
                      'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
                    );
                  } else if (book.openlibraryKey != null) {
                    coverProvider = CachedNetworkImageProvider(
                      'https://covers.openlibrary.org/b/olid/${book.openlibraryKey!.split('/').last}-M.jpg',
                    );
                  }

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
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
                                  child: Container(
                                    width: 50,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: hasCover
                                          ? null
                                          : Theme.of(
                                              context,
                                            ).colorScheme.tertiaryContainer,
                                      border: null,
                                      image: hasCover && coverProvider != null
                                          ? DecorationImage(
                                              image: coverProvider,
                                              fit: BoxFit.cover,
                                              onError: (e, s) {},
                                            )
                                          : null,
                                    ),
                                    child: !hasCover
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  book.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onTertiaryContainer,
                                                        fontSize: 8,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (book.authorText != null &&
                                                    book
                                                        .authorText!
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    book.authorText!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onTertiaryContainer
                                                                  .withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                          fontSize: 6,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          )
                                        : null,
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
                              book.authorText ?? 'Unknown Author',
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
                                        BookDetailsPage(bookId: book.id),
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
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () => _refreshCovers(context, ref, books),
            child: AnimationLimiter(
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: viewOption == ViewOption.grid ? 0.65 : 0.55,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final availabilityResponse = tagIds.isNotEmpty
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

                  bool hasCover =
                      book.coverUrl != null ||
                      book.coverId != null ||
                      book.openlibraryKey != null;
                  ImageProvider? coverProvider;
                  if (book.coverUrl != null) {
                    coverProvider = CachedNetworkImageProvider(book.coverUrl!);
                  } else if (book.coverId != null) {
                    coverProvider = CachedNetworkImageProvider(
                      'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg',
                    );
                  } else if (book.openlibraryKey != null) {
                    coverProvider = CachedNetworkImageProvider(
                      'https://covers.openlibrary.org/b/olid/${book.openlibraryKey!.split('/').last}-L.jpg',
                    );
                  }

                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 3,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
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
                                      BookDetailsPage(bookId: book.id),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: hasCover
                                              ? null
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryContainer,
                                          border: borderColor != null
                                              ? Border.all(
                                                  color: borderColor,
                                                  width: 3,
                                                )
                                              : null,
                                          image:
                                              hasCover && coverProvider != null
                                              ? DecorationImage(
                                                  image: coverProvider,
                                                  fit: BoxFit.cover,
                                                  onError: (e, s) {},
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
                                        child: !hasCover
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        book.title,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .onTertiaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 4,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (book.authorText !=
                                                              null &&
                                                          book
                                                              .authorText!
                                                              .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          book.authorText!,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onTertiaryContainer
                                                                        .withValues(
                                                                          alpha:
                                                                              0.8,
                                                                        ),
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : null,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
