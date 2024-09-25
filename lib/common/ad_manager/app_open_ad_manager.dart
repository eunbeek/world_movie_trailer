import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool isShowingAd = false;

  void loadAd({Function? onAdLoaded}) {
    AppOpenAd.load(
      adUnitId: AdHelper.appOpeningUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          print('App Open Ad loaded');
          _appOpenAd = ad;
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          print('Failed to load App Open Ad: $error');
        },
      ),
    );
  }

  // Method to show the ad
  void showAdIfAvailable(Function onAdDismissed) {
    if (isShowingAd) {
      print('Ad is already being shown.');
      return;
    }
    if (_appOpenAd == null) {
      print('App Open Ad is not loaded yet.');
      loadAd();
      onAdDismissed(); // Move forward to the next screen
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('App Open Ad showed');
        isShowingAd = false;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('App Open Ad dismissed');
        isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Preload next ad
        onAdDismissed(); // After the ad is dismissed, navigate to the next screen
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('App Open Ad failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Preload next ad
        onAdDismissed(); // Continue to the next screen even if the ad fails
      },
    );

    _appOpenAd!.show();
  }
}
