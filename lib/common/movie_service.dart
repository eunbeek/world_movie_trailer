import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/movie_service_kr.dart';
import 'package:world_movie_trailer/common/movie_service_jp.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

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
        return fetchJPMovieMore(countryMovies);
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
        : {'trailerUrl': movie.trailerUrl};
      return trailerData;
  }

  static Future<List<Movie>> fetchJPMovie() async {
    final stopWatchJP = Stopwatch()..start();
    List<Movie> eigaMovies = await MovieServiceJP.fetchRunningFromEIGA(false);
    List<Movie> eigaUpcomingMovies = await MovieServiceJP.fetchUpcomingFromEIGA(false);
    stopWatchJP.stop();
    print('fetchJP: ${stopWatchJP.elapsedMilliseconds}ms');
    return [...eigaMovies, ...eigaUpcomingMovies];
  }

  static Future<List<Movie>> fetchJPMovieMore(List<Movie> moviesJP) async {
    final stopWatchJP = Stopwatch()..start();
    List<Movie> eigaMovies = await MovieServiceJP.fetchRunningFromEIGA(true, moviesJP: moviesJP);
    List<Movie> eigaUpcomingMovies = await MovieServiceJP.fetchUpcomingFromEIGA(true, moviesJP: moviesJP);
    stopWatchJP.stop();
    print('fetchJPMore: ${stopWatchJP.elapsedMilliseconds}ms');
    return [...eigaMovies, ...eigaUpcomingMovies];
  }

  static Future<Map<String, String?>> fetchJPMovieDetails(Movie movie) async {
      Map<String, String?> trailerData = 
        await MovieServiceJP.fetchMovieinfoJP(movie.sourceIdx.toString());

      return trailerData;
  }
  static Future<Map<String, String?>> fetchMovieInfoFromTMDB(String country, Movie movie) async {

    final response = await http.get(Uri.parse('https://cors-anywhere.herokuapp.com/https://www.themoviedb.org/search?query=${Uri.encodeComponent(movie.localTitle)}'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to search movie');
    }

    final document = html.parse(response.body);
    final movieBox = document.querySelector('div.details');
    String? link;
    if (movieBox != null) {
      link = movieBox.querySelector('a')?.attributes['href'];
    }

    if (link == null) {
      throw Exception('Failed to find movie link');
    }

    final res = await http.get(Uri.parse('https://cors-anywhere.herokuapp.com/https://www.themoviedb.org$link?language=${countryCodeByTMDB[country]}'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load movie detail');
    }

    final docu = html.parse(res.body);
    final score = docu.querySelector('div.user_score_chart')?.attributes['data-percent'];
    final overview = docu.querySelector('div.overview > p')?.text;

    return {
      'score': score ?? 'No score available',
      'overview': overview ?? 'No overview available',
    };
  }
}