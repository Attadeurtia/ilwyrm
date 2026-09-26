import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/book_search_api.dart';
import '../../data/cover_storage.dart';
import 'edit_book_page.dart';

/// Rôle attribué à une ligne de texte détectée sur la couverture.
enum _Role {
  none('Ignorer'),
  title('Titre'),
  author('Auteur'),
  publisher('Éditeur');

  const _Role(this.label);
  final String label;
}

class _Line {
  _Line(this.text, this.height, this.top);
  final String text;
  final double height;
  final double top;
}

/// Prend en photo (ou choisit) la couverture d'un livre, en extrait le texte via
/// OCR sur l'appareil (ML Kit), puis laisse l'utilisateur assigner chaque ligne
/// à Titre / Auteur / Éditeur avant d'ouvrir le formulaire d'ajout pré-rempli
/// (la photo servant aussi de couverture).
class ScanCoverPage extends StatefulWidget {
  const ScanCoverPage({super.key});

  @override
  State<ScanCoverPage> createState() => _ScanCoverPageState();
}

class _ScanCoverPageState extends State<ScanCoverPage> {
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  bool _processing = false;
  String? _error;
  List<_Line> _lines = [];
  final Map<int, _Role> _roles = {};

  Future<void> _pick(ImageSource source) async {
    // La permission CAMERA est déclarée (via mobile_scanner) : l'OS exige alors
    // qu'elle soit accordée, et image_picker ne la demande pas lui-même.
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() =>
              _error = 'Permission caméra refusée — impossible de photographier.');
        }
        return;
      }
    }

    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 2000, // assez pour l'OCR tout en limitant la taille du fichier
        imageQuality: 90,
      );
      if (picked == null) {
        if (mounted) setState(() => _processing = false);
        return;
      }

      // Les fichiers d'image_picker sont temporaires : on copie l'image dans un
      // emplacement persistant pour pouvoir la garder comme couverture.
      final savedPath = await persistCoverImage(picked.path);
      final lines = await _runOcr(savedPath);

      if (!mounted) return;
      setState(() {
        _imagePath = savedPath;
        _lines = lines;
        _roles.clear();
        _guessRoles(lines);
        _processing = false;
        if (lines.isEmpty) {
          _error = 'Aucun texte détecté. Réessaie avec une photo plus nette.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = 'Échec de la lecture : $e';
      });
    }
  }

  Future<List<_Line>> _runOcr(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(path));
      final lines = <_Line>[];
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final t = line.text.trim();
          if (t.isNotEmpty) {
            lines.add(_Line(t, line.boundingBox.height, line.boundingBox.top));
          }
        }
      }
      lines.sort((a, b) => a.top.compareTo(b.top)); // ordre de lecture haut→bas
      return lines;
    } finally {
      await recognizer.close();
    }
  }

  /// Pré-remplissage léger : la ligne au plus gros texte = titre. Le reste est
  /// laissé à l'utilisateur, car un titre ou un auteur peut s'étaler sur
  /// plusieurs lignes (ex. « Les » au-dessus de « impatientes »).
  void _guessRoles(List<_Line> lines) {
    if (lines.isEmpty) return;
    var tallest = 0;
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].height > lines[tallest].height) tallest = i;
    }
    _roles[tallest] = _Role.title;
  }

  void _assign(int index, _Role role) {
    setState(() {
      if (role == _Role.none) {
        _roles.remove(index);
      } else {
        // Plusieurs lignes peuvent partager un même rôle : elles seront
        // concaténées (titre ou auteur écrit sur plusieurs lignes).
        _roles[index] = role;
      }
    });
  }

  /// Concatène, dans l'ordre de lecture (les lignes sont triées de haut en bas),
  /// toutes les lignes portant ce rôle.
  String? _textFor(_Role role) {
    final parts = <String>[];
    for (var i = 0; i < _lines.length; i++) {
      if (_roles[i] == role) parts.add(_lines[i].text);
    }
    return parts.isEmpty ? null : parts.join(' ');
  }

  void _continue() {
    final external = ExternalBook(
      key: 'ocr',
      title: _textFor(_Role.title) ?? '',
      authorText: _textFor(_Role.author) ?? '',
      publisher: _textFor(_Role.publisher),
      source: 'ocr',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookPage(
          initialBook: external,
          initialCoverPath: _imagePath,
        ),
      ),
    );
  }

  void _reset() {
    // La photo reprise ne servira pas : on ne la laisse pas traîner.
    deleteLocalCover(_imagePath);
    setState(() {
      _imagePath = null;
      _lines = [];
      _roles.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner une couverture')),
      body: _processing
          ? const Center(child: CircularProgressIndicator())
          : _imagePath == null
              ? _buildChooser()
              : _buildAssign(),
    );
  }

  Widget _buildChooser() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              "Photographie la couverture : le titre, l'auteur et l'éditeur "
              'seront extraits automatiquement.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choisir dans la galerie'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssign() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(_imagePath!),
                    width: 90,
                    height: 135,
                    cacheHeight: 405, // aperçu : inutile de décoder la photo entière
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow('Titre', _textFor(_Role.title)),
                    _summaryRow('Auteur', _textFor(_Role.author)),
                    _summaryRow('Éditeur', _textFor(_Role.publisher)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Attribue chaque ligne. Tu peux mettre plusieurs lignes dans le '
            'même champ (titre ou auteur sur plusieurs lignes).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        Expanded(
          child: _lines.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error ?? 'Aucun texte détecté.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _lines.length,
                  itemBuilder: (context, i) {
                    final role = _roles[i] ?? _Role.none;
                    return Card(
                      child: ListTile(
                        title: Text(_lines[i].text),
                        trailing: DropdownButton<_Role>(
                          value: role,
                          underline: const SizedBox.shrink(),
                          onChanged: (r) {
                            if (r != null) _assign(i, r);
                          },
                          items: _Role.values
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r.label),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reprendre'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _textFor(_Role.title) != null ? _continue : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continuer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
                text: '$label : ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: value ?? '—',
              style: value == null
                  ? TextStyle(color: Theme.of(context).colorScheme.outline)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
