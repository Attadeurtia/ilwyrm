import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../add_book/edit_book_page.dart';
import '../add_book/search_book_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'manage_tags_dialog.dart';

class BookDetailsPage extends ConsumerWidget {
  final int bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return StreamBuilder<Book>(
      stream: (database.select(
        database.books,
      )..where((tbl) => tbl.id.equals(bookId))).watchSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final book = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
            actions: [
              IconButton(
                icon: Icon(
                  book.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: book.isFavorite
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                onPressed: () {
                  final database = ref.read(databaseProvider);
                  (database.update(
                    database.books,
                  )..where((tbl) => tbl.id.equals(book.id))).write(
                    BooksCompanion(isFavorite: drift.Value(!book.isFavorite)),
                  );
                },
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Modifier'),
                    onTap: () {
                      Future.delayed(const Duration(seconds: 0), () {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditBookPage(existingBook: book),
                            ),
                          );
                        }
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () {
                      Future.delayed(const Duration(seconds: 0), () {
                        if (context.mounted) {
                          database.deleteBook(book.id);
                          Navigator.of(
                            context,
                          ).pop(); // Pop the detail page after deleting
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Cover + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image
                    Hero(
                      tag: 'book_cover_${book.id}',
                      child: Container(
                        width: 140,
                        height: 210,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: book.coverId != null
                                ? CachedNetworkImageProvider(
                                    'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg',
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
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child:
                            book.coverId == null && book.openlibraryKey == null
                            ? Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                child: const Center(
                                  child: Icon(Icons.book, size: 40),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author Chips
                          if (book.authorText != null)
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: book.authorText!
                                  .split(',')
                                  .map((author) => author.trim())
                                  .where((author) => author.isNotEmpty)
                                  .map((author) {
                                    return ActionChip(
                                      label: Text(
                                        author,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchBookPage(
                                                  initialQuery: author,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  })
                                  .toList(),
                            )
                          else
                            Text(
                              'Auteur inconnu',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          const SizedBox(height: 16),
                          // Pages
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${book.pageCount ?? "?"} pages',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // ISBN
                          InkWell(
                            onTap: () {
                              if (book.isbn13 != null) {
                                Clipboard.setData(
                                  ClipboardData(text: book.isbn13!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ISBN copié dans le presse-papier',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ISBN',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(book.isbn13 ?? 'Inconnu'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Added Date
                          Text(
                            'Ajouté',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(_formatDate(book.dateAdded)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Summary
                Text(
                  'Résumé',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.reviewContent ?? 'Aucun résumé disponible.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Dates Cards
                _ReadingStatusButton(book: book),
                const SizedBox(height: 16),
                const SizedBox(height: 32),

                // Tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tags', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ManageTagsDialog(bookId: book.id),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BookTagsList(bookId: book.id),
                const SizedBox(height: 32),

                // Other books by author
                Text(
                  'Autre livre de l\'auteur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _AuthorBooksList(
                  author: book.authorText,
                  currentBookId: book.id,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatter, ideally use intl package
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getShelfLabel(String shelf) {
    switch (shelf) {
      case 'to_read':
        return 'À lire';
      case 'reading':
        return 'En cours';
      case 'read':
        return 'Lu';
      default:
        return shelf;
    }
  }

  Future<void> _updateStatus(WidgetRef ref, Book book, String newStatus) async {
    final database = ref.read(databaseProvider);
    await (database.update(database.books)
          ..where((tbl) => tbl.id.equals(book.id)))
        .write(BooksCompanion(shelf: drift.Value(newStatus)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce livre ?'),
        content: Text('Voulez-vous vraiment supprimer "${book.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final database = ref.read(databaseProvider);
      await (database.delete(
        database.books,
      )..where((tbl) => tbl.id.equals(book.id))).go();
      if (context.mounted) {
        Navigator.pop(context); // Close details page
      }
    }
  }
}

class _AuthorBooksList extends ConsumerWidget {
  final String? author;
  final int currentBookId;

  const _AuthorBooksList({required this.author, required this.currentBookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (author == null) return const SizedBox();

    final database = ref.watch(databaseProvider);

    return FutureBuilder<List<Book>>(
      future:
          (database.select(database.books)
                ..where(
                  (tbl) =>
                      tbl.authorText.equals(author!) &
                      tbl.id.equals(currentBookId).not(),
                )
                ..limit(3))
              .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Aucun autre livre trouvé.');
        }

        return Column(
          children: snapshot.data!
              .map(
                (book) => ListTile(
                  leading: Container(
                    width: 50,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                    ),
                  ),
                  title: Text(book.title),
                  subtitle: Text(book.authorText ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailsPage(bookId: book.id),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _BookTagsList extends ConsumerWidget {
  final int bookId;

  const _BookTagsList({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<List<Tag>>(
      future: database.getTagsForBook(bookId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Aucun tag.', style: TextStyle(color: Colors.grey));
        }

        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: snapshot.data!
              .map(
                (tag) => Chip(
                  label: Text(tag.name),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
    );
  }
}

class _ReadingStatusButton extends ConsumerWidget {
  final Book book;

  const _ReadingStatusButton({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);

    if (book.shelf == 'to_read') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await (database.update(
              database.books,
            )..where((tbl) => tbl.id.equals(book.id))).write(
              BooksCompanion(
                shelf: const drift.Value('reading'),
                startDate: drift.Value(DateTime.now()),
                dateModified: drift.Value(DateTime.now()),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Commencer', style: TextStyle(fontSize: 18)),
        ),
      );
    } else if (book.shelf == 'reading') {
      final days = book.startDate != null
          ? DateTime.now().difference(book.startDate!).inDays
          : 0;
      final daysText = days == 0 ? 'aujourd\'hui' : '$days jours';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Commencé $daysText',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await (database.update(
                database.books,
              )..where((tbl) => tbl.id.equals(book.id))).write(
                BooksCompanion(
                  shelf: const drift.Value('read'),
                  finishDate: drift.Value(DateTime.now()),
                  dateModified: drift.Value(DateTime.now()),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('Terminé', style: TextStyle(fontSize: 18)),
          ),
        ],
      );
    } else if (book.shelf == 'read') {
      String durationText = 'Unknown duration';
      if (book.startDate != null && book.finishDate != null) {
        final days = book.finishDate!.difference(book.startDate!).inDays;
        durationText = days == 0 ? '1 jour' : '$days jours';
      }

      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            const Text(
              'Temps de lecture',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(durationText, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
