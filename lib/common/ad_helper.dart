import 'package:flutter/foundation.dart';

class AdHelper {
  static const _includeGoogleTestAds = bool.fromEnvironment(
    'IncludeGoogleTestAds',
    defaultValue: false,
  );

  /// Debug/profile builds always use Google's official test ads. Release
  /// builds use production ads unless IncludeGoogleTestAds=true is supplied.
  static bool get usesGoogleTestAds => !kReleaseMode || _includeGoogleTestAds;

  static String get bannerUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return usesGoogleTestAds
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3506417530430977/5598024145';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return usesGoogleTestAds
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3506417530430977/4991519485';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return usesGoogleTestAds
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3506417530430977/9122336189';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return usesGoogleTestAds
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3506417530430977/5082968494';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
