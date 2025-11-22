import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../data/open_library_api.dart';

class EditBookPage extends ConsumerStatefulWidget {
  final OpenLibraryBook? initialBook;

  const EditBookPage({super.key, this.initialBook});

  @override
  ConsumerState<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends ConsumerState<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  String _status = 'to_read'; // Default status

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialBook?.title ?? '',
    );
    _authorController = TextEditingController(
      text: widget.initialBook?.authorText ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);

      final book = BooksCompanion(
        title: drift.Value(_titleController.text),
        authorText: drift.Value(_authorController.text),
        shelf: drift.Value(_status),
        shelfName: drift.Value(_getShelfName(_status)),
        openlibraryKey: widget.initialBook?.key != null
            ? drift.Value(widget.initialBook!.key)
            : const drift.Value.absent(),
        isbn13: widget.initialBook?.isbns?.isNotEmpty == true
            ? drift.Value(widget.initialBook!.isbns!.first)
            : const drift.Value.absent(),
        dateAdded: drift.Value(DateTime.now()),
        dateModified: drift.Value(DateTime.now()),
      );

      await database.into(database.books).insert(book);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Livre ajouté !')));
        // Pop back to home (pop search page then scanner page/home)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  String _getShelfName(String status) {
    switch (status) {
      case 'to_read':
        return 'À lire';
      case 'reading':
        return 'En cours';
      case 'read':
        return 'Lu';
      default:
        return 'À lire';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un livre'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveBook),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.initialBook?.coverUrl != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.network(
                    widget.initialBook!.coverUrl!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Auteur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'to_read', child: Text('À lire')),
                DropdownMenuItem(value: 'reading', child: Text('En cours')),
                DropdownMenuItem(value: 'read', child: Text('Lu')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
