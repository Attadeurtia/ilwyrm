import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isLoading = false;

  Future<void> _pickAndImportCsv() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final input = await file.readAsString();
        final List<List<dynamic>> rows = const CsvToListConverter().convert(
          input,
          eol: '\n',
        );

        if (rows.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Le fichier CSV est vide.')),
            );
          }
          return;
        }

        // Get header row to map columns
        final headers = rows.first.map((e) => e.toString()).toList();
        final dataRows = rows.skip(1).toList();

        int importedCount = 0;
        final db = ref.read(databaseProvider);

        for (final row in dataRows) {
          if (row.length != headers.length) continue;

          final map = <String, dynamic>{};
          for (int i = 0; i < headers.length; i++) {
            map[headers[i]] = row[i];
          }

          // Map CSV fields to BookCompanion
          final book = BooksCompanion(
            title: drift.Value(map['title']?.toString() ?? ''),
            authorText: drift.Value(map['author_text']?.toString()),
            remoteId: drift.Value(map['remote_id']?.toString()),
            openlibraryKey: drift.Value(map['openlibrary_key']?.toString()),
            finnaKey: drift.Value(map['finna_key']?.toString()),
            inventaireId: drift.Value(map['inventaire_id']?.toString()),
            librarythingKey: drift.Value(map['librarything_key']?.toString()),
            goodreadsKey: drift.Value(map['goodreads_key']?.toString()),
            bnfId: drift.Value(map['bnf_id']?.toString()),
            viaf: drift.Value(map['viaf']?.toString()),
            wikidata: drift.Value(map['wikidata']?.toString()),
            asin: drift.Value(map['asin']?.toString()),
            aasin: drift.Value(map['aasin']?.toString()),
            isfdb: drift.Value(map['isfdb']?.toString()),
            isbn10: drift.Value(map['isbn_10']?.toString()),
            isbn13: drift.Value(map['isbn_13']?.toString()),
            oclcNumber: drift.Value(map['oclc_number']?.toString()),
            startDate: drift.Value(_parseDate(map['start_date']?.toString())),
            finishDate: drift.Value(_parseDate(map['finish_date']?.toString())),
            stoppedDate: drift.Value(
              _parseDate(map['stopped_date']?.toString()),
            ),
            rating: drift.Value(int.tryParse(map['rating']?.toString() ?? '')),
            reviewName: drift.Value(map['review_name']?.toString()),
            reviewCw: drift.Value(map['review_cw']?.toString()),
            reviewContent: drift.Value(map['review_content']?.toString()),
            reviewPublished: drift.Value(
              _parseDate(map['review_published']?.toString()),
            ),
            shelf: drift.Value(
              _mapShelf(map['shelf']?.toString() ?? 'to-read'),
            ),
            shelfName: drift.Value(map['shelf_name']?.toString()),
            shelfDate: drift.Value(_parseDate(map['shelf_date']?.toString())),
          );

          try {
            await db.into(db.books).insertOnConflictUpdate(book);
            importedCount++;
          } catch (e) {
            print('Error importing book: $e');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$importedCount livres importés avec succès.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'importation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  String _mapShelf(String shelf) {
    // Map BookWyrm shelf names to app shelf names if needed
    // Assuming 'read', 'reading', 'to-read' match
    return shelf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Importer un fichier CSV (BookWyrm)'),
                  subtitle: const Text(
                    'Importez vos livres depuis un export BookWyrm',
                  ),
                  onTap: _pickAndImportCsv,
                ),
              ],
            ),
    );
  }
}
