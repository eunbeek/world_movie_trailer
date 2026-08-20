import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:world_movie_trailer/common/ad_helper.dart';
import 'package:world_movie_trailer/common/log_helper.dart';

class InterstitialAdManager {
  InterstitialAd? interstitialAd;
  bool isShowingAd = false;

  // Method to load the interstitial Ad
  void loadAd({required Function onAdLoaded, required Function onAdFailed}) {
    if (kIsWeb) {
      onAdFailed();
      return;
    }
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('interstitial Ad loaded');
          interstitialAd = ad;
          onAdLoaded();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial Ad: $error');
          interstitialAd = null;
          onAdFailed(); // 로드 실패 시 콜백 호출
        },
      ),
    );
  }

  // Method to show the ad
  void showAdIfAvailable(Function onAdDismissed) {
    if (kIsWeb) {
      onAdDismissed();
      return;
    }
    if (isShowingAd) {
      print('Ad is already being shown.');
      onAdDismissed();
      return;
    }
    if (interstitialAd == null) {
      print('interstitial Ad is not loaded yet.');
      loadAd(
        onAdLoaded: () => showAdIfAvailable(onAdDismissed),
        onAdFailed: onAdDismissed,
      );
      return;
    }

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('interstitial Ad showed');
        LogHelper().logEvent("ad_start", parameters: {
          'ad_type': 'interstitial Ad',
          'timestamp': DateTime.now().toIso8601String(),
        });
        isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('interstitial Ad dismissed');
        isShowingAd = false;
        ad.dispose();
        interstitialAd = null;
        onAdDismissed();
        loadAd(
          onAdLoaded: () => {},
          onAdFailed: () => {},
        );
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded Ad failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        interstitialAd = null;
        onAdDismissed();
      },
    );

    interstitialAd!.show();
  }

  Future<void> showAdIfAvailableAsync() {
    final completer = Completer<void>();
    showAdIfAvailable(() {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  void dispose() {
    interstitialAd?.dispose();
    interstitialAd = null;
  }
}
