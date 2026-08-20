import 'package:world_movie_trailer/model/quote.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class QuoteService {
  static Future<List<int>> _readQuotesBytes() async {
    if (!kIsWeb) {
      final data = await FirebaseStorage.instance
          .ref()
          .child('quotes_special.json')
          .getData();
      if (data == null) throw StateError('quotes_special.json is empty');
      return data;
    }
    final uri = Uri.https(
        'firebasestorage.googleapis.com',
        '/v0/b/world-movie-trailer-v2.firebasestorage.app/o/quotes_special.json',
        {'alt': 'media'});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw StateError('Quotes Storage HTTP ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  static Future<Box> _openBox() async {
    return await Hive.openBox<Quote>('quote_cache');
  }

  // Fetch quotes from Hive or Firebase and filter already shown quotes
  static Future<List<Quote>> fetchQuote() async {
    print('fetchQuote');
    Box box = await _openBox();

    // Check if quotes are stored in Hive
    List<Quote> storedQuotes = box.values.cast<Quote>().toList();
    List<Quote> quotes = [];

    // Storage is generated from WMT_RESOURCE and is the source of truth.
    // Preserve each user's shown state while replacing edited quote content.
    final newResult = await readQuotesFromStorage();
    final fetched = newResult['quotes'];
    if (fetched is List) {
      quotes = fetched.whereType<Quote>().toList();
    }
    if (quotes.isNotEmpty) {
      final shownByKey = {
        for (final quote in storedQuotes) quote.quoteKey: quote.isShowed,
      };
      for (final quote in quotes) {
        quote.isShowed = shownByKey[quote.quoteKey] ?? false;
      }
      await box.clear();
      await _saveQuotesToHive(box, quotes);
      return quotes;
    }

    // Keep the last successful local data when Storage is temporarily down.
    return storedQuotes;
  }

  // 개별 Quote의 isShowed 필드를 true로 변경
  static Future<void> markQuoteAsShown(Quote quote) async {
    print('markQuoteAsShown');
    Box box = await _openBox();

    // isShowed를 true로 설정하고 Hive에 저장
    quote.isShowed = true;

    // quoteKey로 저장
    await box.put(quote.quoteKey, quote);
  }

  // 개별 Quote의 isShowed 필드를 false로 변경
  static Future<void> unmarkQuoteAsShown(Quote quote) async {
    print('unmarkQuoteAsShown');
    Box box = await _openBox();

    // isShowed를 true로 설정하고 Hive에 저장
    quote.isShowed = false;

    // quoteKey로 저장
    await box.put(quote.quoteKey, quote);
  }

  // Firebase에서 데이터를 불러오고 Hive에 저장
  static Future<Map<String, dynamic>> readQuotesFromStorage() async {
    try {
      print('readQuotesFromStorage');
      final data = await _readQuotesBytes();
      final jsonString = utf8.decode(data);

      // Decode the JSON string into a List
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final String timestamp = (jsonData['timestamp'] ?? '').toString();
      final List<dynamic> quoteList =
          jsonData['quotes'] is List ? jsonData['quotes'] : const [];

      final List<Quote> quotes = [];
      for (final item in quoteList) {
        if (item is Map) {
          quotes.add(Quote.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      return {
        'timestamp': timestamp,
        'quotes': quotes,
      };
    } catch (e) {
      print('Error reading quotes: $e');
      return {
        'timestamp': null,
        'quotes': [],
      };
    }
  }

  // 모든 Quote들을 Hive에 저장
  static Future<void> _saveQuotesToHive(Box box, List<Quote> quotes) async {
    try {
      print('_saveQuotesToHive');

      // 각각의 quote를 개별적으로 저장
      for (var quote in quotes) {
        await box.put(quote.quoteKey, quote); // quoteKey를 key로 사용
      }

      print('Quotes saved to Hive successfully');
    } catch (err) {
      print('Error saving quotes to Hive: $err');
    }
  }
}
