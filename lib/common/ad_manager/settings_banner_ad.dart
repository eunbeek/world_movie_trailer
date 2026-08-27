import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

class SettingsBannerAd extends StatefulWidget {
  const SettingsBannerAd({super.key});

  @override
  State<SettingsBannerAd> createState() => _SettingsBannerAdState();
}

class _SettingsBannerAdState extends State<SettingsBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;
  int? _requestedWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0 || width == _requestedWidth) return;
    _requestedWidth = width;
    _loadAdaptiveBanner(width);
  }

  Future<void> _loadAdaptiveBanner(int width) async {
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null || width != _requestedWidth) return;
    await _ad?.dispose();
    setState(() => _loaded = false);
    _ad = BannerAd(
      adUnitId: AdHelper.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || context.watch<SettingsProvider>().isAdsFree) {
      return const SizedBox.shrink();
    }
    if (!_loaded || _ad == null) return const SizedBox(height: 50);
    return SizedBox(
      width: double.infinity,
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
