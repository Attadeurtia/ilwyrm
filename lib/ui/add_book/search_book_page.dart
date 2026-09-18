import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/book_companion_mapper.dart';
import '../../data/book_search_api.dart';
import '../../data/book_search_service.dart';
import '../../data/database.dart';
import '../books/bookshelf_detail_page.dart';
import 'edit_book_page.dart';

class SearchBookPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  final bool isAuthorSearch;

  const SearchBookPage({
    super.key,
    this.initialQuery,
    this.isAuthorSearch = false,
  });

  @override
  ConsumerState<SearchBookPage> createState() => _SearchBookPageState();
}

class _SearchBookPageState extends ConsumerState<SearchBookPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final BookSearchService _service = BookSearchService();
  late TabController _tabController;
  Timer? _debounce;

  static const Duration _debounceDelay = Duration(milliseconds: 400);
  static const int _minChars = 2;

  static const List<String> _sourceTabs = [
    kOpenLibrary,
    kBnf,
    kInventaire,
    kGoogleBooks,
  ];

  static const Map<String, String> _sourceBadges = {
    'openlibrary': 'OL',
    'bnf': 'BnF',
    'inventaire': 'Inventaire',
    'google_books': 'Google',
  };

  AggregatedResults _results = AggregatedResults.empty();
  bool _loading = false;
  int _searchSeq = 0;
  String _lastSubmitted = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      _runSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < _minChars) {
      _debounce?.cancel();
      setState(() {
        _results = AggregatedResults.empty();
        _loading = false;
        _lastSubmitted = '';
      });
      return;
    }
    _debounce = Timer(_debounceDelay, () => _runSearch(query));
  }

  Future<void> _runSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;
    _lastSubmitted = query;

    final seq = ++_searchSeq;
    setState(() => _loading = true);

    try {
      final results = await _service.search(
        query,
        authorSearch: widget.isAuthorSearch,
      );
      if (!mounted || seq != _searchSeq) return; // réponse périmée
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || seq != _searchSeq) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _quickAddBook(ExternalBook book) async {
    final database = ref.read(databaseProvider);
    final id =
        await database.into(database.books).insert(book.toBooksCompanion());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('« ${book.title} » ajouté à la liste !'),
        action: SnackBarAction(
          label: 'Y aller',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsPage(bookId: id),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Titre, auteur, ISBN...',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: (value) {
            _debounce?.cancel();
            _runSearch(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _debounce?.cancel();
              _runSearch(_controller.text);
            },
          ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48 + 4),
          child: Column(
            children: [
              SizedBox(
                height: 4,
                child: _loading
                    ? const LinearProgressIndicator(minHeight: 4)
                    : null,
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Tous'),
                  Tab(text: 'OpenLibrary'),
                  Tab(text: 'BnF'),
                  Tab(text: 'Inventaire'),
                  Tab(text: 'Google Books'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMergedList(),
          for (final source in _sourceTabs) _buildSourceList(source),
        ],
      ),
    );
  }

  Widget _buildMergedList() {
    final books = _results.merged;
    if (books.isEmpty) {
      return _emptyState(anyError: _results.errors.values.any((e) => e != null));
    }
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) => _bookTile(books[index], showBadges: true),
    );
  }

  Widget _buildSourceList(String source) {
    final error = _results.errors[source];
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('$source : $error', textAlign: TextAlign.center),
        ),
      );
    }
    final books = _results.bySource[source] ?? const [];
    if (books.isEmpty) return _emptyState();
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) => _bookTile(books[index]),
    );
  }

  Widget _emptyState({bool anyError = false}) {
    final String message;
    if (_loading) {
      message = 'Recherche…';
    } else if (_lastSubmitted.isEmpty) {
      message = 'Entrez un titre, un auteur ou un ISBN.';
    } else if (anyError) {
      message = 'Aucun résultat (certaines sources sont indisponibles).';
    } else {
      message = 'Aucun résultat trouvé.';
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _bookTile(ExternalBook book, {bool showBadges = false}) {
    final year = book.firstPublishYear?.toString() ?? '?';
    final hasAuthor = book.authorText.trim().isNotEmpty &&
        book.authorText.trim().toLowerCase() != 'unknown author';
    final subtitleParts = <String>[
      if (hasAuthor) book.authorText else if (book.description != null) book.description!,
    ];

    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 64,
        child: book.coverUrl != null
            ? Image.network(
                book.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.book, size: 40),
              )
            : const Icon(Icons.book, size: 40),
      ),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitleParts.isEmpty ? '($year)' : '${subtitleParts.first} ($year)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showBadges) _sourceBadgeRow(book.sources),
        ],
      ),
      isThreeLine: showBadges,
      trailing: IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Ajouter à la liste de lecture',
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
  }

  Widget _sourceBadgeRow(Set<String> sources) {
    final labels = sources
        .map((s) => _sourceBadges[s] ?? s)
        .toList()
      ..sort();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        children: [
          for (final label in labels)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
