import 'package:flutter/foundation.dart'; // For platform checking

class AdHelper {

  static String get rewardedUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3506417530430977/9393949997'; 
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3506417530430977/8961908991'; 
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
