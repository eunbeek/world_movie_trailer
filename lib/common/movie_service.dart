import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/movie_service_kr.dart';
import 'package:world_movie_trailer/common/movie_service_jp.dart';

class MovieService {
  // Entry point for fetching movies based on status and country
  static Future<List<Movie>> fetchMovie(String country) async {
    switch (country) {
      case kr:
        return fetchKRMovie();
      case jp:
        return fetchJPMovie();
      default:
        return fetchKRMovie();
    }
  }

  static Future<List<Movie>> fetchMovieMore(String country, List<Movie> countryMovies) async {
    switch (country) {
      case kr:
        return fetchKRMovieMore(countryMovies);
      case jp:
        return fetchKRMovieMore(countryMovies);
      default:
        return fetchKRMovieMore(countryMovies);
    }
  }

  static Future<Map<String, String?>> fetchMovieDetails(String country, Movie movie) async {
    switch (country) {
      case kr:
        return fetchKRMovieDetails(movie);
      case jp:
        return fetchJPMovieDetails(movie);
      default:
        return fetchKRMovieDetails(movie);
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

  static Future<Map<String, String?>> fetchKRMovieDetails(Movie movie) async {
      Map<String, String?> trailerData = movie.source == cgv ? 
        await MovieServiceKR.fetchTrailerFromCGV(movie.sourceIdx.toString()) 
        : await MovieServiceKR.fetchTrailerFromLOTTE(movie.sourceIdx.toString());
      return trailerData;
  }

  static Future<List<Movie>> fetchJPMovie() async {
    final stopWatchJP = Stopwatch()..start();
    List<Movie> eigaMovies = await MovieServiceJP.fetchRunningFromEIGA(false);
    List<Movie> eigaUpcomingMovies = await MovieServiceJP.fetchUpcomingFromEIGA();
    stopWatchJP.stop();
    print('fetchKR: ${stopWatchJP.elapsedMilliseconds}ms');
    return [...eigaMovies, ...eigaUpcomingMovies];
  }

  // static Future<List<Movie>> fetchJPMovieMore(List<Movie> moviesJP) async {
  //   final stopWatch = Stopwatch()..start();
  //   List<Movie> eigaMoreMovies = await MovieServiceJP.fetchMoreFromEIGA();
  //   stopWatch.stop();
  //   return eigaMoreMovies;
  // }

  static Future<Map<String, String?>> fetchJPMovieDetails(Movie movie) async {
      Map<String, String?> trailerData = 
        await MovieServiceJP.fetchMovieinfoJP(movie.sourceIdx.toString());

      return trailerData;
  }

}