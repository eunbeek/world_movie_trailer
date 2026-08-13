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

  Movie(
      {required this.localTitle,
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
      this.weekEndDate // box office
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
        'weekEndDate': weekEndDate
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

    return Movie(
        localTitle: localized('title', 'localTitle'),
        posterUrl: value('posterUrl'),
        trailerUrl: value('trailerUrl'),
        country: localized('country', 'country'),
        source: value('source'),
        spec: localized('overview', 'spec'),
        releaseDate: value('releaseDate'),
        runtime: value('runtime', 0),
        credits: value('credits', <String, dynamic>{}),
        status: value('status'),
        special: (selected['concept'] ?? origin['concept'] ?? value('special'))
            .toString(),
        year: value('year'),
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
        rank: value('rank'),
        lastRank: value('lastRank'),
        totalGross: value('totalGross'),
        weeks: value('weeks'),
        distributor: value('distributor'),
        isNewThisWeek: value('isNewThisWeek', false),
        weekStartDate: value('weekStartDate'),
        weekEndDate: value('weekEndDate'));
  }
}
