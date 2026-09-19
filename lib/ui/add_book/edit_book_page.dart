import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/book_search_api.dart';
import '../../data/enums.dart';
import '../../data/publishers.dart';

class EditBookPage extends ConsumerStatefulWidget {
  final ExternalBook? initialBook;
  final Book? existingBook;

  /// Chemin d'une couverture locale déjà capturée (ex. photo prise lors du scan
  /// OCR) à pré-remplir pour un nouveau livre.
  final String? initialCoverPath;

  const EditBookPage({
    super.key,
    this.initialBook,
    this.existingBook,
    this.initialCoverPath,
  });

  @override
  ConsumerState<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends ConsumerState<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _publisherController;
  late TextEditingController _yearController;
  late TextEditingController _pageCountController;
  BookShelf _status = BookShelf.toRead; // Default status
  String? _localCoverPath;
  DateTime? _startDate;
  DateTime? _finishDate;

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
      _publisherController = TextEditingController(
        text: widget.existingBook!.publisher ?? '',
      );
      _yearController = TextEditingController(
        text: widget.existingBook!.publicationYear?.toString() ?? '',
      );
      _pageCountController = TextEditingController(
        text: widget.existingBook!.pageCount?.toString() ?? '',
      );
      _status = BookShelf.fromId(widget.existingBook!.shelf);
      _localCoverPath = widget.existingBook!.coverPath;
      // Normalise l'affichage pour qu'il soit cohérent avec le statut, même si
      // les données enregistrées ne l'étaient pas.
      final dates = datesForShelf(
        _status,
        currentStart: widget.existingBook!.startDate,
        currentFinish: widget.existingBook!.finishDate,
      );
      _startDate = dates.start;
      _finishDate = dates.finish;
    } else {
      _titleController = TextEditingController(
        text: widget.initialBook?.title ?? '',
      );
      _authorController = TextEditingController(
        text: widget.initialBook?.authorText ?? '',
      );
      _publisherController = TextEditingController(
        text: widget.initialBook?.publisher ?? '',
      );
      _yearController = TextEditingController(
        text: widget.initialBook?.firstPublishYear?.toString() ?? '',
      );
      _pageCountController = TextEditingController(
        text: widget.initialBook?.numberOfPages?.toString() ?? '',
      );
      _localCoverPath = widget.initialCoverPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
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

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    // Contraint la plage pour garantir date de fin ≥ date de début.
    final DateTime firstDate =
        isStart ? DateTime(2000) : (_startDate ?? DateTime(2000));
    final DateTime lastDate =
        isStart ? (_finishDate ?? DateTime(2101)) : DateTime(2101);
    DateTime initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_finishDate ?? _startDate ?? DateTime.now());
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _finishDate = picked;
        }
      });
    }
  }

  /// Le statut pilote les dates : en changeant de statut, on complète/efface les
  /// dates selon la règle d'unification (voir datesForShelf).
  void _onStatusChanged(BookShelf status) {
    final dates = datesForShelf(
      status,
      currentStart: _startDate,
      currentFinish: _finishDate,
    );
    setState(() {
      _status = status;
      _startDate = dates.start;
      _finishDate = dates.finish;
    });
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final int? pageCount = int.tryParse(_pageCountController.text);
      final int? year = int.tryParse(_yearController.text);
      // Applique la règle d'unification statut ↔ dates avant d'enregistrer.
      final dates = datesForShelf(
        _status,
        currentStart: _startDate,
        currentFinish: _finishDate,
      );

      if (widget.existingBook != null) {
        // Update existing
        await ref
            .read(booksRepositoryProvider)
            .updateBookData(
              widget.existingBook!.id,
              BooksCompanion(
                title: drift.Value(_titleController.text),
                authorText: drift.Value(_authorController.text),
                publisher: drift.Value(
                  _publisherController.text.isEmpty
                      ? null
                      : _publisherController.text,
                ),
                publicationYear: drift.Value(year),
                pageCount: drift.Value(pageCount),
                shelf: drift.Value(_status.id),
                shelfName: drift.Value(_status.label),
                startDate: drift.Value(dates.start),
                finishDate: drift.Value(dates.finish),
                coverPath: drift.Value(_localCoverPath),
                coverUrl: widget.initialBook?.coverUrl != null
                    ? drift.Value(widget.initialBook!.coverUrl)
                    : const drift.Value.absent(),
                dateModified: drift.Value(DateTime.now()),
              ),
            );
      } else {
        // Insert new
        final book = BooksCompanion(
          title: drift.Value(_titleController.text),
          authorText: drift.Value(_authorController.text),
          publisher: drift.Value(
            _publisherController.text.isEmpty
                ? null
                : _publisherController.text,
          ),
          publicationYear: drift.Value(year),
          pageCount: drift.Value(pageCount),
          shelf: drift.Value(_status.id),
          shelfName: drift.Value(_status.label),
          startDate: drift.Value(dates.start),
          finishDate: drift.Value(dates.finish),
          openlibraryKey: widget.initialBook?.openlibraryKey != null
              ? drift.Value(widget.initialBook!.openlibraryKey)
              : const drift.Value.absent(),
          inventaireId: widget.initialBook?.inventaireId != null
              ? drift.Value(widget.initialBook!.inventaireId)
              : const drift.Value.absent(),
          wikidata: widget.initialBook?.wikidata != null
              ? drift.Value(widget.initialBook!.wikidata)
              : const drift.Value.absent(),
          isbn13: widget.initialBook?.isbn13 != null
              ? drift.Value(widget.initialBook!.isbn13)
              : const drift.Value.absent(),
          isbn10: widget.initialBook?.isbn10 != null
              ? drift.Value(widget.initialBook!.isbn10)
              : const drift.Value.absent(),
          // coverId (numérique OpenLibrary) non exposé ici : on s'appuie sur
          // coverUrl. BookCover sait retomber sur la couverture par ISBN/clé.
          coverId: const drift.Value.absent(),
          coverUrl: widget.initialBook?.coverUrl != null
              ? drift.Value(widget.initialBook!.coverUrl)
              : const drift.Value.absent(),
          coverPath: drift.Value(_localCoverPath),
          dateAdded: drift.Value(DateTime.now()),
          dateModified: drift.Value(DateTime.now()),
        );
        await ref.read(booksRepositoryProvider).addBook(book);
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  image: coverImage != null
                      ? DecorationImage(image: coverImage, fit: BoxFit.cover)
                      : null,
                ),
                child: coverImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajouter une couverture',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
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
            // Éditeur avec autocomplétion des grands éditeurs. Le champ affiché
            // utilise le contrôleur d'Autocomplete ; on recopie sa valeur dans
            // _publisherController (source lue à l'enregistrement).
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _publisherController.text),
              optionsBuilder: (textEditingValue) {
                final input = textEditingValue.text.trim().toLowerCase();
                if (input.isEmpty) return const Iterable<String>.empty();
                return kMajorPublishers
                    .where((p) => p.toLowerCase().contains(input))
                    .take(8);
              },
              onSelected: (selection) => _publisherController.text = selection,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Éditeur',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _publisherController.text = value,
                  onFieldSubmitted: (_) => onFieldSubmitted(),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Année de publication',
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
            DropdownButtonFormField<BookShelf>(
              // ignore: deprecated_member_use
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
              ),
              items: BookShelf.values.map((shelf) {
                return DropdownMenuItem(value: shelf, child: Text(shelf.label));
              }).toList(),
              onChanged: (value) {
                if (value != null) _onStatusChanged(value);
              },
            ),
            if (_status.usesStartDate) const SizedBox(height: 16),
            if (_status.usesStartDate) ListTile(
              title: const Text('Date de début'),
              subtitle: Text(
                _startDate != null
                    ? DateFormat.yMMMd('fr_FR').format(_startDate!)
                    : 'Non défini',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
              tileColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (_status.usesFinishDate) const SizedBox(height: 16),
            if (_status.usesFinishDate) ListTile(
              title: const Text('Date de fin'),
              subtitle: Text(
                _finishDate != null
                    ? DateFormat.yMMMd('fr_FR').format(_finishDate!)
                    : 'Non défini',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
              tileColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
