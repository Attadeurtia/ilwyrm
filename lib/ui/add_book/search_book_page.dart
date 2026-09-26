import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/book_companion_mapper.dart';
import '../../data/book_search_api.dart';
import '../../data/book_search_service.dart';
import '../../data/database.dart';
import '../../data/library_index.dart';
import '../../l10n/l10n.dart';
import '../adaptive.dart';
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
  late final BookSearchService _service = ref.read(bookSearchServiceProvider);
  late TabController _tabController;
  Timer? _debounce;
  Timer? _snackTimer;

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

  /// Fiches en cours d'ajout : un double appui sur « + » ne crée pas de doublon
  /// (les deux appuis liraient la base avant l'insertion du premier).
  final Set<ExternalBook> _adding = {};

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
    _snackTimer?.cancel();
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
    if (!_adding.add(book)) return;
    try {
      await _addIfAbsent(book);
    } finally {
      _adding.remove(book);
    }
  }

  Future<void> _addIfAbsent(ExternalBook book) async {
    final database = ref.read(databaseProvider);

    // Vérification anti-doublon faisant autorité : on relit la bibliothèque et
    // on applique la même détection (ISBN, identifiants, titre+auteur). Ainsi,
    // même si l'affichage n'est pas encore à jour, on n'insère jamais un
    // doublon.
    final existingId = buildLibraryIndex(await database.getAllBooks()).findId(book);
    if (!mounted) return;
    if (existingId != null) {
      _showSnack(context.l10n.bookAlreadyInLibrary, goToBookId: existingId);
      return;
    }

    final id =
        await database.into(database.books).insert(book.toBooksCompanion());
    if (!mounted) return;
    _showSnack(context.l10n.bookAddedToList(book.title), goToBookId: id);
  }

  /// Affiche un message éphémère (auto-masqué après quelques secondes) avec un
  /// lien « Y aller » vers la fiche du livre.
  void _showSnack(String message, {required int goToBookId}) {
    const duration = Duration(seconds: 3);
    final messenger = ScaffoldMessenger.of(context);
    _snackTimer?.cancel();
    messenger.clearSnackBars();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: context.l10n.goToBook,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsPage(bookId: goToBookId),
              ),
            );
          },
        ),
      ),
    );
    // Filet de sécurité : on force la fermeture après la durée. Le minuteur
    // interne du SnackBar ne se déclenche pas de façon fiable ici (la liste se
    // reconstruit au moment de l'ajout), donc on ferme nous-mêmes cette
    // instance précise.
    _snackTimer = Timer(duration, controller.close);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
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
            tooltip: context.l10n.addManually,
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
                tabs: [
                  Tab(text: context.l10n.searchTabAll),
                  const Tab(text: 'OpenLibrary'),
                  const Tab(text: 'BnF'),
                  const Tab(text: 'Inventaire'),
                  const Tab(text: 'Google Books'),
                ],
              ),
            ],
          ),
        ),
      ),
      // On ne réabonne que la LISTE à l'index des doublons : l'AppBar et le champ
      // de recherche restent stables (sinon leurs reconstructions perturbent le
      // clavier et le minuteur du SnackBar).
      body: Consumer(
        builder: (context, ref, _) {
          final libraryIndex =
              ref.watch(libraryIndexProvider).value ?? LibraryIndex.empty;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMergedList(libraryIndex),
              for (final source in _sourceTabs)
                _buildSourceList(source, libraryIndex),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMergedList(LibraryIndex libraryIndex) {
    final books = _results.merged;
    if (books.isEmpty) {
      return _emptyState(anyError: _results.errors.values.any((e) => e != null));
    }
    return ListView.builder(
      padding: centeredPadding(MediaQuery.sizeOf(context).width, minimum: 0),
      itemCount: books.length,
      itemBuilder: (context, index) =>
          _bookTile(books[index], libraryIndex, showBadges: true),
    );
  }

  Widget _buildSourceList(String source, LibraryIndex libraryIndex) {
    final error = _results.errors[source];
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.sourceError(source, _errorLabel(error)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final books = _results.bySource[source] ?? const [];
    if (books.isEmpty) return _emptyState();
    return ListView.builder(
      padding: centeredPadding(MediaQuery.sizeOf(context).width, minimum: 0),
      itemCount: books.length,
      itemBuilder: (context, index) => _bookTile(books[index], libraryIndex),
    );
  }

  String _errorLabel(SearchError error) => switch (error) {
    SearchError.timeout => context.l10n.searchErrorTimeout,
    SearchError.quotaExceeded => context.l10n.searchErrorQuota,
    SearchError.accessDenied => context.l10n.searchErrorForbidden,
    SearchError.unavailable => context.l10n.searchErrorUnavailable,
  };

  Widget _emptyState({bool anyError = false}) {
    final String message;
    if (_loading) {
      message = context.l10n.searching;
    } else if (_lastSubmitted.isEmpty) {
      message = context.l10n.searchPrompt;
    } else if (anyError) {
      message = context.l10n.noResultsSomeUnavailable;
    } else {
      message = context.l10n.noResults;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _bookTile(ExternalBook book, LibraryIndex libraryIndex,
      {bool showBadges = false}) {
    final year = book.firstPublishYear?.toString() ?? '?';
    final hasAuthor = book.authorText.trim().isNotEmpty &&
        book.authorText.trim().toLowerCase() != 'unknown author';
    final subtitleParts = <String>[
      if (hasAuthor)
        book.authorText
      else if (book.shortDescription != null)
        book.shortDescription!,
    ];

    final existingId = libraryIndex.findId(book);
    final inLibrary = existingId != null;
    final showChips = showBadges || inLibrary;

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
          if (showChips)
            _badgesRow(
              inLibrary: inLibrary,
              sources: showBadges ? book.sources : const {},
            ),
        ],
      ),
      isThreeLine: showChips,
      trailing: inLibrary
          ? Tooltip(
              message: context.l10n.alreadyInLibrary,
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.add),
              tooltip: context.l10n.addToReadingList,
              onPressed: () => _quickAddBook(book),
            ),
      onTap: () {
        if (inLibrary) {
          // Déjà présent : on ouvre la fiche existante plutôt que d'en créer un
          // doublon.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsPage(bookId: existingId),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditBookPage(initialBook: book),
            ),
          );
        }
      },
    );
  }

  Widget _badgesRow({required bool inLibrary, required Set<String> sources}) {
    final scheme = Theme.of(context).colorScheme;
    final sourceLabels = sources.map((s) => _sourceBadges[s] ?? s).toList()
      ..sort();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (inLibrary)
            _badge(
              context.l10n.alreadyInLibrary,
              background: scheme.primaryContainer,
              foreground: scheme.onPrimaryContainer,
              icon: Icons.check,
            ),
          for (final label in sourceLabels)
            _badge(
              label,
              background: scheme.secondaryContainer,
              foreground: scheme.onSecondaryContainer,
            ),
        ],
      ),
    );
  }

  Widget _badge(
    String label, {
    required Color background,
    required Color foreground,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, color: foreground),
          ),
        ],
      ),
    );
  }
}
