const _originLanguageByFeed = <String, String>{
  'kr': 'ko',
  'box_office_kr': 'ko',
  'jp': 'ja',
  'tw': 'tw',
  'cn': 'cn',
  'fr': 'fr',
  'de': 'de',
  'es': 'es',
  'in': 'in',
  'th': 'th',
  'us': 'en',
  'ca': 'en',
  'au': 'en',
  'box_office': 'en',
  'special': 'en',
  'quotes': 'en',
};

String detailOriginLanguage({
  String? sourceFeedCode,
  String? movieId,
}) {
  var feedCode = sourceFeedCode?.trim().toLowerCase() ?? '';
  if (feedCode.isEmpty) {
    feedCode = (movieId ?? '').split(':').first.toLowerCase();
  }
  return _originLanguageByFeed[feedCode] ?? 'en';
}

String detailLabelLanguage({
  required bool showOriginal,
  required String selectedLanguage,
  String? sourceFeedCode,
  String? movieId,
}) {
  if (!showOriginal) return selectedLanguage;
  final originLanguage = detailOriginLanguage(
    sourceFeedCode: sourceFeedCode,
    movieId: movieId,
  );
  return switch (originLanguage) {
    'cn' => 'zh',
    'in' => 'hi',
    _ => originLanguage,
  };
}

String detailOriginalCountry({
  required Map<String, dynamic> originSource,
  required Map<String, dynamic> translations,
  required String fallback,
  String? sourceFeedCode,
  String? movieId,
}) {
  final language = detailOriginLanguage(
    sourceFeedCode: sourceFeedCode,
    movieId: movieId,
  );
  final translation = translations[language];
  if (translation is Map) {
    final localized = (translation['country'] ?? '').toString().trim();
    if (localized.isNotEmpty) return localized;
  }

  final original = (originSource['country'] ?? '').toString().trim();
  return original.isNotEmpty ? original : fallback;
}
