import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../data/book_companion_mapper.dart';
import '../../data/book_search_api.dart';
import '../../data/book_search_service.dart';
import '../theme_extensions.dart';
import 'scan_cover_page.dart';

class BatchAddPage extends ConsumerStatefulWidget {
  final List<String> isbns;

  const BatchAddPage({super.key, required this.isbns});

  @override
  ConsumerState<BatchAddPage> createState() => _BatchAddPageState();
}

class _BatchAddPageState extends ConsumerState<BatchAddPage> {
  final BookSearchService _service = BookSearchService();

  /// Map of ISBN -> List of found books from all sources
  final Map<String, List<ExternalBook>> _candidates = {};

  /// Map of ISBN -> Currently selected book
  final Map<String, ExternalBook> _selectedBooks = {};

  final Set<String> _failedIsbns = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    for (final isbn in widget.isbns) {
      if (_candidates.containsKey(isbn)) continue;

      try {
        // Interroge les 3 sources, fusionne et reclasse : le meilleur candidat
        // (métadonnées les plus complètes, source la plus fiable) arrive en tête.
        final agg = await _service.search(isbn);
        final merged = agg.merged;

        if (merged.isNotEmpty) {
          _candidates[isbn] = merged;
          _selectedBooks[isbn] = merged.first;
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

    for (final isbn in _selectedBooks.keys) {
      final book = _selectedBooks[isbn]!;
      await database.into(database.books).insert(book.toBooksCompanion());
      addedCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$addedCount livres ajoutés !')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _removeBook(String isbn) {
    setState(() {
      _selectedBooks.remove(isbn);
      _candidates.remove(isbn);
    });
  }

  Future<void> _showSelectionDialog(String isbn) async {
    final candidates = _candidates[isbn];
    if (candidates == null || candidates.isEmpty) return;

    final selected = await showModalBottomSheet<ExternalBook>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Choisir une source pour $isbn',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final book = candidates[index];
                  return ListTile(
                    leading: book.coverUrl != null
                        ? Image.network(
                            book.coverUrl!,
                            width: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.book),
                          )
                        : const Icon(Icons.book),
                    title: Text(book.title),
                    subtitle: Text('${book.authorText} • ${book.source}'),
                    onTap: () => Navigator.pop(context, book),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedBooks[isbn] = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookList = _selectedBooks.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmer l\'ajout'),
        actions: [
          if (!_isLoading && _selectedBooks.isNotEmpty)
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
                  Text(
                    'Recherche sur OpenLibrary, Google Books et Inventaire...',
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_failedIsbns.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: context.semanticColors.warning.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: context.semanticColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Impossible de trouver ${_failedIsbns.length} livre(s) '
                                'par code-barres.',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Repli : quand le code-barres ne donne rien, on propose
                        // de photographier la couverture (OCR).
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanCoverPage(),
                            ),
                          ),
                          icon: const Icon(Icons.document_scanner),
                          label: const Text('Scanner la couverture'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: bookList.length,
                    itemBuilder: (context, index) {
                      final entry = bookList[index];
                      final isbn = entry.key;
                      final book = entry.value;
                      final candidateCount = _candidates[isbn]?.length ?? 0;

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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.authorText),
                            if (candidateCount > 1)
                              Text(
                                'Source: ${book.source} (Tap pour changer)',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                ),
                              )
                            else
                              Text(
                                'Source: ${book.source}',
                                style: TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeBook(isbn),
                        ),
                        onTap: candidateCount > 1
                            ? () => _showSelectionDialog(isbn)
                            : null,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _selectedBooks.isNotEmpty ? _addAll : null,
                    icon: const Icon(Icons.playlist_add),
                    label: Text('Ajouter ${_selectedBooks.length} livres'),
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
