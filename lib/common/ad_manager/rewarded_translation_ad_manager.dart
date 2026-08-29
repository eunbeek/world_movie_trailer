import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';
import 'package:world_movie_trailer/common/log_helper.dart';

class RewardedTranslationAdManager {
  const RewardedTranslationAdManager._();

  static RewardedAd? _cachedAd;
  static Future<void>? _loading;
  static bool _showing = false;

  /// Starts loading the next rewarded ad without blocking app startup.
  static Future<void> preload() {
    if (kIsWeb || _cachedAd != null) return Future.value();
    final existingLoad = _loading;
    if (existingLoad != null) return existingLoad;

    final completer = Completer<void>();
    _loading = completer.future;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          _loading = null;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          _loading = null;
          LogHelper().logEvent('translation_reward_ad_failed', parameters: {
            'reason': error.toString(),
          });
          completer.complete();
        },
      ),
    );
    return completer.future;
  }

  static Future<bool> show() async {
    if (kIsWeb || _showing) return false;
    await preload();
    final ad = _cachedAd;
    _cachedAd = null;
    if (ad == null) return false;

    _showing = true;
    final completer = Completer<bool>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => LogHelper().logEvent(
        'translation_reward_ad_started',
      ),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showing = false;
        unawaited(preload());
        if (!completer.isCompleted) completer.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _showing = false;
        unawaited(preload());
        LogHelper().logEvent('translation_reward_ad_failed', parameters: {
          'reason': error.toString(),
        });
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, reward) {
      earnedReward = true;
      LogHelper().logEvent('translation_reward_ad_completed', parameters: {
        'amount': reward.amount,
        'type': reward.type,
      });
    });

    return completer.future;
  }
}
