import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/model/quote.dart';

void main() {
  const languages = [
    'ko',
    'en',
    'ja',
    'zh',
    'tw',
    'fr',
    'de',
    'es',
    'hi',
    'th'
  ];
  const commonUiKeys = [
    'Translate',
    'Original',
    'Done',
    'Delete',
    'Settings',
    'Retry',
    'Trailer unavailable',
  ];

  test('common translated/original UI is defined for every supported language',
      () {
    for (final language in languages) {
      expect(languageDisplayNames[language], isNotEmpty, reason: language);
      for (final key in commonUiKeys) {
        expect(menuTranslations[language]?[key], isNotEmpty,
            reason: '$language/$key');
      }
    }
  });

  test('release labels use the matching translated constant', () {
    expect(getReleaseLabel('de'), labelReleaseDE);
  });

  test('quote localization supports every language key and English fallback',
      () {
    final quote = Quote.fromJson({
      'quoteEN': 'English quote',
      'movieEN': 'English movie',
      for (final language in languages.where((value) => value != 'en'))
        'quote${_suffix(language)}': '$language quote',
      for (final language in languages.where((value) => value != 'en'))
        'movie${_suffix(language)}': '$language movie',
    });

    for (final language in languages) {
      expect(quote.localizedQuote(language),
          language == 'en' ? 'English quote' : '$language quote');
      expect(quote.localizedMovie(language),
          language == 'en' ? 'English movie' : '$language movie');
    }
    expect(quote.localizedQuote('unknown'), 'English quote');
  });
}

String _suffix(String language) => const {
      'ko': 'KR',
      'ja': 'JP',
      'zh': 'ZH',
      'tw': 'TW',
      'fr': 'FR',
      'de': 'DE',
      'es': 'ES',
      'hi': 'HI',
      'th': 'TH',
    }[language]!;
