import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/csv_service.dart';
import '../../data/database.dart';
import '../../data/settings_repository.dart';
import '../theme_extensions.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isLoading = false;

  CsvService get _csvService => CsvService(ref.read(databaseProvider));

  // ---------------------------------------------------------------------------
  // Export CSV
  // ---------------------------------------------------------------------------

  Future<void> _exportCsv() async {
    try {
      setState(() => _isLoading = true);

      final db = ref.read(databaseProvider);
      final books = await db.getAllBooks();

      if (books.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun livre à exporter.')),
          );
        }
        return;
      }

      final file = await _csvService.exportToCsv();

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Export de ma bibliothèque Ilwyrm',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${books.length} livres exportés avec succès.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'exportation : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Import CSV
  // ---------------------------------------------------------------------------

  Future<void> _pickAndImportCsv() async {
    // Demander à l'utilisateur s'il veut chercher les couvertures
    final fetchCovers = await showDialog<bool>(
      context: context,
      builder: (context) => _ImportOptionsDialog(),
    );

    if (fetchCovers == null) return; // Dialogue annulé

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);

      if (!mounted) return;

      // Afficher le dialogue de progression
      final importResult = await showDialog<CsvImportResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ImportProgressDialog(
          csvService: _csvService,
          file: file,
          fetchCovers: fetchCovers,
        ),
      );

      if (importResult != null && mounted) {
        final message = StringBuffer(
          '${importResult.importedCount}/${importResult.totalCount} livres importés.',
        );
        if (importResult.skippedCount > 0) {
          message.write(
            ' ${importResult.skippedCount} ignorés.',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString()),
            duration: const Duration(seconds: 4),
            action: importResult.errors.isNotEmpty
                ? SnackBarAction(
                    label: 'Détails',
                    onPressed: () => _showImportErrors(importResult.errors),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'importation : $e')),
        );
      }
    }
  }

  void _showImportErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreurs d\'importation'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                errors[index],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Données',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Importer un fichier CSV'),
                  subtitle: const Text(
                    'Importez vos livres et tags depuis un fichier CSV',
                  ),
                  onTap: _pickAndImportCsv,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Exporter un fichier CSV'),
                  subtitle: const Text(
                    'Exportez vos livres et tags pour les transférer',
                  ),
                  onTap: _exportCsv,
                ),
                const Divider(),
                const _ExperimentalSettings(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('À propos'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Ilwyrm',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.menu_book, size: 48),
                      applicationLegalese: '© 2025 Ilwyrm',
                      children: [
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text:
                                    'Ilwyrm est une application de gestion de bibliothèque personnelle open-source développée par ',
                              ),
                              TextSpan(
                                text: 'Attadeurtia',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final url = Uri.parse(
                                      'https://github.com/attadeurtia',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text: 'Code source disponible sur GitHub : ',
                              ),
                              TextSpan(
                                text: 'https://github.com/attadeurtia/ilwyrm',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final url = Uri.parse(
                                      'https://github.com/attadeurtia/ilwyrm',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

// =============================================================================
// Dialogue d'options d'import
// =============================================================================

class _ImportOptionsDialog extends StatefulWidget {
  @override
  State<_ImportOptionsDialog> createState() => _ImportOptionsDialogState();
}

class _ImportOptionsDialogState extends State<_ImportOptionsDialog> {
  bool _fetchCovers = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options d\'importation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choisissez les options pour l\'importation de votre fichier CSV.',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Rechercher les couvertures'),
            subtitle: const Text(
              'Recherche en ligne les couvertures manquantes. Plus lent.',
            ),
            value: _fetchCovers,
            onChanged: (value) => setState(() => _fetchCovers = value),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _fetchCovers),
          child: const Text('Choisir le fichier'),
        ),
      ],
    );
  }
}

// =============================================================================
// Dialogue de progression d'import
// =============================================================================

class _ImportProgressDialog extends StatefulWidget {
  final CsvService csvService;
  final File file;
  final bool fetchCovers;

  const _ImportProgressDialog({
    required this.csvService,
    required this.file,
    required this.fetchCovers,
  });

  @override
  State<_ImportProgressDialog> createState() => _ImportProgressDialogState();
}

class _ImportProgressDialogState extends State<_ImportProgressDialog> {
  int _current = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    final result = await widget.csvService.importFromCsv(
      widget.file,
      fetchCovers: widget.fetchCovers,
      onProgress: (current, total) {
        if (mounted) {
          setState(() {
            _current = current;
            _total = total;
          });
        }
      },
    );

    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? _current / _total : 0.0;

    return AlertDialog(
      title: const Text('Importation en cours…'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(
            _total > 0 ? '$_current / $_total livres' : 'Lecture du fichier…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ExperimentalSettings extends ConsumerWidget {
  const _ExperimentalSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsRepo = ref.watch(settingsRepositoryProvider);
    final isEnabled = settingsRepo.isLibraryAvailabilityEnabled;
    final apiUrl = settingsRepo.libraryApiUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Fonctionnalités expérimentales',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Vérifier la disponibilité en bibliothèque'),
          subtitle: Text(
            'Expérimental : Peut être instable ou lent.',
            style: TextStyle(color: context.semanticColors.warning),
          ),
          value: isEnabled,
          onChanged: (value) async {
            await settingsRepo.setLibraryAvailabilityEnabled(value);
            // Force rebuild to update the UI immediately if needed,
            // though Riverpod should handle it if we watched a stream/state.
            // Since we are reading directly from prefs in the repo getter (which isn't reactive by itself),
            // we might need a StateProvider or similar if we want instant UI updates elsewhere.
            // But for this simple case, `ref.refresh` or `setState` in a StatefulWidget would be better.
            // However, since this is a ConsumerWidget and we are not using a StateNotifier,
            // we rely on the fact that `settingsRepositoryProvider` is just a Provider.
            // To make it reactive, we should probably use a StateNotifier or similar.
            // For now, let's just force a rebuild by invalidating the provider if we want,
            // but actually the repo methods are async and don't notify.
            // A simple way is to use a StatefulWidget for this section or make the repo return a Stream.
            // Given the constraints, I'll convert this widget to a StatefulWidget to update local state
            // or better, just use `setState` if it was stateful.
            // Let's make `_ExperimentalSettings` Stateful to handle the switch animation correctly.
            (context as Element).markNeedsBuild();
          },
        ),
        if (isEnabled)
          ListTile(
            title: const Text('URL de l\'API'),
            subtitle: Text(apiUrl ?? 'Non configurée'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final controller = TextEditingController(text: apiUrl);
              final newUrl = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Configurer l\'URL de l\'API'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'http://...',
                      labelText: 'URL',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              );

              if (newUrl != null) {
                await settingsRepo.setLibraryApiUrl(newUrl);
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              }
            },
          ),
      ],
    );
  }
}
