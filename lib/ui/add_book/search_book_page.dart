import 'package:flutter/material.dart';
import '../../data/book_search_api.dart';
import '../../data/google_books_api.dart';
import '../../data/inventaire_api.dart';
import '../../data/open_library_api.dart';
import 'edit_book_page.dart';

class SearchBookPage extends StatefulWidget {
  final String? initialQuery;

  const SearchBookPage({super.key, this.initialQuery});

  @override
  State<SearchBookPage> createState() => _SearchBookPageState();
}

class _SearchBookPageState extends State<SearchBookPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;

  final Map<String, BookSearchApi> _apis = {
    'OpenLibrary': OpenLibraryApi(),
    'Google Books': GoogleBooksApi(),
    'Inventaire': InventaireApi(),
  };

  final Map<String, List<ExternalBook>> _results = {
    'OpenLibrary': [],
    'Google Books': [],
    'Inventaire': [],
  };

  final Map<String, bool> _isLoading = {
    'OpenLibrary': false,
    'Google Books': false,
    'Inventaire': false,
  };

  final Map<String, String?> _errors = {
    'OpenLibrary': null,
    'Google Books': null,
    'Inventaire': null,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialQuery != null) {
      _controller.text = widget.initialQuery!;
      _searchAll();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchAll() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    // Trigger search for all APIs
    // In a more complex app, we might want to only search the active tab
    // and cache others, or search all. Searching all is fine for now.
    for (final source in _apis.keys) {
      _searchSource(source, query);
    }
  }

  Future<void> _searchSource(String source, String query) async {
    setState(() {
      _isLoading[source] = true;
      _errors[source] = null;
    });

    try {
      final books = await _apis[source]!.searchBooks(query);
      if (mounted) {
        setState(() {
          _results[source] = books;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errors[source] = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading[source] = false;
        });
      }
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
          onSubmitted: (_) => _searchAll(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _searchAll),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'OpenLibrary'),
            Tab(text: 'Google Books'),
            Tab(text: 'Inventaire'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResultList('OpenLibrary'),
          _buildResultList('Google Books'),
          _buildResultList('Inventaire'),
        ],
      ),
    );
  }

  Widget _buildResultList(String source) {
    if (_isLoading[source] == true) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errors[source] != null) {
      return Center(child: Text('Erreur: ${_errors[source]}'));
    }

    final books = _results[source] ?? [];

    if (books.isEmpty && _controller.text.isNotEmpty) {
      return const Center(child: Text('Aucun résultat trouvé.'));
    } else if (books.isEmpty) {
      return const Center(child: Text('Entrez une recherche.'));
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
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
          subtitle: Text(
            '${book.authorText} (${book.firstPublishYear ?? "?"})',
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
    );
  }
}
