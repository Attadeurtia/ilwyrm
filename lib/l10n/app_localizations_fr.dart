// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ilwyrm';

  @override
  String get shelfToRead => 'À lire';

  @override
  String get shelfReading => 'En cours';

  @override
  String get shelfRead => 'Lu';

  @override
  String get tabToRead => 'À lire';

  @override
  String get tabReading => 'En cours';

  @override
  String get tabRead => 'Lus';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionChangeStatus => 'Changer le statut';

  @override
  String get actionAddTags => 'Ajouter des tags';

  @override
  String get actionAddToFavorites => 'Ajouter aux favoris';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '$count sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get checkAvailability => 'Vérifier la disponibilité';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get sortLabel => 'Trier';

  @override
  String get sortDateAdded => 'Date d\'ajout';

  @override
  String get sortTitle => 'Titre';

  @override
  String get sortAuthor => 'Auteur';

  @override
  String get changeViewTooltip => 'Changer l\'affichage';

  @override
  String get addLabel => 'Ajouter';

  @override
  String get addBookTooltip => 'Ajouter un livre';

  @override
  String get scanLabel => 'Scanner';

  @override
  String get searchLabel => 'Recherche';

  @override
  String booksUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres mis à jour',
      one: '$count livre mis à jour',
    );
    return '$_temp0';
  }

  @override
  String booksAddedToFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres ajoutés aux favoris',
      one: '$count livre ajouté aux favoris',
    );
    return '$_temp0';
  }

  @override
  String get tagsAdded => 'Tags ajoutés !';

  @override
  String get deleteBooksTitle => 'Supprimer les livres ?';

  @override
  String deleteBooksMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voulez-vous vraiment supprimer ces $count livres ?',
      one: 'Voulez-vous vraiment supprimer ce livre ?',
    );
    return '$_temp0';
  }

  @override
  String booksDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres supprimés',
      one: '$count livre supprimé',
    );
    return '$_temp0';
  }

  @override
  String get tagSearchOrCreateHint => 'Rechercher ou créer un tag';

  @override
  String get tagCreateTooltip => 'Créer le tag';

  @override
  String get noTagsAvailable => 'Aucun tag disponible.';

  @override
  String tagCreateError(String error) {
    return 'Erreur lors de la création du tag : $error';
  }

  @override
  String get favoritesFilter => 'Favoris';

  @override
  String genericError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get emptyShelf => 'Aucun livre ici';

  @override
  String get unknownAuthor => 'Auteur inconnu';

  @override
  String get localSearchPrompt => 'Rechercher un livre…';

  @override
  String get noBookFound => 'Aucun livre trouvé.';

  @override
  String get favoriteRemove => 'Retirer des favoris';

  @override
  String get deleteBookTitle => 'Supprimer le livre ?';

  @override
  String deleteBookMessage(String title) {
    return 'Voulez-vous vraiment supprimer « $title » ?';
  }

  @override
  String get coverHint => 'Couverture';

  @override
  String get isbnCopied => 'ISBN copié dans le presse-papier';

  @override
  String get isbnLabel => 'ISBN :';

  @override
  String get unknownValue => 'Inconnu';

  @override
  String get addedLabel => 'Ajouté :';

  @override
  String get summaryTitle => 'Résumé';

  @override
  String get summaryLoading => 'Chargement du résumé…';

  @override
  String get noSummary => 'Aucun résumé disponible.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get manageTagsTitle => 'Gérer les tags';

  @override
  String get otherBooksByAuthor => 'Autres livres de l\'auteur';

  @override
  String get noOtherBooks => 'Aucun autre livre trouvé.';

  @override
  String get startReading => 'Commencer';

  @override
  String get finishReading => 'Terminé';

  @override
  String startedAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Commencé il y a $days jours',
      one: 'Commencé hier',
      zero: 'Commencé aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get readingTimeTitle => 'Temps de lecture';

  @override
  String durationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '$days jour',
    );
    return '$_temp0';
  }

  @override
  String get durationUnknown => 'Durée inconnue';

  @override
  String get libraryAvailabilityTitle => 'Disponibilité en bibliothèque';

  @override
  String get availableLabel => 'Disponible';

  @override
  String get notAvailableLabel => 'Non disponible';

  @override
  String lastChecked(String date) {
    return 'Dernière vérification : $date';
  }

  @override
  String get refreshTooltip => 'Actualiser';

  @override
  String get bibliographicInfo => 'Informations bibliographiques';

  @override
  String get metaPublisher => 'Éditeur';

  @override
  String get metaPublicationDate => 'Date de publication';

  @override
  String get metaPageCount => 'Nombre de pages';

  @override
  String get coverUpdated => 'Couverture mise à jour';

  @override
  String get otherCovers => 'Autres couvertures';

  @override
  String get bookAlreadyInLibrary => 'Ce livre est déjà dans la bibliothèque.';

  @override
  String bookAddedToList(String title) {
    return '« $title » ajouté à la liste !';
  }

  @override
  String get goToBook => 'Y aller';

  @override
  String get searchHint => 'Titre, auteur, ISBN…';

  @override
  String get addManually => 'Ajouter manuellement';

  @override
  String get searchTabAll => 'Tous';

  @override
  String sourceError(String source, String error) {
    return '$source : $error';
  }

  @override
  String get searchErrorTimeout => 'Délai dépassé';

  @override
  String get searchErrorQuota => 'Quota API dépassé';

  @override
  String get searchErrorForbidden => 'Accès refusé';

  @override
  String get searchErrorUnavailable => 'Indisponible';

  @override
  String get searching => 'Recherche…';

  @override
  String get searchPrompt => 'Entrez un titre, un auteur ou un ISBN.';

  @override
  String get noResultsSomeUnavailable =>
      'Aucun résultat (certaines sources sont indisponibles).';

  @override
  String get noResults => 'Aucun résultat trouvé.';

  @override
  String get alreadyInLibrary => 'Déjà dans la bibliothèque';

  @override
  String get addToReadingList => 'Ajouter à la liste de lecture';

  @override
  String get bookUpdated => 'Livre modifié !';

  @override
  String get bookAdded => 'Livre ajouté !';

  @override
  String get duplicateTitle => 'Déjà dans la bibliothèque';

  @override
  String get duplicateMessage =>
      'Ce livre semble déjà être dans ta bibliothèque.';

  @override
  String get addAnyway => 'Ajouter quand même';

  @override
  String get openBook => 'Voir la fiche';

  @override
  String get addCover => 'Ajouter une couverture';

  @override
  String get editBookTitle => 'Modifier le livre';

  @override
  String get addBookTitle => 'Ajouter un livre';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldTitleRequired => 'Veuillez entrer un titre';

  @override
  String get fieldAuthor => 'Auteur';

  @override
  String get fieldPublisher => 'Éditeur';

  @override
  String get fieldPublicationYear => 'Année de publication';

  @override
  String get fieldPageCount => 'Nombre de pages';

  @override
  String get fieldStatus => 'Statut';

  @override
  String get fieldStartDate => 'Date de début';

  @override
  String get fieldFinishDate => 'Date de fin';

  @override
  String get notSet => 'Non défini';

  @override
  String get roleIgnore => 'Ignorer';

  @override
  String get cameraPermissionDenied =>
      'Permission caméra refusée — impossible de photographier.';

  @override
  String get noTextDetectedRetry =>
      'Aucun texte détecté. Réessaie avec une photo plus nette.';

  @override
  String ocrFailed(String error) {
    return 'Échec de la lecture : $error';
  }

  @override
  String get scanCoverTitle => 'Scanner une couverture';

  @override
  String get scanCoverIntro =>
      'Photographie la couverture : le titre, l\'auteur et l\'éditeur seront extraits automatiquement.';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get pickFromGallery => 'Choisir dans la galerie';

  @override
  String get assignLinesHint =>
      'Attribue chaque ligne. Tu peux mettre plusieurs lignes dans le même champ (titre ou auteur sur plusieurs lignes).';

  @override
  String get noTextDetected => 'Aucun texte détecté.';

  @override
  String get retake => 'Reprendre';

  @override
  String get continueLabel => 'Continuer';

  @override
  String fieldLabelPrefix(String label) {
    return '$label : ';
  }

  @override
  String notAnIsbn(String code) {
    return '« $code » n\'est pas un ISBN de livre : ignoré';
  }

  @override
  String isbnAlreadyInLibrary(String isbn) {
    return '« $isbn » est déjà dans ta bibliothèque';
  }

  @override
  String bookScanned(String isbn) {
    return 'Livre scanné : $isbn';
  }

  @override
  String get scannerTitle => 'Scanner des livres';

  @override
  String get scanCoverTooltip => 'Sans code-barres ? Scanner la couverture';

  @override
  String get torchTooltip => 'Lampe';

  @override
  String get switchCameraTooltip => 'Changer de caméra';

  @override
  String get scannerHint =>
      'Scanne le code-barres d\'un livre.\nPas de code-barres ? Utilise l\'icône couverture en haut.';

  @override
  String duplicatesInLibrary(int count) {
    return '$count déjà dans ta bibliothèque';
  }

  @override
  String finishScanning(int count) {
    return 'Terminer ($count)';
  }

  @override
  String addFailed(String error) {
    return 'Échec de l\'ajout : $error';
  }

  @override
  String booksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres ajoutés',
      one: '$count livre ajouté',
    );
    return '$_temp0';
  }

  @override
  String booksSkippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déjà présents ignorés',
      one: '$count déjà présent ignoré',
    );
    return '$_temp0';
  }

  @override
  String chooseSourceFor(String isbn) {
    return 'Choisir une source pour $isbn';
  }

  @override
  String get confirmAddTitle => 'Confirmer l\'ajout';

  @override
  String get addAllTooltip => 'Tout ajouter';

  @override
  String get batchSearching =>
      'Recherche sur OpenLibrary, la BnF, Inventaire et Google Books…';

  @override
  String barcodeNotFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impossible de trouver $count livres par code-barres.',
      one: 'Impossible de trouver $count livre par code-barres.',
    );
    return '$_temp0';
  }

  @override
  String get scanCoverButton => 'Scanner la couverture';

  @override
  String sourceTapToChange(String source) {
    return 'Source : $source (touchez pour changer)';
  }

  @override
  String sourceLabel(String source) {
    return 'Source : $source';
  }

  @override
  String addBooksButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count livres',
      one: 'Ajouter $count livre',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déjà présents',
      one: '$count déjà présent',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsSubtitle => 'Vos lectures en chiffres';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get noBooksToExport => 'Aucun livre à exporter.';

  @override
  String get exportShareText => 'Export de ma bibliothèque Ilwyrm';

  @override
  String booksExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres exportés avec succès.',
      one: '$count livre exporté avec succès.',
    );
    return '$_temp0';
  }

  @override
  String exportError(String error) {
    return 'Erreur lors de l\'exportation : $error';
  }

  @override
  String booksImported(int imported, int total) {
    return '$imported/$total livres importés.';
  }

  @override
  String rowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ignorés.',
      one: '$count ignoré.',
    );
    return '$_temp0';
  }

  @override
  String get detailsAction => 'Détails';

  @override
  String importError(String error) {
    return 'Erreur lors de l\'importation : $error';
  }

  @override
  String get importErrorsTitle => 'Erreurs d\'importation';

  @override
  String get csvErrorEmpty => 'Le fichier CSV est vide.';

  @override
  String csvErrorColumns(int line) {
    return 'Ligne $line : nombre de colonnes incorrect.';
  }

  @override
  String csvErrorRow(int line, String title, String error) {
    return 'Ligne $line ($title) : $error';
  }

  @override
  String csvErrorUnreadable(String error) {
    return 'Import impossible : $error';
  }

  @override
  String get sectionData => 'Données';

  @override
  String get importCsvTitle => 'Importer un fichier CSV';

  @override
  String get importCsvSubtitle =>
      'Importez vos livres et tags depuis un fichier CSV';

  @override
  String get exportCsvTitle => 'Exporter un fichier CSV';

  @override
  String get exportCsvSubtitle =>
      'Exportez vos livres et tags pour les transférer';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutDescription(String author) {
    return 'Ilwyrm est une application de gestion de bibliothèque personnelle open-source développée par $author.';
  }

  @override
  String get sourceCodeOnGithub => 'Code source disponible sur GitHub : ';

  @override
  String get importOptionsTitle => 'Options d\'importation';

  @override
  String get importOptionsMessage =>
      'Choisissez les options pour l\'importation de votre fichier CSV.';

  @override
  String get fetchCoversTitle => 'Rechercher les couvertures';

  @override
  String get fetchCoversSubtitle =>
      'Recherche en ligne les couvertures manquantes. Plus lent.';

  @override
  String get chooseFile => 'Choisir le fichier';

  @override
  String get importInProgress => 'Importation en cours…';

  @override
  String importProgress(int current, int total) {
    return '$current / $total livres';
  }

  @override
  String get readingFile => 'Lecture du fichier…';

  @override
  String get sectionExperimental => 'Fonctionnalités expérimentales';

  @override
  String get libraryAvailabilitySetting =>
      'Vérifier la disponibilité en bibliothèque';

  @override
  String get experimentalWarning =>
      'Expérimental : Peut être instable ou lent.';

  @override
  String get apiUrlTitle => 'URL de l\'API';

  @override
  String get notConfigured => 'Non configurée';

  @override
  String get configureApiUrl => 'Configurer l\'URL de l\'API';

  @override
  String get urlLabel => 'URL';

  @override
  String get statsLibrarySection => 'Ma bibliothèque';

  @override
  String get statsTotalBooks => 'Livres';

  @override
  String get statsReadingSection => 'Lectures';

  @override
  String statsHeroLabel(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'livres lus en $year',
      one: 'livre lu en $year',
    );
    return '$_temp0';
  }

  @override
  String statsDeltaVsYear(String delta, int year) {
    return '$delta par rapport à $year';
  }

  @override
  String statsSameAsYear(int year) {
    return 'Autant qu\'en $year';
  }

  @override
  String get statsPagesRead => 'Pages lues';

  @override
  String get statsAverageDuration => 'Durée moyenne';

  @override
  String get statsPerMonthTitle => 'Livres lus par mois';

  @override
  String get statsPerYearTitle => 'Livres lus par année';

  @override
  String get statsTopAuthorsTitle => 'Auteurs les plus lus';

  @override
  String get statsNoReadingYet =>
      'Aucune lecture terminée pour l\'instant : termine un livre pour voir tes statistiques de lecture.';

  @override
  String statsBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres',
      one: '$count livre',
      zero: 'Aucun livre',
    );
    return '$_temp0';
  }

  @override
  String get statsShowTable => 'Afficher en tableau';

  @override
  String get statsShowChart => 'Afficher le graphique';

  @override
  String get statsMonthColumn => 'Mois';

  @override
  String get statsYearColumn => 'Année';

  @override
  String get statsBooksColumn => 'Livres';

  @override
  String get statsChartHint => 'Touchez une barre pour voir sa valeur.';
}
