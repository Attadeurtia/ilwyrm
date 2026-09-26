// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Ilwyrm';

  @override
  String get shelfToRead => 'Por leer';

  @override
  String get shelfReading => 'Leyendo';

  @override
  String get shelfRead => 'Leído';

  @override
  String get tabToRead => 'Por leer';

  @override
  String get tabReading => 'Leyendo';

  @override
  String get tabRead => 'Leídos';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionChangeStatus => 'Cambiar estado';

  @override
  String get actionAddTags => 'Añadir etiquetas';

  @override
  String get actionAddToFavorites => 'Añadir a favoritos';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '$count seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get checkAvailability => 'Comprobar disponibilidad';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sortLabel => 'Ordenar';

  @override
  String get sortDateAdded => 'Fecha de adición';

  @override
  String get sortTitle => 'Título';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get changeViewTooltip => 'Cambiar vista';

  @override
  String get addLabel => 'Añadir';

  @override
  String get addBookTooltip => 'Añadir un libro';

  @override
  String get scanLabel => 'Escanear';

  @override
  String get searchLabel => 'Buscar';

  @override
  String booksUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros actualizados',
      one: '$count libro actualizado',
    );
    return '$_temp0';
  }

  @override
  String booksAddedToFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros añadidos a favoritos',
      one: '$count libro añadido a favoritos',
    );
    return '$_temp0';
  }

  @override
  String get tagsAdded => '¡Etiquetas añadidas!';

  @override
  String get deleteBooksTitle => '¿Eliminar libros?';

  @override
  String deleteBooksMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Seguro que quieres eliminar estos $count libros?',
      one: '¿Seguro que quieres eliminar este libro?',
    );
    return '$_temp0';
  }

  @override
  String booksDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros eliminados',
      one: '$count libro eliminado',
    );
    return '$_temp0';
  }

  @override
  String get tagSearchOrCreateHint => 'Buscar o crear una etiqueta';

  @override
  String get tagCreateTooltip => 'Crear etiqueta';

  @override
  String get noTagsAvailable => 'Todavía no hay etiquetas.';

  @override
  String tagCreateError(String error) {
    return 'No se pudo crear la etiqueta: $error';
  }

  @override
  String get favoritesFilter => 'Favoritos';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get emptyShelf => 'No hay libros aquí';

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get localSearchPrompt => 'Buscar un libro…';

  @override
  String get noBookFound => 'No se ha encontrado ningún libro.';

  @override
  String get favoriteRemove => 'Quitar de favoritos';

  @override
  String get deleteBookTitle => '¿Eliminar el libro?';

  @override
  String deleteBookMessage(String title) {
    return '¿Seguro que quieres eliminar «$title»?';
  }

  @override
  String get coverHint => 'Portada';

  @override
  String get isbnCopied => 'ISBN copiado al portapapeles';

  @override
  String get isbnLabel => 'ISBN:';

  @override
  String get unknownValue => 'Desconocido';

  @override
  String get addedLabel => 'Añadido:';

  @override
  String get summaryTitle => 'Resumen';

  @override
  String get summaryLoading => 'Cargando el resumen…';

  @override
  String get noSummary => 'No hay resumen disponible.';

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String get manageTagsTitle => 'Gestionar etiquetas';

  @override
  String get otherBooksByAuthor => 'Otros libros del autor';

  @override
  String get noOtherBooks => 'No se han encontrado otros libros.';

  @override
  String get startReading => 'Empezar';

  @override
  String get finishReading => 'Terminado';

  @override
  String startedAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Empezado hace $days días',
      one: 'Empezado ayer',
      zero: 'Empezado hoy',
    );
    return '$_temp0';
  }

  @override
  String get readingTimeTitle => 'Tiempo de lectura';

  @override
  String durationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return '$_temp0';
  }

  @override
  String get durationUnknown => 'Duración desconocida';

  @override
  String get libraryAvailabilityTitle => 'Disponibilidad en la biblioteca';

  @override
  String get availableLabel => 'Disponible';

  @override
  String get notAvailableLabel => 'No disponible';

  @override
  String lastChecked(String date) {
    return 'Última comprobación: $date';
  }

  @override
  String get refreshTooltip => 'Actualizar';

  @override
  String get bibliographicInfo => 'Información bibliográfica';

  @override
  String get metaPublisher => 'Editorial';

  @override
  String get metaPublicationDate => 'Fecha de publicación';

  @override
  String get metaPageCount => 'Número de páginas';

  @override
  String get coverUpdated => 'Portada actualizada';

  @override
  String get otherCovers => 'Otras portadas';

  @override
  String get bookAlreadyInLibrary => 'Este libro ya está en tu biblioteca.';

  @override
  String bookAddedToList(String title) {
    return '«$title» añadido a la lista';
  }

  @override
  String get goToBook => 'Ver';

  @override
  String get searchHint => 'Título, autor, ISBN…';

  @override
  String get addManually => 'Añadir manualmente';

  @override
  String get searchTabAll => 'Todos';

  @override
  String sourceError(String source, String error) {
    return '$source: $error';
  }

  @override
  String get searchErrorTimeout => 'Tiempo de espera agotado';

  @override
  String get searchErrorQuota => 'Cuota de la API superada';

  @override
  String get searchErrorForbidden => 'Acceso denegado';

  @override
  String get searchErrorUnavailable => 'No disponible';

  @override
  String get searching => 'Buscando…';

  @override
  String get searchPrompt => 'Introduce un título, un autor o un ISBN.';

  @override
  String get noResultsSomeUnavailable =>
      'Sin resultados (algunas fuentes no están disponibles).';

  @override
  String get noResults => 'No se han encontrado resultados.';

  @override
  String get alreadyInLibrary => 'Ya está en tu biblioteca';

  @override
  String get addToReadingList => 'Añadir a la lista de lectura';

  @override
  String get bookUpdated => '¡Libro actualizado!';

  @override
  String get bookAdded => '¡Libro añadido!';

  @override
  String get duplicateTitle => 'Ya está en tu biblioteca';

  @override
  String get duplicateMessage =>
      'Parece que este libro ya está en tu biblioteca.';

  @override
  String get addAnyway => 'Añadir de todos modos';

  @override
  String get openBook => 'Ver la ficha';

  @override
  String get addCover => 'Añadir una portada';

  @override
  String get editBookTitle => 'Editar libro';

  @override
  String get addBookTitle => 'Añadir un libro';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldTitleRequired => 'Introduce un título';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Editorial';

  @override
  String get fieldPublicationYear => 'Año de publicación';

  @override
  String get fieldPageCount => 'Número de páginas';

  @override
  String get fieldStatus => 'Estado';

  @override
  String get fieldStartDate => 'Fecha de inicio';

  @override
  String get fieldFinishDate => 'Fecha de fin';

  @override
  String get notSet => 'Sin definir';

  @override
  String get roleIgnore => 'Ignorar';

  @override
  String get cameraPermissionDenied =>
      'Permiso de cámara denegado: no se puede hacer la foto.';

  @override
  String get noTextDetectedRetry =>
      'No se ha detectado texto. Inténtalo con una foto más nítida.';

  @override
  String ocrFailed(String error) {
    return 'No se pudo leer la foto: $error';
  }

  @override
  String get scanCoverTitle => 'Escanear una portada';

  @override
  String get scanCoverIntro =>
      'Haz una foto de la portada: el título, el autor y la editorial se extraerán automáticamente.';

  @override
  String get takePhoto => 'Hacer una foto';

  @override
  String get pickFromGallery => 'Elegir de la galería';

  @override
  String get assignLinesHint =>
      'Asigna cada línea. Puedes poner varias líneas en el mismo campo (título o autor en varias líneas).';

  @override
  String get noTextDetected => 'No se ha detectado texto.';

  @override
  String get retake => 'Repetir';

  @override
  String get continueLabel => 'Continuar';

  @override
  String fieldLabelPrefix(String label) {
    return '$label: ';
  }

  @override
  String notAnIsbn(String code) {
    return '«$code» no es un ISBN de libro: ignorado';
  }

  @override
  String isbnAlreadyInLibrary(String isbn) {
    return '«$isbn» ya está en tu biblioteca';
  }

  @override
  String bookScanned(String isbn) {
    return 'Libro escaneado: $isbn';
  }

  @override
  String get scannerTitle => 'Escanear libros';

  @override
  String get scanCoverTooltip => '¿Sin código de barras? Escanea la portada';

  @override
  String get torchTooltip => 'Linterna';

  @override
  String get switchCameraTooltip => 'Cambiar de cámara';

  @override
  String get scannerHint =>
      'Escanea el código de barras de un libro.\n¿Sin código de barras? Usa el icono de portada de arriba.';

  @override
  String duplicatesInLibrary(int count) {
    return '$count ya en tu biblioteca';
  }

  @override
  String finishScanning(int count) {
    return 'Terminar ($count)';
  }

  @override
  String addFailed(String error) {
    return 'No se pudo añadir: $error';
  }

  @override
  String booksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros añadidos',
      one: '$count libro añadido',
    );
    return '$_temp0';
  }

  @override
  String booksSkippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ya presentes omitidos',
      one: '$count ya presente omitido',
    );
    return '$_temp0';
  }

  @override
  String chooseSourceFor(String isbn) {
    return 'Elige una fuente para $isbn';
  }

  @override
  String get confirmAddTitle => 'Confirmar libros';

  @override
  String get addAllTooltip => 'Añadir todo';

  @override
  String get batchSearching =>
      'Buscando en OpenLibrary, la BnF, Inventaire y Google Books…';

  @override
  String barcodeNotFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se han encontrado $count libros por código de barras.',
      one: 'No se ha encontrado $count libro por código de barras.',
    );
    return '$_temp0';
  }

  @override
  String get scanCoverButton => 'Escanear la portada';

  @override
  String sourceTapToChange(String source) {
    return 'Fuente: $source (toca para cambiar)';
  }

  @override
  String sourceLabel(String source) {
    return 'Fuente: $source';
  }

  @override
  String addBooksButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count libros',
      one: 'Añadir $count libro',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ya presentes',
      one: '$count ya presente',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsSubtitle => 'Tus lecturas en cifras';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get noBooksToExport => 'No hay libros que exportar.';

  @override
  String get exportShareText => 'Exportación de mi biblioteca Ilwyrm';

  @override
  String booksExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros exportados.',
      one: '$count libro exportado.',
    );
    return '$_temp0';
  }

  @override
  String exportError(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String booksImported(int imported, int total) {
    return '$imported/$total libros importados.';
  }

  @override
  String rowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count omitidos.',
      one: '$count omitido.',
    );
    return '$_temp0';
  }

  @override
  String get detailsAction => 'Detalles';

  @override
  String importError(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get importErrorsTitle => 'Errores de importación';

  @override
  String get csvErrorEmpty => 'El archivo CSV está vacío.';

  @override
  String csvErrorColumns(int line) {
    return 'Línea $line: número de columnas incorrecto.';
  }

  @override
  String csvErrorRow(int line, String title, String error) {
    return 'Línea $line ($title): $error';
  }

  @override
  String csvErrorUnreadable(String error) {
    return 'No se pudo importar: $error';
  }

  @override
  String get sectionData => 'Datos';

  @override
  String get importCsvTitle => 'Importar un archivo CSV';

  @override
  String get importCsvSubtitle =>
      'Importa tus libros y etiquetas desde un archivo CSV';

  @override
  String get exportCsvTitle => 'Exportar un archivo CSV';

  @override
  String get exportCsvSubtitle =>
      'Exporta tus libros y etiquetas para transferirlos';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutDescription(String author) {
    return 'Ilwyrm es una aplicación de código abierto para gestionar tu biblioteca personal, desarrollada por $author.';
  }

  @override
  String get sourceCodeOnGithub => 'Código fuente en GitHub: ';

  @override
  String get importOptionsTitle => 'Opciones de importación';

  @override
  String get importOptionsMessage =>
      'Elige las opciones para importar tu archivo CSV.';

  @override
  String get fetchCoversTitle => 'Buscar portadas';

  @override
  String get fetchCoversSubtitle =>
      'Busca en línea las portadas que faltan. Más lento.';

  @override
  String get chooseFile => 'Elegir archivo';

  @override
  String get importInProgress => 'Importando…';

  @override
  String importProgress(int current, int total) {
    return '$current / $total libros';
  }

  @override
  String get readingFile => 'Leyendo el archivo…';

  @override
  String get sectionExperimental => 'Funciones experimentales';

  @override
  String get libraryAvailabilitySetting =>
      'Comprobar disponibilidad en la biblioteca';

  @override
  String get experimentalWarning =>
      'Experimental: puede ser inestable o lento.';

  @override
  String get apiUrlTitle => 'URL de la API';

  @override
  String get notConfigured => 'Sin configurar';

  @override
  String get configureApiUrl => 'Configurar la URL de la API';

  @override
  String get urlLabel => 'URL';

  @override
  String get statsLibrarySection => 'Mi biblioteca';

  @override
  String get statsTotalBooks => 'Libros';

  @override
  String get statsReadingSection => 'Lecturas';

  @override
  String statsHeroLabel(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'libros leídos en $year',
      one: 'libro leído en $year',
    );
    return '$_temp0';
  }

  @override
  String statsDeltaVsYear(String delta, int year) {
    return '$delta respecto a $year';
  }

  @override
  String statsSameAsYear(int year) {
    return 'Igual que en $year';
  }

  @override
  String get statsPagesRead => 'Páginas leídas';

  @override
  String get statsAverageDuration => 'Duración media';

  @override
  String get statsPerMonthTitle => 'Libros leídos por mes';

  @override
  String get statsPerYearTitle => 'Libros leídos por año';

  @override
  String get statsTopAuthorsTitle => 'Autores más leídos';

  @override
  String get statsNoReadingYet =>
      'Aún no has terminado ningún libro: termina uno para ver tus estadísticas de lectura.';

  @override
  String statsBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros',
      one: '$count libro',
      zero: 'Ningún libro',
    );
    return '$_temp0';
  }

  @override
  String get statsShowTable => 'Ver como tabla';

  @override
  String get statsShowChart => 'Ver gráfico';

  @override
  String get statsMonthColumn => 'Mes';

  @override
  String get statsYearColumn => 'Año';

  @override
  String get statsBooksColumn => 'Libros';

  @override
  String get statsChartHint => 'Toca una barra para ver su valor.';

  @override
  String get refreshCoversTooltip => 'Actualizar portadas (F5)';
}
