import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
import '../../data/database.dart';
import 'package:drift/drift.dart' as drift;
import '../add_book/edit_book_page.dart';
import '../../data/settings_repository.dart';
import 'availability_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectionState = ref.watch(selectionProvider);

    return Scaffold(
      appBar: selectionState.isSelecting
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectionProvider.notifier).clear();
                },
              ),
              title: Text(
                '${selectionState.selectedIds.length} sélectionné(s)',
              ),
              actions: [
                if (selectionState.selectedIds.length == 1)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Modifier',
                    onPressed: () async {
                      final bookId = selectionState.selectedIds.first;
                      final database = ref.read(databaseProvider);
                      final book = await (database.select(
                        database.books,
                      )..where((tbl) => tbl.id.equals(bookId))).getSingle();

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditBookPage(existingBook: book),
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
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'status',
                          child: ListTile(
                            leading: Icon(Icons.bookmark_border),
                            title: Text('Changer le statut'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'tags',
                          child: ListTile(
                            leading: Icon(Icons.label),
                            title: Text('Ajouter des tags'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'favorite',
                          child: ListTile(
                            leading: Icon(Icons.favorite),
                            title: Text('Ajouter aux favoris'),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                ),
              ],
            )
          : AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: LocalSearchDelegate(ref),
                  );
                },
              ),
              title: const Text('Ilwyrm'),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final selectedTagId = ref.watch(selectedTagProvider);
                    final settingsRepo = ref.watch(settingsRepositoryProvider);
                    final isExperimental =
                        settingsRepo.isLibraryAvailabilityEnabled;

                    if (isExperimental && selectedTagId != null) {
                      return IconButton(
                        icon: const Icon(Icons.travel_explore),
                        tooltip: 'Vérifier la disponibilité',
                        onPressed: () async {
                          final database = ref.read(databaseProvider);
                          final books = await database.getBooksByTag(
                            selectedTagId,
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
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
              ],
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
                  child: const Row(
                    children: [
                      Icon(Icons.swap_vert),
                      SizedBox(width: 8),
                      Text('Trie'),
                    ],
                  ),
                  onSelected: (SortOption result) {
                    ref.read(sortProvider.notifier).setSort(result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        const PopupMenuItem<SortOption>(
                          value: SortOption.dateAdded,
                          child: ListTile(
                            leading: Icon(Icons.calendar_today),
                            title: Text('Date d\'ajout'),
                          ),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.title,
                          child: ListTile(
                            leading: Icon(Icons.sort_by_alpha),
                            title: Text('Titre'),
                          ),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.author,
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Auteur'),
                          ),
                        ),
                      ],
                ),
                IconButton(
                  icon: Consumer(
                    builder: (context, ref, child) {
                      final view = ref.watch(viewProvider);
                      switch (view) {
                        case ViewOption.list:
                          return const Icon(Icons.view_list);
                        case ViewOption.grid:
                          return const Icon(Icons.grid_view);
                        case ViewOption.gridWithDetails:
                          return const Icon(Icons.grid_on);
                      }
                    },
                  ),
                  onPressed: () {
                    ref.read(viewProvider.notifier).toggle();
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _buildBookList(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'À lire',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories), // Or a filled variant
            label: 'En cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.check),
            selectedIcon: Icon(Icons.done_all),
            label: 'Lus',
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        label: const Text('Ajouter'),
        activeIcon: Icons.close,
        spacing: 3,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        tooltip: 'Ajouter un livre',
        heroTag: 'speed-dial-hero-tag',
        elevation: 8.0,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            label: 'Scanner',
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
            label: 'Recherche',
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

  Widget _buildBookList(int index) {
    final selectedTagId = ref.watch(selectedTagProvider);
    switch (index) {
      case 0:
        return BookListView(status: 'to_read', tagId: selectedTagId);
      case 1:
        return BookListView(status: 'reading', tagId: selectedTagId);
      case 2:
        return BookListView(status: 'read', tagId: selectedTagId);
      default:
        return const SizedBox();
    }
  }

  Future<void> _showStatusDialog(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Changer le statut'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'to_read'),
              child: const Text('À lire'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'reading'),
              child: const Text('En cours'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'read'),
              child: const Text('Lu'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final database = ref.read(databaseProvider);
      String shelfName = 'À lire';
      if (result == 'reading') shelfName = 'En cours';
      if (result == 'read') shelfName = 'Lu';

      await (database.update(
        database.books,
      )..where((tbl) => tbl.id.isIn(selectedIds))).write(
        BooksCompanion(
          shelf: drift.Value(result),
          shelfName: drift.Value(shelfName),
        ),
      );

      ref.read(selectionProvider.notifier).clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedIds.length} livre(s) mis à jour')),
        );
      }
    }
  }

  Future<void> _addToFavorites(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final database = ref.read(databaseProvider);
    await (database.update(database.books)
          ..where((tbl) => tbl.id.isIn(selectedIds)))
        .write(const BooksCompanion(isFavorite: drift.Value(true)));

    ref.read(selectionProvider.notifier).clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedIds.length} livre(s) ajoutés aux favoris'),
        ),
      );
    }
  }

  Future<void> _showTagsDialog(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final database = ref.read(databaseProvider);
    final allTags = await database.getAllTags();
    final selectedTags = <int>{};

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter des tags'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTags.length,
                  itemBuilder: (context, index) {
                    final tag = allTags[index];
                    return CheckboxListTile(
                      title: Text(tag.name),
                      value: selectedTags.contains(tag.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedTags.add(tag.id);
                          } else {
                            selectedTags.remove(tag.id);
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () async {
                    for (final bookId in selectedIds) {
                      for (final tagId in selectedTags) {
                        await database.addTagToBook(bookId, tagId);
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    ref.read(selectionProvider.notifier).clear();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tags ajoutés !')));
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Set<int> selectedIds,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer les livres ?'),
          content: Text(
            'Voulez-vous vraiment supprimer ${selectedIds.length} livre(s) ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final database = ref.read(databaseProvider);
      await (database.delete(
        database.books,
      )..where((tbl) => tbl.id.isIn(selectedIds))).go();

      ref.read(selectionProvider.notifier).clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedIds.length} livre(s) supprimé(s)')),
        );
      }
    }
  }
}
