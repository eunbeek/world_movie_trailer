import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/tmdb_credit_info.dart';

void main() {
  test('looks up a localized credit name using TMDB ID and language alias', () {
    final translations = <String, dynamic>{
      'cn': {
        'creditNames': {'525': '克里斯托弗·诺兰'},
      },
    };

    expect(
      localizedTmdbCreditName(
        translations: translations,
        language: 'zh',
        tmdbId: 525,
        fallback: 'Christopher Nolan',
      ),
      '克里斯托弗·诺兰',
    );
  });

  test('falls back to the original name when no mapping exists', () {
    expect(
      localizedTmdbCreditName(
        translations: const {},
        language: 'ja',
        tmdbId: 525,
        fallback: 'Christopher Nolan',
      ),
      'Christopher Nolan',
    );
  });

  test('special credits keep localized names and attach a TMDB ID', () {
    final people = specialTmdbCreditPeople(
      displayCredits: 'ポン・ジュノ',
      originalCredits: 'Bong Joon-Ho',
      credits: {
        'cast': <dynamic>[],
        'crew': [
          {'id': 21684, 'name': 'Bong Joon Ho', 'job': 'Director'},
        ],
      },
    );

    expect(people, hasLength(1));
    expect(people.single.name, 'ポン・ジュノ');
    expect(people.single.tmdbId, 21684);
  });
}
