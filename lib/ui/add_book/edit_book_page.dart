import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../data/book_companion_mapper.dart';
import '../../data/cover_storage.dart';
import '../../data/database.dart';
import '../../data/library_index.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/book_search_api.dart';
import '../../data/enums.dart';
import '../../data/publishers.dart';
import '../../l10n/l10n.dart';
import '../books/book_cover.dart';
import '../books/bookshelf_detail_page.dart';

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
    // Image réduite (comme pour le scan de couverture) puis copiée dans le
    // dossier de l'app : le fichier renvoyé par le sélecteur est temporaire et
    // peut être effacé par le système (la couverture disparaîtrait).
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 90,
    );
    if (picked == null) return;
    final path = await persistCoverImage(picked.path);
    if (!mounted) return;
    setState(() => _localCoverPath = path);
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

  String? _textOrNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final author = _textOrNull(_authorController);
    final publisher = _textOrNull(_publisherController);
    final int? pageCount = int.tryParse(_pageCountController.text.trim());
    final int? year = int.tryParse(_yearController.text.trim());
    // Applique la règle d'unification statut ↔ dates avant d'enregistrer.
    final dates = datesForShelf(
      _status,
      currentStart: _startDate,
      currentFinish: _finishDate,
    );
    final repository = ref.read(booksRepositoryProvider);

    if (widget.existingBook != null) {
      await repository.updateBookData(
        widget.existingBook!.id,
        BooksCompanion(
          title: drift.Value(title),
          authorText: drift.Value(author),
          publisher: drift.Value(publisher),
          publicationYear: drift.Value(year),
          pageCount: drift.Value(pageCount),
          shelf: drift.Value(_status.id),
          shelfName: drift.Value(_status.label),
          startDate: drift.Value(dates.start),
          finishDate: drift.Value(dates.finish),
          coverPath: drift.Value(_localCoverPath),
          dateModified: drift.Value(DateTime.now()),
        ),
      );
    } else {
      // Pas de doublon silencieux (saisie manuelle, scan de couverture) : même
      // détection que la recherche (ISBN, identifiants, titre + auteur).
      final candidate = (widget.initialBook ??
              ExternalBook(key: 'manual', title: title, authorText: '', source: 'manual'))
          .copyWith(title: title, authorText: author ?? '');
      final existingId = buildLibraryIndex(
        await repository.getAllBooks(),
      ).findId(candidate);
      if (existingId != null && !await _confirmDuplicate(existingId)) return;

      // Base = fiche externe complète (ISBN, identifiants, résumé, couverture),
      // complétée/corrigée par le formulaire.
      final now = DateTime.now();
      final base = widget.initialBook?.toBooksCompanion() ?? const BooksCompanion();
      await repository.addBook(
        base.copyWith(
          title: drift.Value(title),
          authorText: drift.Value(author),
          publisher: drift.Value(publisher),
          publicationYear: drift.Value(year),
          pageCount: drift.Value(pageCount),
          shelf: drift.Value(_status.id),
          shelfName: drift.Value(_status.label),
          startDate: drift.Value(dates.start),
          finishDate: drift.Value(dates.finish),
          coverPath: drift.Value(_localCoverPath),
          dateAdded: drift.Value(now),
          dateModified: drift.Value(now),
        ),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingBook != null
                ? context.l10n.bookUpdated
                : context.l10n.bookAdded,
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  /// Le livre semble déjà présent : propose d'ouvrir sa fiche plutôt que de
  /// créer un doublon. Renvoie vrai pour ajouter quand même.
  Future<bool> _confirmDuplicate(int existingId) async {
    if (!mounted) return false;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.duplicateTitle),
        content: Text(context.l10n.duplicateMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'add'),
            child: Text(context.l10n.addAnyway),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'open'),
            child: Text(context.l10n.openBook),
          ),
        ],
      ),
    );
    if (choice == 'open' && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BookDetailsPage(bookId: existingId),
        ),
      );
    }
    return choice == 'add';
  }

  /// Aperçu de la couverture : photo choisie, sinon couverture actuelle du
  /// livre, sinon celle du résultat de recherche, sinon une invite.
  Widget _coverPreview(BuildContext context) {
    final hint = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 40,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.addCover,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
    final existing = widget.existingBook;
    final initialCoverUrl = widget.initialBook?.coverUrl;

    Widget image = hint;
    if (_localCoverPath != null) {
      image = Image.file(
        File(_localCoverPath!),
        fit: BoxFit.cover,
        cacheHeight: 600,
        errorBuilder: (context, _, _) => hint,
      );
    } else if (existing != null &&
        ((existing.coverUrl?.isNotEmpty ?? false) ||
            existing.coverId != null ||
            (existing.openlibraryKey?.isNotEmpty ?? false))) {
      image = BookCover(book: existing, borderRadius: 0);
    } else if (initialCoverUrl != null && initialCoverUrl.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: initialCoverUrl,
        fit: BoxFit.cover,
        errorWidget: (context, _, _) => hint,
      );
    }

    // Centré : dans une ListView, la largeur de 140 serait sinon ignorée (la
    // couverture s'étirait en bandeau pleine largeur).
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingBook != null
              ? context.l10n.editBookTitle
              : context.l10n.addBookTitle,
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
            _coverPreview(context),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.l10n.fieldTitle,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.fieldTitleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: context.l10n.fieldAuthor,
                border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: context.l10n.fieldPublisher,
                    border: const OutlineInputBorder(),
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
              decoration: InputDecoration(
                labelText: context.l10n.fieldPublicationYear,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pageCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.fieldPageCount,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BookShelf>(
              // ignore: deprecated_member_use
              value: _status,
              decoration: InputDecoration(
                labelText: context.l10n.fieldStatus,
                border: const OutlineInputBorder(),
              ),
              items: BookShelf.values.map((shelf) {
                return DropdownMenuItem(
                  value: shelf,
                  child: Text(shelf.displayName(context.l10n)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) _onStatusChanged(value);
              },
            ),
            if (_status.usesStartDate) const SizedBox(height: 16),
            if (_status.usesStartDate) ListTile(
              title: Text(context.l10n.fieldStartDate),
              subtitle: Text(
                _startDate != null
                    ? DateFormat.yMMMd(context.l10n.localeName).format(_startDate!)
                    : context.l10n.notSet,
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
              title: Text(context.l10n.fieldFinishDate),
              subtitle: Text(
                _finishDate != null
                    ? DateFormat.yMMMd(context.l10n.localeName).format(_finishDate!)
                    : context.l10n.notSet,
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
