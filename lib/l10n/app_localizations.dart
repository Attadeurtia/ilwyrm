import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
  ];

  /// Nom de l’application
  ///
  /// In fr, this message translates to:
  /// **'Ilwyrm'**
  String get appTitle;

  /// Statut de lecture
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get shelfToRead;

  /// No description provided for @shelfReading.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get shelfReading;

  /// No description provided for @shelfRead.
  ///
  /// In fr, this message translates to:
  /// **'Lu'**
  String get shelfRead;

  /// Onglet de l'accueil
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get tabToRead;

  /// No description provided for @tabReading.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get tabReading;

  /// No description provided for @tabRead.
  ///
  /// In fr, this message translates to:
  /// **'Lus'**
  String get tabRead;

  /// No description provided for @actionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get actionAdd;

  /// No description provided for @actionClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get actionClose;

  /// No description provided for @actionSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// No description provided for @actionChangeStatus.
  ///
  /// In fr, this message translates to:
  /// **'Changer le statut'**
  String get actionChangeStatus;

  /// No description provided for @actionAddTags.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des tags'**
  String get actionAddTags;

  /// No description provided for @actionAddToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get actionAddToFavorites;

  /// No description provided for @selectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} sélectionné} other{{count} sélectionnés}}'**
  String selectedCount(int count);

  /// No description provided for @checkAvailability.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier la disponibilité'**
  String get checkAvailability;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @sortLabel.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortLabel;

  /// No description provided for @sortDateAdded.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'ajout'**
  String get sortDateAdded;

  /// No description provided for @sortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get sortTitle;

  /// No description provided for @sortAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get sortAuthor;

  /// No description provided for @changeViewTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'affichage'**
  String get changeViewTooltip;

  /// Bouton flottant d'ajout
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addLabel;

  /// No description provided for @addBookTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un livre'**
  String get addBookTooltip;

  /// No description provided for @scanLabel.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get scanLabel;

  /// No description provided for @searchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get searchLabel;

  /// No description provided for @booksUpdated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} livre mis à jour} other{{count} livres mis à jour}}'**
  String booksUpdated(int count);

  /// No description provided for @booksAddedToFavorites.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} livre ajouté aux favoris} other{{count} livres ajoutés aux favoris}}'**
  String booksAddedToFavorites(int count);

  /// No description provided for @tagsAdded.
  ///
  /// In fr, this message translates to:
  /// **'Tags ajoutés !'**
  String get tagsAdded;

  /// No description provided for @deleteBooksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les livres ?'**
  String get deleteBooksTitle;

  /// No description provided for @deleteBooksMessage.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Voulez-vous vraiment supprimer ce livre ?} other{Voulez-vous vraiment supprimer ces {count} livres ?}}'**
  String deleteBooksMessage(int count);

  /// No description provided for @booksDeleted.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} livre supprimé} other{{count} livres supprimés}}'**
  String booksDeleted(int count);

  /// No description provided for @tagSearchOrCreateHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher ou créer un tag'**
  String get tagSearchOrCreateHint;

  /// No description provided for @tagCreateTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Créer le tag'**
  String get tagCreateTooltip;

  /// No description provided for @noTagsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tag disponible.'**
  String get noTagsAvailable;

  /// No description provided for @tagCreateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création du tag : {error}'**
  String tagCreateError(String error);

  /// No description provided for @favoritesFilter.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favoritesFilter;

  /// No description provided for @genericError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String genericError(String error);

  /// No description provided for @emptyShelf.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre ici'**
  String get emptyShelf;

  /// No description provided for @unknownAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur inconnu'**
  String get unknownAuthor;

  /// No description provided for @localSearchPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un livre…'**
  String get localSearchPrompt;

  /// No description provided for @noBookFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre trouvé.'**
  String get noBookFound;

  /// No description provided for @favoriteRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get favoriteRemove;

  /// No description provided for @deleteBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le livre ?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer « {title} » ?'**
  String deleteBookMessage(String title);

  /// Indice sur un livre sans couverture
  ///
  /// In fr, this message translates to:
  /// **'Couverture'**
  String get coverHint;

  /// No description provided for @isbnCopied.
  ///
  /// In fr, this message translates to:
  /// **'ISBN copié dans le presse-papier'**
  String get isbnCopied;

  /// No description provided for @isbnLabel.
  ///
  /// In fr, this message translates to:
  /// **'ISBN :'**
  String get isbnLabel;

  /// No description provided for @unknownValue.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknownValue;

  /// No description provided for @addedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté :'**
  String get addedLabel;

  /// No description provided for @summaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résumé'**
  String get summaryTitle;

  /// No description provided for @summaryLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du résumé…'**
  String get summaryLoading;

  /// No description provided for @noSummary.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résumé disponible.'**
  String get noSummary;

  /// No description provided for @tagsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @manageTagsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les tags'**
  String get manageTagsTitle;

  /// No description provided for @otherBooksByAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Autres livres de l\'auteur'**
  String get otherBooksByAuthor;

  /// No description provided for @noOtherBooks.
  ///
  /// In fr, this message translates to:
  /// **'Aucun autre livre trouvé.'**
  String get noOtherBooks;

  /// No description provided for @startReading.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get startReading;

  /// No description provided for @finishReading.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get finishReading;

  /// No description provided for @startedAgo.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =0{Commencé aujourd\'hui} =1{Commencé hier} other{Commencé il y a {days} jours}}'**
  String startedAgo(int days);

  /// No description provided for @readingTimeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Temps de lecture'**
  String get readingTimeTitle;

  /// No description provided for @durationDays.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, one{{days} jour} other{{days} jours}}'**
  String durationDays(int days);

  /// No description provided for @durationUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Durée inconnue'**
  String get durationUnknown;

  /// No description provided for @libraryAvailabilityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité en bibliothèque'**
  String get libraryAvailabilityTitle;

  /// No description provided for @availableLabel.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get availableLabel;

  /// No description provided for @notAvailableLabel.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible'**
  String get notAvailableLabel;

  /// No description provided for @lastChecked.
  ///
  /// In fr, this message translates to:
  /// **'Dernière vérification : {date}'**
  String lastChecked(String date);

  /// No description provided for @refreshTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refreshTooltip;

  /// No description provided for @bibliographicInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations bibliographiques'**
  String get bibliographicInfo;

  /// No description provided for @metaPublisher.
  ///
  /// In fr, this message translates to:
  /// **'Éditeur'**
  String get metaPublisher;

  /// No description provided for @metaPublicationDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de publication'**
  String get metaPublicationDate;

  /// No description provided for @metaPageCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pages'**
  String get metaPageCount;

  /// No description provided for @coverUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Couverture mise à jour'**
  String get coverUpdated;

  /// No description provided for @otherCovers.
  ///
  /// In fr, this message translates to:
  /// **'Autres couvertures'**
  String get otherCovers;

  /// No description provided for @bookAlreadyInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre est déjà dans la bibliothèque.'**
  String get bookAlreadyInLibrary;

  /// No description provided for @bookAddedToList.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » ajouté à la liste !'**
  String bookAddedToList(String title);

  /// No description provided for @goToBook.
  ///
  /// In fr, this message translates to:
  /// **'Y aller'**
  String get goToBook;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre, auteur, ISBN…'**
  String get searchHint;

  /// No description provided for @addManually.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter manuellement'**
  String get addManually;

  /// No description provided for @searchTabAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get searchTabAll;

  /// No description provided for @sourceError.
  ///
  /// In fr, this message translates to:
  /// **'{source} : {error}'**
  String sourceError(String source, String error);

  /// No description provided for @searchErrorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Délai dépassé'**
  String get searchErrorTimeout;

  /// No description provided for @searchErrorQuota.
  ///
  /// In fr, this message translates to:
  /// **'Quota API dépassé'**
  String get searchErrorQuota;

  /// No description provided for @searchErrorForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé'**
  String get searchErrorForbidden;

  /// No description provided for @searchErrorUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get searchErrorUnavailable;

  /// No description provided for @searching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche…'**
  String get searching;

  /// No description provided for @searchPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un titre, un auteur ou un ISBN.'**
  String get searchPrompt;

  /// No description provided for @noResultsSomeUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat (certaines sources sont indisponibles).'**
  String get noResultsSomeUnavailable;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé.'**
  String get noResults;

  /// No description provided for @alreadyInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Déjà dans la bibliothèque'**
  String get alreadyInLibrary;

  /// No description provided for @addToReadingList.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la liste de lecture'**
  String get addToReadingList;

  /// No description provided for @bookUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Livre modifié !'**
  String get bookUpdated;

  /// No description provided for @bookAdded.
  ///
  /// In fr, this message translates to:
  /// **'Livre ajouté !'**
  String get bookAdded;

  /// No description provided for @duplicateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déjà dans la bibliothèque'**
  String get duplicateTitle;

  /// No description provided for @duplicateMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre semble déjà être dans ta bibliothèque.'**
  String get duplicateMessage;

  /// No description provided for @addAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter quand même'**
  String get addAnyway;

  /// No description provided for @openBook.
  ///
  /// In fr, this message translates to:
  /// **'Voir la fiche'**
  String get openBook;

  /// No description provided for @addCover.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une couverture'**
  String get addCover;

  /// No description provided for @editBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le livre'**
  String get editBookTitle;

  /// No description provided for @addBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un livre'**
  String get addBookTitle;

  /// No description provided for @fieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get fieldTitle;

  /// No description provided for @fieldTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un titre'**
  String get fieldTitleRequired;

  /// No description provided for @fieldAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get fieldAuthor;

  /// No description provided for @fieldPublisher.
  ///
  /// In fr, this message translates to:
  /// **'Éditeur'**
  String get fieldPublisher;

  /// No description provided for @fieldPublicationYear.
  ///
  /// In fr, this message translates to:
  /// **'Année de publication'**
  String get fieldPublicationYear;

  /// No description provided for @fieldPageCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pages'**
  String get fieldPageCount;

  /// No description provided for @fieldStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get fieldStatus;

  /// No description provided for @fieldStartDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get fieldStartDate;

  /// No description provided for @fieldFinishDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get fieldFinishDate;

  /// No description provided for @notSet.
  ///
  /// In fr, this message translates to:
  /// **'Non défini'**
  String get notSet;

  /// No description provided for @roleIgnore.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get roleIgnore;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission caméra refusée — impossible de photographier.'**
  String get cameraPermissionDenied;

  /// No description provided for @noTextDetectedRetry.
  ///
  /// In fr, this message translates to:
  /// **'Aucun texte détecté. Réessaie avec une photo plus nette.'**
  String get noTextDetectedRetry;

  /// No description provided for @ocrFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la lecture : {error}'**
  String ocrFailed(String error);

  /// No description provided for @scanCoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner une couverture'**
  String get scanCoverTitle;

  /// No description provided for @scanCoverIntro.
  ///
  /// In fr, this message translates to:
  /// **'Photographie la couverture : le titre, l\'auteur et l\'éditeur seront extraits automatiquement.'**
  String get scanCoverIntro;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @pickFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get pickFromGallery;

  /// No description provided for @assignLinesHint.
  ///
  /// In fr, this message translates to:
  /// **'Attribue chaque ligne. Tu peux mettre plusieurs lignes dans le même champ (titre ou auteur sur plusieurs lignes).'**
  String get assignLinesHint;

  /// No description provided for @noTextDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun texte détecté.'**
  String get noTextDetected;

  /// No description provided for @retake.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get retake;

  /// No description provided for @continueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueLabel;

  /// No description provided for @fieldLabelPrefix.
  ///
  /// In fr, this message translates to:
  /// **'{label} : '**
  String fieldLabelPrefix(String label);

  /// No description provided for @notAnIsbn.
  ///
  /// In fr, this message translates to:
  /// **'« {code} » n\'est pas un ISBN de livre : ignoré'**
  String notAnIsbn(String code);

  /// No description provided for @isbnAlreadyInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'« {isbn} » est déjà dans ta bibliothèque'**
  String isbnAlreadyInLibrary(String isbn);

  /// No description provided for @bookScanned.
  ///
  /// In fr, this message translates to:
  /// **'Livre scanné : {isbn}'**
  String bookScanned(String isbn);

  /// No description provided for @scannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner des livres'**
  String get scannerTitle;

  /// No description provided for @scanCoverTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Sans code-barres ? Scanner la couverture'**
  String get scanCoverTooltip;

  /// No description provided for @torchTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Lampe'**
  String get torchTooltip;

  /// No description provided for @switchCameraTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Changer de caméra'**
  String get switchCameraTooltip;

  /// No description provided for @scannerHint.
  ///
  /// In fr, this message translates to:
  /// **'Scanne le code-barres d\'un livre.\nPas de code-barres ? Utilise l\'icône couverture en haut.'**
  String get scannerHint;

  /// No description provided for @duplicatesInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'{count} déjà dans ta bibliothèque'**
  String duplicatesInLibrary(int count);

  /// No description provided for @finishScanning.
  ///
  /// In fr, this message translates to:
  /// **'Terminer ({count})'**
  String finishScanning(int count);

  /// No description provided for @addFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'ajout : {error}'**
  String addFailed(String error);

  /// No description provided for @booksAddedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} livre ajouté} other{{count} livres ajoutés}}'**
  String booksAddedCount(int count);

  /// No description provided for @booksSkippedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} déjà présent ignoré} other{{count} déjà présents ignorés}}'**
  String booksSkippedCount(int count);

  /// No description provided for @chooseSourceFor.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une source pour {isbn}'**
  String chooseSourceFor(String isbn);

  /// No description provided for @confirmAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'ajout'**
  String get confirmAddTitle;

  /// No description provided for @addAllTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Tout ajouter'**
  String get addAllTooltip;

  /// No description provided for @batchSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche sur OpenLibrary, la BnF, Inventaire et Google Books…'**
  String get batchSearching;

  /// No description provided for @barcodeNotFound.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Impossible de trouver {count} livre par code-barres.} other{Impossible de trouver {count} livres par code-barres.}}'**
  String barcodeNotFound(int count);

  /// No description provided for @scanCoverButton.
  ///
  /// In fr, this message translates to:
  /// **'Scanner la couverture'**
  String get scanCoverButton;

  /// No description provided for @sourceTapToChange.
  ///
  /// In fr, this message translates to:
  /// **'Source : {source} (touchez pour changer)'**
  String sourceTapToChange(String source);

  /// No description provided for @sourceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Source : {source}'**
  String sourceLabel(String source);

  /// No description provided for @addBooksButton.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Ajouter {count} livre} other{Ajouter {count} livres}}'**
  String addBooksButton(int count);

  /// No description provided for @alreadyPresentCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} déjà présent} other{{count} déjà présents}}'**
  String alreadyPresentCount(int count);

  /// No description provided for @statsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsTitle;

  /// No description provided for @statsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos lectures en chiffres'**
  String get statsSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du système'**
  String get languageSystem;

  /// No description provided for @noBooksToExport.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre à exporter.'**
  String get noBooksToExport;

  /// No description provided for @exportShareText.
  ///
  /// In fr, this message translates to:
  /// **'Export de ma bibliothèque Ilwyrm'**
  String get exportShareText;

  /// No description provided for @booksExported.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} livre exporté avec succès.} other{{count} livres exportés avec succès.}}'**
  String booksExported(int count);

  /// No description provided for @exportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'exportation : {error}'**
  String exportError(String error);

  /// No description provided for @booksImported.
  ///
  /// In fr, this message translates to:
  /// **'{imported}/{total} livres importés.'**
  String booksImported(int imported, int total);

  /// No description provided for @rowsSkipped.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} ignoré.} other{{count} ignorés.}}'**
  String rowsSkipped(int count);

  /// No description provided for @detailsAction.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get detailsAction;

  /// No description provided for @importError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'importation : {error}'**
  String importError(String error);

  /// No description provided for @importErrorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Erreurs d\'importation'**
  String get importErrorsTitle;

  /// No description provided for @csvErrorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier CSV est vide.'**
  String get csvErrorEmpty;

  /// No description provided for @csvErrorColumns.
  ///
  /// In fr, this message translates to:
  /// **'Ligne {line} : nombre de colonnes incorrect.'**
  String csvErrorColumns(int line);

  /// No description provided for @csvErrorRow.
  ///
  /// In fr, this message translates to:
  /// **'Ligne {line} ({title}) : {error}'**
  String csvErrorRow(int line, String title, String error);

  /// No description provided for @csvErrorUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Import impossible : {error}'**
  String csvErrorUnreadable(String error);

  /// No description provided for @sectionData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get sectionData;

  /// No description provided for @importCsvTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier CSV'**
  String get importCsvTitle;

  /// No description provided for @importCsvSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Importez vos livres et tags depuis un fichier CSV'**
  String get importCsvSubtitle;

  /// No description provided for @exportCsvTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter un fichier CSV'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Exportez vos livres et tags pour les transférer'**
  String get exportCsvSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ilwyrm est une application de gestion de bibliothèque personnelle open-source développée par {author}.'**
  String aboutDescription(String author);

  /// No description provided for @sourceCodeOnGithub.
  ///
  /// In fr, this message translates to:
  /// **'Code source disponible sur GitHub : '**
  String get sourceCodeOnGithub;

  /// No description provided for @importOptionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Options d\'importation'**
  String get importOptionsTitle;

  /// No description provided for @importOptionsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez les options pour l\'importation de votre fichier CSV.'**
  String get importOptionsMessage;

  /// No description provided for @fetchCoversTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher les couvertures'**
  String get fetchCoversTitle;

  /// No description provided for @fetchCoversSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en ligne les couvertures manquantes. Plus lent.'**
  String get fetchCoversSubtitle;

  /// No description provided for @chooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier'**
  String get chooseFile;

  /// No description provided for @importInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Importation en cours…'**
  String get importInProgress;

  /// No description provided for @importProgress.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total} livres'**
  String importProgress(int current, int total);

  /// No description provided for @readingFile.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du fichier…'**
  String get readingFile;

  /// No description provided for @sectionExperimental.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités expérimentales'**
  String get sectionExperimental;

  /// No description provided for @libraryAvailabilitySetting.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier la disponibilité en bibliothèque'**
  String get libraryAvailabilitySetting;

  /// No description provided for @experimentalWarning.
  ///
  /// In fr, this message translates to:
  /// **'Expérimental : Peut être instable ou lent.'**
  String get experimentalWarning;

  /// No description provided for @apiUrlTitle.
  ///
  /// In fr, this message translates to:
  /// **'URL de l\'API'**
  String get apiUrlTitle;

  /// No description provided for @notConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Non configurée'**
  String get notConfigured;

  /// No description provided for @configureApiUrl.
  ///
  /// In fr, this message translates to:
  /// **'Configurer l\'URL de l\'API'**
  String get configureApiUrl;

  /// No description provided for @urlLabel.
  ///
  /// In fr, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @statsLibrarySection.
  ///
  /// In fr, this message translates to:
  /// **'Ma bibliothèque'**
  String get statsLibrarySection;

  /// Libellé de la tuile du nombre total de livres
  ///
  /// In fr, this message translates to:
  /// **'Livres'**
  String get statsTotalBooks;

  /// No description provided for @statsReadingSection.
  ///
  /// In fr, this message translates to:
  /// **'Lectures'**
  String get statsReadingSection;

  /// No description provided for @statsHeroLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{livre lu en {year}} other{livres lus en {year}}}'**
  String statsHeroLabel(int count, int year);

  /// No description provided for @statsDeltaVsYear.
  ///
  /// In fr, this message translates to:
  /// **'{delta} par rapport à {year}'**
  String statsDeltaVsYear(String delta, int year);

  /// No description provided for @statsSameAsYear.
  ///
  /// In fr, this message translates to:
  /// **'Autant qu\'en {year}'**
  String statsSameAsYear(int year);

  /// No description provided for @statsPagesRead.
  ///
  /// In fr, this message translates to:
  /// **'Pages lues'**
  String get statsPagesRead;

  /// No description provided for @statsAverageDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée moyenne'**
  String get statsAverageDuration;

  /// No description provided for @statsPerMonthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livres lus par mois'**
  String get statsPerMonthTitle;

  /// No description provided for @statsPerYearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livres lus par année'**
  String get statsPerYearTitle;

  /// No description provided for @statsTopAuthorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Auteurs les plus lus'**
  String get statsTopAuthorsTitle;

  /// No description provided for @statsNoReadingYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune lecture terminée pour l\'instant : termine un livre pour voir tes statistiques de lecture.'**
  String get statsNoReadingYet;

  /// No description provided for @statsBooksCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun livre} one{{count} livre} other{{count} livres}}'**
  String statsBooksCount(int count);

  /// No description provided for @statsShowTable.
  ///
  /// In fr, this message translates to:
  /// **'Afficher en tableau'**
  String get statsShowTable;

  /// No description provided for @statsShowChart.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le graphique'**
  String get statsShowChart;

  /// No description provided for @statsMonthColumn.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get statsMonthColumn;

  /// No description provided for @statsYearColumn.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get statsYearColumn;

  /// No description provided for @statsBooksColumn.
  ///
  /// In fr, this message translates to:
  /// **'Livres'**
  String get statsBooksColumn;

  /// No description provided for @statsChartHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une barre pour voir sa valeur.'**
  String get statsChartHint;

  /// No description provided for @refreshCoversTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir les couvertures (F5)'**
  String get refreshCoversTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
