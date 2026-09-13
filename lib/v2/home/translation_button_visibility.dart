const contentSourceLanguages = <String, String>{
  'us': 'en',
  'ca': 'en',
  'au': 'en',
  'box_office': 'en',
  'special': 'en',
  'quotes': 'en',
  'kr': 'ko',
  'box_office_kr': 'ko',
  'jp': 'ja',
  'tw': 'tw',
  'cn': 'zh',
  'fr': 'fr',
  'de': 'de',
  'in': 'hi',
  'es': 'es',
  'th': 'th',
};

bool shouldShowTranslationForSources({
  required String selectedLanguage,
  required Iterable<String?> sources,
}) {
  if (sources.isEmpty) return false;
  return sources.any((source) {
    final originalLanguage = contentSourceLanguages[source];
    return originalLanguage == null || originalLanguage != selectedLanguage;
  });
}
