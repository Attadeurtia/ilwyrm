import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../add_book/edit_book_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implement favorites
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
                    child: const Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
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
                          // Author Chip
                          InkWell(
                            onTap: () {
                              // TODO: Implement navigation or action to show all books by this author
                              // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AuthorBooksPage(author: book.authorText)));
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006978),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                book.authorText ?? 'Auteur inconnu',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commencé',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.startDate != null
                            ? _formatDate(book.startDate!)
                            : 'Pas encore commencé',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fini ?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.finishDate != null
                            ? _formatDate(book.finishDate!)
                            : 'En cours ou non lu',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Genre
                Text('Genre', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [Chip(label: Text(_getShelfLabel(book.shelf)))],
                ),
                const SizedBox(height: 32),

                // Status Change Buttons (Ensuring they are here)
                const Text('Changer de statut'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatusButton(
                      label: 'À lire',
                      isSelected: book.shelf == 'to_read',
                      onPressed: () => _updateStatus(ref, book, 'to_read'),
                    ),
                    _StatusButton(
                      label: 'En cours',
                      isSelected: book.shelf == 'reading',
                      onPressed: () => _updateStatus(ref, book, 'reading'),
                    ),
                    _StatusButton(
                      label: 'Lu',
                      isSelected: book.shelf == 'read',
                      onPressed: () => _updateStatus(ref, book, 'read'),
                    ),
                  ],
                ),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
