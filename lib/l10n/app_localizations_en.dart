// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ilwyrm';

  @override
  String get shelfToRead => 'To read';

  @override
  String get shelfReading => 'Reading';

  @override
  String get shelfRead => 'Read';

  @override
  String get tabToRead => 'To read';

  @override
  String get tabReading => 'Reading';

  @override
  String get tabRead => 'Read';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSave => 'Save';

  @override
  String get actionChangeStatus => 'Change status';

  @override
  String get actionAddTags => 'Add tags';

  @override
  String get actionAddToFavorites => 'Add to favorites';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String get checkAvailability => 'Check availability';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortDateAdded => 'Date added';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortAuthor => 'Author';

  @override
  String get changeViewTooltip => 'Change view';

  @override
  String get addLabel => 'Add';

  @override
  String get addBookTooltip => 'Add a book';

  @override
  String get scanLabel => 'Scan';

  @override
  String get searchLabel => 'Search';

  @override
  String booksUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books updated',
      one: '$count book updated',
    );
    return '$_temp0';
  }

  @override
  String booksAddedToFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books added to favorites',
      one: '$count book added to favorites',
    );
    return '$_temp0';
  }

  @override
  String get tagsAdded => 'Tags added!';

  @override
  String get deleteBooksTitle => 'Delete books?';

  @override
  String deleteBooksMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Do you really want to delete these $count books?',
      one: 'Do you really want to delete this book?',
    );
    return '$_temp0';
  }

  @override
  String booksDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books deleted',
      one: '$count book deleted',
    );
    return '$_temp0';
  }

  @override
  String get tagSearchOrCreateHint => 'Search or create a tag';

  @override
  String get tagCreateTooltip => 'Create tag';

  @override
  String get noTagsAvailable => 'No tags yet.';

  @override
  String tagCreateError(String error) {
    return 'Could not create the tag: $error';
  }

  @override
  String get favoritesFilter => 'Favorites';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get emptyShelf => 'No books here';

  @override
  String get unknownAuthor => 'Unknown author';

  @override
  String get localSearchPrompt => 'Search for a book…';

  @override
  String get noBookFound => 'No book found.';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get deleteBookTitle => 'Delete book?';

  @override
  String deleteBookMessage(String title) {
    return 'Do you really want to delete “$title”?';
  }

  @override
  String get coverHint => 'Cover';

  @override
  String get isbnCopied => 'ISBN copied to clipboard';

  @override
  String get isbnLabel => 'ISBN:';

  @override
  String get unknownValue => 'Unknown';

  @override
  String get addedLabel => 'Added:';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summaryLoading => 'Loading summary…';

  @override
  String get noSummary => 'No summary available.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get manageTagsTitle => 'Manage tags';

  @override
  String get otherBooksByAuthor => 'More by this author';

  @override
  String get noOtherBooks => 'No other books found.';

  @override
  String get startReading => 'Start reading';

  @override
  String get finishReading => 'Finished';

  @override
  String startedAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Started $days days ago',
      one: 'Started yesterday',
      zero: 'Started today',
    );
    return '$_temp0';
  }

  @override
  String get readingTimeTitle => 'Reading time';

  @override
  String durationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String get durationUnknown => 'Unknown duration';

  @override
  String get libraryAvailabilityTitle => 'Library availability';

  @override
  String get availableLabel => 'Available';

  @override
  String get notAvailableLabel => 'Not available';

  @override
  String lastChecked(String date) {
    return 'Last checked: $date';
  }

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get bibliographicInfo => 'Bibliographic details';

  @override
  String get metaPublisher => 'Publisher';

  @override
  String get metaPublicationDate => 'Publication date';

  @override
  String get metaPageCount => 'Pages';

  @override
  String get coverUpdated => 'Cover updated';

  @override
  String get otherCovers => 'Other covers';

  @override
  String get bookAlreadyInLibrary => 'This book is already in your library.';

  @override
  String bookAddedToList(String title) {
    return '“$title” added to your list!';
  }

  @override
  String get goToBook => 'View';

  @override
  String get searchHint => 'Title, author, ISBN…';

  @override
  String get addManually => 'Add manually';

  @override
  String get searchTabAll => 'All';

  @override
  String sourceError(String source, String error) {
    return '$source: $error';
  }

  @override
  String get searchErrorTimeout => 'Timed out';

  @override
  String get searchErrorQuota => 'API quota exceeded';

  @override
  String get searchErrorForbidden => 'Access denied';

  @override
  String get searchErrorUnavailable => 'Unavailable';

  @override
  String get searching => 'Searching…';

  @override
  String get searchPrompt => 'Enter a title, an author or an ISBN.';

  @override
  String get noResultsSomeUnavailable =>
      'No results (some sources are unavailable).';

  @override
  String get noResults => 'No results found.';

  @override
  String get alreadyInLibrary => 'Already in your library';

  @override
  String get addToReadingList => 'Add to reading list';

  @override
  String get bookUpdated => 'Book updated!';

  @override
  String get bookAdded => 'Book added!';

  @override
  String get duplicateTitle => 'Already in your library';

  @override
  String get duplicateMessage =>
      'This book already seems to be in your library.';

  @override
  String get addAnyway => 'Add anyway';

  @override
  String get openBook => 'Open book';

  @override
  String get addCover => 'Add a cover';

  @override
  String get editBookTitle => 'Edit book';

  @override
  String get addBookTitle => 'Add a book';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldTitleRequired => 'Please enter a title';

  @override
  String get fieldAuthor => 'Author';

  @override
  String get fieldPublisher => 'Publisher';

  @override
  String get fieldPublicationYear => 'Publication year';

  @override
  String get fieldPageCount => 'Number of pages';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldStartDate => 'Start date';

  @override
  String get fieldFinishDate => 'End date';

  @override
  String get notSet => 'Not set';

  @override
  String get roleIgnore => 'Ignore';

  @override
  String get cameraPermissionDenied =>
      'Camera permission denied — cannot take a photo.';

  @override
  String get noTextDetectedRetry =>
      'No text detected. Try again with a sharper photo.';

  @override
  String ocrFailed(String error) {
    return 'Could not read the photo: $error';
  }

  @override
  String get scanCoverTitle => 'Scan a cover';

  @override
  String get scanCoverIntro =>
      'Take a photo of the cover: the title, author and publisher will be extracted automatically.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get assignLinesHint =>
      'Assign each line. Several lines can go into the same field (a title or author spread over several lines).';

  @override
  String get noTextDetected => 'No text detected.';

  @override
  String get retake => 'Retake';

  @override
  String get continueLabel => 'Continue';

  @override
  String fieldLabelPrefix(String label) {
    return '$label: ';
  }

  @override
  String notAnIsbn(String code) {
    return '“$code” is not a book ISBN: ignored';
  }

  @override
  String isbnAlreadyInLibrary(String isbn) {
    return '“$isbn” is already in your library';
  }

  @override
  String bookScanned(String isbn) {
    return 'Book scanned: $isbn';
  }

  @override
  String get scannerTitle => 'Scan books';

  @override
  String get scanCoverTooltip => 'No barcode? Scan the cover';

  @override
  String get torchTooltip => 'Flashlight';

  @override
  String get switchCameraTooltip => 'Switch camera';

  @override
  String get scannerHint =>
      'Scan a book\'s barcode.\nNo barcode? Use the cover icon at the top.';

  @override
  String duplicatesInLibrary(int count) {
    return '$count already in your library';
  }

  @override
  String finishScanning(int count) {
    return 'Done ($count)';
  }

  @override
  String addFailed(String error) {
    return 'Could not add: $error';
  }

  @override
  String booksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books added',
      one: '$count book added',
    );
    return '$_temp0';
  }

  @override
  String booksSkippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already in your library skipped',
    );
    return '$_temp0';
  }

  @override
  String chooseSourceFor(String isbn) {
    return 'Choose a source for $isbn';
  }

  @override
  String get confirmAddTitle => 'Confirm books';

  @override
  String get addAllTooltip => 'Add all';

  @override
  String get batchSearching =>
      'Searching OpenLibrary, BnF, Inventaire and Google Books…';

  @override
  String barcodeNotFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Couldn\'t find $count books by barcode.',
      one: 'Couldn\'t find $count book by barcode.',
    );
    return '$_temp0';
  }

  @override
  String get scanCoverButton => 'Scan the cover';

  @override
  String sourceTapToChange(String source) {
    return 'Source: $source (tap to change)';
  }

  @override
  String sourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String addBooksButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count books',
      one: 'Add $count book',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already in your library',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsSubtitle => 'Your reading in numbers';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get noBooksToExport => 'No books to export.';

  @override
  String get exportShareText => 'My Ilwyrm library export';

  @override
  String booksExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books exported.',
      one: '$count book exported.',
    );
    return '$_temp0';
  }

  @override
  String exportError(String error) {
    return 'Export failed: $error';
  }

  @override
  String booksImported(int imported, int total) {
    return '$imported/$total books imported.';
  }

  @override
  String rowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skipped.',
    );
    return '$_temp0';
  }

  @override
  String get detailsAction => 'Details';

  @override
  String importError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get importErrorsTitle => 'Import errors';

  @override
  String get csvErrorEmpty => 'The CSV file is empty.';

  @override
  String csvErrorColumns(int line) {
    return 'Line $line: wrong number of columns.';
  }

  @override
  String csvErrorRow(int line, String title, String error) {
    return 'Line $line ($title): $error';
  }

  @override
  String csvErrorUnreadable(String error) {
    return 'Could not import: $error';
  }

  @override
  String get sectionData => 'Data';

  @override
  String get importCsvTitle => 'Import a CSV file';

  @override
  String get importCsvSubtitle => 'Import your books and tags from a CSV file';

  @override
  String get exportCsvTitle => 'Export a CSV file';

  @override
  String get exportCsvSubtitle =>
      'Export your books and tags to move them elsewhere';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutDescription(String author) {
    return 'Ilwyrm is an open-source personal library app developed by $author.';
  }

  @override
  String get sourceCodeOnGithub => 'Source code on GitHub: ';

  @override
  String get importOptionsTitle => 'Import options';

  @override
  String get importOptionsMessage =>
      'Choose the options for importing your CSV file.';

  @override
  String get fetchCoversTitle => 'Look up covers';

  @override
  String get fetchCoversSubtitle => 'Looks up missing covers online. Slower.';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get importInProgress => 'Importing…';

  @override
  String importProgress(int current, int total) {
    return '$current / $total books';
  }

  @override
  String get readingFile => 'Reading file…';

  @override
  String get sectionExperimental => 'Experimental features';

  @override
  String get libraryAvailabilitySetting => 'Check library availability';

  @override
  String get experimentalWarning => 'Experimental: may be unstable or slow.';

  @override
  String get apiUrlTitle => 'API URL';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get configureApiUrl => 'Set the API URL';

  @override
  String get urlLabel => 'URL';

  @override
  String get statsLibrarySection => 'My library';

  @override
  String get statsTotalBooks => 'Books';

  @override
  String get statsReadingSection => 'Reading';

  @override
  String statsHeroLabel(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'books read in $year',
      one: 'book read in $year',
    );
    return '$_temp0';
  }

  @override
  String statsDeltaVsYear(String delta, int year) {
    return '$delta vs $year';
  }

  @override
  String statsSameAsYear(int year) {
    return 'Same as $year';
  }

  @override
  String get statsPagesRead => 'Pages read';

  @override
  String get statsAverageDuration => 'Average time';

  @override
  String get statsPerMonthTitle => 'Books read per month';

  @override
  String get statsPerYearTitle => 'Books read per year';

  @override
  String get statsTopAuthorsTitle => 'Most-read authors';

  @override
  String get statsNoReadingYet =>
      'No finished books yet: finish a book to see your reading statistics.';

  @override
  String statsBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '$count book',
      zero: 'No books',
    );
    return '$_temp0';
  }

  @override
  String get statsShowTable => 'Show as table';

  @override
  String get statsShowChart => 'Show chart';

  @override
  String get statsMonthColumn => 'Month';

  @override
  String get statsYearColumn => 'Year';

  @override
  String get statsBooksColumn => 'Books';

  @override
  String get statsChartHint => 'Tap a bar to see its value.';

  @override
  String get refreshCoversTooltip => 'Refresh covers (F5)';
}
