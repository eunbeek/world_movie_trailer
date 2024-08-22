import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MovieService {
  // Entry point for fetching movies based on status and country
  static Future<List<Movie>> fetchMovie(String country) async {
    switch (country) {
      case kr:
        return await readMoviesFromStorage('kr');
      case jp:
        return await readMoviesFromStorage('jp');
      default:
        return await readMoviesFromStorage('na');
    }
  }

  static Future<List<Movie>> readMoviesFromStorage(String countryCode) async {
    try {
      print('read " ${countryCode}');
      final ref = FirebaseStorage.instance.ref().child('movies_$countryCode.json');
      print('data');
      final data = await ref.getData();
      final jsonString = utf8.decode(data!);
      final List<dynamic> jsonData = json.decode(jsonString);

      DateTime today = DateTime.now();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      // Map the JSON data to a list of Movie objects with status
      final List<Movie> movies = jsonData.map((json) {
        final movie = Movie.fromJson(json);

        // Parse the releaseDate with the specified format
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
        print(movie.localTitle);
        return movie;
      }).toList();

      return movies;
    } catch (e) {
      print('Error reading movies: $e');
      return []; // Return an empty list in case of an error
    }
  }
}
