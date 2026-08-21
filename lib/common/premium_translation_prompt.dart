import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_translation_ad_manager.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/layout/donation_page.dart';

const _labels = <String, Map<String, String>>{
  'ko': {
    'title': '무제한 번역',
    'noAds': '동영상 광고 없이!',
    'body': '광고 1회를 시청하면 12시간 동안\n동영상 광고 없이 무제한 번역을 이용할 수 있습니다.',
    'watch': '광고보기',
    'failed': '광고를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
    'premiumTitle': '번역 기능은 Premium 전용입니다',
    'premiumBody': 'Premium으로 업그레이드하면 영화 정보 번역과 광고 제거 기능을 사용할 수 있습니다.',
    'cancel': '나중에',
    'upgrade': '구매하기',
  },
  'en': {
    'title': 'Unlimited translation',
    'noAds': 'No video ads!',
    'body':
        'Watch one ad to unlock unlimited translations\nand no video ads for 12 hours.',
    'watch': 'Watch ad',
    'failed': 'The ad is unavailable. Please try again shortly.',
    'premiumTitle': 'Translation is a Premium feature',
    'premiumBody':
        'Upgrade to Premium to translate movie details and remove ads.',
    'cancel': 'Not now',
    'upgrade': 'Upgrade',
  },
};

Future<bool> showPremiumTranslationPrompt(
  BuildContext context,
  String language,
) async {
  final label = _labels[language] ?? _labels['en']!;
  if (kIsWeb) {
    final upgrade = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(label['premiumTitle']!),
        content: Text(label['premiumBody']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(label['cancel']!),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(label['upgrade']!),
          ),
        ],
      ),
    );
    if (upgrade == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DonationPage()),
      );
    }
    return context.mounted && context.read<SettingsProvider>().isAdsFree;
  }

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _TranslationRewardDialog(label: label),
      ) ??
      false;
}

class _TranslationRewardDialog extends StatefulWidget {
  const _TranslationRewardDialog({required this.label});

  final Map<String, String> label;

  @override
  State<_TranslationRewardDialog> createState() =>
      _TranslationRewardDialogState();
}

class _TranslationRewardDialogState extends State<_TranslationRewardDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _watchAd() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final rewarded = await RewardedTranslationAdManager.show();
    if (!mounted) return;
    if (rewarded) {
      context.read<SettingsProvider>().grantTranslationAdAccess();
      Navigator.pop(context, true);
    } else {
      setState(() {
        _loading = false;
        _error = widget.label['failed'];
      });
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filledTonal(
                    onPressed:
                        _loading ? null : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    border: Border.all(color: const Color(0xFFBBD7FF)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded,
                          size: 42, color: Color(0xFF3982F7)),
                      SizedBox(width: 14),
                      Icon(Icons.phone_iphone_rounded,
                          size: 42, color: Color(0xFF3982F7)),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _BenefitRow(
                        icon: Icons.translate_rounded,
                        label: widget.label['title']!,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Icon(Icons.add_circle, color: Color(0xFF3982F7)),
                      ),
                      _BenefitRow(
                        icon: Icons.videocam_off_rounded,
                        label: widget.label['noAds']!,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.label['body']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.45),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _loading ? null : _watchAd,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3982F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.label['watch']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: const Color(0xFF3982F7), size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
}
