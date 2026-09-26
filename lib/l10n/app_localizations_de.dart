// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Ilwyrm';

  @override
  String get shelfToRead => 'Zu lesen';

  @override
  String get shelfReading => 'Wird gelesen';

  @override
  String get shelfRead => 'Gelesen';

  @override
  String get tabToRead => 'Zu lesen';

  @override
  String get tabReading => 'Aktuell';

  @override
  String get tabRead => 'Gelesen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionChangeStatus => 'Status ändern';

  @override
  String get actionAddTags => 'Tags hinzufügen';

  @override
  String get actionAddToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get checkAvailability => 'Verfügbarkeit prüfen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sortLabel => 'Sortieren';

  @override
  String get sortDateAdded => 'Hinzugefügt am';

  @override
  String get sortTitle => 'Titel';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get changeViewTooltip => 'Ansicht wechseln';

  @override
  String get addLabel => 'Hinzufügen';

  @override
  String get addBookTooltip => 'Buch hinzufügen';

  @override
  String get scanLabel => 'Scannen';

  @override
  String get searchLabel => 'Suche';

  @override
  String booksUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher aktualisiert',
      one: '$count Buch aktualisiert',
    );
    return '$_temp0';
  }

  @override
  String booksAddedToFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher zu den Favoriten hinzugefügt',
      one: '$count Buch zu den Favoriten hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get tagsAdded => 'Tags hinzugefügt!';

  @override
  String get deleteBooksTitle => 'Bücher löschen?';

  @override
  String deleteBooksMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Möchtest du diese $count Bücher wirklich löschen?',
      one: 'Möchtest du dieses Buch wirklich löschen?',
    );
    return '$_temp0';
  }

  @override
  String booksDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher gelöscht',
      one: '$count Buch gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get tagSearchOrCreateHint => 'Tag suchen oder erstellen';

  @override
  String get tagCreateTooltip => 'Tag erstellen';

  @override
  String get noTagsAvailable => 'Noch keine Tags.';

  @override
  String tagCreateError(String error) {
    return 'Tag konnte nicht erstellt werden: $error';
  }

  @override
  String get favoritesFilter => 'Favoriten';

  @override
  String genericError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get emptyShelf => 'Keine Bücher hier';

  @override
  String get unknownAuthor => 'Unbekannter Autor';

  @override
  String get localSearchPrompt => 'Nach einem Buch suchen…';

  @override
  String get noBookFound => 'Kein Buch gefunden.';

  @override
  String get favoriteRemove => 'Aus Favoriten entfernen';

  @override
  String get deleteBookTitle => 'Buch löschen?';

  @override
  String deleteBookMessage(String title) {
    return 'Möchtest du „$title“ wirklich löschen?';
  }

  @override
  String get coverHint => 'Cover';

  @override
  String get isbnCopied => 'ISBN in die Zwischenablage kopiert';

  @override
  String get isbnLabel => 'ISBN:';

  @override
  String get unknownValue => 'Unbekannt';

  @override
  String get addedLabel => 'Hinzugefügt:';

  @override
  String get summaryTitle => 'Zusammenfassung';

  @override
  String get summaryLoading => 'Zusammenfassung wird geladen…';

  @override
  String get noSummary => 'Keine Zusammenfassung verfügbar.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get manageTagsTitle => 'Tags verwalten';

  @override
  String get otherBooksByAuthor => 'Weitere Bücher des Autors';

  @override
  String get noOtherBooks => 'Keine weiteren Bücher gefunden.';

  @override
  String get startReading => 'Beginnen';

  @override
  String get finishReading => 'Fertig gelesen';

  @override
  String startedAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vor $days Tagen begonnen',
      one: 'Gestern begonnen',
      zero: 'Heute begonnen',
    );
    return '$_temp0';
  }

  @override
  String get readingTimeTitle => 'Lesedauer';

  @override
  String durationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '$days Tag',
    );
    return '$_temp0';
  }

  @override
  String get durationUnknown => 'Unbekannte Dauer';

  @override
  String get libraryAvailabilityTitle => 'Verfügbarkeit in der Bibliothek';

  @override
  String get availableLabel => 'Verfügbar';

  @override
  String get notAvailableLabel => 'Nicht verfügbar';

  @override
  String lastChecked(String date) {
    return 'Zuletzt geprüft: $date';
  }

  @override
  String get refreshTooltip => 'Aktualisieren';

  @override
  String get bibliographicInfo => 'Bibliografische Angaben';

  @override
  String get metaPublisher => 'Verlag';

  @override
  String get metaPublicationDate => 'Erscheinungsdatum';

  @override
  String get metaPageCount => 'Seitenzahl';

  @override
  String get coverUpdated => 'Cover aktualisiert';

  @override
  String get otherCovers => 'Weitere Cover';

  @override
  String get bookAlreadyInLibrary =>
      'Dieses Buch ist bereits in deiner Bibliothek.';

  @override
  String bookAddedToList(String title) {
    return '„$title“ zur Liste hinzugefügt!';
  }

  @override
  String get goToBook => 'Ansehen';

  @override
  String get searchHint => 'Titel, Autor, ISBN…';

  @override
  String get addManually => 'Manuell hinzufügen';

  @override
  String get searchTabAll => 'Alle';

  @override
  String sourceError(String source, String error) {
    return '$source: $error';
  }

  @override
  String get searchErrorTimeout => 'Zeitüberschreitung';

  @override
  String get searchErrorQuota => 'API-Kontingent überschritten';

  @override
  String get searchErrorForbidden => 'Zugriff verweigert';

  @override
  String get searchErrorUnavailable => 'Nicht verfügbar';

  @override
  String get searching => 'Suche läuft…';

  @override
  String get searchPrompt => 'Gib einen Titel, einen Autor oder eine ISBN ein.';

  @override
  String get noResultsSomeUnavailable =>
      'Keine Ergebnisse (einige Quellen sind nicht verfügbar).';

  @override
  String get noResults => 'Keine Ergebnisse gefunden.';

  @override
  String get alreadyInLibrary => 'Bereits in deiner Bibliothek';

  @override
  String get addToReadingList => 'Zur Leseliste hinzufügen';

  @override
  String get bookUpdated => 'Buch aktualisiert!';

  @override
  String get bookAdded => 'Buch hinzugefügt!';

  @override
  String get duplicateTitle => 'Bereits in deiner Bibliothek';

  @override
  String get duplicateMessage =>
      'Dieses Buch scheint bereits in deiner Bibliothek zu sein.';

  @override
  String get addAnyway => 'Trotzdem hinzufügen';

  @override
  String get openBook => 'Buch öffnen';

  @override
  String get addCover => 'Cover hinzufügen';

  @override
  String get editBookTitle => 'Buch bearbeiten';

  @override
  String get addBookTitle => 'Buch hinzufügen';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldTitleRequired => 'Bitte gib einen Titel ein';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Verlag';

  @override
  String get fieldPublicationYear => 'Erscheinungsjahr';

  @override
  String get fieldPageCount => 'Seitenzahl';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldStartDate => 'Startdatum';

  @override
  String get fieldFinishDate => 'Enddatum';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get roleIgnore => 'Ignorieren';

  @override
  String get cameraPermissionDenied =>
      'Kamerazugriff verweigert – Foto nicht möglich.';

  @override
  String get noTextDetectedRetry =>
      'Kein Text erkannt. Versuche es mit einem schärferen Foto.';

  @override
  String ocrFailed(String error) {
    return 'Foto konnte nicht gelesen werden: $error';
  }

  @override
  String get scanCoverTitle => 'Cover scannen';

  @override
  String get scanCoverIntro =>
      'Fotografiere das Cover: Titel, Autor und Verlag werden automatisch erkannt.';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get pickFromGallery => 'Aus der Galerie wählen';

  @override
  String get assignLinesHint =>
      'Ordne jede Zeile zu. Mehrere Zeilen können in dasselbe Feld (Titel oder Autor über mehrere Zeilen).';

  @override
  String get noTextDetected => 'Kein Text erkannt.';

  @override
  String get retake => 'Neu aufnehmen';

  @override
  String get continueLabel => 'Weiter';

  @override
  String fieldLabelPrefix(String label) {
    return '$label: ';
  }

  @override
  String notAnIsbn(String code) {
    return '„$code“ ist keine Buch-ISBN: ignoriert';
  }

  @override
  String isbnAlreadyInLibrary(String isbn) {
    return '„$isbn“ ist bereits in deiner Bibliothek';
  }

  @override
  String bookScanned(String isbn) {
    return 'Buch gescannt: $isbn';
  }

  @override
  String get scannerTitle => 'Bücher scannen';

  @override
  String get scanCoverTooltip => 'Kein Barcode? Cover scannen';

  @override
  String get torchTooltip => 'Taschenlampe';

  @override
  String get switchCameraTooltip => 'Kamera wechseln';

  @override
  String get scannerHint =>
      'Scanne den Barcode eines Buchs.\nKein Barcode? Nutze oben das Cover-Symbol.';

  @override
  String duplicatesInLibrary(int count) {
    return '$count bereits in deiner Bibliothek';
  }

  @override
  String finishScanning(int count) {
    return 'Fertig ($count)';
  }

  @override
  String addFailed(String error) {
    return 'Hinzufügen fehlgeschlagen: $error';
  }

  @override
  String booksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher hinzugefügt',
      one: '$count Buch hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String booksSkippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bereits vorhanden, übersprungen',
    );
    return '$_temp0';
  }

  @override
  String chooseSourceFor(String isbn) {
    return 'Quelle für $isbn wählen';
  }

  @override
  String get confirmAddTitle => 'Hinzufügen bestätigen';

  @override
  String get addAllTooltip => 'Alle hinzufügen';

  @override
  String get batchSearching =>
      'Suche in OpenLibrary, BnF, Inventaire und Google Books…';

  @override
  String barcodeNotFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher wurden per Barcode nicht gefunden.',
      one: '$count Buch wurde per Barcode nicht gefunden.',
    );
    return '$_temp0';
  }

  @override
  String get scanCoverButton => 'Cover scannen';

  @override
  String sourceTapToChange(String source) {
    return 'Quelle: $source (zum Ändern tippen)';
  }

  @override
  String sourceLabel(String source) {
    return 'Quelle: $source';
  }

  @override
  String addBooksButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher hinzufügen',
      one: '$count Buch hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bereits vorhanden',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get statsSubtitle => 'Deine Lektüre in Zahlen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get noBooksToExport => 'Keine Bücher zum Exportieren.';

  @override
  String get exportShareText => 'Export meiner Ilwyrm-Bibliothek';

  @override
  String booksExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher exportiert.',
      one: '$count Buch exportiert.',
    );
    return '$_temp0';
  }

  @override
  String exportError(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String booksImported(int imported, int total) {
    return '$imported/$total Bücher importiert.';
  }

  @override
  String rowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count übersprungen.',
    );
    return '$_temp0';
  }

  @override
  String get detailsAction => 'Details';

  @override
  String importError(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get importErrorsTitle => 'Importfehler';

  @override
  String get csvErrorEmpty => 'Die CSV-Datei ist leer.';

  @override
  String csvErrorColumns(int line) {
    return 'Zeile $line: falsche Spaltenanzahl.';
  }

  @override
  String csvErrorRow(int line, String title, String error) {
    return 'Zeile $line ($title): $error';
  }

  @override
  String csvErrorUnreadable(String error) {
    return 'Import nicht möglich: $error';
  }

  @override
  String get sectionData => 'Daten';

  @override
  String get importCsvTitle => 'CSV-Datei importieren';

  @override
  String get importCsvSubtitle =>
      'Bücher und Tags aus einer CSV-Datei importieren';

  @override
  String get exportCsvTitle => 'CSV-Datei exportieren';

  @override
  String get exportCsvSubtitle => 'Bücher und Tags zum Übertragen exportieren';

  @override
  String get aboutTitle => 'Über';

  @override
  String aboutDescription(String author) {
    return 'Ilwyrm ist eine Open-Source-App für deine persönliche Bibliothek, entwickelt von $author.';
  }

  @override
  String get sourceCodeOnGithub => 'Quellcode auf GitHub: ';

  @override
  String get importOptionsTitle => 'Importoptionen';

  @override
  String get importOptionsMessage =>
      'Wähle die Optionen für den Import deiner CSV-Datei.';

  @override
  String get fetchCoversTitle => 'Cover suchen';

  @override
  String get fetchCoversSubtitle => 'Sucht fehlende Cover online. Langsamer.';

  @override
  String get chooseFile => 'Datei wählen';

  @override
  String get importInProgress => 'Import läuft…';

  @override
  String importProgress(int current, int total) {
    return '$current / $total Bücher';
  }

  @override
  String get readingFile => 'Datei wird gelesen…';

  @override
  String get sectionExperimental => 'Experimentelle Funktionen';

  @override
  String get libraryAvailabilitySetting =>
      'Verfügbarkeit in der Bibliothek prüfen';

  @override
  String get experimentalWarning =>
      'Experimentell: kann instabil oder langsam sein.';

  @override
  String get apiUrlTitle => 'API-URL';

  @override
  String get notConfigured => 'Nicht konfiguriert';

  @override
  String get configureApiUrl => 'API-URL festlegen';

  @override
  String get urlLabel => 'URL';

  @override
  String get statsLibrarySection => 'Meine Bibliothek';

  @override
  String get statsTotalBooks => 'Bücher';

  @override
  String get statsReadingSection => 'Lektüre';

  @override
  String statsHeroLabel(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bücher $year gelesen',
      one: 'Buch $year gelesen',
    );
    return '$_temp0';
  }

  @override
  String statsDeltaVsYear(String delta, int year) {
    return '$delta gegenüber $year';
  }

  @override
  String statsSameAsYear(int year) {
    return 'Gleich viele wie $year';
  }

  @override
  String get statsPagesRead => 'Gelesene Seiten';

  @override
  String get statsAverageDuration => 'Durchschnittliche Dauer';

  @override
  String get statsPerMonthTitle => 'Gelesene Bücher pro Monat';

  @override
  String get statsPerYearTitle => 'Gelesene Bücher pro Jahr';

  @override
  String get statsTopAuthorsTitle => 'Meistgelesene Autoren';

  @override
  String get statsNoReadingYet =>
      'Noch keine beendeten Bücher: Beende ein Buch, um deine Lesestatistiken zu sehen.';

  @override
  String statsBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher',
      one: '$count Buch',
      zero: 'Keine Bücher',
    );
    return '$_temp0';
  }

  @override
  String get statsShowTable => 'Als Tabelle anzeigen';

  @override
  String get statsShowChart => 'Diagramm anzeigen';

  @override
  String get statsMonthColumn => 'Monat';

  @override
  String get statsYearColumn => 'Jahr';

  @override
  String get statsBooksColumn => 'Bücher';

  @override
  String get statsChartHint =>
      'Tippe auf einen Balken, um seinen Wert zu sehen.';
}
