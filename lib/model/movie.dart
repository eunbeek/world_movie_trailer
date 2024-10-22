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
    this.special,
    this.year,
    this.nameKR,
    this.nameJP,
    this.nameCH,
    this.nameTW,
    this.nameFR,
    this.nameDE,
    this.nameES,
    this.nameHI,
    this.nameTH,
    this.isYoutube,
    this.period,
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
    );
  }
}
