import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 2)
class Quote extends HiveObject {
  @HiveField(0)
  final String quoteEN;

  @HiveField(1)
  final String movieEN;

  @HiveField(2)
  final String quoteKR;

  @HiveField(3)
  final String movieKR;

  @HiveField(4)
  final String quoteJP;

  @HiveField(5)
  final String movieJP;

  @HiveField(6)
  bool isShowed;

  @HiveField(7)
  int quoteKey;

  @HiveField(8)
  String timestamp;

  @HiveField(9)
  final Map<String, String> quoteTranslations;

  @HiveField(10)
  final Map<String, String> movieTranslations;

  Quote({
    required this.quoteEN,
    required this.movieEN,
    required this.quoteKR,
    required this.movieKR,
    required this.quoteJP,
    required this.movieJP,
    this.isShowed = false,
    required this.quoteKey,
    required this.timestamp,
    this.quoteTranslations = const {},
    this.movieTranslations = const {},
  });

  String localizedQuote(String language) {
    final value = quoteTranslations[language]?.trim() ?? '';
    return value.isNotEmpty ? value : quoteEN;
  }

  String localizedMovie(String language) {
    final value = movieTranslations[language]?.trim() ?? '';
    return value.isNotEmpty ? value : movieEN;
  }

  Map<String, dynamic> toJson() {
    return {
      'quoteEN': quoteEN,
      'movieEN': movieEN,
      'quoteKR': quoteKR,
      'movieKR': movieKR,
      'quoteJP': quoteJP,
      'movieJP': movieJP,
      'isShowed': isShowed,
      'quoteKey': quoteKey,
      'timestamp': timestamp,
      'quoteTranslations': quoteTranslations,
      'movieTranslations': movieTranslations,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    String text(String key) => (json[key] ?? '').toString();
    const suffixes = <String, String>{
      'en': 'EN',
      'ko': 'KR',
      'ja': 'JP',
      'zh': 'ZH',
      'tw': 'TW',
      'fr': 'FR',
      'de': 'DE',
      'es': 'ES',
      'hi': 'HI',
      'th': 'TH',
    };
    final quoteTranslations = <String, String>{};
    final movieTranslations = <String, String>{};
    for (final entry in suffixes.entries) {
      final quote = text('quote${entry.value}').trim();
      final movie = text('movie${entry.value}').trim();
      if (quote.isNotEmpty) quoteTranslations[entry.key] = quote;
      if (movie.isNotEmpty) movieTranslations[entry.key] = movie;
    }
    final translations = json['translations'];
    if (translations is Map) {
      for (final entry in translations.entries) {
        if (entry.value is! Map) continue;
        final language = entry.key.toString();
        final values = Map<dynamic, dynamic>.from(entry.value as Map);
        final quote = (values['quote'] ?? '').toString().trim();
        final movie = (values['movie'] ?? '').toString().trim();
        if (quote.isNotEmpty) quoteTranslations[language] = quote;
        if (movie.isNotEmpty) movieTranslations[language] = movie;
      }
    }
    return Quote(
      quoteEN: text('quoteEN'),
      movieEN: text('movieEN'),
      quoteKR: text('quoteKR'),
      movieKR: text('movieKR'),
      quoteJP: text('quoteJP'),
      movieJP: text('movieJP'),
      isShowed: json['isShowed'] == true,
      quoteKey: int.tryParse(text('quoteKey')) ?? 0,
      timestamp: text('timestamp'),
      quoteTranslations: quoteTranslations,
      movieTranslations: movieTranslations,
    );
  }
}
