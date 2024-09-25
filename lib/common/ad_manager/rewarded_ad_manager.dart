import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool isShowingAd = false;

  // Method to load the rewarded ad
  void loadAd({required Function onAdLoaded}) {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Rewarded Ad loaded');
          _rewardedAd = ad;
          onAdLoaded();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load Rewarded Ad: $error');
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
    if (_rewardedAd == null) {
      print('Rewarded Ad is not loaded yet.');
      loadAd(onAdLoaded: onAdDismissed);
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Rewarded Ad showed');
        isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded Ad dismissed');
        isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        loadAd(onAdLoaded: onAdDismissed);
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded Ad failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        loadAd(onAdLoaded: onAdDismissed);
        onAdDismissed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }
}
