import 'package:hive/hive.dart';

part 'movie.g.dart'; // This part file will be generated later

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final String localTitle;

  @HiveField(1)
  final String posterUrl;

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
    );
  }
}
