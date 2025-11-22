import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import 'bookshelf_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/sort_provider.dart';
import 'package:drift/drift.dart' as drift;

class BookListView extends ConsumerWidget {
  final String status;

  const BookListView({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    // Map tab status to database shelf values
    // "À lire" -> "to_read" (or "to-read")
    // "En cours" -> "reading"
    // "Lus" -> "read"
    String dbStatus;
    if (status == 'to_read') {
      dbStatus = 'to_read'; // Or 'to-read' depending on what we used in seed
    } else if (status == 'reading') {
      dbStatus = 'reading';
    } else {
      dbStatus = 'read';
    }

    // Handle the 'to-read' vs 'to_read' inconsistency if any
    // In seed we used 'to_read' for Dune and 'read'/'reading' for others.
    // Let's query safely.

    final sortOption = ref.watch(sortProvider);

    return StreamBuilder<List<Book>>(
      stream:
          (database.select(database.books)
                ..where((tbl) => tbl.shelf.equals(dbStatus))
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
              .watch(),
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

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: book.coverId != null
                          ? CachedNetworkImageProvider(
                              'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
                            )
                          : book.openlibraryKey != null
                          ? CachedNetworkImageProvider(
                              'https://covers.openlibrary.org/b/olid/${book.openlibraryKey!.split('/').last}-M.jpg',
                            )
                          : const AssetImage('assets/placeholder_book.png')
                                as ImageProvider,
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                    color: Colors.grey[300],
                  ),
                  child: book.openlibraryKey == null && book.coverId == null
                      ? const Center(child: Icon(Icons.book, size: 24))
                      : null,
                ),
                title: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  book.authorText ?? 'Auteur inconnu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: book.rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text('${book.rating}'),
                        ],
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsPage(bookId: book.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
