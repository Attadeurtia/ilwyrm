import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../data/book_search_api.dart';
import '../../data/open_library_api.dart';
import '../theme_extensions.dart';

class BatchAddPage extends ConsumerStatefulWidget {
  final List<String> isbns;

  const BatchAddPage({super.key, required this.isbns});

  @override
  ConsumerState<BatchAddPage> createState() => _BatchAddPageState();
}

class _BatchAddPageState extends ConsumerState<BatchAddPage> {
  final OpenLibraryApi _api = OpenLibraryApi();
  final List<ExternalBook> _books = [];
  final Set<String> _failedIsbns = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    for (final isbn in widget.isbns) {
      try {
        final results = await _api.searchBooks(isbn);
        if (results.isNotEmpty) {
          // Prefer exact ISBN match if possible, otherwise take the first result
          // OpenLibrary search might return multiple results for an ISBN query
          _books.add(results.first);
        } else {
          _failedIsbns.add(isbn);
        }
      } catch (e) {
        _failedIsbns.add(isbn);
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addAll() async {
    final database = ref.read(databaseProvider);
    int addedCount = 0;

    for (final book in _books) {
      final companion = BooksCompanion(
        title: drift.Value(book.title),
        authorText: drift.Value(book.authorText),
        pageCount: drift.Value(book.numberOfPages),
        shelf: const drift.Value('to_read'),
        shelfName: const drift.Value('À lire'),
        openlibraryKey: book.key.isNotEmpty && book.source == 'openlibrary'
            ? drift.Value(book.key.split('/').last)
            : const drift.Value.absent(),
        isbn13: book.isbns?.isNotEmpty == true
            ? drift.Value(book.isbns!.first)
            : const drift.Value.absent(),
        coverId: const drift.Value.absent(), // See EditBookPage note
        dateAdded: drift.Value(DateTime.now()),
        dateModified: drift.Value(DateTime.now()),
      );
      await database.into(database.books).insert(companion);
      addedCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$addedCount livres ajoutés !')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _removeBook(int index) {
    setState(() {
      _books.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmer l\'ajout'),
        actions: [
          if (!_isLoading && _books.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _addAll,
              tooltip: 'Tout ajouter',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Récupération des informations...'),
                ],
              ),
            )
          : Column(
              children: [
                if (_failedIsbns.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: context.semanticColors.warning.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: context.semanticColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Impossible de trouver ${_failedIsbns.length} livre(s).',
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return ListTile(
                        leading: book.coverUrl != null
                            ? Image.network(
                                book.coverUrl!,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.book, size: 50),
                              )
                            : const Icon(Icons.book, size: 50),
                        title: Text(book.title),
                        subtitle: Text(book.authorText),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeBook(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _books.isNotEmpty ? _addAll : null,
                    icon: const Icon(Icons.playlist_add),
                    label: Text('Ajouter ${_books.length} livres'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
