import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/detail_country_localization.dart';

void main() {
  final translations = <String, dynamic>{
    'ko': {'country': '미국'},
    'en': {'country': 'United States'},
    'ja': {'country': 'アメリカ合衆国'},
    'fr': {'country': 'États-Unis'},
  };

  test('uses the source feed native language in original mode', () {
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'US'},
        translations: translations,
        fallback: 'US',
        sourceFeedCode: 'kr',
      ),
      '미국',
    );
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'US'},
        translations: translations,
        fallback: 'US',
        sourceFeedCode: 'jp',
      ),
      'アメリカ合衆国',
    );
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'US'},
        translations: translations,
        fallback: 'US',
        sourceFeedCode: 'fr',
      ),
      'États-Unis',
    );
  });

  test('detail labels follow translation state and source feed language', () {
    expect(
      detailLabelLanguage(
        showOriginal: false,
        selectedLanguage: 'ko',
        sourceFeedCode: 'us',
      ),
      'ko',
    );
    expect(
      detailLabelLanguage(
        showOriginal: true,
        selectedLanguage: 'ko',
        sourceFeedCode: 'us',
      ),
      'en',
    );
    expect(
      detailLabelLanguage(
        showOriginal: true,
        selectedLanguage: 'en',
        sourceFeedCode: 'kr',
      ),
      'ko',
    );
    expect(
      detailLabelLanguage(
        showOriginal: true,
        selectedLanguage: 'ko',
        sourceFeedCode: 'special',
      ),
      'en',
    );
    expect(
      detailLabelLanguage(
        showOriginal: true,
        selectedLanguage: 'ko',
        sourceFeedCode: 'box_office_kr',
      ),
      'ko',
    );
    expect(
      detailLabelLanguage(
        showOriginal: true,
        selectedLanguage: 'ko',
        movieId: 'cn:tmdb:123',
      ),
      'zh',
    );
  });

  test('supports box office, special, and bookmark movie id fallback', () {
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'US'},
        translations: translations,
        fallback: 'US',
        sourceFeedCode: 'box_office_kr',
      ),
      '미국',
    );
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'U.S.'},
        translations: translations,
        fallback: 'U.S.',
        sourceFeedCode: 'special',
      ),
      'United States',
    );
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'US'},
        translations: translations,
        fallback: 'US',
        movieId: 'kr:tmdb:123',
      ),
      '미국',
    );
  });

  test('falls back to origin source when native translation is unavailable',
      () {
    expect(
      detailOriginalCountry(
        originSource: const {'country': 'Brazil'},
        translations: const {},
        fallback: 'BR',
        sourceFeedCode: 'kr',
      ),
      'Brazil',
    );
  });
}
