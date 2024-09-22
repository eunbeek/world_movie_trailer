import 'package:world_movie_trailer/model/quote.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class QuoteService {
  static Future<Box> _openBox() async {
    return await Hive.openBox<Quote>('quotesBox');
  }

  // Fetch quotes from Hive or Firebase and filter already shown quotes
  static Future<List<Quote>> fetchQuote() async {
    print('fetchQuote');
    Box box = await _openBox();

    // Check if quotes are stored in Hive
    List<Quote> storedQuotes = box.values.cast<Quote>().toList();
    List<Quote> quotes = [];

    if (storedQuotes.isNotEmpty) {
      // 필터링: isShowed가 false인 Quote만 선택
      quotes = storedQuotes.where((quote) => !quote.isShowed).toList();
      return quotes;
    } else {
      // Fetch new data from Firebase Storage
      Map<String, dynamic> newResult = await readQuotesFromStorage();
      quotes = newResult['quotes'];
      // Save the new data to Hive
      await _saveQuotesToHive(box, quotes);
      return quotes;
    }
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

  // Firebase에서 데이터를 불러오고 Hive에 저장
  static Future<Map<String, dynamic>> readQuotesFromStorage() async {
    try {
      print('readQuotesFromStorage');
      final ref = FirebaseStorage.instance.ref().child('quotes_special.json');
      final data = await ref.getData();
      final jsonString = utf8.decode(data!);

      // Decode the JSON string into a List
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final String timestamp = jsonData['timestamp'];
      final List<dynamic> quoteList = jsonData['quotes'];

      List<Quote> quotes = quoteList.map((json) {
        final quote = Quote.fromJson(json);
        return quote;
      }).toList();

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

  // 데이터가 오래되었는지 확인하는 함수
  static bool _isDataOutdated(DateTime lastFetched) {
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 182));
    return lastFetched.isBefore(sixMonthsAgo);
  }
}
