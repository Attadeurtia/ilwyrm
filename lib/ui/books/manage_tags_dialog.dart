import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';

class ManageTagsDialog extends ConsumerStatefulWidget {
  final int bookId;

  const ManageTagsDialog({super.key, required this.bookId});

  @override
  ConsumerState<ManageTagsDialog> createState() => _ManageTagsDialogState();
}

class _ManageTagsDialogState extends ConsumerState<ManageTagsDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Tag> _allTags = [];
  List<Tag> _bookTags = [];
  List<Tag> _filteredTags = [];

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
    final database = ref.read(databaseProvider);
    final allTags = await database.getAllTags();
    final bookTags = await database.getTagsForBook(widget.bookId);

    if (mounted) {
      setState(() {
        _allTags = allTags;
        _bookTags = bookTags;
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

    final database = ref.read(databaseProvider);
    try {
      await database.createTag(name);
      _searchController.clear();
      await _loadTags();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création du tag: $e')),
        );
      }
    }
  }

  Future<void> _toggleTag(Tag tag) async {
    final database = ref.read(databaseProvider);
    final isSelected = _bookTags.any((t) => t.id == tag.id);

    if (isSelected) {
      await database.removeTagFromBook(widget.bookId, tag.id);
    } else {
      await database.addTagToBook(widget.bookId, tag.id);
    }
    await _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gérer les tags'),
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
                    decoration: const InputDecoration(
                      hintText: 'Rechercher ou créer un tag',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty &&
                    !_allTags.any(
                      (t) =>
                          t.name.toLowerCase() ==
                          _searchController.text.toLowerCase(),
                    ))
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _createTag,
                    tooltip: 'Créer le tag',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _allTags.isEmpty
                  ? const Text('Aucun tag disponible.')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredTags.length,
                      itemBuilder: (context, index) {
                        final tag = _filteredTags[index];
                        final isSelected = _bookTags.any((t) => t.id == tag.id);
                        return CheckboxListTile(
                          title: Text(tag.name),
                          value: isSelected,
                          onChanged: (_) => _toggleTag(tag),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
