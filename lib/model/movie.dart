class Movie {
  final String localTitle;
  final String engTitle;
  final String posterUrl;
  final String trailerUrl;
  final String country;
  final String source;
  final int sourceIdx;

  Movie({
    required this.localTitle,
    required this.engTitle,
    required this.posterUrl,
    required this.trailerUrl,
    required this.country,
    required this.source,
    required this.sourceIdx,
  });

  Map<String, dynamic> toJson() => {
    'localTitle': localTitle,
    'engTitle': engTitle,
    'posterUrl': posterUrl,
    'trailerUrl': trailerUrl,
    'country': country,
    'source': source,
    'sourceIdx': sourceIdx,
  };

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      localTitle: json['local_title'],
      engTitle: json['eng_title'],
      posterUrl: json['poster_url'],
      trailerUrl: json['trailer_url'],
      country: json['country'],
      source: json['source'],
      sourceIdx: json['source_idx'],
    );
  }
}
