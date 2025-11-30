import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import 'bookshelf_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/sort_provider.dart';
import '../home/view_provider.dart';
import '../home/filter_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../home/selection_provider.dart';
import '../home/availability_provider.dart';

class BookListView extends ConsumerWidget {
  final String status;
  final int? tagId;

  const BookListView({super.key, required this.status, this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

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

    if (tagId != null) {
      // If filtering by tag, we first get books by tag, then filter by status/sort in memory
      // (Drift doesn't easily support complex joins + where + sort in a single fluent stream without custom SQL)
      // For simplicity and performance on small datasets, this is fine.
      bookStream = database.getBooksByTag(tagId!).asStream().map((books) {
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
      bookStream =
          (database.select(database.books)
                ..where((tbl) {
                  final statusFilter = tbl.shelf.equals(dbStatus);
                  if (filters.contains('Favoris')) {
                    return statusFilter & tbl.isFavorite.equals(true);
                  }
                  return statusFilter;
                })
                ..orderBy([
                  (t) {
                    switch (sortOption) {
                      case SortOption.title:
                        return drift.OrderingTerm(
                          expression: t.title,
                          mode: drift.OrderingMode.asc,
                        );
                      case SortOption.author:
                        return drift.OrderingTerm(
                          expression: t.authorText,
                          mode: drift.OrderingMode.asc,
                        );
                      case SortOption.dateAdded:
                        return drift.OrderingTerm(
                          expression: t.dateAdded,
                          mode: drift.OrderingMode.desc,
                        );
                    }
                  },
                ]))
              .watch();
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
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final availabilityResponse = tagId != null
                    ? availabilityState[book.id]
                    : null;
                IconData? statusIcon;
                Color? statusColor;

                if (availabilityResponse != null) {
                  if (availabilityResponse.available) {
                    statusIcon = Icons.check_circle;
                    statusColor = Colors.green;
                  } else {
                    statusIcon = Icons.cancel;
                    statusColor = Colors.red;
                  }
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
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.2),
                          leading: Stack(
                            children: [
                              Hero(
                                tag: 'book_cover_${book.id}',
                                child: Container(
                                  width: 50,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: null,
                                    image: DecorationImage(
                                      image: book.coverUrl != null
                                          ? CachedNetworkImageProvider(
                                              book.coverUrl!,
                                            )
                                          : book.coverId != null
                                          ? CachedNetworkImageProvider(
                                              'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
                                            )
                                          : book.openlibraryKey != null
                                          ? CachedNetworkImageProvider(
                                              'https://covers.openlibrary.org/b/olid/${book.openlibraryKey!.split('/').last}-M.jpg',
                                            )
                                          : const AssetImage(
                                                  'assets/placeholder_book.png',
                                                )
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                      onError: (_, __) {},
                                    ),
                                  ),
                                ),
                              ),
                              if (selectionState.selectedIds.contains(book.id))
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black45,
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
          );
        } else {
          return AnimationLimiter(
            child: GridView.builder(
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
                final availabilityResponse = tagId != null
                    ? availabilityState[book.id]
                    : null;
                Color? borderColor;
                if (availabilityResponse != null) {
                  if (availabilityResponse.available) {
                    borderColor = Colors.green;
                  } else {
                    borderColor = Colors.red;
                  }
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
                          ref.read(selectionProvider.notifier).select(book.id);
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
                                        image: DecorationImage(
                                          image: book.coverUrl != null
                                              ? CachedNetworkImageProvider(
                                                  book.coverUrl!,
                                                )
                                              : book.coverId != null
                                              ? CachedNetworkImageProvider(
                                                  'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
                                                )
                                              : book.openlibraryKey != null
                                              ? CachedNetworkImageProvider(
                                                  'https://covers.openlibrary.org/b/olid/${book.openlibraryKey!.split('/').last}-L.jpg',
                                                )
                                              : const AssetImage(
                                                      'assets/placeholder_book.png',
                                                    )
                                                    as ImageProvider,
                                          fit: BoxFit.cover,
                                          onError: (_, __) {},
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (selectionState.selectedIds.contains(
                                    book.id,
                                  ))
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
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
          );
        }
      },
    );
  }
}
