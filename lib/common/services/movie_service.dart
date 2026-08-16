import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class MovieService {
  static const String _webStorageBucket =
      'world-movie-trailer-v2.firebasestorage.app';

  static Future<List<int>> _readStorageObject(String fileName) async {
    if (!kIsWeb) {
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final data = await ref.getData();
      if (data == null) throw StateError('Storage object is empty: $fileName');
      return data;
    }
    final uri = Uri.https(
        'firebasestorage.googleapis.com',
        '/v0/b/$_webStorageBucket/o/${Uri.encodeComponent(fileName)}',
        {'alt': 'media'});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw StateError('Storage HTTP ${response.statusCode}: $fileName');
    }
    return response.bodyBytes;
  }

  static Future<Box> _openBox() async {
    return await Hive.openBox('moviesBoxV2');
  }

  static const Set<String> storageCountryCodes = {
    'kr',
    'jp',
    'ca',
    'tw',
    'fr',
    'de',
    'th',
    'au',
    'es',
    'in',
    'cn',
    'us',
    'box_office',
    'box_office_kr',
    'special',
  };

  /// V2 entry point. UI routes use stable Storage codes and never reverse-map
  /// translated country labels back into API identifiers.
  static Future<List<Movie>> fetchMovieByCode(
      String countryCode, String languageCode) async {
    if (!storageCountryCodes.contains(countryCode)) {
      throw ArgumentError.value(
          countryCode, 'countryCode', 'Unsupported movie feed');
    }

    final box = await _openBox();
    final cacheKey =
        'movies_v2_${countryCode}_${_translationKey(languageCode)}';
    final cached = await _getMoviesFromHive(box, cacheKey);
    final cachedAt = cached['cachedAt'] as String?;
    if (cachedAt != null &&
        !_isV2CacheOutdated(DateTime.tryParse(cachedAt) ?? DateTime(1970))) {
      return (cached['movies'] as List?)?.whereType<Movie>().toList() ?? [];
    }

    final result = await readMoviesFromStorage(countryCode, languageCode);
    result['cachedAt'] = DateTime.now().toIso8601String();
    await _saveMoviesToHive(box, cacheKey, result);
    return (result['movies'] as List?)?.whereType<Movie>().toList() ?? [];
  }

  static Future<List<Movie>> fetchMovie(
      String country, String languageCode) async {
    print('fetchMovie');
    Box box = await _openBox();
    String countryCode;
    String? countryName = country == special
        ? special
        : country == boxOffice
            ? boxOffice
            : localizedCountries[languageCode]
                ?.entries
                .firstWhere((entry) => entry.value == country,
                    orElse: () => MapEntry('', ''))
                .key;

    switch (countryName) {
      case kr:
        countryCode = 'kr';
        break;
      case jp:
        countryCode = 'jp';
        break;
      case ca:
        countryCode = 'ca';
        break;
      case tw:
        countryCode = 'tw';
        break;
      case fr:
        countryCode = 'fr';
        break;
      case de:
        countryCode = 'de';
        break;
      case th:
        countryCode = 'th';
        break;
      case au:
        countryCode = 'au';
        break;
      case es:
        countryCode = 'es';
        break;
      case ind:
        countryCode = 'in';
        break;
      case cn:
        countryCode = 'cn';
        break;
      case boxOffice:
        countryCode = 'box_office';
        break;
      case special:
        countryCode = 'special';
        break;
      default:
        countryCode = 'us';
        break;
    }

    // Check if movies are stored in Hive
    // A Movie contains the selected localized values. Keep a cache per language
    // so changing the app language never returns objects localized previously.
    final cacheKey =
        'movies_v2_${countryCode}_${_translationKey(languageCode)}';
    Map<String, dynamic> result = await _getMoviesFromHive(box, cacheKey);
    List<Movie> movies = [];
    String? timestamp = result['timestamp'];

    if (timestamp != null &&
        !_isDataOutdated(DateTime.tryParse(timestamp) ?? DateTime(1970),
            countryCode == special,
            country: countryName)) {
      return result['movies'];
    } else {
      // Fetch new data from Firebase Storage
      Map<String, dynamic> newResult =
          await readMoviesFromStorage(countryCode, languageCode);
      final fetchedMovies = newResult['movies'];
      movies = fetchedMovies is List
          ? fetchedMovies.whereType<Movie>().toList()
          : <Movie>[];
      // Save the new data to Hive
      await _saveMoviesToHive(box, cacheKey, newResult);
      return movies;
    }
  }

  static Future<Map<String, dynamic>> readMoviesFromStorage(String countryCode,
      [String languageCode = 'en']) async {
    try {
      print('readMoviesFromStorage');
      final data = await _readStorageObject('movies_$countryCode.json');
      final jsonString = utf8.decode(data);

      // Decode the JSON string into a List
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Assuming jsonData[0] contains the timestamp and jsonData[1] contains the movies
      final String timestamp = (jsonData['timestamp'] ?? '').toString();

      final List<dynamic> movieList = jsonData['movies'] is List
          ? jsonData['movies'] as List<dynamic>
          : const [];

      // Process each movie
      DateTime today = DateTime.now();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      final List<Movie> movies = <Movie>[];
      for (final item in movieList) {
        if (item is! Map) continue;
        try {
          final movie = Movie.fromJson(
            Map<dynamic, dynamic>.from(item),
            languageCode: languageCode,
          );
          if (!movie.posterUrl.startsWith('http')) {
            movie.posterUrl = "";
          }
          // Native apps can display external crawler images directly. On
          // Web, only request origins whose CORS behavior we control or
          // explicitly trust; every other source falls back to the blank
          // poster instead of flooding the console with CORS errors.
          if (kIsWeb && !_isWebSafePoster(movie.posterUrl)) {
            movie.posterUrl = "";
          }
          DateTime? releaseDate;
          try {
            releaseDate = movie.releaseDate.isNotEmpty
                ? dateFormat.parseStrict(movie.releaseDate)
                : null;
          } catch (e) {
            print('Invalid date format: ${movie.releaseDate}');
            releaseDate = null;
          }

          if (releaseDate != null &&
              (releaseDate.isBefore(today) ||
                  releaseDate.isAtSameMomentAs(today))) {
            movie.status = 'Running';
          } else {
            movie.status = 'Upcoming';
          }

          if (movie.trailerUrl.isNotEmpty &&
              movie.localTitle.isNotEmpty &&
              movie.posterUrl.isNotEmpty &&
              (countryCode == special || movie.releaseDate.isNotEmpty)) {
            movies.add(movie);
          }
        } catch (error, stackTrace) {
          print('Skipping invalid movie JSON: $error');
          print(stackTrace);
        }
      }

      String normalizeTitle(String title) {
        return title
            .replaceAll(RegExp(r'[-:]', multiLine: true),
                ' ') // Replace `-` and `:` with a space
            .replaceAll(
                RegExp(r'\s+'), ' ') // Collapse multiple spaces into one
            .trim(); // Trim leading and trailing spaces
      }

      // Use a map to ensure unique trailerUrls and titles
      var uniqueMovies = <String, Movie>{};
      var trailerUrls = <String>{};

      for (var movie in movies) {
        String normalizedTitle = normalizeTitle(movie.localTitle);

        if (!trailerUrls.contains(movie.trailerUrl)) {
          uniqueMovies[normalizedTitle] = movie;
          trailerUrls.add(movie.trailerUrl);
        }
      }
      // Convert the Map back to a list
      List<Movie> finalMovies = uniqueMovies.values.toList();

      // Return a Map containing the timestamp and the processed movies
      return {
        'timestamp': timestamp,
        'movies': countryCode == 'special' ? movies : finalMovies,
      };
    } catch (e, stackTrace) {
      print('Error reading movies: $e');
      print(stackTrace);
      return {
        'timestamp': null,
        'movies': [],
      }; // Return an empty list and null timestamp in case of an error
    }
  }

  static Future<void> _saveMoviesToHive(
      Box box, String cacheKey, Map<String, dynamic> newUpdate) async {
    try {
      print('_saveMoviesToHive');

      Map<String, dynamic> dataToSave = newUpdate;

      await box.put(cacheKey, dataToSave);
      print('Movies saved to Hive successfully');
    } catch (err) {
      print('Error saving movies to Hive: $err');
    }
  }

  static Future<Map<String, dynamic>> _getMoviesFromHive(
      Box box, String cacheKey) async {
    print('_getMoviesFromHive');
    try {
      // Retrieve data as dynamic first
      final dynamic cached = box.get(cacheKey);
      Map<dynamic, dynamic>? storedData =
          cached is Map ? Map<dynamic, dynamic>.from(cached) : null;

      if (storedData != null) {
        // Convert JSON data back to Movie objects
        final rawMovies = storedData['movies'];
        final List<Movie> movies = rawMovies is List
            ? rawMovies
                .map<Movie?>((value) {
                  if (value is Movie) return value;
                  if (value is Map) {
                    return Movie.fromJson(Map<dynamic, dynamic>.from(value));
                  }
                  return null;
                })
                .whereType<Movie>()
                .toList()
            : [];

        return {
          'timestamp': storedData["timestamp"] as String?,
          'cachedAt': storedData["cachedAt"] as String?,
          'movies': movies,
        };
      }

      return {
        'timestamp': null,
        'movies': [],
      };
    } catch (err) {
      print('Error retrieving movies from Hive: $err');
      return {
        'timestamp': null,
        'movies': [],
      };
    }
  }

  static String _translationKey(String languageCode) {
    const aliases = {'zh': 'cn', 'hi': 'in'};
    return aliases[languageCode] ?? languageCode;
  }

  static bool _isV2CacheOutdated(DateTime lastFetched) {
    return DateTime.now().difference(lastFetched).inHours >= 6;
  }

  static bool _isWebSafePoster(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    return host == 'image.tmdb.org' ||
        host == 'firebasestorage.googleapis.com' ||
        host.endsWith('.firebasestorage.app') ||
        host == 'storage.googleapis.com';
  }

  static bool _isDataOutdated(DateTime lastFetched, bool isSpecial,
      {String? country}) {
    final now = DateTime.now();
    print('_isDataOutdated');
    if (isSpecial) {
      // For special sections, check if the year and month are the same
      return now.difference(lastFetched).inDays > 30;
    } else {
      if (country == null) return true;

      int? updateDay;
      countryByDay.forEach((day, countries) {
        if (countries.contains(country)) {
          updateDay = day;
        }
      });

      if (updateDay == null) return true;

      final nextUpdateDay = _nextUpdateDay(updateDay!, lastFetched);

      return now.isAfter(nextUpdateDay);
    }
  }

  static DateTime _nextUpdateDay(int updateDay, DateTime lastFetched) {
    // Get the day of the week for lastFetched (1 = Monday, 7 = Sunday)
    final fetchedDay = lastFetched.weekday;

    // Calculate the difference in days to the next update day
    final daysToNextUpdate = (updateDay - fetchedDay + 7) % 7;
    final nextUpdateDate = lastFetched
        .add(Duration(days: daysToNextUpdate == 0 ? 7 : daysToNextUpdate));

    return DateTime(
        nextUpdateDate.year, nextUpdateDate.month, nextUpdateDate.day);
  }

  static Future<String> fetchPromotionUrl() async {
    try {
      print('readMoviesFromStorage');
      final data = await _readStorageObject('promotion_url.json');
      final jsonString = utf8.decode(data);

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final String url = jsonData['url'];

      // Return a Map containing the timestamp and the processed movies
      return url;
    } catch (e) {
      print('Error reading movies: $e');
      return '';
    }
  }

  static Future<bool> fetchHotFixMode() async {
    try {
      print('Fetching hotFixMode from Firebase Storage...');
      final data = await _readStorageObject('hotFixMode.json');
      final jsonString = utf8.decode(data);

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final bool hotFixMode = jsonData['hotFixMode'] ?? false;

      return hotFixMode;
    } catch (e) {
      print('Error reading hotFixMode: $e');
      return false;
    }
  }
}
