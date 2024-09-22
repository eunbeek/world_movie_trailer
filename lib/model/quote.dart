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
    return Quote(
      quoteEN: json['quoteEN'] as String,
      movieEN: json['movieEN'] as String,
      quoteKR: json['quoteKR'] as String,
      movieKR: json['movieKR'] as String,
      quoteJP: json['quoteJP'] as String,
      movieJP: json['movieJP'] as String,
      isShowed: json['isShowed'] ?? false,
      quoteKey: int.parse(json['quoteKey']),
      timestamp: json['timestamp'] as String,
    );
  }
}
