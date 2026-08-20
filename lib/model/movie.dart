import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final String localTitle;

  @HiveField(1)
  String posterUrl;

  @HiveField(2)
  final String trailerUrl;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final String source;

  @HiveField(5)
  final String spec;

  @HiveField(6)
  final String releaseDate;

  @HiveField(7)
  dynamic runtime;

  @HiveField(8)
  Map<String, dynamic>? credits;

  @HiveField(9)
  String? status;

  @HiveField(10)
  String? special;

  @HiveField(11)
  String? year;

  @HiveField(12)
  String? nameKR;

  @HiveField(13)
  String? nameJP;

  @HiveField(14)
  String? nameCH;

  @HiveField(15)
  String? nameTW;

  @HiveField(16)
  String? nameFR;

  @HiveField(17)
  String? nameDE;

  @HiveField(18)
  String? nameES;

  @HiveField(19)
  String? nameHI;

  @HiveField(20)
  String? nameTH;

  @HiveField(21)
  bool? isYoutube;

  @HiveField(22)
  int? period;

  @HiveField(23)
  String? rank;

  @HiveField(24)
  String? lastRank;

  @HiveField(25)
  String? totalGross;

  @HiveField(26)
  String? weeks;

  @HiveField(27)
  String? distributor;

  @HiveField(28)
  bool? isNewThisWeek;

  @HiveField(29)
  String? weekStartDate;

  @HiveField(30)
  String? weekEndDate;

  // Schema v2 fields. Existing Hive field numbers 0-30 must never change:
  // bookmarks and memos created by v1 users are stored with those numbers.
  @HiveField(31)
  final String id;

  @HiveField(32)
  final String tid;

  @HiveField(33)
  final Map<String, dynamic> originSource;

  @HiveField(34)
  final Map<String, dynamic> translations;

  @HiveField(35)
  final Map<String, dynamic> metadata;

  Movie({
    required this.localTitle,
    required this.posterUrl,
    required this.trailerUrl,
    required this.country,
    required this.source,
    required this.spec,
    required this.releaseDate,
    this.runtime,
    this.credits,
    this.status,
    this.special, // special
    this.year, // special
    this.nameKR, // special
    this.nameJP, // special
    this.nameCH, // special
    this.nameTW, // special
    this.nameFR, // special
    this.nameDE, // special
    this.nameES, // special
    this.nameHI, // special
    this.nameTH, // special
    this.isYoutube, // es
    this.period, // special
    this.rank, // box office
    this.lastRank, // box office
    this.totalGross, // box office
    this.weeks, // box office
    this.distributor, // box office
    this.isNewThisWeek, // box office
    this.weekStartDate, // box office
    this.weekEndDate, // box office
    this.id = '',
    this.tid = '',
    this.originSource = const {},
    this.translations = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'localTitle': localTitle,
        'posterUrl': posterUrl,
        'trailerUrl': trailerUrl,
        'country': country,
        'source': source,
        'spec': spec,
        'releaseDate': releaseDate,
        'runtime': runtime,
        'credits': credits,
        'status': status,
        'special': special,
        'year': year,
        'nameKR': nameKR,
        'nameJP': nameJP,
        'nameCH': nameCH,
        'nameTW': nameTW,
        'nameFR': nameFR,
        'nameDE': nameDE,
        'nameES': nameES,
        'nameHI': nameHI,
        'nameTH': nameTH,
        'isYoutube': isYoutube,
        'period': period,
        'rank': rank,
        'lastRank': lastRank,
        'totalGross': totalGross,
        'weeks': weeks,
        'distributor': distributor,
        'isNewThisWeek': isNewThisWeek,
        'weekStartDate': weekStartDate,
        'weekEndDate': weekEndDate,
        'id': id,
        'tid': tid,
        'originSource': originSource,
        'translations': translations,
        'metadata': metadata,
      };

  factory Movie.fromJson(Map<dynamic, dynamic> json,
      {String languageCode = 'en'}) {
    final origin = json['originSource'] is Map
        ? Map<dynamic, dynamic>.from(json['originSource'])
        : <dynamic, dynamic>{};
    final metadata = json['metadata'] is Map
        ? Map<dynamic, dynamic>.from(json['metadata'])
        : <dynamic, dynamic>{};
    final translations = json['translations'] is Map
        ? Map<dynamic, dynamic>.from(json['translations'])
        : <dynamic, dynamic>{};
    const translationKeys = {'zh': 'cn', 'hi': 'in'};
    final translationKey = translationKeys[languageCode] ?? languageCode;
    final selected = translations[translationKey] is Map
        ? Map<dynamic, dynamic>.from(translations[translationKey])
        : <dynamic, dynamic>{};

    dynamic value(String key, [dynamic fallback = '']) =>
        json[key] ?? metadata[key] ?? fallback;
    String localized(String key, String legacyKey) =>
        (selected[key] ?? origin[key] ?? json[legacyKey] ?? '').toString();

    Map<String, dynamic> stringMap(Map<dynamic, dynamic> source) =>
        source.map((key, value) => MapEntry(key.toString(), value));

    Map<String, dynamic> creditsMap() {
      final raw = json['credits'];
      return raw is Map ? stringMap(Map<dynamic, dynamic>.from(raw)) : {};
    }

    return Movie(
        localTitle: localized('title', 'localTitle'),
        posterUrl: value('posterUrl').toString(),
        trailerUrl: value('trailerUrl').toString(),
        country: localized('country', 'country'),
        source: (value('source').toString().isNotEmpty
                ? value('source')
                : origin['credits'] ?? '')
            .toString(),
        spec: localized('overview', 'spec'),
        releaseDate: value('releaseDate').toString(),
        runtime: value('runtime', 0),
        credits: creditsMap(),
        status: value('status').toString(),
        special: (selected['concept'] ?? origin['concept'] ?? value('special'))
            .toString(),
        year: value('year').toString(),
        nameKR: translations['ko']?['credits'] ?? json['NameKR'] ?? '',
        nameJP: translations['ja']?['credits'] ?? json['NameJP'] ?? '',
        nameCH: translations['cn']?['credits'] ?? json['NameCH'] ?? '',
        nameTW: translations['tw']?['credits'] ?? json['NameTW'] ?? '',
        nameFR: translations['fr']?['credits'] ?? json['NameFR'] ?? '',
        nameDE: translations['de']?['credits'] ?? json['NameDE'] ?? '',
        nameES: translations['es']?['credits'] ?? json['NameES'] ?? '',
        nameHI: translations['in']?['credits'] ?? json['NameHI'] ?? '',
        nameTH: translations['th']?['credits'] ?? json['NameTH'] ?? '',
        isYoutube: value('isYoutube', true),
        period: int.tryParse(value('period', 0).toString()) ?? 0,
        rank: value('rank').toString(),
        lastRank: value('lastRank').toString(),
        totalGross: value('totalGross').toString(),
        weeks: value('weeks').toString(),
        distributor: value('distributor').toString(),
        isNewThisWeek: value('isNewThisWeek', false) == true,
        weekStartDate: value('weekStartDate').toString(),
        weekEndDate: value('weekEndDate').toString(),
        id: value('id').toString(),
        tid: value('tid').toString(),
        originSource: stringMap(origin),
        translations: stringMap(translations),
        metadata: stringMap(metadata));
  }
}
