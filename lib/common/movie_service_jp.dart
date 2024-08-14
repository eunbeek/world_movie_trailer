import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieServiceJP {
  static Future<List<Movie>> fetchRunningFromEIGA(bool isMore, {List<Movie>? moviesJP}) async {
    final response = await http.get(Uri.parse(isMore?eigaRunning : eigaMore));

    if (response.statusCode != 200) {
      throw Exception('Failed to load EIGA movies');
    }

    final document = html.parse(response.body);
    final movies = <Movie>[];
    final movieBoxes = document.querySelectorAll('section div.list-block');

    for (final movieBox in movieBoxes) {
      final aTag = movieBox.querySelector('div.img-box a');
      if (aTag != null) {
        final title = aTag.querySelector('img')?.attributes['alt'];
        if(isMore && moviesJP != null){
          final localTitle = title?.trim();

          if (moviesJP.any((movieJP) => movieJP.localTitle == localTitle)) continue;
        }

        final posterUrl = aTag.querySelector('img')?.attributes['src'];
        final href = aTag.attributes['href'] ?? '';
        final midxMatch = RegExp(r'/movie/(\d+)/').firstMatch(href);
        if (midxMatch == null) continue;
        
        final midx = midxMatch.group(1) ?? '';

        // Extract and parse the release date
        final releaseDateString = movieBox.querySelector('small.time')?.text ?? '';
        final releaseDate = _parseReleaseDate(releaseDateString);

        String status = 'Upcoming';
        if (releaseDate != null) {
          status = releaseDate.isAfter(DateTime.now()) ? 'Upcoming' : 'Running';
        }

        movies.add(Movie(
          localTitle: title!,
          engTitle: '',
          posterUrl: posterUrl!,
          trailerUrl: '',
          country: jp,
          source: eiga,
          sourceIdx: midx,
          spec: 'N/A',
          status: status,
        ));
      }
    }

    return movies;
  }

 static Future<List<Movie>> fetchUpcomingFromEIGA(bool isMore, {List<Movie>? moviesJP}) async {
    final response = await http.get(Uri.parse(isMore?eigaUpcoming:eigaMoreUpcoming));

    if (response.statusCode != 200) {
      throw Exception('Failed to load EIGA movies');
    }

    final document = html.parse(response.body);
    final movies = <Movie>[];
    final movieBoxes = document.querySelectorAll('li.col-s-4');

    for (final movieBox in movieBoxes) {
      final aTag = movieBox.querySelector('a');

      if (aTag != null) {

        final title = movieBox.querySelector('div.img-thumb')?.querySelector('img')?.attributes['alt'];
        if(isMore && moviesJP != null){
          final localTitle = title?.trim();

          if (moviesJP.any((movieJP) => movieJP.localTitle == localTitle)) continue;
        }

       
        final posterUrl = movieBox.querySelector('div.img-thumb')?.querySelector('img')?.attributes['src'];
        final href = aTag.attributes['href'] ?? '';
        final midxMatch = RegExp(r'/movie/(\d+)/video/').firstMatch(href);
        if (midxMatch == null) continue;
        
        final midx = midxMatch.group(1) ?? '';

        // Extract and parse the release date
        final releaseDateString = movieBox.querySelector('p.published')?.text ?? '';
        final releaseDate = _parseReleaseDateYear(releaseDateString);
        String status = 'Upcoming';
        if (releaseDate != null) {
          status = releaseDate.isAfter(DateTime.now()) ? 'Upcoming' : 'Running';
        }

        movies.add(Movie(
          localTitle: title!,
          engTitle: '', // Set English title if available
          posterUrl: posterUrl!,
          trailerUrl: '',
          country: jp,
          source: eiga,
          sourceIdx: midx,
          spec: 'N/A',
          status: status,
        ));
      }
    }
    return movies;
  }

  // Function to parse the release date string
  static DateTime? _parseReleaseDate(String releaseDateString) {
    final match = RegExp(r'(\d{1,2}月\d{1,2}日)').firstMatch(releaseDateString);
    if (match != null) {
      final currentYear = DateTime.now().year;  // Get the current year
      final dateString = '$currentYear-' + match.group(0)!.replaceAll('月', '-').replaceAll('日', '');

      try {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    return null;
  }

   // Function to parse the release date string
  static DateTime? _parseReleaseDateYear(String releaseDateString) {
    final match = RegExp(r'(\d{4}年\d{1,2}月\d{1,2}日)').firstMatch(releaseDateString);
    if (match != null) {
      final dateString = match.group(0)!.replaceAll('年', '-').replaceAll('月', '-').replaceAll('日', '');
      try {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    return null;
  }

  static Future<Map<String, String>> fetchMovieinfoJP(String midx) async {
    final response = await http.get(Uri.parse('$eigaDetail$midx/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load EIGA movies');
    }

    final document = html.parse(response.body);

    final trailerElement = document.querySelector('.thumb-play-btn');
    final trailerUrl = trailerElement?.attributes['data-movie'];

    return {
      'trailerUrl': trailerUrl ?? '',
    };
  }
}