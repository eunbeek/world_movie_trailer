import 'package:flutter/foundation.dart'; // For platform checking

class AdHelper {
  // Setting page
  static String get bannerUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // return 'ca-app-pub-3506417530430977/5598024145';
      return 'ca-app-pub-3940256099942544/6300978111'; // test
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // return 'ca-app-pub-3506417530430977/4991519485';
      return 'ca-app-pub-3940256099942544/2934735716'; // test
    }
    throw UnsupportedError('Unsupported platform');
  }

  // translate, bookmark, upcoming button
  static String get rewardedUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // return 'ca-app-pub-3506417530430977/9122336189';
      return 'ca-app-pub-3940256099942544/5224354917'; // test
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // return 'ca-app-pub-3506417530430977/5082968494';
      return 'ca-app-pub-3940256099942544/1712485313'; // test
    }
    throw UnsupportedError('Unsupported platform');
  }
}
