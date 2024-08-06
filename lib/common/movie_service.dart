import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:intl/intl.dart';

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

  // Fetch movies from Korea (integrates CGV and Lotte Cinema)
  static Future<List<Movie>> fetchKRMovie() async {
    final stopWatch = Stopwatch()..start();
    List<Movie> cgvMovies = await fetchFromCgv();
    List<Movie> lotteMovies = await fetchFromLotte(cgvMovies);
    stopWatch.stop();
    print('fetchKR: ${stopWatch.elapsedMilliseconds}ms');
    return [...cgvMovies, ...lotteMovies];
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

  // Fetch movies from CGV based on the status
  static Future<List<Movie>> fetchFromCgv() async {
    final response = await http.get(Uri.parse(cgvUrlAll));

    if (response.statusCode != 200) {
      throw Exception('Failed to load thumbnails');
    }

    final document = html.parse(response.body);
    final trailers = <Movie>[];
    final movieBoxes = document.querySelectorAll('div.box-image');


    for (int i = 0; i < movieBoxes.length; i++) {
      final movieBox = movieBoxes[i];
      final aTag = movieBox.querySelector('a');
      if (aTag != null) {
        final midxMatch = RegExp(r'midx=(\d+)').firstMatch(aTag.attributes['href'] ?? '');
        if (midxMatch != null) {
          final midx = midxMatch.group(1);
          if (midx != null) {
            final trailerData = await fetchMovieInfoFromCGV(midx);
            if (trailerData['trailerUrl'] != null) {
              trailers.add(Movie(
                localTitle: trailerData['localTitle'] ?? '',
                engTitle: trailerData['engTitle'] ?? '',
                posterUrl: aTag.querySelector('span.thumb-image img')?.attributes['src'] ?? '',
                trailerUrl: trailerData['trailerUrl'] ?? '',
                country: kr,
                source: cgv,
                sourceIdx: int.parse(midx),
                spec: 'N/A',
                status: trailerData['status'] ?? 'Upcoming',
              ));
            }
          }
        }
      }
    }

    return trailers;
  }

  // Fetch video and titles for a specific movie from CGV
  static Future<Map<String, String?>> fetchMovieInfoFromCGV(String midx) async {
    final response = await http.get(Uri.parse('$cgvDetailUrl$midx'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load video details');
    }

    final document = html.parse(response.body);
    String? trailerUrl;
    String localTitle = 'N/A';
    String engTitle = 'N/A';
    String spec = '';
    DateTime? releaseDate;

    try {
      final trailerCount = document.querySelector('div.sect-trailer')?.querySelectorAll("li");
      if (trailerCount?.isEmpty ?? true) {
        return {
          'trailerUrl': null,
          'localTitle': null,
          'engTitle': null,
          'status': null,
          'spec': null,
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

      final releaseDateString = document.querySelectorAll('dd.on').last.text.trim();

      releaseDate = DateFormat('yyyy.MM.dd').parse(releaseDateString);

      final specDiv = document.querySelector('div.spec');
      if (specDiv != null) {
        spec = specDiv.innerHtml.trim();
      }
    } catch (e) {
      print('An error occurred: $e');
    }

    String status = '';
    if (releaseDate != null) {
      status = releaseDate.isAfter(DateTime.now()) ? 'Upcoming' : 'Running';
    }

    return {
      'trailerUrl': trailerUrl ?? '',
      'localTitle': localTitle,
      'engTitle': engTitle,
      'status': status,
      'spec': spec,
    };
  }

  static Future<List<Movie>> fetchFromLotte(List<Movie> cgvMovies) async {
    final List<Map<String, dynamic>> requestDataList = [
      {
        "MethodName": "GetMoviesToBe",
        "channelType": "HO",
        "osType": "Chrome",
        "osVersion": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
        "multiLanguageID": "EN",
        "division": 1,
        "moviePlayYN": 'Y',
        "orderType": "1",
        "blockSize": 100,
        "pageNo": 1,
        "memberOnNo": ""
      },
      {
        "MethodName": "GetMoviesToBe",
        "channelType": "HO",
        "osType": "Chrome",
        "osVersion": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
        "multiLanguageID": "EN",
        "division": 1,
        "moviePlayYN": 'N',
        "orderType": "1",
        "blockSize": 100,
        "pageNo": 1,
        "memberOnNo": ""
      }
    ];

    final trailers = <Movie>[];

    for (var requestData in requestDataList) {
      String requestDataJson = jsonEncode(requestData);

      final response = await http.post(
        Uri.parse(lotteDetail),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {'paramList': requestDataJson},
      );

      if (response.statusCode != 200) {
        print('Failed to load movie data');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }

      try {
        final responseData = json.decode(response.body);
        final movies = responseData['Movies']['Items'] as List;

        for (var movieJson in movies) {
          if (movieJson['RepresentationMovieCode'] == 'AD' ||
              cgvMovies.any((cgvMovie) => _normalizeTitle(cgvMovie.localTitle) == _normalizeTitle(movieJson['MovieNameKR']))) {
            continue;
          }
          String? trailerUrl = await _isTrailerExist(movieJson['RepresentationMovieCode']);

          if (trailerUrl != null) {
            trailers.add(Movie(
              localTitle: movieJson['MovieNameKR'] as String,
              engTitle: '',
              posterUrl: movieJson['PosterURL'] as String,
              trailerUrl: trailerUrl,
              country: 'kr',
              source: 'lotte',
              sourceIdx: int.parse(movieJson['RepresentationMovieCode'] as String),
              spec: 'N/A',
              status: requestData['moviePlayYN'] == 'Y' ? 'Running' : 'Upcoming',
            ));
          }
        }
      } catch (e) {
        print('Failed to parse response body as JSON');
        print('Error: $e');
        return [];
      }
    }

    return trailers;
  }

  static Future<String?> _isTrailerExist(String midx) async {
    try {
      final Map<String, dynamic> requestData = {
        "MethodName": "GetMovieDetailTOBE",
        "channelType": "HO",
        "osType": "Chrome",
        "osVersion": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
        "multiLanguageID": "KR",
        "representationMovieCode": midx,
        "memberOnNo": ""
      };

      String requestDataJson = jsonEncode(requestData);

      final response = await http.post(
        Uri.parse(lotteDetail),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {'paramList': requestDataJson},
      );

    final responseData = json.decode(response.body);
    final trailers = responseData['Trailer']["Items"] as List;

    // MediaURL이 비어있지 않은 마지막 요소를 필터링하여 찾기
    final trailer = trailers.lastWhere((item) => item["MediaURL"].isNotEmpty, orElse: () => null);

    if (trailer != null) {
      final traileURL = trailer["MediaURL"];
      return traileURL;
    } else {
      return null;
    }
    } catch (e) {
      print('Failed to check trailer URL: $e');
      return null;
    }
  }

  static String _normalizeTitle(String title) {
    return title.replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }
}