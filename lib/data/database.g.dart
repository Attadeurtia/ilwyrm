// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorTextMeta = const VerificationMeta(
    'authorText',
  );
  @override
  late final GeneratedColumn<String> authorText = GeneratedColumn<String>(
    'author_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _openlibraryKeyMeta = const VerificationMeta(
    'openlibraryKey',
  );
  @override
  late final GeneratedColumn<String> openlibraryKey = GeneratedColumn<String>(
    'openlibrary_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finnaKeyMeta = const VerificationMeta(
    'finnaKey',
  );
  @override
  late final GeneratedColumn<String> finnaKey = GeneratedColumn<String>(
    'finna_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inventaireIdMeta = const VerificationMeta(
    'inventaireId',
  );
  @override
  late final GeneratedColumn<String> inventaireId = GeneratedColumn<String>(
    'inventaire_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _librarythingKeyMeta = const VerificationMeta(
    'librarythingKey',
  );
  @override
  late final GeneratedColumn<String> librarythingKey = GeneratedColumn<String>(
    'librarything_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goodreadsKeyMeta = const VerificationMeta(
    'goodreadsKey',
  );
  @override
  late final GeneratedColumn<String> goodreadsKey = GeneratedColumn<String>(
    'goodreads_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bnfIdMeta = const VerificationMeta('bnfId');
  @override
  late final GeneratedColumn<String> bnfId = GeneratedColumn<String>(
    'bnf_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viafMeta = const VerificationMeta('viaf');
  @override
  late final GeneratedColumn<String> viaf = GeneratedColumn<String>(
    'viaf',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wikidataMeta = const VerificationMeta(
    'wikidata',
  );
  @override
  late final GeneratedColumn<String> wikidata = GeneratedColumn<String>(
    'wikidata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _asinMeta = const VerificationMeta('asin');
  @override
  late final GeneratedColumn<String> asin = GeneratedColumn<String>(
    'asin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aasinMeta = const VerificationMeta('aasin');
  @override
  late final GeneratedColumn<String> aasin = GeneratedColumn<String>(
    'aasin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isfdbMeta = const VerificationMeta('isfdb');
  @override
  late final GeneratedColumn<String> isfdb = GeneratedColumn<String>(
    'isfdb',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbn10Meta = const VerificationMeta('isbn10');
  @override
  late final GeneratedColumn<String> isbn10 = GeneratedColumn<String>(
    'isbn_10',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbn13Meta = const VerificationMeta('isbn13');
  @override
  late final GeneratedColumn<String> isbn13 = GeneratedColumn<String>(
    'isbn_13',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oclcNumberMeta = const VerificationMeta(
    'oclcNumber',
  );
  @override
  late final GeneratedColumn<String> oclcNumber = GeneratedColumn<String>(
    'oclc_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicationYearMeta = const VerificationMeta(
    'publicationYear',
  );
  @override
  late final GeneratedColumn<int> publicationYear = GeneratedColumn<int>(
    'publication_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishDateMeta = const VerificationMeta(
    'finishDate',
  );
  @override
  late final GeneratedColumn<DateTime> finishDate = GeneratedColumn<DateTime>(
    'finish_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stoppedDateMeta = const VerificationMeta(
    'stoppedDate',
  );
  @override
  late final GeneratedColumn<DateTime> stoppedDate = GeneratedColumn<DateTime>(
    'stopped_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverIdMeta = const VerificationMeta(
    'coverId',
  );
  @override
  late final GeneratedColumn<int> coverId = GeneratedColumn<int>(
    'cover_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewNameMeta = const VerificationMeta(
    'reviewName',
  );
  @override
  late final GeneratedColumn<String> reviewName = GeneratedColumn<String>(
    'review_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewCwMeta = const VerificationMeta(
    'reviewCw',
  );
  @override
  late final GeneratedColumn<String> reviewCw = GeneratedColumn<String>(
    'review_cw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewContentMeta = const VerificationMeta(
    'reviewContent',
  );
  @override
  late final GeneratedColumn<String> reviewContent = GeneratedColumn<String>(
    'review_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewPublishedMeta = const VerificationMeta(
    'reviewPublished',
  );
  @override
  late final GeneratedColumn<DateTime> reviewPublished =
      GeneratedColumn<DateTime>(
        'review_published',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shelfMeta = const VerificationMeta('shelf');
  @override
  late final GeneratedColumn<String> shelf = GeneratedColumn<String>(
    'shelf',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('to-read'),
  );
  static const VerificationMeta _shelfNameMeta = const VerificationMeta(
    'shelfName',
  );
  @override
  late final GeneratedColumn<String> shelfName = GeneratedColumn<String>(
    'shelf_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfDateMeta = const VerificationMeta(
    'shelfDate',
  );
  @override
  late final GeneratedColumn<DateTime> shelfDate = GeneratedColumn<DateTime>(
    'shelf_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateModifiedMeta = const VerificationMeta(
    'dateModified',
  );
  @override
  late final GeneratedColumn<DateTime> dateModified = GeneratedColumn<DateTime>(
    'date_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    authorText,
    remoteId,
    openlibraryKey,
    finnaKey,
    inventaireId,
    librarythingKey,
    goodreadsKey,
    bnfId,
    viaf,
    wikidata,
    asin,
    aasin,
    isfdb,
    isbn10,
    isbn13,
    oclcNumber,
    pageCount,
    currentPage,
    publisher,
    publicationYear,
    startDate,
    finishDate,
    stoppedDate,
    coverId,
    coverUrl,
    coverPath,
    rating,
    reviewName,
    reviewCw,
    reviewContent,
    reviewPublished,
    shelf,
    shelfName,
    shelfDate,
    isFavorite,
    dateAdded,
    dateModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author_text')) {
      context.handle(
        _authorTextMeta,
        authorText.isAcceptableOrUnknown(data['author_text']!, _authorTextMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('openlibrary_key')) {
      context.handle(
        _openlibraryKeyMeta,
        openlibraryKey.isAcceptableOrUnknown(
          data['openlibrary_key']!,
          _openlibraryKeyMeta,
        ),
      );
    }
    if (data.containsKey('finna_key')) {
      context.handle(
        _finnaKeyMeta,
        finnaKey.isAcceptableOrUnknown(data['finna_key']!, _finnaKeyMeta),
      );
    }
    if (data.containsKey('inventaire_id')) {
      context.handle(
        _inventaireIdMeta,
        inventaireId.isAcceptableOrUnknown(
          data['inventaire_id']!,
          _inventaireIdMeta,
        ),
      );
    }
    if (data.containsKey('librarything_key')) {
      context.handle(
        _librarythingKeyMeta,
        librarythingKey.isAcceptableOrUnknown(
          data['librarything_key']!,
          _librarythingKeyMeta,
        ),
      );
    }
    if (data.containsKey('goodreads_key')) {
      context.handle(
        _goodreadsKeyMeta,
        goodreadsKey.isAcceptableOrUnknown(
          data['goodreads_key']!,
          _goodreadsKeyMeta,
        ),
      );
    }
    if (data.containsKey('bnf_id')) {
      context.handle(
        _bnfIdMeta,
        bnfId.isAcceptableOrUnknown(data['bnf_id']!, _bnfIdMeta),
      );
    }
    if (data.containsKey('viaf')) {
      context.handle(
        _viafMeta,
        viaf.isAcceptableOrUnknown(data['viaf']!, _viafMeta),
      );
    }
    if (data.containsKey('wikidata')) {
      context.handle(
        _wikidataMeta,
        wikidata.isAcceptableOrUnknown(data['wikidata']!, _wikidataMeta),
      );
    }
    if (data.containsKey('asin')) {
      context.handle(
        _asinMeta,
        asin.isAcceptableOrUnknown(data['asin']!, _asinMeta),
      );
    }
    if (data.containsKey('aasin')) {
      context.handle(
        _aasinMeta,
        aasin.isAcceptableOrUnknown(data['aasin']!, _aasinMeta),
      );
    }
    if (data.containsKey('isfdb')) {
      context.handle(
        _isfdbMeta,
        isfdb.isAcceptableOrUnknown(data['isfdb']!, _isfdbMeta),
      );
    }
    if (data.containsKey('isbn_10')) {
      context.handle(
        _isbn10Meta,
        isbn10.isAcceptableOrUnknown(data['isbn_10']!, _isbn10Meta),
      );
    }
    if (data.containsKey('isbn_13')) {
      context.handle(
        _isbn13Meta,
        isbn13.isAcceptableOrUnknown(data['isbn_13']!, _isbn13Meta),
      );
    }
    if (data.containsKey('oclc_number')) {
      context.handle(
        _oclcNumberMeta,
        oclcNumber.isAcceptableOrUnknown(data['oclc_number']!, _oclcNumberMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('publication_year')) {
      context.handle(
        _publicationYearMeta,
        publicationYear.isAcceptableOrUnknown(
          data['publication_year']!,
          _publicationYearMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('finish_date')) {
      context.handle(
        _finishDateMeta,
        finishDate.isAcceptableOrUnknown(data['finish_date']!, _finishDateMeta),
      );
    }
    if (data.containsKey('stopped_date')) {
      context.handle(
        _stoppedDateMeta,
        stoppedDate.isAcceptableOrUnknown(
          data['stopped_date']!,
          _stoppedDateMeta,
        ),
      );
    }
    if (data.containsKey('cover_id')) {
      context.handle(
        _coverIdMeta,
        coverId.isAcceptableOrUnknown(data['cover_id']!, _coverIdMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review_name')) {
      context.handle(
        _reviewNameMeta,
        reviewName.isAcceptableOrUnknown(data['review_name']!, _reviewNameMeta),
      );
    }
    if (data.containsKey('review_cw')) {
      context.handle(
        _reviewCwMeta,
        reviewCw.isAcceptableOrUnknown(data['review_cw']!, _reviewCwMeta),
      );
    }
    if (data.containsKey('review_content')) {
      context.handle(
        _reviewContentMeta,
        reviewContent.isAcceptableOrUnknown(
          data['review_content']!,
          _reviewContentMeta,
        ),
      );
    }
    if (data.containsKey('review_published')) {
      context.handle(
        _reviewPublishedMeta,
        reviewPublished.isAcceptableOrUnknown(
          data['review_published']!,
          _reviewPublishedMeta,
        ),
      );
    }
    if (data.containsKey('shelf')) {
      context.handle(
        _shelfMeta,
        shelf.isAcceptableOrUnknown(data['shelf']!, _shelfMeta),
      );
    }
    if (data.containsKey('shelf_name')) {
      context.handle(
        _shelfNameMeta,
        shelfName.isAcceptableOrUnknown(data['shelf_name']!, _shelfNameMeta),
      );
    }
    if (data.containsKey('shelf_date')) {
      context.handle(
        _shelfDateMeta,
        shelfDate.isAcceptableOrUnknown(data['shelf_date']!, _shelfDateMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    if (data.containsKey('date_modified')) {
      context.handle(
        _dateModifiedMeta,
        dateModified.isAcceptableOrUnknown(
          data['date_modified']!,
          _dateModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_text'],
      ),
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      openlibraryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}openlibrary_key'],
      ),
      finnaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finna_key'],
      ),
      inventaireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventaire_id'],
      ),
      librarythingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}librarything_key'],
      ),
      goodreadsKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goodreads_key'],
      ),
      bnfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bnf_id'],
      ),
      viaf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viaf'],
      ),
      wikidata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wikidata'],
      ),
      asin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asin'],
      ),
      aasin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aasin'],
      ),
      isfdb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isfdb'],
      ),
      isbn10: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn_10'],
      ),
      isbn13: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn_13'],
      ),
      oclcNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oclc_number'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      publicationYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publication_year'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      finishDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finish_date'],
      ),
      stoppedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stopped_date'],
      ),
      coverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_id'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      reviewName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_name'],
      ),
      reviewCw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_cw'],
      ),
      reviewContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_content'],
      ),
      reviewPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_published'],
      ),
      shelf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf'],
      )!,
      shelfName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_name'],
      ),
      shelfDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shelf_date'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      dateModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_modified'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String? authorText;
  final String? remoteId;
  final String? openlibraryKey;
  final String? finnaKey;
  final String? inventaireId;
  final String? librarythingKey;
  final String? goodreadsKey;
  final String? bnfId;
  final String? viaf;
  final String? wikidata;
  final String? asin;
  final String? aasin;
  final String? isfdb;
  final String? isbn10;
  final String? isbn13;
  final String? oclcNumber;
  final int? pageCount;
  final int? currentPage;
  final String? publisher;
  final int? publicationYear;
  final DateTime? startDate;
  final DateTime? finishDate;
  final DateTime? stoppedDate;
  final int? coverId;
  final String? coverUrl;
  final String? coverPath;
  final int? rating;
  final String? reviewName;
  final String? reviewCw;
  final String? reviewContent;
  final DateTime? reviewPublished;
  final String shelf;
  final String? shelfName;
  final DateTime? shelfDate;
  final bool isFavorite;
  final DateTime dateAdded;
  final DateTime dateModified;
  const Book({
    required this.id,
    required this.title,
    this.authorText,
    this.remoteId,
    this.openlibraryKey,
    this.finnaKey,
    this.inventaireId,
    this.librarythingKey,
    this.goodreadsKey,
    this.bnfId,
    this.viaf,
    this.wikidata,
    this.asin,
    this.aasin,
    this.isfdb,
    this.isbn10,
    this.isbn13,
    this.oclcNumber,
    this.pageCount,
    this.currentPage,
    this.publisher,
    this.publicationYear,
    this.startDate,
    this.finishDate,
    this.stoppedDate,
    this.coverId,
    this.coverUrl,
    this.coverPath,
    this.rating,
    this.reviewName,
    this.reviewCw,
    this.reviewContent,
    this.reviewPublished,
    required this.shelf,
    this.shelfName,
    this.shelfDate,
    required this.isFavorite,
    required this.dateAdded,
    required this.dateModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || authorText != null) {
      map['author_text'] = Variable<String>(authorText);
    }
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || openlibraryKey != null) {
      map['openlibrary_key'] = Variable<String>(openlibraryKey);
    }
    if (!nullToAbsent || finnaKey != null) {
      map['finna_key'] = Variable<String>(finnaKey);
    }
    if (!nullToAbsent || inventaireId != null) {
      map['inventaire_id'] = Variable<String>(inventaireId);
    }
    if (!nullToAbsent || librarythingKey != null) {
      map['librarything_key'] = Variable<String>(librarythingKey);
    }
    if (!nullToAbsent || goodreadsKey != null) {
      map['goodreads_key'] = Variable<String>(goodreadsKey);
    }
    if (!nullToAbsent || bnfId != null) {
      map['bnf_id'] = Variable<String>(bnfId);
    }
    if (!nullToAbsent || viaf != null) {
      map['viaf'] = Variable<String>(viaf);
    }
    if (!nullToAbsent || wikidata != null) {
      map['wikidata'] = Variable<String>(wikidata);
    }
    if (!nullToAbsent || asin != null) {
      map['asin'] = Variable<String>(asin);
    }
    if (!nullToAbsent || aasin != null) {
      map['aasin'] = Variable<String>(aasin);
    }
    if (!nullToAbsent || isfdb != null) {
      map['isfdb'] = Variable<String>(isfdb);
    }
    if (!nullToAbsent || isbn10 != null) {
      map['isbn_10'] = Variable<String>(isbn10);
    }
    if (!nullToAbsent || isbn13 != null) {
      map['isbn_13'] = Variable<String>(isbn13);
    }
    if (!nullToAbsent || oclcNumber != null) {
      map['oclc_number'] = Variable<String>(oclcNumber);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || currentPage != null) {
      map['current_page'] = Variable<int>(currentPage);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || publicationYear != null) {
      map['publication_year'] = Variable<int>(publicationYear);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || finishDate != null) {
      map['finish_date'] = Variable<DateTime>(finishDate);
    }
    if (!nullToAbsent || stoppedDate != null) {
      map['stopped_date'] = Variable<DateTime>(stoppedDate);
    }
    if (!nullToAbsent || coverId != null) {
      map['cover_id'] = Variable<int>(coverId);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || reviewName != null) {
      map['review_name'] = Variable<String>(reviewName);
    }
    if (!nullToAbsent || reviewCw != null) {
      map['review_cw'] = Variable<String>(reviewCw);
    }
    if (!nullToAbsent || reviewContent != null) {
      map['review_content'] = Variable<String>(reviewContent);
    }
    if (!nullToAbsent || reviewPublished != null) {
      map['review_published'] = Variable<DateTime>(reviewPublished);
    }
    map['shelf'] = Variable<String>(shelf);
    if (!nullToAbsent || shelfName != null) {
      map['shelf_name'] = Variable<String>(shelfName);
    }
    if (!nullToAbsent || shelfDate != null) {
      map['shelf_date'] = Variable<DateTime>(shelfDate);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['date_modified'] = Variable<DateTime>(dateModified);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      authorText: authorText == null && nullToAbsent
          ? const Value.absent()
          : Value(authorText),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      openlibraryKey: openlibraryKey == null && nullToAbsent
          ? const Value.absent()
          : Value(openlibraryKey),
      finnaKey: finnaKey == null && nullToAbsent
          ? const Value.absent()
          : Value(finnaKey),
      inventaireId: inventaireId == null && nullToAbsent
          ? const Value.absent()
          : Value(inventaireId),
      librarythingKey: librarythingKey == null && nullToAbsent
          ? const Value.absent()
          : Value(librarythingKey),
      goodreadsKey: goodreadsKey == null && nullToAbsent
          ? const Value.absent()
          : Value(goodreadsKey),
      bnfId: bnfId == null && nullToAbsent
          ? const Value.absent()
          : Value(bnfId),
      viaf: viaf == null && nullToAbsent ? const Value.absent() : Value(viaf),
      wikidata: wikidata == null && nullToAbsent
          ? const Value.absent()
          : Value(wikidata),
      asin: asin == null && nullToAbsent ? const Value.absent() : Value(asin),
      aasin: aasin == null && nullToAbsent
          ? const Value.absent()
          : Value(aasin),
      isfdb: isfdb == null && nullToAbsent
          ? const Value.absent()
          : Value(isfdb),
      isbn10: isbn10 == null && nullToAbsent
          ? const Value.absent()
          : Value(isbn10),
      isbn13: isbn13 == null && nullToAbsent
          ? const Value.absent()
          : Value(isbn13),
      oclcNumber: oclcNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(oclcNumber),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      currentPage: currentPage == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPage),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      publicationYear: publicationYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationYear),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      finishDate: finishDate == null && nullToAbsent
          ? const Value.absent()
          : Value(finishDate),
      stoppedDate: stoppedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(stoppedDate),
      coverId: coverId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverId),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      reviewName: reviewName == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewName),
      reviewCw: reviewCw == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewCw),
      reviewContent: reviewContent == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewContent),
      reviewPublished: reviewPublished == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewPublished),
      shelf: Value(shelf),
      shelfName: shelfName == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfName),
      shelfDate: shelfDate == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfDate),
      isFavorite: Value(isFavorite),
      dateAdded: Value(dateAdded),
      dateModified: Value(dateModified),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      authorText: serializer.fromJson<String?>(json['authorText']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      openlibraryKey: serializer.fromJson<String?>(json['openlibraryKey']),
      finnaKey: serializer.fromJson<String?>(json['finnaKey']),
      inventaireId: serializer.fromJson<String?>(json['inventaireId']),
      librarythingKey: serializer.fromJson<String?>(json['librarythingKey']),
      goodreadsKey: serializer.fromJson<String?>(json['goodreadsKey']),
      bnfId: serializer.fromJson<String?>(json['bnfId']),
      viaf: serializer.fromJson<String?>(json['viaf']),
      wikidata: serializer.fromJson<String?>(json['wikidata']),
      asin: serializer.fromJson<String?>(json['asin']),
      aasin: serializer.fromJson<String?>(json['aasin']),
      isfdb: serializer.fromJson<String?>(json['isfdb']),
      isbn10: serializer.fromJson<String?>(json['isbn10']),
      isbn13: serializer.fromJson<String?>(json['isbn13']),
      oclcNumber: serializer.fromJson<String?>(json['oclcNumber']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      currentPage: serializer.fromJson<int?>(json['currentPage']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      publicationYear: serializer.fromJson<int?>(json['publicationYear']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      finishDate: serializer.fromJson<DateTime?>(json['finishDate']),
      stoppedDate: serializer.fromJson<DateTime?>(json['stoppedDate']),
      coverId: serializer.fromJson<int?>(json['coverId']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      rating: serializer.fromJson<int?>(json['rating']),
      reviewName: serializer.fromJson<String?>(json['reviewName']),
      reviewCw: serializer.fromJson<String?>(json['reviewCw']),
      reviewContent: serializer.fromJson<String?>(json['reviewContent']),
      reviewPublished: serializer.fromJson<DateTime?>(json['reviewPublished']),
      shelf: serializer.fromJson<String>(json['shelf']),
      shelfName: serializer.fromJson<String?>(json['shelfName']),
      shelfDate: serializer.fromJson<DateTime?>(json['shelfDate']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      dateModified: serializer.fromJson<DateTime>(json['dateModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'authorText': serializer.toJson<String?>(authorText),
      'remoteId': serializer.toJson<String?>(remoteId),
      'openlibraryKey': serializer.toJson<String?>(openlibraryKey),
      'finnaKey': serializer.toJson<String?>(finnaKey),
      'inventaireId': serializer.toJson<String?>(inventaireId),
      'librarythingKey': serializer.toJson<String?>(librarythingKey),
      'goodreadsKey': serializer.toJson<String?>(goodreadsKey),
      'bnfId': serializer.toJson<String?>(bnfId),
      'viaf': serializer.toJson<String?>(viaf),
      'wikidata': serializer.toJson<String?>(wikidata),
      'asin': serializer.toJson<String?>(asin),
      'aasin': serializer.toJson<String?>(aasin),
      'isfdb': serializer.toJson<String?>(isfdb),
      'isbn10': serializer.toJson<String?>(isbn10),
      'isbn13': serializer.toJson<String?>(isbn13),
      'oclcNumber': serializer.toJson<String?>(oclcNumber),
      'pageCount': serializer.toJson<int?>(pageCount),
      'currentPage': serializer.toJson<int?>(currentPage),
      'publisher': serializer.toJson<String?>(publisher),
      'publicationYear': serializer.toJson<int?>(publicationYear),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'finishDate': serializer.toJson<DateTime?>(finishDate),
      'stoppedDate': serializer.toJson<DateTime?>(stoppedDate),
      'coverId': serializer.toJson<int?>(coverId),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'coverPath': serializer.toJson<String?>(coverPath),
      'rating': serializer.toJson<int?>(rating),
      'reviewName': serializer.toJson<String?>(reviewName),
      'reviewCw': serializer.toJson<String?>(reviewCw),
      'reviewContent': serializer.toJson<String?>(reviewContent),
      'reviewPublished': serializer.toJson<DateTime?>(reviewPublished),
      'shelf': serializer.toJson<String>(shelf),
      'shelfName': serializer.toJson<String?>(shelfName),
      'shelfDate': serializer.toJson<DateTime?>(shelfDate),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'dateModified': serializer.toJson<DateTime>(dateModified),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    Value<String?> authorText = const Value.absent(),
    Value<String?> remoteId = const Value.absent(),
    Value<String?> openlibraryKey = const Value.absent(),
    Value<String?> finnaKey = const Value.absent(),
    Value<String?> inventaireId = const Value.absent(),
    Value<String?> librarythingKey = const Value.absent(),
    Value<String?> goodreadsKey = const Value.absent(),
    Value<String?> bnfId = const Value.absent(),
    Value<String?> viaf = const Value.absent(),
    Value<String?> wikidata = const Value.absent(),
    Value<String?> asin = const Value.absent(),
    Value<String?> aasin = const Value.absent(),
    Value<String?> isfdb = const Value.absent(),
    Value<String?> isbn10 = const Value.absent(),
    Value<String?> isbn13 = const Value.absent(),
    Value<String?> oclcNumber = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<int?> currentPage = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<int?> publicationYear = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> finishDate = const Value.absent(),
    Value<DateTime?> stoppedDate = const Value.absent(),
    Value<int?> coverId = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<String?> reviewName = const Value.absent(),
    Value<String?> reviewCw = const Value.absent(),
    Value<String?> reviewContent = const Value.absent(),
    Value<DateTime?> reviewPublished = const Value.absent(),
    String? shelf,
    Value<String?> shelfName = const Value.absent(),
    Value<DateTime?> shelfDate = const Value.absent(),
    bool? isFavorite,
    DateTime? dateAdded,
    DateTime? dateModified,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    authorText: authorText.present ? authorText.value : this.authorText,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    openlibraryKey: openlibraryKey.present
        ? openlibraryKey.value
        : this.openlibraryKey,
    finnaKey: finnaKey.present ? finnaKey.value : this.finnaKey,
    inventaireId: inventaireId.present ? inventaireId.value : this.inventaireId,
    librarythingKey: librarythingKey.present
        ? librarythingKey.value
        : this.librarythingKey,
    goodreadsKey: goodreadsKey.present ? goodreadsKey.value : this.goodreadsKey,
    bnfId: bnfId.present ? bnfId.value : this.bnfId,
    viaf: viaf.present ? viaf.value : this.viaf,
    wikidata: wikidata.present ? wikidata.value : this.wikidata,
    asin: asin.present ? asin.value : this.asin,
    aasin: aasin.present ? aasin.value : this.aasin,
    isfdb: isfdb.present ? isfdb.value : this.isfdb,
    isbn10: isbn10.present ? isbn10.value : this.isbn10,
    isbn13: isbn13.present ? isbn13.value : this.isbn13,
    oclcNumber: oclcNumber.present ? oclcNumber.value : this.oclcNumber,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    currentPage: currentPage.present ? currentPage.value : this.currentPage,
    publisher: publisher.present ? publisher.value : this.publisher,
    publicationYear: publicationYear.present
        ? publicationYear.value
        : this.publicationYear,
    startDate: startDate.present ? startDate.value : this.startDate,
    finishDate: finishDate.present ? finishDate.value : this.finishDate,
    stoppedDate: stoppedDate.present ? stoppedDate.value : this.stoppedDate,
    coverId: coverId.present ? coverId.value : this.coverId,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    rating: rating.present ? rating.value : this.rating,
    reviewName: reviewName.present ? reviewName.value : this.reviewName,
    reviewCw: reviewCw.present ? reviewCw.value : this.reviewCw,
    reviewContent: reviewContent.present
        ? reviewContent.value
        : this.reviewContent,
    reviewPublished: reviewPublished.present
        ? reviewPublished.value
        : this.reviewPublished,
    shelf: shelf ?? this.shelf,
    shelfName: shelfName.present ? shelfName.value : this.shelfName,
    shelfDate: shelfDate.present ? shelfDate.value : this.shelfDate,
    isFavorite: isFavorite ?? this.isFavorite,
    dateAdded: dateAdded ?? this.dateAdded,
    dateModified: dateModified ?? this.dateModified,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      authorText: data.authorText.present
          ? data.authorText.value
          : this.authorText,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      openlibraryKey: data.openlibraryKey.present
          ? data.openlibraryKey.value
          : this.openlibraryKey,
      finnaKey: data.finnaKey.present ? data.finnaKey.value : this.finnaKey,
      inventaireId: data.inventaireId.present
          ? data.inventaireId.value
          : this.inventaireId,
      librarythingKey: data.librarythingKey.present
          ? data.librarythingKey.value
          : this.librarythingKey,
      goodreadsKey: data.goodreadsKey.present
          ? data.goodreadsKey.value
          : this.goodreadsKey,
      bnfId: data.bnfId.present ? data.bnfId.value : this.bnfId,
      viaf: data.viaf.present ? data.viaf.value : this.viaf,
      wikidata: data.wikidata.present ? data.wikidata.value : this.wikidata,
      asin: data.asin.present ? data.asin.value : this.asin,
      aasin: data.aasin.present ? data.aasin.value : this.aasin,
      isfdb: data.isfdb.present ? data.isfdb.value : this.isfdb,
      isbn10: data.isbn10.present ? data.isbn10.value : this.isbn10,
      isbn13: data.isbn13.present ? data.isbn13.value : this.isbn13,
      oclcNumber: data.oclcNumber.present
          ? data.oclcNumber.value
          : this.oclcNumber,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      publicationYear: data.publicationYear.present
          ? data.publicationYear.value
          : this.publicationYear,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      finishDate: data.finishDate.present
          ? data.finishDate.value
          : this.finishDate,
      stoppedDate: data.stoppedDate.present
          ? data.stoppedDate.value
          : this.stoppedDate,
      coverId: data.coverId.present ? data.coverId.value : this.coverId,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewName: data.reviewName.present
          ? data.reviewName.value
          : this.reviewName,
      reviewCw: data.reviewCw.present ? data.reviewCw.value : this.reviewCw,
      reviewContent: data.reviewContent.present
          ? data.reviewContent.value
          : this.reviewContent,
      reviewPublished: data.reviewPublished.present
          ? data.reviewPublished.value
          : this.reviewPublished,
      shelf: data.shelf.present ? data.shelf.value : this.shelf,
      shelfName: data.shelfName.present ? data.shelfName.value : this.shelfName,
      shelfDate: data.shelfDate.present ? data.shelfDate.value : this.shelfDate,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateModified: data.dateModified.present
          ? data.dateModified.value
          : this.dateModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('authorText: $authorText, ')
          ..write('remoteId: $remoteId, ')
          ..write('openlibraryKey: $openlibraryKey, ')
          ..write('finnaKey: $finnaKey, ')
          ..write('inventaireId: $inventaireId, ')
          ..write('librarythingKey: $librarythingKey, ')
          ..write('goodreadsKey: $goodreadsKey, ')
          ..write('bnfId: $bnfId, ')
          ..write('viaf: $viaf, ')
          ..write('wikidata: $wikidata, ')
          ..write('asin: $asin, ')
          ..write('aasin: $aasin, ')
          ..write('isfdb: $isfdb, ')
          ..write('isbn10: $isbn10, ')
          ..write('isbn13: $isbn13, ')
          ..write('oclcNumber: $oclcNumber, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('publisher: $publisher, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('startDate: $startDate, ')
          ..write('finishDate: $finishDate, ')
          ..write('stoppedDate: $stoppedDate, ')
          ..write('coverId: $coverId, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverPath: $coverPath, ')
          ..write('rating: $rating, ')
          ..write('reviewName: $reviewName, ')
          ..write('reviewCw: $reviewCw, ')
          ..write('reviewContent: $reviewContent, ')
          ..write('reviewPublished: $reviewPublished, ')
          ..write('shelf: $shelf, ')
          ..write('shelfName: $shelfName, ')
          ..write('shelfDate: $shelfDate, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    authorText,
    remoteId,
    openlibraryKey,
    finnaKey,
    inventaireId,
    librarythingKey,
    goodreadsKey,
    bnfId,
    viaf,
    wikidata,
    asin,
    aasin,
    isfdb,
    isbn10,
    isbn13,
    oclcNumber,
    pageCount,
    currentPage,
    publisher,
    publicationYear,
    startDate,
    finishDate,
    stoppedDate,
    coverId,
    coverUrl,
    coverPath,
    rating,
    reviewName,
    reviewCw,
    reviewContent,
    reviewPublished,
    shelf,
    shelfName,
    shelfDate,
    isFavorite,
    dateAdded,
    dateModified,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.authorText == this.authorText &&
          other.remoteId == this.remoteId &&
          other.openlibraryKey == this.openlibraryKey &&
          other.finnaKey == this.finnaKey &&
          other.inventaireId == this.inventaireId &&
          other.librarythingKey == this.librarythingKey &&
          other.goodreadsKey == this.goodreadsKey &&
          other.bnfId == this.bnfId &&
          other.viaf == this.viaf &&
          other.wikidata == this.wikidata &&
          other.asin == this.asin &&
          other.aasin == this.aasin &&
          other.isfdb == this.isfdb &&
          other.isbn10 == this.isbn10 &&
          other.isbn13 == this.isbn13 &&
          other.oclcNumber == this.oclcNumber &&
          other.pageCount == this.pageCount &&
          other.currentPage == this.currentPage &&
          other.publisher == this.publisher &&
          other.publicationYear == this.publicationYear &&
          other.startDate == this.startDate &&
          other.finishDate == this.finishDate &&
          other.stoppedDate == this.stoppedDate &&
          other.coverId == this.coverId &&
          other.coverUrl == this.coverUrl &&
          other.coverPath == this.coverPath &&
          other.rating == this.rating &&
          other.reviewName == this.reviewName &&
          other.reviewCw == this.reviewCw &&
          other.reviewContent == this.reviewContent &&
          other.reviewPublished == this.reviewPublished &&
          other.shelf == this.shelf &&
          other.shelfName == this.shelfName &&
          other.shelfDate == this.shelfDate &&
          other.isFavorite == this.isFavorite &&
          other.dateAdded == this.dateAdded &&
          other.dateModified == this.dateModified);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> authorText;
  final Value<String?> remoteId;
  final Value<String?> openlibraryKey;
  final Value<String?> finnaKey;
  final Value<String?> inventaireId;
  final Value<String?> librarythingKey;
  final Value<String?> goodreadsKey;
  final Value<String?> bnfId;
  final Value<String?> viaf;
  final Value<String?> wikidata;
  final Value<String?> asin;
  final Value<String?> aasin;
  final Value<String?> isfdb;
  final Value<String?> isbn10;
  final Value<String?> isbn13;
  final Value<String?> oclcNumber;
  final Value<int?> pageCount;
  final Value<int?> currentPage;
  final Value<String?> publisher;
  final Value<int?> publicationYear;
  final Value<DateTime?> startDate;
  final Value<DateTime?> finishDate;
  final Value<DateTime?> stoppedDate;
  final Value<int?> coverId;
  final Value<String?> coverUrl;
  final Value<String?> coverPath;
  final Value<int?> rating;
  final Value<String?> reviewName;
  final Value<String?> reviewCw;
  final Value<String?> reviewContent;
  final Value<DateTime?> reviewPublished;
  final Value<String> shelf;
  final Value<String?> shelfName;
  final Value<DateTime?> shelfDate;
  final Value<bool> isFavorite;
  final Value<DateTime> dateAdded;
  final Value<DateTime> dateModified;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.authorText = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.openlibraryKey = const Value.absent(),
    this.finnaKey = const Value.absent(),
    this.inventaireId = const Value.absent(),
    this.librarythingKey = const Value.absent(),
    this.goodreadsKey = const Value.absent(),
    this.bnfId = const Value.absent(),
    this.viaf = const Value.absent(),
    this.wikidata = const Value.absent(),
    this.asin = const Value.absent(),
    this.aasin = const Value.absent(),
    this.isfdb = const Value.absent(),
    this.isbn10 = const Value.absent(),
    this.isbn13 = const Value.absent(),
    this.oclcNumber = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.startDate = const Value.absent(),
    this.finishDate = const Value.absent(),
    this.stoppedDate = const Value.absent(),
    this.coverId = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewName = const Value.absent(),
    this.reviewCw = const Value.absent(),
    this.reviewContent = const Value.absent(),
    this.reviewPublished = const Value.absent(),
    this.shelf = const Value.absent(),
    this.shelfName = const Value.absent(),
    this.shelfDate = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.authorText = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.openlibraryKey = const Value.absent(),
    this.finnaKey = const Value.absent(),
    this.inventaireId = const Value.absent(),
    this.librarythingKey = const Value.absent(),
    this.goodreadsKey = const Value.absent(),
    this.bnfId = const Value.absent(),
    this.viaf = const Value.absent(),
    this.wikidata = const Value.absent(),
    this.asin = const Value.absent(),
    this.aasin = const Value.absent(),
    this.isfdb = const Value.absent(),
    this.isbn10 = const Value.absent(),
    this.isbn13 = const Value.absent(),
    this.oclcNumber = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publicationYear = const Value.absent(),
    this.startDate = const Value.absent(),
    this.finishDate = const Value.absent(),
    this.stoppedDate = const Value.absent(),
    this.coverId = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewName = const Value.absent(),
    this.reviewCw = const Value.absent(),
    this.reviewContent = const Value.absent(),
    this.reviewPublished = const Value.absent(),
    this.shelf = const Value.absent(),
    this.shelfName = const Value.absent(),
    this.shelfDate = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? authorText,
    Expression<String>? remoteId,
    Expression<String>? openlibraryKey,
    Expression<String>? finnaKey,
    Expression<String>? inventaireId,
    Expression<String>? librarythingKey,
    Expression<String>? goodreadsKey,
    Expression<String>? bnfId,
    Expression<String>? viaf,
    Expression<String>? wikidata,
    Expression<String>? asin,
    Expression<String>? aasin,
    Expression<String>? isfdb,
    Expression<String>? isbn10,
    Expression<String>? isbn13,
    Expression<String>? oclcNumber,
    Expression<int>? pageCount,
    Expression<int>? currentPage,
    Expression<String>? publisher,
    Expression<int>? publicationYear,
    Expression<DateTime>? startDate,
    Expression<DateTime>? finishDate,
    Expression<DateTime>? stoppedDate,
    Expression<int>? coverId,
    Expression<String>? coverUrl,
    Expression<String>? coverPath,
    Expression<int>? rating,
    Expression<String>? reviewName,
    Expression<String>? reviewCw,
    Expression<String>? reviewContent,
    Expression<DateTime>? reviewPublished,
    Expression<String>? shelf,
    Expression<String>? shelfName,
    Expression<DateTime>? shelfDate,
    Expression<bool>? isFavorite,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? dateModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (authorText != null) 'author_text': authorText,
      if (remoteId != null) 'remote_id': remoteId,
      if (openlibraryKey != null) 'openlibrary_key': openlibraryKey,
      if (finnaKey != null) 'finna_key': finnaKey,
      if (inventaireId != null) 'inventaire_id': inventaireId,
      if (librarythingKey != null) 'librarything_key': librarythingKey,
      if (goodreadsKey != null) 'goodreads_key': goodreadsKey,
      if (bnfId != null) 'bnf_id': bnfId,
      if (viaf != null) 'viaf': viaf,
      if (wikidata != null) 'wikidata': wikidata,
      if (asin != null) 'asin': asin,
      if (aasin != null) 'aasin': aasin,
      if (isfdb != null) 'isfdb': isfdb,
      if (isbn10 != null) 'isbn_10': isbn10,
      if (isbn13 != null) 'isbn_13': isbn13,
      if (oclcNumber != null) 'oclc_number': oclcNumber,
      if (pageCount != null) 'page_count': pageCount,
      if (currentPage != null) 'current_page': currentPage,
      if (publisher != null) 'publisher': publisher,
      if (publicationYear != null) 'publication_year': publicationYear,
      if (startDate != null) 'start_date': startDate,
      if (finishDate != null) 'finish_date': finishDate,
      if (stoppedDate != null) 'stopped_date': stoppedDate,
      if (coverId != null) 'cover_id': coverId,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (coverPath != null) 'cover_path': coverPath,
      if (rating != null) 'rating': rating,
      if (reviewName != null) 'review_name': reviewName,
      if (reviewCw != null) 'review_cw': reviewCw,
      if (reviewContent != null) 'review_content': reviewContent,
      if (reviewPublished != null) 'review_published': reviewPublished,
      if (shelf != null) 'shelf': shelf,
      if (shelfName != null) 'shelf_name': shelfName,
      if (shelfDate != null) 'shelf_date': shelfDate,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateModified != null) 'date_modified': dateModified,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? authorText,
    Value<String?>? remoteId,
    Value<String?>? openlibraryKey,
    Value<String?>? finnaKey,
    Value<String?>? inventaireId,
    Value<String?>? librarythingKey,
    Value<String?>? goodreadsKey,
    Value<String?>? bnfId,
    Value<String?>? viaf,
    Value<String?>? wikidata,
    Value<String?>? asin,
    Value<String?>? aasin,
    Value<String?>? isfdb,
    Value<String?>? isbn10,
    Value<String?>? isbn13,
    Value<String?>? oclcNumber,
    Value<int?>? pageCount,
    Value<int?>? currentPage,
    Value<String?>? publisher,
    Value<int?>? publicationYear,
    Value<DateTime?>? startDate,
    Value<DateTime?>? finishDate,
    Value<DateTime?>? stoppedDate,
    Value<int?>? coverId,
    Value<String?>? coverUrl,
    Value<String?>? coverPath,
    Value<int?>? rating,
    Value<String?>? reviewName,
    Value<String?>? reviewCw,
    Value<String?>? reviewContent,
    Value<DateTime?>? reviewPublished,
    Value<String>? shelf,
    Value<String?>? shelfName,
    Value<DateTime?>? shelfDate,
    Value<bool>? isFavorite,
    Value<DateTime>? dateAdded,
    Value<DateTime>? dateModified,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      authorText: authorText ?? this.authorText,
      remoteId: remoteId ?? this.remoteId,
      openlibraryKey: openlibraryKey ?? this.openlibraryKey,
      finnaKey: finnaKey ?? this.finnaKey,
      inventaireId: inventaireId ?? this.inventaireId,
      librarythingKey: librarythingKey ?? this.librarythingKey,
      goodreadsKey: goodreadsKey ?? this.goodreadsKey,
      bnfId: bnfId ?? this.bnfId,
      viaf: viaf ?? this.viaf,
      wikidata: wikidata ?? this.wikidata,
      asin: asin ?? this.asin,
      aasin: aasin ?? this.aasin,
      isfdb: isfdb ?? this.isfdb,
      isbn10: isbn10 ?? this.isbn10,
      isbn13: isbn13 ?? this.isbn13,
      oclcNumber: oclcNumber ?? this.oclcNumber,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      stoppedDate: stoppedDate ?? this.stoppedDate,
      coverId: coverId ?? this.coverId,
      coverUrl: coverUrl ?? this.coverUrl,
      coverPath: coverPath ?? this.coverPath,
      rating: rating ?? this.rating,
      reviewName: reviewName ?? this.reviewName,
      reviewCw: reviewCw ?? this.reviewCw,
      reviewContent: reviewContent ?? this.reviewContent,
      reviewPublished: reviewPublished ?? this.reviewPublished,
      shelf: shelf ?? this.shelf,
      shelfName: shelfName ?? this.shelfName,
      shelfDate: shelfDate ?? this.shelfDate,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authorText.present) {
      map['author_text'] = Variable<String>(authorText.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (openlibraryKey.present) {
      map['openlibrary_key'] = Variable<String>(openlibraryKey.value);
    }
    if (finnaKey.present) {
      map['finna_key'] = Variable<String>(finnaKey.value);
    }
    if (inventaireId.present) {
      map['inventaire_id'] = Variable<String>(inventaireId.value);
    }
    if (librarythingKey.present) {
      map['librarything_key'] = Variable<String>(librarythingKey.value);
    }
    if (goodreadsKey.present) {
      map['goodreads_key'] = Variable<String>(goodreadsKey.value);
    }
    if (bnfId.present) {
      map['bnf_id'] = Variable<String>(bnfId.value);
    }
    if (viaf.present) {
      map['viaf'] = Variable<String>(viaf.value);
    }
    if (wikidata.present) {
      map['wikidata'] = Variable<String>(wikidata.value);
    }
    if (asin.present) {
      map['asin'] = Variable<String>(asin.value);
    }
    if (aasin.present) {
      map['aasin'] = Variable<String>(aasin.value);
    }
    if (isfdb.present) {
      map['isfdb'] = Variable<String>(isfdb.value);
    }
    if (isbn10.present) {
      map['isbn_10'] = Variable<String>(isbn10.value);
    }
    if (isbn13.present) {
      map['isbn_13'] = Variable<String>(isbn13.value);
    }
    if (oclcNumber.present) {
      map['oclc_number'] = Variable<String>(oclcNumber.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (publicationYear.present) {
      map['publication_year'] = Variable<int>(publicationYear.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (finishDate.present) {
      map['finish_date'] = Variable<DateTime>(finishDate.value);
    }
    if (stoppedDate.present) {
      map['stopped_date'] = Variable<DateTime>(stoppedDate.value);
    }
    if (coverId.present) {
      map['cover_id'] = Variable<int>(coverId.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (reviewName.present) {
      map['review_name'] = Variable<String>(reviewName.value);
    }
    if (reviewCw.present) {
      map['review_cw'] = Variable<String>(reviewCw.value);
    }
    if (reviewContent.present) {
      map['review_content'] = Variable<String>(reviewContent.value);
    }
    if (reviewPublished.present) {
      map['review_published'] = Variable<DateTime>(reviewPublished.value);
    }
    if (shelf.present) {
      map['shelf'] = Variable<String>(shelf.value);
    }
    if (shelfName.present) {
      map['shelf_name'] = Variable<String>(shelfName.value);
    }
    if (shelfDate.present) {
      map['shelf_date'] = Variable<DateTime>(shelfDate.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (dateModified.present) {
      map['date_modified'] = Variable<DateTime>(dateModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('authorText: $authorText, ')
          ..write('remoteId: $remoteId, ')
          ..write('openlibraryKey: $openlibraryKey, ')
          ..write('finnaKey: $finnaKey, ')
          ..write('inventaireId: $inventaireId, ')
          ..write('librarythingKey: $librarythingKey, ')
          ..write('goodreadsKey: $goodreadsKey, ')
          ..write('bnfId: $bnfId, ')
          ..write('viaf: $viaf, ')
          ..write('wikidata: $wikidata, ')
          ..write('asin: $asin, ')
          ..write('aasin: $aasin, ')
          ..write('isfdb: $isfdb, ')
          ..write('isbn10: $isbn10, ')
          ..write('isbn13: $isbn13, ')
          ..write('oclcNumber: $oclcNumber, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('publisher: $publisher, ')
          ..write('publicationYear: $publicationYear, ')
          ..write('startDate: $startDate, ')
          ..write('finishDate: $finishDate, ')
          ..write('stoppedDate: $stoppedDate, ')
          ..write('coverId: $coverId, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverPath: $coverPath, ')
          ..write('rating: $rating, ')
          ..write('reviewName: $reviewName, ')
          ..write('reviewCw: $reviewCw, ')
          ..write('reviewContent: $reviewContent, ')
          ..write('reviewPublished: $reviewPublished, ')
          ..write('shelf: $shelf, ')
          ..write('shelfName: $shelfName, ')
          ..write('shelfDate: $shelfDate, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final int? color;
  const Tag({required this.id, required this.name, this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int?>(color),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    Value<int?> color = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $BookTagsTable extends BookTags with TableInfo<$BookTagsTable, BookTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, tagId};
  @override
  BookTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookTag(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $BookTagsTable createAlias(String alias) {
    return $BookTagsTable(attachedDatabase, alias);
  }
}

class BookTag extends DataClass implements Insertable<BookTag> {
  final int bookId;
  final int tagId;
  const BookTag({required this.bookId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  BookTagsCompanion toCompanion(bool nullToAbsent) {
    return BookTagsCompanion(bookId: Value(bookId), tagId: Value(tagId));
  }

  factory BookTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookTag(
      bookId: serializer.fromJson<int>(json['bookId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  BookTag copyWith({int? bookId, int? tagId}) =>
      BookTag(bookId: bookId ?? this.bookId, tagId: tagId ?? this.tagId);
  BookTag copyWithCompanion(BookTagsCompanion data) {
    return BookTag(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookTag(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookTag &&
          other.bookId == this.bookId &&
          other.tagId == this.tagId);
}

class BookTagsCompanion extends UpdateCompanion<BookTag> {
  final Value<int> bookId;
  final Value<int> tagId;
  final Value<int> rowid;
  const BookTagsCompanion({
    this.bookId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookTagsCompanion.insert({
    required int bookId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       tagId = Value(tagId);
  static Insertable<BookTag> custom({
    Expression<int>? bookId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookTagsCompanion copyWith({
    Value<int>? bookId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return BookTagsCompanion(
      bookId: bookId ?? this.bookId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookTagsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $BookTagsTable bookTags = $BookTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books, tags, bookTags];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> authorText,
      Value<String?> remoteId,
      Value<String?> openlibraryKey,
      Value<String?> finnaKey,
      Value<String?> inventaireId,
      Value<String?> librarythingKey,
      Value<String?> goodreadsKey,
      Value<String?> bnfId,
      Value<String?> viaf,
      Value<String?> wikidata,
      Value<String?> asin,
      Value<String?> aasin,
      Value<String?> isfdb,
      Value<String?> isbn10,
      Value<String?> isbn13,
      Value<String?> oclcNumber,
      Value<int?> pageCount,
      Value<int?> currentPage,
      Value<String?> publisher,
      Value<int?> publicationYear,
      Value<DateTime?> startDate,
      Value<DateTime?> finishDate,
      Value<DateTime?> stoppedDate,
      Value<int?> coverId,
      Value<String?> coverUrl,
      Value<String?> coverPath,
      Value<int?> rating,
      Value<String?> reviewName,
      Value<String?> reviewCw,
      Value<String?> reviewContent,
      Value<DateTime?> reviewPublished,
      Value<String> shelf,
      Value<String?> shelfName,
      Value<DateTime?> shelfDate,
      Value<bool> isFavorite,
      Value<DateTime> dateAdded,
      Value<DateTime> dateModified,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> authorText,
      Value<String?> remoteId,
      Value<String?> openlibraryKey,
      Value<String?> finnaKey,
      Value<String?> inventaireId,
      Value<String?> librarythingKey,
      Value<String?> goodreadsKey,
      Value<String?> bnfId,
      Value<String?> viaf,
      Value<String?> wikidata,
      Value<String?> asin,
      Value<String?> aasin,
      Value<String?> isfdb,
      Value<String?> isbn10,
      Value<String?> isbn13,
      Value<String?> oclcNumber,
      Value<int?> pageCount,
      Value<int?> currentPage,
      Value<String?> publisher,
      Value<int?> publicationYear,
      Value<DateTime?> startDate,
      Value<DateTime?> finishDate,
      Value<DateTime?> stoppedDate,
      Value<int?> coverId,
      Value<String?> coverUrl,
      Value<String?> coverPath,
      Value<int?> rating,
      Value<String?> reviewName,
      Value<String?> reviewCw,
      Value<String?> reviewContent,
      Value<DateTime?> reviewPublished,
      Value<String> shelf,
      Value<String?> shelfName,
      Value<DateTime?> shelfDate,
      Value<bool> isFavorite,
      Value<DateTime> dateAdded,
      Value<DateTime> dateModified,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookTagsTable, List<BookTag>> _bookTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: $_aliasNameGenerator(db.books.id, db.bookTags.bookId),
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorText => $composableBuilder(
    column: $table.authorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openlibraryKey => $composableBuilder(
    column: $table.openlibraryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finnaKey => $composableBuilder(
    column: $table.finnaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inventaireId => $composableBuilder(
    column: $table.inventaireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get librarythingKey => $composableBuilder(
    column: $table.librarythingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goodreadsKey => $composableBuilder(
    column: $table.goodreadsKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bnfId => $composableBuilder(
    column: $table.bnfId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viaf => $composableBuilder(
    column: $table.viaf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wikidata => $composableBuilder(
    column: $table.wikidata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asin => $composableBuilder(
    column: $table.asin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aasin => $composableBuilder(
    column: $table.aasin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isfdb => $composableBuilder(
    column: $table.isfdb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn10 => $composableBuilder(
    column: $table.isbn10,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn13 => $composableBuilder(
    column: $table.isbn13,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oclcNumber => $composableBuilder(
    column: $table.oclcNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishDate => $composableBuilder(
    column: $table.finishDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get stoppedDate => $composableBuilder(
    column: $table.stoppedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverId => $composableBuilder(
    column: $table.coverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewName => $composableBuilder(
    column: $table.reviewName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewCw => $composableBuilder(
    column: $table.reviewCw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewContent => $composableBuilder(
    column: $table.reviewContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewPublished => $composableBuilder(
    column: $table.reviewPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelf => $composableBuilder(
    column: $table.shelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelfName => $composableBuilder(
    column: $table.shelfName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shelfDate => $composableBuilder(
    column: $table.shelfDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorText => $composableBuilder(
    column: $table.authorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openlibraryKey => $composableBuilder(
    column: $table.openlibraryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finnaKey => $composableBuilder(
    column: $table.finnaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inventaireId => $composableBuilder(
    column: $table.inventaireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get librarythingKey => $composableBuilder(
    column: $table.librarythingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goodreadsKey => $composableBuilder(
    column: $table.goodreadsKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bnfId => $composableBuilder(
    column: $table.bnfId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viaf => $composableBuilder(
    column: $table.viaf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wikidata => $composableBuilder(
    column: $table.wikidata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asin => $composableBuilder(
    column: $table.asin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aasin => $composableBuilder(
    column: $table.aasin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isfdb => $composableBuilder(
    column: $table.isfdb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn10 => $composableBuilder(
    column: $table.isbn10,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn13 => $composableBuilder(
    column: $table.isbn13,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oclcNumber => $composableBuilder(
    column: $table.oclcNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishDate => $composableBuilder(
    column: $table.finishDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get stoppedDate => $composableBuilder(
    column: $table.stoppedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverId => $composableBuilder(
    column: $table.coverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewName => $composableBuilder(
    column: $table.reviewName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewCw => $composableBuilder(
    column: $table.reviewCw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewContent => $composableBuilder(
    column: $table.reviewContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewPublished => $composableBuilder(
    column: $table.reviewPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelf => $composableBuilder(
    column: $table.shelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelfName => $composableBuilder(
    column: $table.shelfName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shelfDate => $composableBuilder(
    column: $table.shelfDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get authorText => $composableBuilder(
    column: $table.authorText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get openlibraryKey => $composableBuilder(
    column: $table.openlibraryKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finnaKey =>
      $composableBuilder(column: $table.finnaKey, builder: (column) => column);

  GeneratedColumn<String> get inventaireId => $composableBuilder(
    column: $table.inventaireId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get librarythingKey => $composableBuilder(
    column: $table.librarythingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goodreadsKey => $composableBuilder(
    column: $table.goodreadsKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bnfId =>
      $composableBuilder(column: $table.bnfId, builder: (column) => column);

  GeneratedColumn<String> get viaf =>
      $composableBuilder(column: $table.viaf, builder: (column) => column);

  GeneratedColumn<String> get wikidata =>
      $composableBuilder(column: $table.wikidata, builder: (column) => column);

  GeneratedColumn<String> get asin =>
      $composableBuilder(column: $table.asin, builder: (column) => column);

  GeneratedColumn<String> get aasin =>
      $composableBuilder(column: $table.aasin, builder: (column) => column);

  GeneratedColumn<String> get isfdb =>
      $composableBuilder(column: $table.isfdb, builder: (column) => column);

  GeneratedColumn<String> get isbn10 =>
      $composableBuilder(column: $table.isbn10, builder: (column) => column);

  GeneratedColumn<String> get isbn13 =>
      $composableBuilder(column: $table.isbn13, builder: (column) => column);

  GeneratedColumn<String> get oclcNumber => $composableBuilder(
    column: $table.oclcNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<int> get publicationYear => $composableBuilder(
    column: $table.publicationYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get finishDate => $composableBuilder(
    column: $table.finishDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get stoppedDate => $composableBuilder(
    column: $table.stoppedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coverId =>
      $composableBuilder(column: $table.coverId, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get reviewName => $composableBuilder(
    column: $table.reviewName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewCw =>
      $composableBuilder(column: $table.reviewCw, builder: (column) => column);

  GeneratedColumn<String> get reviewContent => $composableBuilder(
    column: $table.reviewContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewPublished => $composableBuilder(
    column: $table.reviewPublished,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shelf =>
      $composableBuilder(column: $table.shelf, builder: (column) => column);

  GeneratedColumn<String> get shelfName =>
      $composableBuilder(column: $table.shelfName, builder: (column) => column);

  GeneratedColumn<DateTime> get shelfDate =>
      $composableBuilder(column: $table.shelfDate, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => column,
  );

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({bool bookTagsRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> authorText = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> openlibraryKey = const Value.absent(),
                Value<String?> finnaKey = const Value.absent(),
                Value<String?> inventaireId = const Value.absent(),
                Value<String?> librarythingKey = const Value.absent(),
                Value<String?> goodreadsKey = const Value.absent(),
                Value<String?> bnfId = const Value.absent(),
                Value<String?> viaf = const Value.absent(),
                Value<String?> wikidata = const Value.absent(),
                Value<String?> asin = const Value.absent(),
                Value<String?> aasin = const Value.absent(),
                Value<String?> isfdb = const Value.absent(),
                Value<String?> isbn10 = const Value.absent(),
                Value<String?> isbn13 = const Value.absent(),
                Value<String?> oclcNumber = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> finishDate = const Value.absent(),
                Value<DateTime?> stoppedDate = const Value.absent(),
                Value<int?> coverId = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> reviewName = const Value.absent(),
                Value<String?> reviewCw = const Value.absent(),
                Value<String?> reviewContent = const Value.absent(),
                Value<DateTime?> reviewPublished = const Value.absent(),
                Value<String> shelf = const Value.absent(),
                Value<String?> shelfName = const Value.absent(),
                Value<DateTime?> shelfDate = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime> dateModified = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                authorText: authorText,
                remoteId: remoteId,
                openlibraryKey: openlibraryKey,
                finnaKey: finnaKey,
                inventaireId: inventaireId,
                librarythingKey: librarythingKey,
                goodreadsKey: goodreadsKey,
                bnfId: bnfId,
                viaf: viaf,
                wikidata: wikidata,
                asin: asin,
                aasin: aasin,
                isfdb: isfdb,
                isbn10: isbn10,
                isbn13: isbn13,
                oclcNumber: oclcNumber,
                pageCount: pageCount,
                currentPage: currentPage,
                publisher: publisher,
                publicationYear: publicationYear,
                startDate: startDate,
                finishDate: finishDate,
                stoppedDate: stoppedDate,
                coverId: coverId,
                coverUrl: coverUrl,
                coverPath: coverPath,
                rating: rating,
                reviewName: reviewName,
                reviewCw: reviewCw,
                reviewContent: reviewContent,
                reviewPublished: reviewPublished,
                shelf: shelf,
                shelfName: shelfName,
                shelfDate: shelfDate,
                isFavorite: isFavorite,
                dateAdded: dateAdded,
                dateModified: dateModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> authorText = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> openlibraryKey = const Value.absent(),
                Value<String?> finnaKey = const Value.absent(),
                Value<String?> inventaireId = const Value.absent(),
                Value<String?> librarythingKey = const Value.absent(),
                Value<String?> goodreadsKey = const Value.absent(),
                Value<String?> bnfId = const Value.absent(),
                Value<String?> viaf = const Value.absent(),
                Value<String?> wikidata = const Value.absent(),
                Value<String?> asin = const Value.absent(),
                Value<String?> aasin = const Value.absent(),
                Value<String?> isfdb = const Value.absent(),
                Value<String?> isbn10 = const Value.absent(),
                Value<String?> isbn13 = const Value.absent(),
                Value<String?> oclcNumber = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> publicationYear = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> finishDate = const Value.absent(),
                Value<DateTime?> stoppedDate = const Value.absent(),
                Value<int?> coverId = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> reviewName = const Value.absent(),
                Value<String?> reviewCw = const Value.absent(),
                Value<String?> reviewContent = const Value.absent(),
                Value<DateTime?> reviewPublished = const Value.absent(),
                Value<String> shelf = const Value.absent(),
                Value<String?> shelfName = const Value.absent(),
                Value<DateTime?> shelfDate = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime> dateModified = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                authorText: authorText,
                remoteId: remoteId,
                openlibraryKey: openlibraryKey,
                finnaKey: finnaKey,
                inventaireId: inventaireId,
                librarythingKey: librarythingKey,
                goodreadsKey: goodreadsKey,
                bnfId: bnfId,
                viaf: viaf,
                wikidata: wikidata,
                asin: asin,
                aasin: aasin,
                isfdb: isfdb,
                isbn10: isbn10,
                isbn13: isbn13,
                oclcNumber: oclcNumber,
                pageCount: pageCount,
                currentPage: currentPage,
                publisher: publisher,
                publicationYear: publicationYear,
                startDate: startDate,
                finishDate: finishDate,
                stoppedDate: stoppedDate,
                coverId: coverId,
                coverUrl: coverUrl,
                coverPath: coverPath,
                rating: rating,
                reviewName: reviewName,
                reviewCw: reviewCw,
                reviewContent: reviewContent,
                reviewPublished: reviewPublished,
                shelf: shelf,
                shelfName: shelfName,
                shelfDate: shelfDate,
                isFavorite: isFavorite,
                dateAdded: dateAdded,
                dateModified: dateModified,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookTagsRefs) db.bookTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookTagsRefs)
                    await $_getPrefetchedData<Book, $BooksTable, BookTag>(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences
                          ._bookTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).bookTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({bool bookTagsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> color,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> color,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookTagsTable, List<BookTag>> _bookTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.bookTags.tagId),
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool bookTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> color = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> color = const Value.absent(),
              }) => TagsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookTagsRefs) db.bookTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, BookTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._bookTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).bookTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool bookTagsRefs})
    >;
typedef $$BookTagsTableCreateCompanionBuilder =
    BookTagsCompanion Function({
      required int bookId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$BookTagsTableUpdateCompanionBuilder =
    BookTagsCompanion Function({
      Value<int> bookId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$BookTagsTableReferences
    extends BaseReferences<_$AppDatabase, $BookTagsTable, BookTag> {
  $$BookTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books.createAlias(
    $_aliasNameGenerator(db.bookTags.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.bookTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookTagsTableFilterComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookTagsTable,
          BookTag,
          $$BookTagsTableFilterComposer,
          $$BookTagsTableOrderingComposer,
          $$BookTagsTableAnnotationComposer,
          $$BookTagsTableCreateCompanionBuilder,
          $$BookTagsTableUpdateCompanionBuilder,
          (BookTag, $$BookTagsTableReferences),
          BookTag,
          PrefetchHooks Function({bool bookId, bool tagId})
        > {
  $$BookTagsTableTableManager(_$AppDatabase db, $BookTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  BookTagsCompanion(bookId: bookId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int bookId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => BookTagsCompanion.insert(
                bookId: bookId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$BookTagsTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$BookTagsTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$BookTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$BookTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookTagsTable,
      BookTag,
      $$BookTagsTableFilterComposer,
      $$BookTagsTableOrderingComposer,
      $$BookTagsTableAnnotationComposer,
      $$BookTagsTableCreateCompanionBuilder,
      $$BookTagsTableUpdateCompanionBuilder,
      (BookTag, $$BookTagsTableReferences),
      BookTag,
      PrefetchHooks Function({bool bookId, bool tagId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$BookTagsTableTableManager get bookTags =>
      $$BookTagsTableTableManager(_db, _db.bookTags);
}
