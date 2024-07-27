import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieService {
  static Future<List<Movie>> fetchFromCgv(String status) async {
    String cgvUrl;

    switch (status) {
      case listFilterUpcoming:
        cgvUrl = cgvUrlUpcoming;
        break;
      case listFilterRunning:
        cgvUrl = cgvUrlRunning;
        break;
      default:
        cgvUrl = cgvUrlAll;
        break;
    }

    final response = await http.get(Uri.parse(cgvUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load thumbnails');
    }

    final document = html.parse(response.body);
    final trailers = <Movie>[];

    final movieBoxes = document.querySelectorAll('div.box-image');
    int startIndex = (status == listFilterUpcoming) ? 3 : 0; // Skip first 3 items if status is listFilterUpcoming

    for (int i = startIndex; i < movieBoxes.length; i++) {
      final movieBox = movieBoxes[i];
      final aTag = movieBox.querySelector('a');
      if (aTag != null) {
        final midxMatch = RegExp(r'midx=(\d+)').firstMatch(aTag.attributes['href'] ?? '');
        if (midxMatch != null) {
          final midx = midxMatch.group(1);
          if (midx != null) {
            final trailerData = await fetchVideoAndTitles(midx);
            if (trailerData['trailerUrl'] != null) {
              trailers.add(
                Movie(
                  localTitle: trailerData['localTitle'] ?? '',
                  engTitle: trailerData['engTitle'] ?? '',
                  posterUrl: aTag.querySelector('span.thumb-image img')?.attributes['src'] ?? '',
                  trailerUrl: trailerData['trailerUrl'] ?? '',
                  country: korea,
                  source: cgv,
                  sourceIdx: int.parse(midx),
                  spec: trailerData['spec'] ?? '',
                  status: status,
                ),
              );
            }
          }
        }
      }
    }

    return trailers;
  }

  static Future<Map<String, String?>> fetchVideoAndTitles(String midx) async {
    final response = await http.get(Uri.parse('$cgvDetailUrl$midx'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load video details');
    }

    final document = html.parse(response.body);
    String? trailerUrl;
    String localTitle = 'N/A';
    String engTitle = 'N/A';
    String spec = '';

    try {
      final trailerCount = document.querySelector('div.sect-trailer')?.querySelectorAll("li");
      if (trailerCount?.isEmpty ?? true) {
        return {
          'trailerUrl': null,
          'localTitle': localTitle,
          'engTitle': engTitle,
          'spec': spec,
        };
      }

      final popupButton = document.querySelector('a.movie_player_popup');
      if (popupButton != null) {
        final videoDataIdx = popupButton.attributes['data-gallery-idx'];
        if (videoDataIdx != null) {
          trailerUrl = "https://h.vod.cgv.co.kr/vodCGVa/$midx/${midx}_${videoDataIdx}_1200_128_960_540.mp4";
        }
      }

      final titleDiv = document.querySelector('div.title');
      final localTitleTag = titleDiv?.querySelector('strong');
      if (localTitleTag != null) {
        localTitle = localTitleTag.text.trim();
      }

      final engTitleTag = titleDiv?.querySelector('p');
      if (engTitleTag != null) {
        engTitle = engTitleTag.text.trim();
      }

      final specDiv = document.querySelector('div.spec');
      if (specDiv != null) {
        spec = specDiv.innerHtml.trim();
      }
    } catch (e) {
      print('An error occurred: $e');
    }

    return {
      'trailerUrl': trailerUrl ?? '',
      'localTitle': localTitle,
      'engTitle': engTitle,
      'spec': spec,
    };
  }
}
