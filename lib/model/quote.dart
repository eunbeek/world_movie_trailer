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
  });

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
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    String text(String key) => (json[key] ?? '').toString();
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
    );
  }
}
