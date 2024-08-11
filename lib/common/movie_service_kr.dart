import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieServiceKR {
  // Fetch Movies list from CGV except lotte movie
  static Future<List<Movie>> fetchNoTrailerFromCGV(List<Movie> lotteMovies) async {

    final movies = <Movie>[];

    // Existing URLs for fetching current and upcoming movies
    final cgvUrls = {cgvUrlRunning, cgvUrlUpcoming};
    for (var url in cgvUrls) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load thumbnails');
      }

      final document = html.parse(response.body);
      final movieBoxes = document.querySelectorAll('div.sect-movie-chart ol li');
      final startPointByStatus = url == cgvUrlRunning ? 0 : 3;

      for (var i = startPointByStatus; i < movieBoxes.length; i++) {
        final titleElement = movieBoxes[i].querySelector('.box-contents .title');

        if (titleElement == null ) continue;

        final localTitle = titleElement.text.trim();

        if (lotteMovies.any((lotteMovie) => lotteMovie.localTitle == localTitle)) continue;
        
        final posterElement = movieBoxes[i].querySelector('.thumb-image img');
        final posterUrl = posterElement?.attributes['src'] ?? '';

        final aTag = movieBoxes[i].querySelector('a');
        final midxMatch = RegExp(r'midx=(\d+)').firstMatch(aTag?.attributes['href'] ?? '');
        final midx = midxMatch?.group(1) ?? '0';

        // final status = movieBoxes[i].querySelector('.txt-info strong em.dday') != null
        //     ? listFilterUpcoming
        //     : listFilterRunning;
        final status = url == cgvUrlRunning ? listFilterRunning: listFilterUpcoming;

        final movie = Movie(
          localTitle: localTitle,
          engTitle: '',
          posterUrl: posterUrl,
          trailerUrl: '',
          country: kr,
          source: cgv,
          sourceIdx: int.parse(midx),
          spec: '',
          status: status,
        );

        movies.add(movie);
      }
      if(url == cgvUrlRunning){
        // Fetch additional movies
        final additionalMoviesResponse = await http.get(Uri.parse(cgvMoreMoviesUrl), headers: cgvMoreMovieHeader);

        if (additionalMoviesResponse.statusCode != 200) {
          throw Exception('Failed to load more movies');
        }

        final jsonResponse = json.decode(additionalMoviesResponse.body) as Map<String, dynamic>;
        final additionalMoviesData = json.decode(jsonResponse['d']) as Map<String, dynamic>;  // Access the nested data
        _processAdditionalMovies(additionalMoviesData['List'], movies, lotteMovies);
      }
    }

    return movies;
  }

  static void _processAdditionalMovies(List<dynamic> movieList, List<Movie> movies, List<Movie> lotteMovies) {
    if (movieList.isEmpty) return;

    for (var movieJson in movieList) {
      final localTitle = movieJson['Title'] ?? 'Unknown';
      final engTitle = movieJson['EnglishTitle'] ?? '';
      final posterUrl = movieJson['PosterImage']['LargeImage'] ?? '';
      final midx = movieJson['MovieIdx'] ?? '0';

      if (lotteMovies.any((lotteMovie) => lotteMovie.localTitle == localTitle)) continue;

      final movie = Movie(
        localTitle: localTitle,
        engTitle: engTitle,
        posterUrl: posterUrl,
        trailerUrl: '',
        country: kr,
        source: cgv,
        sourceIdx: midx,
        spec: '',
        status: listFilterRunning,
      );

      movies.add(movie);
    }
  }
  
  static Future<Map<String, String?>> fetchTrailerFromCGV(String midx) async {
    final response = await http.get(Uri.parse('$cgvDetailUrl$midx'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load video details');
    }

    final document = html.parse(response.body);
    String? trailerUrl;
    String? engTitle;

    try {
      final trailerCount = document.querySelector('div.sect-trailer')?.querySelectorAll("li");

      if (trailerCount?.isEmpty ?? true) {
        return {
          'trailerUrl': null,
          'engTitle': null,
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

      final engTitleTag = titleDiv?.querySelector('p');
      if (engTitleTag != null) {
        engTitle = engTitleTag.text.trim();
      }

    } catch (e) {
      print('An error occurred: $e');
    }

    return {
      'trailerUrl': trailerUrl ?? '',
      'engTitle': engTitle ?? '',
    };
  }

  static Future<List<Movie>> fetchNoTrailerFromLOTTE() async {
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

    final movies = <Movie>[];

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
        final moviesList = responseData['Movies']['Items'] as List;

        for (var movieJson in moviesList) {
          if (movieJson['RepresentationMovieCode'] == 'AD') continue;
          // final posterUrl = "https://cors-anywhere.herokuapp.com/" +   movieJson['PosterURL'];
          final posterUrl = movieJson['PosterURL'];
          movies.add(Movie(
            localTitle: movieJson['MovieNameKR'] as String,
            engTitle: '',
            posterUrl: posterUrl,
            trailerUrl: '',
            country: kr,
            source: lotte,
            sourceIdx: int.parse(movieJson['RepresentationMovieCode'] as String),
            spec: '',
            status: requestData['moviePlayYN'] == 'Y' ? 'Running' : 'Upcoming',
          ));
        }
      } catch (e) {
        print('Failed to parse response body as JSON');
        print('Error: $e');
        return [];
      }
    }

    return movies;
  }
  
  static Future<String?> fetchTrailerFromLOTTE(String midx) async {
    try {
      final Map<String, dynamic> requestData = {
        "MethodName": "GetMovieDetailTOBE",
        "channelType": "HO",
        "osType": "Chrome",
        "osVersion": "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
        "multiLanguageID": "EN",
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
}