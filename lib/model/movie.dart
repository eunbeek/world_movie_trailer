class Movie {
  final String localTitle;
  final String posterUrl;
  final String trailerUrl;
  final String country;
  final String source;
  final String spec;
  final String releaseDate;
  dynamic? runtime;
  Map<String, dynamic>? credits;
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
    'status': status
  };

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      localTitle: json['localTitle'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      country: json['country'] ?? '',
      source: json['source'] ?? '',
      spec: json['spec'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      runtime: json['runtime'] ?? 0,
      credits: json['credits']?? [],
    );
  }
}
