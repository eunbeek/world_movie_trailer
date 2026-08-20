import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/translation_access.dart';

void main() {
  test('free users default to original and cannot translate', () {
    expect(TranslationAccess.defaultToTranslation(isPremium: false), isFalse);
    expect(TranslationAccess.canTranslate(isPremium: false), isFalse);
  });

  test('premium users can use translated content', () {
    expect(TranslationAccess.defaultToTranslation(isPremium: true), isTrue);
    expect(TranslationAccess.canTranslate(isPremium: true), isTrue);
  });

  test('US and Korean box office notifications are configured separately', () {
    expect(countryByDay[1], containsAll(['box_us', 'box_kr']));
    expect(countryByDay[1]!.where((key) => key.startsWith('box_')).length, 2);
  });
}
