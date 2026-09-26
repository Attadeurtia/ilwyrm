import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/database.dart';

/// Affiche la couverture d'un livre de façon robuste.
///
/// Corrige deux problèmes qui laissaient des cases vides :
/// 1. Les couvertures étaient rendues via `BoxDecoration.image` (`DecorationImage`),
///    qui ne peut afficher AUCUN repli en cas d'échec de chargement.
/// 2. L'API OpenLibrary renvoie un HTTP 200 avec une image blanche quand la
///    couverture est absente ; on ajoute `?default=false` pour obtenir un vrai
///    404, qui déclenche alors le repli.
///
/// Essaie successivement `coverUrl`, puis la couverture OpenLibrary par
/// `coverId`, puis par `openlibraryKey`, et retombe enfin sur un placeholder
/// titre/auteur.
class BookCover extends StatelessWidget {
  final Book book;
  final double borderRadius;

  /// Petits contextes (vignette de liste) : placeholder texte réduit.
  final bool compact;

  /// Ajustement de l'image. `cover` (défaut) pour remplir une vignette ;
  /// `contain` pour l'aperçu plein écran (couverture entière, sans rognage).
  final BoxFit fit;

  /// Aperçu plein écran (zoomable) : image décodée en pleine résolution.
  /// Ailleurs, elle est décodée à une taille plafonnée (voir [_decodeHeight]).
  final bool fullResolution;

  const BookCover({
    super.key,
    required this.book,
    this.borderRadius = 8,
    this.compact = false,
    this.fit = BoxFit.cover,
    this.fullResolution = false,
  });

  /// Hauteur maximale (pixels physiques) à laquelle une couverture est décodée
  /// hors plein écran — assez pour la fiche (210 dp × densité ≈ 3,5). Une
  /// photo de couverture (2000 px de large) décodée en entier pèse ~20 Mo en
  /// mémoire, contre ~1 Mo ainsi. La même taille sert partout (grille, liste,
  /// fiche) : l'image décodée est réutilisée pendant la transition Hero, sans
  /// nouveau décodage ni clignotement. Les images plus petites ne sont jamais
  /// agrandies.
  static const int _decodeHeight = 720;

  String _withDefaultFalse(String url) {
    if (url.contains('covers.openlibrary.org') && !url.contains('default=')) {
      return '$url${url.contains('?') ? '&' : '?'}default=false';
    }
    return url;
  }

  List<String> _candidateUrls() {
    final urls = <String>[];
    final coverUrl = book.coverUrl;
    if (coverUrl != null && coverUrl.trim().isNotEmpty) {
      urls.add(_withDefaultFalse(coverUrl.trim()));
    }
    if (book.coverId != null) {
      urls.add(_withDefaultFalse(
          'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg'));
    }
    final olid = book.openlibraryKey;
    if (olid != null && olid.trim().isNotEmpty) {
      urls.add(_withDefaultFalse(
          'https://covers.openlibrary.org/b/olid/${olid.split('/').last}-L.jpg'));
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.expand(
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // Couverture locale (photo prise via le scan OCR ou choisie) en priorité ;
    // en cas d'échec, on retombe sur la cascade réseau puis le placeholder.
    final path = book.coverPath;
    if (path != null && path.trim().isNotEmpty) {
      final file = File(path);
      Widget local({required bool full}) => Image.file(
            file,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            cacheHeight: full ? null : _decodeHeight,
            // Plein écran : la version plafonnée (déjà décodée) s'affiche en
            // attendant la pleine résolution.
            frameBuilder: full
                ? (context, child, frame, sync) =>
                    frame == null && !sync ? local(full: false) : child
                : null,
            errorBuilder: (context, _, _) =>
                _chain(context, _candidateUrls(), 0),
          );
      return local(full: fullResolution);
    }
    return _chain(context, _candidateUrls(), 0);
  }

  Widget _chain(
    BuildContext context,
    List<String> urls,
    int index, {
    bool? full,
  }) {
    if (index >= urls.length) return _fallback(context);
    final fullSize = full ?? fullResolution;
    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      memCacheHeight: fullSize ? null : _decodeHeight,
      // Pas de fondu : l'image s'affiche directement une fois chargée. Pendant
      // le chargement, on montre déjà le repli coloré titre/auteur (plutôt qu'une
      // case vide), qui reste informatif si la couverture finit par échouer.
      // En plein écran, c'est la version plafonnée qui patiente.
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (context, _) => fullSize
          ? _chain(context, urls, index, full: false)
          : _fallback(context),
      errorWidget: (context, _, _) =>
          _chain(context, urls, index + 1, full: full),
    );
  }

  /// Couleur de fond du repli : une teinte stable par livre (dérivée du titre)
  /// mais avec la luminosité/saturation du thème (claire en thème clair, sombre
  /// en thème sombre) — pour varier les couleurs sans sortir du thème, au lieu
  /// d'avoir toujours la même.
  Color _placeholderColor(BuildContext context) {
    final base =
        HSLColor.fromColor(Theme.of(context).colorScheme.secondaryContainer);
    final saturation = base.saturation.clamp(0.32, 0.55).toDouble();
    return HSLColor.fromAHSL(
      1,
      _stableHue().toDouble(),
      saturation,
      base.lightness,
    ).toColor();
  }

  /// Texte lisible sur [background], quelle que soit la teinte générée.
  Color _placeholderForeground(Color background) =>
      background.computeLuminance() > 0.5
          ? Colors.black.withValues(alpha: 0.72)
          : Colors.white.withValues(alpha: 0.92);

  /// Teinte (0–359) déterministe à partir du titre (ou de l'id à défaut) : le
  /// même livre garde toujours la même couleur.
  int _stableHue() {
    final key = book.title.trim().isNotEmpty ? book.title.trim() : '${book.id}';
    var h = 0;
    for (final unit in key.codeUnits) {
      h = (h * 31 + unit) & 0x7fffffff;
    }
    return h % 360;
  }

  Widget _background(Color background, {Widget? child}) => Container(
        color: background,
        alignment: Alignment.center,
        child: child,
      );

  Widget _fallback(BuildContext context) {
    final background = _placeholderColor(context);
    final foreground = _placeholderForeground(background);
    final author = book.authorText;

    if (compact) {
      return _background(
        background,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            book.title,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 8, color: foreground),
          ),
        ),
      );
    }

    return _background(
      background,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (author != null && author.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                author,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
