import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../l10n/l10n.dart';
import '../add_book/scanner_page.dart';
import '../add_book/search_book_page.dart';
import 'filter_bar.dart';
import '../books/book_list_view.dart';

import 'sort_provider.dart';
import 'view_provider.dart';
import '../settings/settings_page.dart';
import 'local_search_delegate.dart';

import 'tag_filter_provider.dart';
import 'selection_provider.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/enums.dart';
import '../add_book/edit_book_page.dart';
import '../../data/settings_repository.dart';
import 'availability_provider.dart';
import '../../data/database.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  /// Apparition en cascade des livres : seulement au premier affichage. Ensuite
  /// (changement d'onglet ou d'affichage), le fondu enchaîné suffit.
  bool _animateEntrance = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectionState = ref.watch(selectionProvider);

    return Scaffold(
      // Passage en mode sélection : la barre contextuelle apparaît en fondu.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selectionState.isSelecting
              ? _selectionAppBar(context, selectionState)
              : _mainAppBar(context),
        ),
      ),
      body: Column(
        children: [
          const FilterBar(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<SortOption>(
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert),
                      const SizedBox(width: 8),
                      Text(l10n.sortLabel),
                    ],
                  ),
                  onSelected: (SortOption result) {
                    ref.read(sortProvider.notifier).setSort(result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        PopupMenuItem<SortOption>(
                          value: SortOption.dateAdded,
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(l10n.sortDateAdded),
                          ),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.title,
                          child: ListTile(
                            leading: const Icon(Icons.sort_by_alpha),
                            title: Text(l10n.sortTitle),
                          ),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.author,
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(l10n.sortAuthor),
                          ),
                        ),
                      ],
                ),
                IconButton(
                  tooltip: l10n.changeViewTooltip,
                  icon: Consumer(
                    builder: (context, ref, child) {
                      final view = ref.watch(viewProvider);
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          switch (view) {
                            ViewOption.list => Icons.view_list,
                            ViewOption.grid => Icons.grid_view,
                            ViewOption.gridWithDetails => Icons.grid_on,
                          },
                          key: ValueKey(view),
                        ),
                      );
                    },
                  ),
                  onPressed: () {
                    setState(() => _animateEntrance = false);
                    ref.read(viewProvider.notifier).toggle();
                  },
                ),
              ],
            ),
          ),
          // Changement d'onglet : fondu enchaîné (motif Material de la barre de
          // navigation).
          Expanded(
            child: PageTransitionSwitcher(
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    fillColor: Colors.transparent,
                    child: child,
                  ),
              child: _buildBookList(_selectedIndex),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _animateEntrance = false;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: l10n.tabToRead,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories),
            label: l10n.tabReading,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check),
            selectedIcon: const Icon(Icons.done_all),
            label: l10n.tabRead,
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        label: Text(l10n.addLabel),
        activeIcon: Icons.close,
        spacing: 3,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        tooltip: l10n.addBookTooltip,
        heroTag: 'speed-dial-hero-tag',
        elevation: 8.0,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            label: l10n.scanLabel,
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ScannerPage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            label: l10n.searchLabel,
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchBookPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  AppBar _selectionAppBar(BuildContext context, SelectionState selectionState) {
    final l10n = context.l10n;
    return AppBar(
      key: const ValueKey('selection-app-bar'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: l10n.actionClose,
        onPressed: () {
          ref.read(selectionProvider.notifier).clear();
        },
      ),
      title: Text(l10n.selectedCount(selectionState.selectedIds.length)),
      actions: [
        if (selectionState.selectedIds.length == 1)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.actionEdit,
            onPressed: () async {
              final bookId = selectionState.selectedIds.first;
              final repository = ref.read(booksRepositoryProvider);
              final book = await repository.getBook(bookId);

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBookPage(existingBook: book),
                  ),
                );
                ref.read(selectionProvider.notifier).clear();
              }
            },
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'status':
                _showStatusDialog(context, selectionState.selectedIds);
                break;
              case 'tags':
                _showTagsDialog(context, selectionState.selectedIds);
                break;
              case 'favorite':
                _addToFavorites(context, selectionState.selectedIds);
                break;
              case 'delete':
                _showDeleteDialog(context, selectionState.selectedIds);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'status',
              child: ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(l10n.actionChangeStatus),
              ),
            ),
            PopupMenuItem<String>(
              value: 'tags',
              child: ListTile(
                leading: const Icon(Icons.label),
                title: Text(l10n.actionAddTags),
              ),
            ),
            PopupMenuItem<String>(
              value: 'favorite',
              child: ListTile(
                leading: const Icon(Icons.favorite),
                title: Text(l10n.actionAddToFavorites),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l10n.actionDelete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  AppBar _mainAppBar(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(
      key: const ValueKey('main-app-bar'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.search),
        tooltip: MaterialLocalizations.of(context).searchFieldLabel,
        onPressed: () {
          showSearch(context: context, delegate: LocalSearchDelegate(ref));
        },
      ),
      title: Text(l10n.appTitle),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final selectedTagIds = ref.watch(selectedTagProvider);
            final isExperimental = ref
                .watch(settingsProvider)
                .libraryAvailabilityEnabled;

            // Vérification de disponibilité proposée quand au moins un
            // tag est sélectionné (fonctionnalité expérimentale).
            if (isExperimental && selectedTagIds.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.travel_explore),
                tooltip: l10n.checkAvailability,
                onPressed: () async {
                  final repository = ref.read(booksRepositoryProvider);
                  final books = await repository.getBooksByTags(
                    selectedTagIds.toList(),
                  );
                  ref
                      .read(availabilityProvider.notifier)
                      .checkAvailabilityForBooks(books);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Tooltip(
            message: l10n.settingsTitle,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookList(int index) {
    // Une clé par onglet : chaque liste garde son propre état (défilement,
    // animations) au lieu de réutiliser celui de l'onglet précédent.
    const shelves = ['to_read', 'reading', 'read'];
    final shelf = shelves[index];
    return BookListView(
      key: ValueKey(shelf),
      status: shelf,
      animateEntrance: _animateEntrance,
    );
  }

  Future<void> _showStatusDialog(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final l10n = context.l10n;
    final result = await showDialog<BookShelf>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(l10n.actionChangeStatus),
          children: [
            for (final shelf in BookShelf.values)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, shelf),
                child: Text(shelf.displayName(l10n)),
              ),
          ],
        );
      },
    );

    if (result != null) {
      final repository = ref.read(booksRepositoryProvider);
      await repository.updateStatusForBooks(selectedIds, result);

      ref.read(selectionProvider.notifier).clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.booksUpdated(selectedIds.length))),
        );
      }
    }
  }

  Future<void> _addToFavorites(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final l10n = context.l10n;
    final repository = ref.read(booksRepositoryProvider);
    await repository.setFavoriteForBooks(selectedIds, true);

    ref.read(selectionProvider.notifier).clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.booksAddedToFavorites(selectedIds.length))),
      );
    }
  }

  Future<void> _showTagsDialog(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ManageMultipleTagsDialog(selectedIds: selectedIds),
    );

    if (result == true) {
      ref.read(selectionProvider.notifier).clear();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tagsAdded)));
      }
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteBooksTitle),
          content: Text(l10n.deleteBooksMessage(selectedIds.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final repository = ref.read(booksRepositoryProvider);
      await repository.deleteBooks(selectedIds);

      ref.read(selectionProvider.notifier).clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.booksDeleted(selectedIds.length))),
        );
      }
    }
  }
}

