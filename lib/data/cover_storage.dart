import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Dossier persistant des couvertures locales (photos prises ou choisies).
Future<Directory> _coversDir() async {
  final docs = await getApplicationDocumentsDirectory();
  return Directory(p.join(docs.path, 'covers')).create(recursive: true);
}

/// Copie une image (fichier temporaire d'image_picker, cache de file_picker…)
/// dans le dossier persistant des couvertures et renvoie son nouveau chemin.
/// Le système peut vider les dossiers temporaires à tout moment : une
/// couverture qui y resterait finirait par disparaître.
Future<String> persistCoverImage(String sourcePath) async {
  final dir = await _coversDir();
  final ext = p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
  final dest = p.join(
      dir.path, 'cover_${DateTime.now().microsecondsSinceEpoch}$ext');
  await File(sourcePath).copy(dest);
  return dest;
}

/// Supprime une photo de couverture abandonnée (seulement si elle est dans
/// notre dossier de couvertures).
Future<void> deleteLocalCover(String? path) async {
  if (path == null) return;
  try {
    if (p.isWithin((await _coversDir()).path, path)) await File(path).delete();
  } catch (_) {
    // Déjà supprimée : rien à faire.
  }
}

/// Entretien des couvertures locales, lancé au démarrage :
/// - rapatrie dans le dossier des couvertures les images encore stockées
///   ailleurs (couvertures choisies avec d'anciennes versions, restées dans le
///   cache de file_picker) et oublie les chemins morts (fichier disparu, chemin
///   importé d'un autre appareil) ;
/// - supprime les photos qui ne servent plus à aucun livre (photo reprise,
///   ajout annulé, couverture remplacée, livre supprimé).
Future<void> maintainLocalCovers(AppDatabase db) async {
  try {
    final dir = await _coversDir();
    final books = await (db.select(db.books)
          ..where((b) => b.coverPath.isNotNull()))
        .get();

    final used = <String>{};
    for (final book in books) {
      final path = book.coverPath!;
      if (p.isWithin(dir.path, path)) {
        used.add(p.normalize(path));
        continue;
      }
      final String? kept =
          await File(path).exists() ? await persistCoverImage(path) : null;
      if (kept != null) used.add(p.normalize(kept));
      await (db.update(db.books)..where((b) => b.id.equals(book.id)))
          .write(BooksCompanion(coverPath: Value(kept)));
    }

    // Marge d'une heure : ne touche pas à une photo tout juste prise dont le
    // livre n'est pas encore enregistré.
    final threshold = DateTime.now().subtract(const Duration(hours: 1));
    await for (final entity in dir.list()) {
      if (entity is File &&
          !used.contains(p.normalize(entity.path)) &&
          (await entity.lastModified()).isBefore(threshold)) {
        await entity.delete();
      }
    }
  } catch (_) {
    // Entretien opportuniste : ne doit jamais gêner le démarrage.
  }
}
