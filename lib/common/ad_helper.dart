import 'package:flutter/foundation.dart'; // For platform checking

class AdHelper {

  static String get rewardedUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3506417530430977/9393949997'; 
      // return 'ca-app-pub-3940256099942544/5224354917'; // test
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3506417530430977/8961908991'; 
      // return 'ca-app-pub-3940256099942544/1712485313'; // test
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}