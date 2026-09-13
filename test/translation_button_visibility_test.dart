import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/v2/home/translation_button_visibility.dart';

void main() {
  test('English content hides translation for English settings', () {
    for (final source in ['us', 'ca', 'au', 'box_office']) {
      expect(
        shouldShowTranslationForSources(
          selectedLanguage: 'en',
          sources: [source],
        ),
        isFalse,
        reason: source,
      );
    }
  });

  test('translation appears when content language differs', () {
    expect(
      shouldShowTranslationForSources(
        selectedLanguage: 'en',
        sources: ['fr'],
      ),
      isTrue,
    );
    expect(
      shouldShowTranslationForSources(
        selectedLanguage: 'fr',
        sources: ['fr'],
      ),
      isFalse,
    );
    expect(
      shouldShowTranslationForSources(
        selectedLanguage: 'fr',
        sources: ['box_office'],
      ),
      isTrue,
    );
  });

  test('mixed-source bookmarks show translation when any item needs it', () {
    expect(
      shouldShowTranslationForSources(
        selectedLanguage: 'ko',
        sources: ['kr', 'box_office_kr'],
      ),
      isFalse,
    );
    expect(
      shouldShowTranslationForSources(
        selectedLanguage: 'ko',
        sources: ['kr', 'us'],
      ),
      isTrue,
    );
  });
}
