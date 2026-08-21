import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';
import 'package:world_movie_trailer/common/log_helper.dart';

class RewardedTranslationAdManager {
  const RewardedTranslationAdManager._();

  static Future<bool> show() async {
    if (kIsWeb) return false;
    final completer = Completer<bool>();

    await RewardedAd.load(
      adUnitId: AdHelper.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          var earnedReward = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => LogHelper().logEvent(
              'translation_reward_ad_started',
            ),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) completer.complete(earnedReward);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              LogHelper().logEvent('translation_reward_ad_failed', parameters: {
                'reason': error.toString(),
              });
              if (!completer.isCompleted) completer.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (_, reward) {
            earnedReward = true;
            LogHelper()
                .logEvent('translation_reward_ad_completed', parameters: {
              'amount': reward.amount,
              'type': reward.type,
            });
          });
        },
        onAdFailedToLoad: (error) {
          LogHelper().logEvent('translation_reward_ad_failed', parameters: {
            'reason': error.toString(),
          });
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future;
  }
}
