import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _androidSystemUiChannel = MethodChannel(
  'com.sunnyinnolab.worldMovieTrailer/system_ui',
);

bool get isAndroidApp =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Keeps the Android status bar visible while hiding its navigation bar.
Future<void> hideAndroidNavigationBar() async {
  if (!isAndroidApp) return;
  await _androidSystemUiChannel.invokeMethod<void>('hideNavigationBar');
}
