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
import '../../l10n/l10n.dart';
import '../stats/stats_page.dart';
import '../theme_extensions.dart';

/// Langues proposées, chacune nommée dans sa propre langue.
const Map<String, String> _languageNames = {
  'fr': 'Français',
  'en': 'English',
  'es': 'Español',
  'de': 'Deutsch',
};

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
    final l10n = context.l10n;
    try {
      setState(() => _isLoading = true);

      final db = ref.read(databaseProvider);
      final books = await db.getAllBooks();

      if (books.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noBooksToExport)));
        }
        return;
      }

      final file = await _csvService.exportToCsv();

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: l10n.exportShareText),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.booksExported(books.length))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Import CSV
  // ---------------------------------------------------------------------------

  Future<void> _pickAndImportCsv() async {
    final l10n = context.l10n;
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
          l10n.booksImported(
            importResult.importedCount,
            importResult.totalCount,
          ),
        );
        if (importResult.skippedCount > 0) {
          message.write(' ${l10n.rowsSkipped(importResult.skippedCount)}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString()),
            duration: const Duration(seconds: 4),
            action: importResult.errors.isNotEmpty
                ? SnackBarAction(
                    label: l10n.detailsAction,
                    onPressed: () => _showImportErrors(importResult.errors),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.importError('$e'))));
      }
    }
  }

  /// Ouvre un lien dans le navigateur. Pas de canLaunchUrl() préalable : sur
  /// Android 11+, il renvoie faux sans déclaration `<queries>` dans le manifeste,
  /// et le lien ne s'ouvrait jamais.
  Future<void> _openLink(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  String _importErrorText(CsvImportError error, AppLocalizations l10n) {
    return switch (error.kind) {
      CsvImportErrorKind.emptyFile => l10n.csvErrorEmpty,
      CsvImportErrorKind.wrongColumnCount => l10n.csvErrorColumns(
        error.line ?? 0,
      ),
      CsvImportErrorKind.rowFailed => l10n.csvErrorRow(
        error.line ?? 0,
        error.title ?? '?',
        error.detail ?? '',
      ),
      CsvImportErrorKind.unreadableFile => l10n.csvErrorUnreadable(
        error.detail ?? '',
      ),
    };
  }

  void _showImportErrors(List<CsvImportError> errors) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importErrorsTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                _importErrorText(errors[index], l10n),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Langue
  // ---------------------------------------------------------------------------

  Future<void> _chooseLanguage() async {
    final l10n = context.l10n;
    final current = ref.read(localeProvider)?.languageCode;
    // Valeur vide = langue du système (un RadioGroup ne peut pas porter null
    // comme choix distinct).
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.languageTitle),
        children: [
          RadioGroup<String>(
            groupValue: current ?? '',
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: '',
                  title: Text(l10n.languageSystem),
                ),
                for (final entry in _languageNames.entries)
                  RadioListTile<String>(
                    value: entry.key,
                    title: Text(entry.value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (choice == null) return; // Dialogue fermé sans choix.
    await ref
        .read(localeProvider.notifier)
        .setLocale(choice.isEmpty ? null : Locale(choice));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chosenLanguage = ref.watch(localeProvider)?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.insights_outlined),
                  title: Text(l10n.statsTitle),
                  subtitle: Text(l10n.statsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const StatsPage()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(l10n.languageTitle),
                  subtitle: Text(
                    _languageNames[chosenLanguage] ?? l10n.languageSystem,
                  ),
                  onTap: _chooseLanguage,
                ),
                const Divider(),
                _sectionTitle(context, l10n.sectionData),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: Text(l10n.importCsvTitle),
                  subtitle: Text(l10n.importCsvSubtitle),
                  onTap: _pickAndImportCsv,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.exportCsvTitle),
                  subtitle: Text(l10n.exportCsvSubtitle),
                  onTap: _exportCsv,
                ),
                const Divider(),
                const _ExperimentalSettings(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutTitle),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = context.l10n;
    const author = 'Attadeurtia';
    const repoUrl = 'https://github.com/attadeurtia/ilwyrm';
    // Le nom de l'auteur est un lien : on découpe la phrase traduite autour de
    // lui, où qu'il se trouve selon la langue.
    final parts = l10n.aboutDescription('\u0000').split('\u0000');
    const linkStyle = TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );

    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '2.4.0',
      applicationIcon: const Icon(Icons.menu_book, size: 48),
      applicationLegalese: '© 2025 Ilwyrm',
      children: [
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: parts.first),
              TextSpan(
                text: author,
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _openLink('https://github.com/attadeurtia'),
              ),
              if (parts.length > 1) TextSpan(text: parts.last),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: l10n.sourceCodeOnGithub),
              TextSpan(
                text: repoUrl,
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _openLink(repoUrl),
              ),
            ],
          ),
        ),
      ],
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.importOptionsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.importOptionsMessage),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.fetchCoversTitle),
            subtitle: Text(l10n.fetchCoversSubtitle),
            value: _fetchCovers,
            onChanged: (value) => setState(() => _fetchCovers = value),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _fetchCovers),
          child: Text(l10n.chooseFile),
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
    CsvImportResult result;
    try {
      result = await widget.csvService.importFromCsv(
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
    } catch (e) {
      // Fichier illisible (encodage…) : on ferme quand même ce dialogue non
      // annulable, avec l'erreur, au lieu de bloquer l'écran.
      result = CsvImportResult(
        importedCount: 0,
        skippedCount: 0,
        totalCount: 0,
        errors: [
          CsvImportError(CsvImportErrorKind.unreadableFile, detail: '$e'),
        ],
      );
    }

    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = _total > 0 ? _current / _total : 0.0;

    return AlertDialog(
      title: Text(l10n.importInProgress),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(
            _total > 0
                ? l10n.importProgress(_current, _total)
                : l10n.readingFile,
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
    final l10n = context.l10n;
    // Réactif : le NotifierProvider fait se reconstruire l'UI à chaque change.
    final settings = ref.watch(settingsProvider);
    final isEnabled = settings.libraryAvailabilityEnabled;
    final apiUrl = settings.libraryApiUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.sectionExperimental,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.libraryAvailabilitySetting),
          subtitle: Text(
            l10n.experimentalWarning,
            style: TextStyle(color: context.semanticColors.warning),
          ),
          value: isEnabled,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .setLibraryAvailabilityEnabled(value),
        ),
        if (isEnabled)
          ListTile(
            title: Text(l10n.apiUrlTitle),
            subtitle: Text(apiUrl ?? l10n.notConfigured),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final controller = TextEditingController(text: apiUrl);
              try {
                final newUrl = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.configureApiUrl),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'https://...',
                        labelText: l10n.urlLabel,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.actionCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, controller.text),
                        child: Text(l10n.actionSave),
                      ),
                    ],
                  ),
                );
                if (newUrl != null) {
                  await ref
                      .read(settingsProvider.notifier)
                      .setLibraryApiUrl(newUrl.trim());
                }
              } finally {
                controller.dispose();
              }
            },
          ),
      ],
    );
  }
}
