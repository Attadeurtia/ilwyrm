import 'package:flutter/material.dart';
import '../../data/open_library_api.dart';
import 'edit_book_page.dart';

class SearchBookPage extends StatefulWidget {
  final String? initialQuery;

  const SearchBookPage({super.key, this.initialQuery});

  @override
  State<SearchBookPage> createState() => _SearchBookPageState();
}

class _SearchBookPageState extends State<SearchBookPage> {
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
