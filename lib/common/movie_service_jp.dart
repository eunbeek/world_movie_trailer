import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieServiceJP {
   static Future<List<Movie>> fetchFromEIGA() async {
    final response = await http.get(Uri.parse('https://eiga.com/movie/video/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load EIGA movies');
    }

    final document = html.parse(response.body);
    final movies = <Movie>[];
    final movieBoxes = document.querySelectorAll('li.col-s-4');

    for (final movieBox in movieBoxes) {
      final aTag = movieBox.querySelector('a');
      final pTag = movieBox.querySelector('p');

            if (aTag != null && pTag != null) {
        final title = pTag.text.trim();
        final href = aTag.attributes['href'] ?? '';
        final midxMatch = RegExp(r'/movie/(\d+)/video/').firstMatch(href);
        if (midxMatch == null) continue;
        
        final midx = midxMatch.group(1) ?? '';

        // Extract and parse the release date
        final releaseDateString = movieBox.querySelector('p.published')?.text ?? '';
        final releaseDate = _parseReleaseDateJP(releaseDateString);
        print(releaseDate);
        String status = 'Upcoming';
        if (releaseDate != null) {
          status = releaseDate.isAfter(DateTime.now()) ? 'Upcoming' : 'Running';
        }

        final trailer = await fetchMovieinfoJP(midx);

        movies.add(Movie(
          localTitle: title,
          engTitle: '', // Set English title if available
          posterUrl: trailer["posterUrl"] ?? '',
          trailerUrl: trailer["trailerUrl"] ?? '',
          country: jp,
          source: eiga,
          sourceIdx: int.parse(midx),
          spec: 'N/A',
          status: status,
        ));
      }
    }
    return movies;
  }

   // Function to parse the release date string
  static DateTime? _parseReleaseDateJP(String releaseDateString) {
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
    final response = await http.get(Uri.parse('https://eiga.com/movie/$midx/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load EIGA movies');
    }

    final document = html.parse(response.body);
    
    final posterElement = document.querySelector('.icon-movie-poster img');
    final posterUrl = posterElement?.attributes['src'];

    final trailerElement = document.querySelector('.thumb-play-btn');
    final trailerUrl = trailerElement?.attributes['data-movie'];

    return {
      'posterUrl': posterUrl ?? '',
      'trailerUrl': trailerUrl ?? '',
    };
  }
}