import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';

class RewardedAdManager {
  RewardedAd? rewardedAd;
  bool isShowingAd = false;

  // Method to load the rewarded ad with timeout handling
  void loadAdWithTimeout({required Function onAdLoaded, int timeoutSeconds = 5}) {
    bool isAdLoaded = false;
    loadAd(onAdLoaded: () {
      isAdLoaded = true;
      onAdLoaded();
    });

    // Timeout setting
    Future.delayed(Duration(seconds: timeoutSeconds), () {
      if (!isAdLoaded) {
        print('Loading Ad timed out.');
        onAdLoaded(); // Timeout occurred, invoke callback to proceed
      }
    });
  }
  
  // Method to load the rewarded ad
  void loadAd({required Function onAdLoaded}) {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Rewarded Ad loaded');
          rewardedAd = ad;
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
    if (rewardedAd == null) {
      print('Rewarded Ad is not loaded yet.');
      loadAdWithTimeout(onAdLoaded: onAdDismissed);
      return;
    }

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Rewarded Ad showed');
        isShowingAd = true;
        Future.delayed(Duration(seconds: 1), () {
          onAdDismissed();
        });
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded Ad dismissed');
        isShowingAd = false;
        ad.dispose();
        rewardedAd = null;
        loadAd(onAdLoaded: (){});
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded Ad failed to show: $error');
        isShowingAd = false;
        ad.dispose();
        rewardedAd = null;
        loadAd(onAdLoaded: (){});
      },
      onAdClicked: (ad) {
        print('Ad Clicked');
      }
    );

    rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }
}