class _ManageMultipleTagsDialog extends ConsumerStatefulWidget {
  final Set<int> selectedIds;

  const _ManageMultipleTagsDialog({required this.selectedIds});

  @override
  ConsumerState<_ManageMultipleTagsDialog> createState() =>
      _ManageMultipleTagsDialogState();
}

class _ManageMultipleTagsDialogState
    extends ConsumerState<_ManageMultipleTagsDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Tag> _allTags = [];
  List<Tag> _filteredTags = [];
  final Set<int> _selectedTagIds = {};

  @override
  void initState() {
    super.initState();
    _loadTags();
    _searchController.addListener(_filterTags);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final repository = ref.read(booksRepositoryProvider);
    final allTags = await repository.getAllTags();

    if (mounted) {
      setState(() {
        _allTags = allTags;
        _filterTags();
      });
    }
  }

  void _filterTags() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTags = _allTags;
      } else {
        _filteredTags = _allTags
            .where((tag) => tag.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _createTag() async {
    final name = _searchController.text.trim();
    if (name.isEmpty) return;

    final repository = ref.read(booksRepositoryProvider);
    try {
      final newTagId = await repository.createTag(name);
      _selectedTagIds.add(newTagId);
      _searchController.clear();
      await _loadTags();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tagCreateError('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.actionAddTags),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.tagSearchOrCreateHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty &&
                    !_allTags.any(
                      (t) =>
                          t.name.toLowerCase() ==
                          _searchController.text.trim().toLowerCase(),
                    ))
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _createTag,
                    tooltip: l10n.tagCreateTooltip,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _allTags.isEmpty
                  ? Text(l10n.noTagsAvailable)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredTags.length,
                      itemBuilder: (context, index) {
                        final tag = _filteredTags[index];
                        return CheckboxListTile(
                          title: Text(tag.name),
                          value: _selectedTagIds.contains(tag.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedTagIds.add(tag.id);
                              } else {
                                _selectedTagIds.remove(tag.id);
                              }
                            });
                          },
                          secondary: tag.color != null
                              ? CircleAvatar(
                                  backgroundColor: Color(tag.color!),
                                  radius: 10,
                                )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () async {
            final repository = ref.read(booksRepositoryProvider);
            await repository.addTagsToBooks(widget.selectedIds, _selectedTagIds);
            if (context.mounted) Navigator.pop(context, true);
          },
          child: Text(l10n.actionAdd),
        ),
      ],
    );
  }
}
