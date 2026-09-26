import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/book_search_service.dart';
import '../../data/database.dart';
import '../../data/open_library_api.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/text_normalize.dart';
import '../add_book/edit_book_page.dart';
import '../add_book/search_book_page.dart';
import 'book_cover.dart';
import '../../data/settings_repository.dart';
import 'manage_tags_dialog.dart';
import '../home/availability_provider.dart';
import '../theme_extensions.dart';
import '../../data/enums.dart';
import '../../l10n/l10n.dart';
import '../adaptive.dart';

class BookDetailsPage extends ConsumerWidget {
  final int bookId;

  /// Livre déjà connu de l'appelant (grille/liste). Utilisé comme donnée
  /// initiale : la couverture (Hero) est ainsi présente dès la 1re frame, sinon
  /// la page affiche d'abord un spinner et la transition Hero « aller » (grille
  /// → fiche) ne se déclenche pas.
  final Book? initialBook;

  const BookDetailsPage({super.key, required this.bookId, this.initialBook});

  /// Vrai s'il y a une vraie couverture à afficher (sinon on ne propose pas le
  /// plein écran, qui n'aurait qu'un placeholder).
  bool _hasCover(Book book) =>
      (book.coverUrl != null && book.coverUrl!.trim().isNotEmpty) ||
      book.coverId != null ||
      (book.openlibraryKey != null && book.openlibraryKey!.trim().isNotEmpty);

