import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Owns Google's UMP consent flow and is the single gate for ad requests.
class AdConsentManager {
  AdConsentManager._();

  static final instance = AdConsentManager._();

  bool _canRequestAds = false;
  bool get canRequestAds => !kIsWeb && _canRequestAds;

  Future<void> initialize() async {
    if (kIsWeb) return;
    final update = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => update.complete(),
      (_) => update.complete(),
    );
    await update.future;
    await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
  }

  Future<bool> privacyOptionsRequired() async {
    if (kIsWeb) return false;
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  Future<void> showPrivacyOptions() async {
    if (kIsWeb) return;
    await ConsentForm.showPrivacyOptionsForm((_) {});
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
  }
}
