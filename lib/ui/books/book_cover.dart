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

  const BookCover({
    super.key,
    required this.book,
    this.borderRadius = 8,
    this.compact = false,
  });

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
        child: _chain(context, _candidateUrls(), 0),
      ),
    );
  }

  Widget _chain(BuildContext context, List<String> urls, int index) {
    if (index >= urls.length) return _fallback(context);
    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: const Duration(milliseconds: 150),
      // Pendant le chargement, on montre déjà le repli titre/auteur plutôt
      // qu'une case vide : évite le « flash » avant l'apparition du texte quand
      // la couverture finit par échouer, et reste informatif si elle charge.
      placeholder: (context, _) => _fallback(context),
      errorWidget: (context, _, _) => _chain(context, urls, index + 1),
    );
  }

  Widget _background(BuildContext context, {Widget? child}) => Container(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        alignment: Alignment.center,
        child: child,
      );

  Widget _fallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final author = book.authorText;

    if (compact) {
      return _background(
        context,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            book.title,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 8, color: scheme.onTertiaryContainer),
          ),
        ),
      );
    }

    return _background(
      context,
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
                    color: scheme.onTertiaryContainer,
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
                      color: scheme.onTertiaryContainer.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
