import 'package:flutter/foundation.dart'; // For platform checking

class AdHelper {
  static String get interstitialUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // return 'ca-app-pub-3506417530430977/4328483623';
      return 'ca-app-pub-3940256099942544/1033173712'; // test
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // return 'ca-app-pub-3506417530430977/3849971476';
      return 'ca-app-pub-3940256099942544/4411468910'; // test
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
