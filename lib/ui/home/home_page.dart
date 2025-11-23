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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: LocalSearchDelegate(ref));
          },
        ),
        title: const Text('Ilwyrm'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
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
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'À lire',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            selectedIcon: Icon(Icons.menu_book), // Or a filled variant
            label: 'En cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.check),
            selectedIcon: Icon(Icons.check_circle),
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
    switch (index) {
      case 0:
        return const BookListView(status: 'to_read');
      case 1:
        return const BookListView(status: 'reading');
      case 2:
        return const BookListView(status: 'read');
      default:
        return const SizedBox();
    }
  }
}
