import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../data/open_library_api.dart';
import 'edit_book_page.dart';

class SearchBookPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchBookPage({super.key, this.initialQuery});

  @override
  ConsumerState<SearchBookPage> createState() => _SearchBookPageState();
}

class _SearchBookPageState extends ConsumerState<SearchBookPage> {
  final TextEditingController _controller = TextEditingController();
  final OpenLibraryApi _api = OpenLibraryApi();
  List<OpenLibraryBook> _books = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _controller.text = widget.initialQuery!;
      _search();
    }
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final books = await _api.searchBooks(query);
      setState(() {
        _books = books;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _quickAddBook(OpenLibraryBook book) async {
    final database = ref.read(databaseProvider);

    final newBook = BooksCompanion(
      title: drift.Value(book.title),
      authorText: drift.Value(book.authorText),
      pageCount: drift.Value(book.numberOfPages),
      shelf: const drift.Value('to_read'),
      shelfName: const drift.Value('À lire'),
      openlibraryKey: book.key.isNotEmpty
          ? drift.Value(book.key.split('/').last)
          : const drift.Value.absent(),
      isbn13: book.isbns?.isNotEmpty == true
          ? drift.Value(book.isbns!.first)
          : const drift.Value.absent(),
      coverId: drift.Value(book.coverId),
      dateAdded: drift.Value(DateTime.now()),
      dateModified: drift.Value(DateTime.now()),
    );

    await database.into(database.books).insert(newBook);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livre ajouté à "À lire" !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Titre, auteur, ISBN...',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter manuellement',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditBookPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Erreur: $_error'))
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  leading: book.coverUrl != null
                      ? Image.network(
                          book.coverUrl!,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, size: 50),
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.authorText} (${book.firstPublishYear ?? "?"})',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Ajouter rapidement',
                    onPressed: () => _quickAddBook(book),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBookPage(initialBook: book),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
