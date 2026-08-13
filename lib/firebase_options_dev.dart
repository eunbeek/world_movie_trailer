// File generated from the world-movie-trailer-v2 Firebase app registrations.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DevFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DevFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5R97bRJpXoiL2lhAgi7h7KJDbgA1l_dE',
    appId: '1:1034047577753:android:0b4015c6114e7468dfa208',
    messagingSenderId: '1034047577753',
    projectId: 'world-movie-trailer-v2',
    storageBucket: 'world-movie-trailer-v2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIZsSc5DbyW2ZIXzOKmV8wuO7xa89Z5mU',
    appId: '1:1034047577753:ios:f2d23cf425778a1bdfa208',
    messagingSenderId: '1034047577753',
    projectId: 'world-movie-trailer-v2',
    storageBucket: 'world-movie-trailer-v2.firebasestorage.app',
    iosBundleId: 'com.sunnyinnolab.worldMovieTrailer.dev',
  );
}
