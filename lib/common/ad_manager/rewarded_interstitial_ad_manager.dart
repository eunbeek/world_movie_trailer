import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';
import 'package:world_movie_trailer/common/log_helper.dart';

class RewardedInterstitialAdManager {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool isShowingAd = false;

  // Method to load the rewarded interstitial ad
  void loadAd({required Function onAdLoaded}) {
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          print('Rewarded Interstitial Ad loaded');
          _rewardedInterstitialAd = ad;
          onAdLoaded();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load Rewarded Interstitial Ad: $error');
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
    if (_rewardedInterstitialAd == null) {
      print('Rewarded Interstitial Ad is not loaded yet.');
      loadAd(onAdLoaded: onAdDismissed);
      return;
    }
    DateTime adStartTime = DateTime.now();

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Rewarded Interstitial Ad showed');
        isShowingAd = true;
        LogHelper().logEvent('ad_start', parameters: {'startTime': adStartTime.toIso8601String()});
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded Interstitial Ad dismissed');
        isShowingAd = false;
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadAd(onAdLoaded: onAdDismissed);
        onAdDismissed();
        DateTime adEndTime = DateTime.now();
        Duration adWatchDuration = adEndTime.difference(adStartTime);
        LogHelper().logEvent('ad_duration', parameters: {'duration': adWatchDuration.inSeconds},);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded Interstitial Ad failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadAd(onAdLoaded: onAdDismissed);
        onAdDismissed();
      },
    );

    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }
}
