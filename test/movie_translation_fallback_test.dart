import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/model/movie.dart';

void main() {
  test('empty translated fields fall back to origin source values', () {
    final movie = Movie.fromJson({
      'id': 'jp:tmdb:1368337',
      'posterUrl': 'https://image.tmdb.org/poster.jpg',
      'trailerUrl': 'https://youtube.com/watch?v=trailer',
      'releaseDate': '2026-09-01',
      'originSource': {
        'concept': '今月の監督',
        'title': 'オデュッセイア',
        'overview': '日本語の紹介',
        'country': 'JP',
        'credits': '監督名',
      },
      'translations': {
        'ko': {
          'title': '',
          'concept': '',
          'overview': '',
          'country': '',
          'credits': '',
        },
      },
    }, languageCode: 'ko');

    expect(movie.localTitle, 'オデュッセイア');
    expect(movie.special, '今月の監督');
    expect(movie.spec, '日本語の紹介');
    expect(movie.country, 'JP');
  });
}
