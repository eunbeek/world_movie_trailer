import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MovieService {
  static Future<Box> _openBox() async {
    return await Hive.openBox('moviesBox');
  }

  static Future<List<Movie>> fetchMovie(String country) async {
    print('fetchMovie');
    Box box = await _openBox();
    String countryCode;

    switch (country) {
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
      case special:
        countryCode = 'special';
        break;
      default:
        countryCode = 'na';
        break;
    }

    // Check if movies are stored in Hive
    Map<String, dynamic> result = await _getMoviesFromHive(box, countryCode);
    List<Movie> movies = [];
    String? timestamp = result['timestamp'];

    if (timestamp != null && !_isDataOutdated(DateTime.parse(timestamp))) {
      return result['movies'];
    } else {
      // Fetch new data from Firebase Storage
      Map<String, dynamic> newResult = await readMoviesFromStorage(countryCode);
      movies = newResult['movies'];
      // Save the new data to Hive
      await _saveMoviesToHive(box, countryCode, newResult);
      return movies;
    }
  }

  static Future<Map<String, dynamic>> readMoviesFromStorage(String countryCode) async {
    try {
      print('readMoviesFromStorage');
      final ref = FirebaseStorage.instance.ref().child('movies_$countryCode.json');
      final data = await ref.getData();
      final jsonString = utf8.decode(data!);

      // Decode the JSON string into a List
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Assuming jsonData[0] contains the timestamp and jsonData[1] contains the movies
      final String timestamp = jsonData['timestamp'];

      final List<dynamic> movieList = jsonData['movies'];

      // Process each movie
      DateTime today = DateTime.now();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      List<Movie> movies = movieList.map((json) {
        final movie = Movie.fromJson(json);

        DateTime? releaseDate;
        try {
          releaseDate = movie.releaseDate.isNotEmpty ? dateFormat.parseStrict(movie.releaseDate) : null;
        } catch (e) {
          print('Invalid date format: ${movie.releaseDate}');
          releaseDate = null;
        }

        if (releaseDate != null && (releaseDate.isBefore(today) || releaseDate.isAtSameMomentAs(today))) {
          movie.status = 'Running';
        } else {
          movie.status = 'Upcoming';
        }

        return movie;
      }).where((movie)=> movie.trailerUrl.isNotEmpty)
      .toList();

      // Return a Map containing the timestamp and the processed movies
      return {
        'timestamp': timestamp,
        'movies': movies,
      };
    } catch (e) {
      print('Error reading movies: $e');
      return {
        'timestamp': null,
        'movies': [],
      }; // Return an empty list and null timestamp in case of an error
    }
  }

  static Future<void> _saveMoviesToHive(Box box, String countryCode, Map<String, dynamic> newUpdate) async {
    try {
      print('_saveMoviesToHive');

      Map<String, dynamic> dataToSave = newUpdate;

      await box.put('movies_$countryCode', dataToSave);
      print('Movies saved to Hive successfully');
    } catch (err) {
      print('Error saving movies to Hive: $err');
    }
  }

  static Future<Map<String, dynamic>> _getMoviesFromHive(Box box, String countryCode) async {
    print('_getMoviesFromHive');
    try {
      // Retrieve data as dynamic first
      Map<dynamic, dynamic>? storedData = box.get('movies_$countryCode');

      if (storedData != null) {
        // Convert JSON data back to Movie objects
        List<Movie> movies = (storedData["movies"] as List<dynamic>).map((json) {
          return Movie(
            localTitle: json.localTitle as String,
            posterUrl: json.posterUrl as String,
            trailerUrl: json.trailerUrl ?? '',
            country: json.country as String,
            source: json.source as String,
            spec: json.spec as String,
            releaseDate: json.releaseDate ?? '',
            runtime: json.runtime ?? 0,
            credits: json.credits as Map<String, dynamic>? ?? {},
            status: json.status as String? ?? 'Upcoming',
            special: json.special as String? ?? '',
            year: json.year as String? ?? '',
            originName: json.originName as String? ?? '',
          );
        }).toList();

        return {
          'timestamp': storedData["timestamp"] as String?,
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


  static bool _isDataOutdated(DateTime lastFetched) {
    return DateTime.now().difference(lastFetched).inDays > 7; // Data older than a week is considered outdated
  }
}
