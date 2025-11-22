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

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Ilwyrm'),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                }
              });
            },
          ),
          if (!_isSearchActive) ...[
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                ref.read(sortProvider.notifier).setSort(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: SortOption.dateAdded,
                  child: Text('Date d\'ajout'),
                ),
                const PopupMenuItem(
                  value: SortOption.title,
                  child: Text('Titre'),
                ),
                const PopupMenuItem(
                  value: SortOption.author,
                  child: Text('Auteur'),
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
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            100,
          ), // Height for TabBar + FilterBar
          child: Column(
            children: [
              const FilterBar(),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'À lire'),
                  Tab(text: 'En cours'),
                  Tab(text: 'Lus'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BookListView(status: 'to_read'),
          BookListView(status: 'reading'),
          BookListView(status: 'read'),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        // renderOverlay: false, // Try disabling overlay if it causes issues
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
}
