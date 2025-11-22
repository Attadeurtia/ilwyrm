import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'filter_bar.dart';
import '../books/book_list_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                // TODO: Implement sort
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'date', child: Text('Date d\'ajout')),
                const PopupMenuItem(value: 'title', child: Text('Titre')),
                const PopupMenuItem(value: 'author', child: Text('Auteur')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.grid_view), // Toggle between list/grid
              onPressed: () {
                // TODO: Implement view toggle
              },
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100), // Height for TabBar + FilterBar
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add book
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
