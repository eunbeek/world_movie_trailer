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

  factory Movie.fromJson(Map<dynamic, dynamic> json) {
    return Movie(
      localTitle: json['localTitle'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      country: json['country'] ?? '',
      source: json['source'] ?? '',
      spec: json['spec'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      runtime: json['runtime'] ?? 0,
      credits: json['credits'] ?? {},
      status: json['status'] ?? '',
      special: json['special'] ?? '',
      year: json['year'] ?? '', 
      nameKR: json['NameKR'] ?? '', 
      nameJP: json['NameJP'] ?? '', 
      nameCH: json['NameCH'] ?? '', 
      nameTW: json['NameTW'] ?? '', 
      nameFR: json['NameFR'] ?? '', 
      nameDE: json['NameDE'] ?? '', 
      nameES: json['NameES'] ?? '', 
      nameHI: json['NameHI'] ?? '', 
      nameTH: json['NameTH'] ?? '', 
      isYoutube: json['isYoutube'] ??  true,
      period: int.tryParse(json['period']?.toString() ?? '0') ?? 0,
      rank: json['rank'] ?? '',
      lastRank: json['lastRank'] ?? '',
      totalGross: json['totalGross'] ?? '',
      weeks: json['weeks'] ?? '',
      distributor: json['distributor'] ?? '',
      isNewThisWeek: json['isNewThisWeek'] ?? false,
      weekStartDate: json['weekStartDate'] ?? '',
      weekEndDate: json['weekEndDate'] ?? ''
    );
  }
}
