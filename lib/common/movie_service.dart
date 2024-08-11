import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/movie_service_kr.dart';

class MovieService {
  // Entry point for fetching movies based on status and country
  static Future<List<Movie>> fetchMovie(String country) async {
    switch (country) {
      case kr:
        return fetchKRMovie();
      case jp:
        return fetchJPMovie();
      case na:
        return fetchNAMovie();
      case fr:
        return fetchFRMovie();
      default:
        return fetchKRMovie();
    }
  }

  static Future<List<Movie>> fetchMovieMore(String country, List<Movie> countryMovies) async {
    print(country);
    switch (country) {
      case kr:
        return fetchKRMovieMore(countryMovies);
      case jp:
        return fetchJPMovie();
      default:
        return fetchKRMovie();
    }
  }

  static Future<List<Movie>> fetchKRMovie() async {
    final stopWatch = Stopwatch()..start();
    List<Movie> lotteMovies = await MovieServiceKR.fetchNoTrailerFromLOTTE();
    stopWatch.stop();
    return lotteMovies;
  }

  static Future<List<Movie>> fetchKRMovieMore(List<Movie> moviesKR) async {
    final stopWatch = Stopwatch()..start();
    List<Movie> cgvMovies = await MovieServiceKR.fetchNoTrailerFromCGV(moviesKR);
    stopWatch.stop();
    return cgvMovies;
  }

  static Future<List<Movie>> fetchJPMovie() async {
    return [];
  }

  static Future<List<Movie>> fetchNAMovie() async {
    return [];
  }

  static Future<List<Movie>> fetchFRMovie() async {
    return [];
  }

}