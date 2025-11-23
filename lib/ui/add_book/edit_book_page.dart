import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import '../../data/database.dart';
import '../../data/open_library_api.dart';

class EditBookPage extends ConsumerStatefulWidget {
  final OpenLibraryBook? initialBook;
  final Book? existingBook;

  const EditBookPage({super.key, this.initialBook, this.existingBook});

  @override
  ConsumerState<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends ConsumerState<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pageCountController;
  String _status = 'to_read'; // Default status
  String? _localCoverPath;

  @override
  void initState() {
    super.initState();
    if (widget.existingBook != null) {
      _titleController = TextEditingController(
        text: widget.existingBook!.title,
      );
      _authorController = TextEditingController(
        text: widget.existingBook!.authorText ?? '',
      );
      _pageCountController = TextEditingController(
        text: widget.existingBook!.pageCount?.toString() ?? '',
      );
      _status = widget.existingBook!.shelf;
      _localCoverPath = widget.existingBook!.coverPath;
    } else {
      _titleController = TextEditingController(
        text: widget.initialBook?.title ?? '',
      );
      _authorController = TextEditingController(
        text: widget.initialBook?.authorText ?? '',
      );
      _pageCountController = TextEditingController(
        text: widget.initialBook?.numberOfPages?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _localCoverPath = result.files.single.path;
      });
    }
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);
      final int? pageCount = int.tryParse(_pageCountController.text);

      if (widget.existingBook != null) {
        // Update existing
        await (database.update(
          database.books,
        )..where((tbl) => tbl.id.equals(widget.existingBook!.id))).write(
          BooksCompanion(
            title: drift.Value(_titleController.text),
            authorText: drift.Value(_authorController.text),
            pageCount: drift.Value(pageCount),
            shelf: drift.Value(_status),
            shelfName: drift.Value(_getShelfName(_status)),
            coverPath: drift.Value(_localCoverPath),
            dateModified: drift.Value(DateTime.now()),
          ),
        );
      } else {
        // Insert new
        final book = BooksCompanion(
          title: drift.Value(_titleController.text),
          authorText: drift.Value(_authorController.text),
          pageCount: drift.Value(pageCount),
          shelf: drift.Value(_status),
          shelfName: drift.Value(_getShelfName(_status)),
          openlibraryKey: widget.initialBook?.key != null
              ? drift.Value(widget.initialBook!.key.split('/').last)
              : const drift.Value.absent(),
          isbn13: widget.initialBook?.isbns?.isNotEmpty == true
              ? drift.Value(widget.initialBook!.isbns!.first)
              : const drift.Value.absent(),
          coverId: drift.Value(widget.initialBook?.coverId),
          coverPath: drift.Value(_localCoverPath),
          dateAdded: drift.Value(DateTime.now()),
          dateModified: drift.Value(DateTime.now()),
        );
        await database.into(database.books).insert(book);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingBook != null
                  ? 'Livre modifié !'
                  : 'Livre ajouté !',
            ),
          ),
        );
        Navigator.of(context).pop();
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
    ImageProvider? coverImage;
    if (_localCoverPath != null) {
      coverImage = FileImage(File(_localCoverPath!));
    } else if (widget.existingBook?.openlibraryKey != null) {
      coverImage = NetworkImage(
        'https://covers.openlibrary.org/b/olid/${widget.existingBook!.openlibraryKey}-L.jpg',
      );
    } else if (widget.initialBook?.coverUrl != null) {
      coverImage = NetworkImage(widget.initialBook!.coverUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingBook != null
              ? 'Modifier le livre'
              : 'Ajouter un livre',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveBook),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: coverImage != null
                      ? DecorationImage(image: coverImage, fit: BoxFit.cover)
                      : null,
                ),
                child: coverImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Ajouter une couverture',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
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
            TextFormField(
              controller: _pageCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de pages',
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
