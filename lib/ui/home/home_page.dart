import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../add_book/scanner_page.dart';
import '../add_book/search_book_page.dart';
import 'filter_bar.dart';
import '../books/book_list_view.dart';
import 'sort_provider.dart';
import 'view_provider.dart';

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
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchBookPage()),
            );
          },
        ),
        title: const Text('Ilwyrm'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF006978),
              child: Text(
                'A',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
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
                TextButton.icon(
                  onPressed: () {
                    // Show sort menu
                    _showSortMenu(context);
                  },
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Trie'),
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

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date d\'ajout'),
              onTap: () {
                ref.read(sortProvider.notifier).setSort(SortOption.dateAdded);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Titre'),
              onTap: () {
                ref.read(sortProvider.notifier).setSort(SortOption.title);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Auteur'),
              onTap: () {
                ref.read(sortProvider.notifier).setSort(SortOption.author);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
