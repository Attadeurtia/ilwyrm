import 'package:flutter/widgets.dart';

import '../data/enums.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// Textes de l'interface dans la langue courante.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Libellé traduit d'un statut de lecture (le libellé [BookShelf.label], en
/// français, reste la valeur enregistrée en base).
extension BookShelfL10n on BookShelf {
  String displayName(AppLocalizations l10n) => switch (this) {
    BookShelf.toRead => l10n.shelfToRead,
    BookShelf.reading => l10n.shelfReading,
    BookShelf.read => l10n.shelfRead,
  };
}