  void _openFullscreenCover(BuildContext context, Book book) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, _, _) => _FullscreenCoverPage(book: book),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(booksRepositoryProvider);
    // Tant que le flux n'a rien émis (ou après suppression), on affiche le livre
    // transmis par l'appelant : la couverture Hero est là dès la 1re frame.
    final book = ref.watch(bookProvider(bookId)).value ?? initialBook;
    if (book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            tooltip: book.isFavorite
                ? context.l10n.favoriteRemove
                : context.l10n.actionAddToFavorites,
            icon: Icon(
              book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: book.isFavorite
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            onPressed: () {
              final repository = ref.read(booksRepositoryProvider);
              repository.toggleFavorite(book.id, !book.isFavorite);
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(context.l10n.actionEdit),
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
                  context.l10n.actionDelete,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () async {
                    if (!context.mounted) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(context.l10n.deleteBookTitle),
                        content: Text(
                          context.l10n.deleteBookMessage(book.title),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(context.l10n.actionCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              context.l10n.actionDelete,
                              style: TextStyle(
                                color: Theme.of(ctx).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await repository.deleteBook(book.id);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Centré sur grand écran (ordinateur) pour garder des lignes lisibles.
        padding: centeredPadding(
          MediaQuery.sizeOf(context).width,
          maxWidth: 840,
          top: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Cover + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Couverture — tap pour l'agrandir et proposer des
                // couvertures alternatives. Même comportement qu'il y ait une
                // couverture ou non : sans couverture, ça permet d'en choisir
                // une (un indice « Couverture » l'indique).
                GestureDetector(
                  onTap: () => _openFullscreenCover(context, book),
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'book_cover_${book.id}',
                        child: Container(
                          width: 140,
                          height: 210,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: BookCover(book: book, borderRadius: 16),
                        ),
                      ),
                      if (!_hasCover(book))
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.l10n.coverHint,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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
                                              isAuthorSearch: true,
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
                          context.l10n.unknownAuthor,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 16),

                      // ISBN
                      InkWell(
                        onTap: () {
                          final isbn = book.isbn13 ?? book.isbn10;
                          if (isbn != null) {
                            Clipboard.setData(ClipboardData(text: isbn));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.isbnCopied),
                              ),
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 15,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.isbnLabel,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              book.isbn13 ??
                                  book.isbn10 ??
                                  context.l10n.unknownValue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Added Date
                      Row(
                        children: [
                          Text(
                            context.l10n.addedLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(_formatDate(context, book.dateAdded)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Summary
            Text(
              context.l10n.summaryTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _BookSummary(book: book),
            const SizedBox(height: 32),
            _BookMetadataTable(book: book),
            const SizedBox(height: 32),

            // Dates Cards
            _ReadingStatusButton(book: book),
            const SizedBox(height: 16),
            _LibraryAvailabilityWidget(book: book),
            const SizedBox(height: 32),

            // Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    context.l10n.tagsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: context.l10n.manageTagsTitle,
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
              context.l10n.otherBooksByAuthor,
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
  }

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMMMd(context.l10n.localeName).format(date);
  }
}

class _AuthorBooksList extends ConsumerWidget {
  final String? author;
  final int currentBookId;

  const _AuthorBooksList({required this.author, required this.currentBookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (author == null) return const SizedBox();

    final booksAsync = ref.watch(authorBooksProvider(author!));
    if (!booksAsync.hasValue) return const SizedBox.shrink();
    final books = booksAsync.value!.where((b) => b.id != currentBookId).toList();
    if (books.isEmpty) {
      return Text(context.l10n.noOtherBooks);
    }

    return Column(
      children: books
          .map(
            (book) => ListTile(
              leading: SizedBox(
                width: 50,
                height: 75,
                child: BookCover(book: book, compact: true),
              ),
              title: Text(book.title),
              subtitle: Text(book.authorText ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookDetailsPage(bookId: book.id, initialBook: book),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}

class _BookTagsList extends ConsumerWidget {
  final int bookId;

  const _BookTagsList({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(allTagsProvider).value;
    final bookTags = ref.watch(bookTagsProvider(bookId)).value;
    if (allTags == null || bookTags == null) return const SizedBox.shrink();

    if (allTags.isEmpty) {
      return Text(
        context.l10n.noTagsAvailable,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }

    final repository = ref.read(booksRepositoryProvider);
    final bookTagIds = bookTags.map((t) => t.id).toSet();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: allTags.map((tag) {
        return FilterChip(
          label: Text(tag.name),
          selected: bookTagIds.contains(tag.id),
          onSelected: (selected) => selected
              ? repository.addTagToBook(bookId, tag.id)
              : repository.removeTagFromBook(bookId, tag.id),
        );
      }).toList(),
    );
  }
}

class _ReadingStatusButton extends ConsumerWidget {
  final Book book;

  const _ReadingStatusButton({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(booksRepositoryProvider);

    final status = BookShelf.fromId(book.shelf);
    if (status == BookShelf.toRead) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await repository.updateStatus(book.id, BookShelf.reading);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(
            context.l10n.startReading,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    } else if (status == BookShelf.reading) {
      final days = book.startDate != null
          ? DateTime.now().difference(book.startDate!).inDays
          : 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.startedAgo(days < 0 ? 0 : days),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await repository.updateStatus(book.id, BookShelf.read);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: Text(
              context.l10n.finishReading,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      );
    } else if (status == BookShelf.read) {
      String durationText = context.l10n.durationUnknown;
      if (book.startDate != null && book.finishDate != null) {
        final days = book.finishDate!.difference(book.startDate!).inDays;
        durationText = context.l10n.durationDays(days < 1 ? 1 : days);
      }

      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        child: Column(
          children: [
            Text(
              context.l10n.readingTimeTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
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

class _LibraryAvailabilityWidget extends ConsumerStatefulWidget {
  final Book book;

  const _LibraryAvailabilityWidget({required this.book});

  @override
  ConsumerState<_LibraryAvailabilityWidget> createState() =>
      _LibraryAvailabilityWidgetState();
}

class _LibraryAvailabilityWidgetState
    extends ConsumerState<_LibraryAvailabilityWidget> {
  bool _isLoading = false;
  String? _error;

  Future<void> _checkAvailability() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(availabilityProvider.notifier).checkAvailabilityForBooks([
        widget.book,
      ]);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (!settings.libraryAvailabilityEnabled) {
      return const SizedBox.shrink();
    }

    final availabilityState = ref.watch(availabilityProvider);
    final response = availabilityState[widget.book.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                context.l10n.libraryAvailabilityTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (response != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: context.l10n.refreshTooltip,
                onPressed: _isLoading ? null : _checkAvailability,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (response == null && !_isLoading && _error == null)
          ElevatedButton.icon(
            onPressed: _checkAvailability,
            icon: const Icon(Icons.local_library),
            label: Text(context.l10n.checkAvailability),
          )
        else if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(
            context.l10n.genericError('$_error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else if (response != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    response.available ? Icons.check_circle : Icons.cancel,
                    color: response.available
                        ? context.semanticColors.success
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    response.available
                        ? context.l10n.availableLabel
                        : context.l10n.notAvailableLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: response.available
                          ? context.semanticColors.success
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (response.details.isNotEmpty)
                ...response.details.map(
                  (detail) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(detail.library),
                    subtitle: Text('${detail.status} - ${detail.callNumber}'),
                    trailing: Icon(
                      detail.available ? Icons.check : Icons.close,
                      color: detail.available
                          ? context.semanticColors.success
                          : Theme.of(context).colorScheme.outline,
                      size: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                context.l10n.lastChecked(
                  DateFormat.yMMMd(context.l10n.localeName)
                      .add_Hm()
                      .format(
                        DateTime.fromMillisecondsSinceEpoch(response.lastCheck),
                      ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}

class _BookMetadataTable extends StatelessWidget {
  final Book book;

  const _BookMetadataTable({required this.book});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Map<String, String?> metadata = {
      l10n.metaPublisher: book.publisher,
      l10n.metaPublicationDate: book.publicationYear?.toString(),
      l10n.metaPageCount: book.pageCount?.toString(),
    };

    // Filter out null values
    final validMetadata = Map.fromEntries(
      metadata.entries.where((e) => e.value != null && e.value!.isNotEmpty),
    );

    if (validMetadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bibliographicInfo,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: validMetadata.entries.map((entry) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 16.0),
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    entry.value!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Aperçu plein écran de la couverture, avec zoom/déplacement (InteractiveViewer)
/// et transition Hero depuis la fiche. Propose sous la couverture une liste de
/// couvertures alternatives (par source) ; en toucher une remplace la couverture
/// du livre. On ferme par tap sur l'image, bouton ✕ ou retour système.
class _FullscreenCoverPage extends ConsumerStatefulWidget {
  final Book book;

  const _FullscreenCoverPage({required this.book});

  @override
  ConsumerState<_FullscreenCoverPage> createState() =>
      _FullscreenCoverPageState();
}

class _FullscreenCoverPageState extends ConsumerState<_FullscreenCoverPage> {
  late final BookSearchService _service = ref.read(bookSearchServiceProvider);
  List<_CoverOption> _alternatives = const [];
  bool _loading = true;

  /// Couverture choisie : vignette de la liste (pour la surligner et patienter)
  /// et URL enregistrée (version large pour OpenLibrary).
  _CoverOption? _selected;
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    _fetchAlternatives();
  }

  Future<void> _fetchAlternatives() async {
    final book = widget.book;
    final isbn13 = book.isbn13;
    final isbn10 = book.isbn10;
    final isbn = (isbn13 != null && isbn13.isNotEmpty)
        ? isbn13
        : (isbn10 != null && isbn10.isNotEmpty)
            ? isbn10
            : null;
    // Recherche par titre + auteur pour ramener PLUSIEURS éditions par source.
    final query = [book.title, book.authorText ?? '']
        .where((s) => s.trim().isNotEmpty)
        .join(' ');
    if (query.trim().isEmpty && isbn == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      // En parallèle : les couvertures des ÉDITIONS de l'œuvre OpenLibrary
      // (modèle Work → Editions) + une recherche multi-sources dont on garde
      // plusieurs couvertures par source (BnF, Inventaire, Google Books).
      final olFuture = OpenLibraryApi()
          .fetchEditionCovers(openlibraryKey: book.openlibraryKey, isbn: isbn);
      final aggFuture = query.trim().isEmpty
          ? Future.value(AggregatedResults.empty())
          : _service.search(query);
      final olCovers = await olFuture;
      final agg = await aggFuture;

      final options = <_CoverOption>[];
      final seen = <String>{};
      // Éditions OpenLibrary (couvertures multiples, déjà propres à l'œuvre).
      for (final url in olCovers) {
        if (seen.add(url)) {
          options.add(_CoverOption(url: url, source: kOpenLibrary));
        }
      }
      // Autres sources : plusieurs couvertures chacune, en ne gardant que les
      // résultats dont le titre correspond (évite les couvertures d'un autre
      // livre du même auteur).
      const perSourceCap = 6;
      for (final entry in agg.bySource.entries) {
        if (entry.key == kOpenLibrary) continue;
        var count = 0;
        for (final b in entry.value) {
          if (count >= perSourceCap) break;
          final url = b.coverUrl;
          if (url != null &&
              url.isNotEmpty &&
              titlesMatch(book.title, b.title) &&
              seen.add(url)) {
            options.add(_CoverOption(url: url, source: entry.key));
            count++;
          }
        }
      }
      if (mounted) {
        setState(() {
          _alternatives = options.take(30).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _select(_CoverOption option) async {
    final url = option.url;
    // Pour une couverture OpenLibrary, on enregistre la version large (-L) plutôt
    // que la vignette (-M) affichée dans la liste.
    final persisted = url.contains('covers.openlibrary.org')
        ? url.replaceAll('-M.jpg', '-L.jpg')
        : url;
    setState(() {
      _selected = option;
      _selectedUrl = persisted;
    });
    await ref.read(booksRepositoryProvider).updateCover(widget.book.id, persisted);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.coverUpdated),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: context.l10n.actionClose,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Hero(
                      tag: 'book_cover_${widget.book.id}',
                      child: _selectedUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _selectedUrl!,
                              fit: BoxFit.contain,
                              fadeInDuration: Duration.zero,
                              // La vignette (déjà chargée) patiente pendant le
                              // téléchargement de la version large.
                              placeholder: (context, _) => CachedNetworkImage(
                                imageUrl: _selected!.url,
                                fit: BoxFit.contain,
                              ),
                            )
                          : BookCover(
                              book: widget.book,
                              fit: BoxFit.contain,
                              borderRadius: 0,
                              fullResolution: true,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            // La bande apparaît en fondu, et sa hauteur s'anime (chargement →
            // liste, ou disparition s'il n'y a rien à proposer).
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildAlternatives(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternatives() {
    if (_loading) {
      return const SizedBox(
        key: ValueKey('loading'),
        height: 150,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_alternatives.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      key: const ValueKey('alternatives'),
      height: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              context.l10n.otherCovers,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: MouseDragScroll(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _alternatives.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final opt = _alternatives[i];
                  final selected = identical(_selected, opt);
                  return GestureDetector(
                    onTap: () => _select(opt),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: selected
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: opt.url,
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                            placeholder: (c, _) => Container(
                              width: 80,
                              height: 110,
                              color: Colors.white10,
                            ),
                            errorWidget: (c, _, _) => Container(
                              width: 80,
                              height: 110,
                              color: Colors.white10,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.white30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt.source,
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverOption {
  const _CoverOption({required this.url, required this.source});
  final String url;
  final String source;
}

/// Affiche le résumé du livre : celui déjà en base, sinon le récupère via les
/// APIs (Google Books, OpenLibrary, Inventaire) et le met en cache.
class _BookSummary extends ConsumerStatefulWidget {
  final Book book;

  const _BookSummary({required this.book});

  @override
  ConsumerState<_BookSummary> createState() => _BookSummaryState();
}

class _BookSummaryState extends ConsumerState<_BookSummary> {
  /// Livres pour lesquels aucune source n'a de résumé (durant cette session) :
  /// on ne relance pas 4 recherches réseau à chaque ouverture de la fiche.
  static final Set<int> _notFound = {};

  String? _summary;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final stored = widget.book.description?.trim();
    if (stored != null && stored.isNotEmpty) {
      _summary = _cleanHtml(stored);
    } else if (!_notFound.contains(widget.book.id)) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final book = widget.book;
    final isbn = [book.isbn13, book.isbn10]
        .whereType<String>()
        .firstWhere((s) => s.trim().isNotEmpty, orElse: () => '');
    final titleQuery = [book.title, book.authorText ?? '']
        .where((s) => s.trim().isNotEmpty)
        .join(' ');

    // D'abord par ISBN (l'édition exacte), puis par titre + auteur (une autre
    // édition du même livre), en ne gardant qu'un résultat au titre concordant.
    String? desc;
    try {
      final service = ref.read(bookSearchServiceProvider);
      if (isbn.isNotEmpty) desc = _firstDescription(await service.search(isbn));
      if (desc == null && titleQuery.isNotEmpty) {
        desc = _firstDescription(
          await service.search(titleQuery),
          matchingTitle: book.title,
        );
      }
    } catch (_) {}

    if (desc == null) _notFound.add(book.id);
    if (!mounted) return;
    setState(() {
      _summary = desc;
      _loading = false;
    });
    if (desc != null) {
      // Mise en cache pour les prochaines ouvertures (et l'hors-ligne).
      ref.read(booksRepositoryProvider).updateDescription(book.id, desc);
    }
  }

  String? _firstDescription(AggregatedResults agg, {String? matchingTitle}) {
    for (final b in agg.merged) {
      if (matchingTitle != null && !titlesMatch(matchingTitle, b.title)) {
        continue;
      }
      final d = b.description?.trim();
      if (d != null && d.isNotEmpty) return _cleanHtml(d);
    }
    return null;
  }

  static final RegExp _br = RegExp(r'<br\s*/?>', caseSensitive: false);
  static final RegExp _pEnd = RegExp(r'</p>', caseSensitive: false);
  static final RegExp _tag = RegExp(r'<[^>]+>');
  static final RegExp _blankLines = RegExp(r'\n{3,}');

  /// Nettoie le HTML léger que renvoient certaines sources (Google Books).
  String _cleanHtml(String s) {
    var out = s.replaceAll(_br, '\n');
    out = out.replaceAll(_pEnd, '\n\n');
    out = out.replaceAll(_tag, '');
    out = out
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
    return out.replaceAll(_blankLines, '\n\n').trim();
  }

  @override
  Widget build(BuildContext context) {
    // Le résumé remplace l'indicateur en fondu, et la hauteur s'anime au lieu
    // de faire sauter la mise en page.
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topLeft,
          children: [...previous, ?current],
        ),
        child: _loading ? _loadingRow(context) : _summaryText(context),
      ),
    );
  }

  Widget _loadingRow(BuildContext context) {
    return Row(
      key: const ValueKey('loading'),
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          context.l10n.summaryLoading,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _summaryText(BuildContext context) {
    final text = (_summary != null && _summary!.isNotEmpty)
        ? _summary!
        : context.l10n.noSummary;
    return Text(
      text,
      key: const ValueKey('summary'),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
    );
  }
}
