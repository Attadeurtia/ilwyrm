import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/book_search_service.dart';
import '../../data/database.dart';
import '../../data/open_library_api.dart';
import '../../data/repositories/books_repository.dart';
import '../add_book/edit_book_page.dart';
import '../add_book/search_book_page.dart';
import 'book_cover.dart';
import '../../data/settings_repository.dart';
import 'manage_tags_dialog.dart';
import '../home/availability_provider.dart';
import '../theme_extensions.dart';
import '../../data/enums.dart';

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

    return StreamBuilder<Book>(
      initialData: initialBook,
      stream: repository.watchBook(bookId),
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
                  final repository = ref.read(booksRepositoryProvider);
                  repository.toggleFavorite(book.id, !book.isFavorite);
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
                      Future.delayed(Duration.zero, () async {
                        if (!context.mounted) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Supprimer le livre ?'),
                            content: Text(
                              'Voulez-vous vraiment supprimer « ${book.title} » ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  'Supprimer',
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Cover + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image — tap pour l'afficher en plein écran.
                    GestureDetector(
                      onTap: _hasCover(book)
                          ? () => _openFullscreenCover(context, book)
                          : null,
                      child: Hero(
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
                              'Auteur inconnu',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          const SizedBox(height: 16),

                          // Pages
                          const SizedBox(height: 16),

                          // ISBN
                          InkWell(
                            onTap: () {
                              final isbn = book.isbn13 ?? book.isbn10;
                              if (isbn != null) {
                                Clipboard.setData(ClipboardData(text: isbn));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ISBN copié dans le presse-papier',
                                    ),
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
                                  'ISBN :',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Text(book.isbn13 ?? book.isbn10 ?? 'Inconnu'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Added Date
                          Row(
                            children: [
                              Text(
                                'Ajouté :',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(_formatDate(book.dateAdded)),
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
                  'Résumé',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.reviewContent ?? 'Aucun résumé disponible.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
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
                        'Tags',
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
    return DateFormat.yMMMd('fr_FR').format(date);
  }
}

class _AuthorBooksList extends ConsumerWidget {
  final String? author;
  final int currentBookId;

  const _AuthorBooksList({required this.author, required this.currentBookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (author == null) return const SizedBox();

    final repository = ref.watch(booksRepositoryProvider);

    return FutureBuilder<List<Book>>(
      future: repository.getBooksByAuthor(author!),
      builder: (context, snapshot) {
        final books =
            (snapshot.data ?? []).where((b) => b.id != currentBookId).toList();
        if (books.isEmpty) {
          return const Text('Aucun autre livre trouvé.');
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
      },
    );
  }
}

class _BookTagsList extends ConsumerStatefulWidget {
  final int bookId;

  const _BookTagsList({required this.bookId});

  @override
  ConsumerState<_BookTagsList> createState() => _BookTagsListState();
}

class _BookTagsListState extends ConsumerState<_BookTagsList> {
  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(booksRepositoryProvider);

    return FutureBuilder<(List<Tag>, List<Tag>)>(
      future: Future.wait([
        repository.getAllTags(),
        repository.getTagsForBook(widget.bookId),
      ]).then((values) => (values[0], values[1])),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allTags = snapshot.data!.$1;
        final bookTags = snapshot.data!.$2;
        final bookTagIds = bookTags.map((t) => t.id).toSet();

        if (allTags.isEmpty) {
          return Text(
            'Aucun tag disponible.',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: allTags.map((tag) {
            final isSelected = bookTagIds.contains(tag.id);
            return FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (selected) async {
                if (selected) {
                  await repository.addTagToBook(widget.bookId, tag.id);
                } else {
                  await repository.removeTagFromBook(widget.bookId, tag.id);
                }
                setState(() {});
              },
            );
          }).toList(),
        );
      },
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
          child: const Text('Commencer', style: TextStyle(fontSize: 18)),
        ),
      );
    } else if (status == BookShelf.reading) {
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
              await repository.updateStatus(book.id, BookShelf.read);
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
    } else if (status == BookShelf.read) {
      String durationText = 'Unknown duration';
      if (book.startDate != null && book.finishDate != null) {
        final days = book.finishDate!.difference(book.startDate!).inDays;
        durationText = days == 0 ? '1 jour' : '$days jours';
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
      setState(() {
        _error = e.toString();
      });
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
                'Disponibilité en bibliothèque',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (response != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading ? null : _checkAvailability,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (response == null && !_isLoading && _error == null)
          ElevatedButton.icon(
            onPressed: _checkAvailability,
            icon: const Icon(Icons.local_library),
            label: const Text('Vérifier la disponibilité'),
          )
        else if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(
            'Erreur : $_error',
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
                    response.available ? 'Disponible' : 'Non disponible',
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
                'Dernière vérification : ${DateFormat.yMMMd('fr_FR').add_Hm().format(DateTime.fromMillisecondsSinceEpoch(response.lastCheck))}',
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
    final Map<String, String?> metadata = {
      'Éditeur': book.publisher,
      'Date de publication': book.publicationYear?.toString(),
      'Nombre de pages': book.pageCount?.toString(),
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
          'Informations bibliographiques',
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
  final BookSearchService _service = BookSearchService();
  List<_CoverOption> _alternatives = const [];
  bool _loading = true;
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
              _titleMatches(book.title, b.title) &&
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

  /// Normalise un titre pour comparaison (minuscules, sans accents ni ponctuation).
  String _normTitle(String s) {
    var out = s.toLowerCase();
    const accents = {
      'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', 'ç': 'c',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'í': 'i', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o', 'ù': 'u',
      'û': 'u', 'ü': 'u', 'ú': 'u', 'ñ': 'n', 'œ': 'oe', 'æ': 'ae',
    };
    accents.forEach((k, v) => out = out.replaceAll(k, v));
    return out
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Le résultat correspond-il au livre ? Égalité de titre, ou (titres à
  /// plusieurs mots) le résultat commence par le titre du livre suivi d'un
  /// sous-titre — pour ne pas confondre « Dune » et « Dune Messiah ».
  bool _titleMatches(String bookTitle, String resultTitle) {
    final b = _normTitle(bookTitle);
    final r = _normTitle(resultTitle);
    if (b.isEmpty || r.isEmpty) return false;
    if (b == r) return true;
    return b.contains(' ') && r.startsWith('$b ');
  }

  Future<void> _select(String url) async {
    // Pour une couverture OpenLibrary, on enregistre la version large (-L) plutôt
    // que la vignette (-M) affichée dans la liste.
    final persisted = url.contains('covers.openlibrary.org')
        ? url.replaceAll('-M.jpg', '-L.jpg')
        : url;
    setState(() => _selectedUrl = persisted);
    await ref.read(booksRepositoryProvider).updateCover(widget.book.id, persisted);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couverture mise à jour'),
          duration: Duration(seconds: 2),
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
                tooltip: 'Fermer',
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
                            )
                          : BookCover(
                              book: widget.book,
                              fit: BoxFit.contain,
                              borderRadius: 0,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            _buildAlternatives(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternatives() {
    if (_loading) {
      return const SizedBox(
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
      height: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'Autres couvertures',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _alternatives.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final opt = _alternatives[i];
                final selected = _selectedUrl == opt.url;
                return GestureDetector(
                  onTap: () => _select(opt.url),
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
