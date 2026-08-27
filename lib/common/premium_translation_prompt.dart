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
    'body': '광고 1회를 시청하면 10분 동안\n광고 없이 모든 기능을 이용할 수 있습니다.',
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
        'Watch one ad to unlock all features\nand no rewarded video ads for 10 minutes.',
    'watch': 'Watch ad',
    'failed': 'The ad is unavailable. Please try again shortly.',
    'premiumTitle': 'Translation is a Premium feature',
    'premiumBody':
        'Upgrade to Premium to translate movie details and remove ads.',
    'cancel': 'Not now',
    'upgrade': 'Upgrade',
  },
  'ja': {
    'title': '無制限の翻訳',
    'noAds': '動画広告なし！',
    'body': '広告を1回見ると、10分間\n広告なしですべての機能を利用できます。',
    'watch': '広告を見る',
    'failed': '広告を読み込めませんでした。しばらくしてからもう一度お試しください。',
    'premiumTitle': '翻訳はPremium限定機能です',
    'premiumBody': 'Premiumにアップグレードすると、映画情報の翻訳と広告削除を利用できます。',
    'cancel': '後で',
    'upgrade': '購入する',
  },
  'zh': {
    'title': '无限翻译',
    'noAds': '无视频广告！',
    'body': '观看一次广告，即可在10分钟内\n无广告使用所有功能。',
    'watch': '观看广告',
    'failed': '无法加载广告，请稍后重试。',
    'premiumTitle': '翻译是Premium专属功能',
    'premiumBody': '升级Premium即可翻译电影信息并移除广告。',
    'cancel': '稍后',
    'upgrade': '购买',
  },
  'tw': {
    'title': '無限翻譯',
    'noAds': '無影片廣告！',
    'body': '觀看一次廣告，即可在10分鐘內\n無廣告使用所有功能。',
    'watch': '觀看廣告',
    'failed': '無法載入廣告，請稍後再試。',
    'premiumTitle': '翻譯是Premium專屬功能',
    'premiumBody': '升級Premium即可翻譯電影資訊並移除廣告。',
    'cancel': '稍後',
    'upgrade': '購買',
  },
  'fr': {
    'title': 'Traduction illimitée',
    'noAds': 'Sans publicité vidéo !',
    'body':
        'Regardez une publicité pour débloquer toutes les fonctions\nsans publicité vidéo pendant 10 minutes.',
    'watch': 'Voir la publicité',
    'failed': 'La publicité est indisponible. Réessayez plus tard.',
    'premiumTitle': 'La traduction est réservée à Premium',
    'premiumBody':
        'Passez à Premium pour traduire les films et supprimer les publicités.',
    'cancel': 'Plus tard',
    'upgrade': 'Acheter',
  },
  'de': {
    'title': 'Unbegrenzte Übersetzung',
    'noAds': 'Keine Videoanzeigen!',
    'body':
        'Sieh eine Anzeige an und nutze 10 Minuten lang\nalle Funktionen ohne Videoanzeigen.',
    'watch': 'Anzeige ansehen',
    'failed': 'Die Anzeige ist nicht verfügbar. Bitte später erneut versuchen.',
    'premiumTitle': 'Übersetzen ist eine Premium-Funktion',
    'premiumBody':
        'Mit Premium kannst du Filminfos übersetzen und Werbung entfernen.',
    'cancel': 'Später',
    'upgrade': 'Kaufen',
  },
  'es': {
    'title': 'Traducción ilimitada',
    'noAds': '¡Sin anuncios de vídeo!',
    'body':
        'Mira un anuncio para usar todas las funciones\nsin anuncios de vídeo durante 10 minutos.',
    'watch': 'Ver anuncio',
    'failed': 'El anuncio no está disponible. Inténtalo más tarde.',
    'premiumTitle': 'La traducción es una función Premium',
    'premiumBody':
        'Mejora a Premium para traducir películas y eliminar anuncios.',
    'cancel': 'Más tarde',
    'upgrade': 'Comprar',
  },
  'hi': {
    'title': 'असीमित अनुवाद',
    'noAds': 'वीडियो विज्ञापन नहीं!',
    'body':
        'एक विज्ञापन देखकर 10 मिनट तक\nबिना वीडियो विज्ञापन सभी सुविधाएँ पाएँ।',
    'watch': 'विज्ञापन देखें',
    'failed': 'विज्ञापन उपलब्ध नहीं है। कृपया बाद में फिर कोशिश करें।',
    'premiumTitle': 'अनुवाद एक Premium सुविधा है',
    'premiumBody':
        'फ़िल्म जानकारी का अनुवाद और विज्ञापन हटाने के लिए Premium लें।',
    'cancel': 'बाद में',
    'upgrade': 'खरीदें',
  },
  'th': {
    'title': 'แปลได้ไม่จำกัด',
    'noAds': 'ไม่มีโฆษณาวิดีโอ!',
    'body': 'ดูโฆษณา 1 ครั้งเพื่อใช้ทุกฟีเจอร์ 10 นาที\nโดยไม่มีโฆษณาวิดีโอ',
    'watch': 'ดูโฆษณา',
    'failed': 'ไม่สามารถโหลดโฆษณาได้ โปรดลองอีกครั้งภายหลัง',
    'premiumTitle': 'การแปลเป็นฟีเจอร์ Premium',
    'premiumBody': 'อัปเกรดเป็น Premium เพื่อแปลข้อมูลภาพยนตร์และลบโฆษณา',
    'cancel': 'ไว้ภายหลัง',
    'upgrade': 'ซื้อ',
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
  static const _accentColor = Color(0xFF6750A4);

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
      context.read<SettingsProvider>().grantRewardedAdAccess();
      Navigator.pop(context, true);
    } else {
      setState(() {
        _loading = false;
        _error = widget.label['failed'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkTheme;
    final cardColor =
        isDark ? const Color(0xFF2B292D) : const Color(0xFFF5F2F7);
    final secondaryColor = isDark ? Colors.white70 : Colors.black54;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: isDark ? const Color(0xFF1C1B1F) : Colors.white,
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
                  style: IconButton.styleFrom(
                    foregroundColor: _accentColor,
                    backgroundColor: isDark
                        ? const Color(0xFF332D3B)
                        : const Color(0xFFF1ECF4),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/deco_donation_xxhdpi.png',
                width: 92,
                height: 92,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.workspace_premium_rounded,
                  size: 72,
                  color: _accentColor,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentColor.withValues(
                      alpha: isDark ? 0.42 : 0.18,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _BenefitRow(
                      icon: Icons.translate_rounded,
                      label: widget.label['title']!,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Icon(Icons.add_circle, color: _accentColor),
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
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: secondaryColor,
                ),
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
                    backgroundColor: _accentColor,
                    disabledBackgroundColor:
                        _accentColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _loading ? null : _openPremium,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accentColor,
                    side: const BorderSide(color: _accentColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.label['upgrade']!,
                    style: const TextStyle(
                      fontSize: 16,
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

  Future<void> _openPremium() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DonationPage()),
    );
    if (!mounted) return;
    if (context.read<SettingsProvider>().isAdsFree) {
      Navigator.pop(context, true);
    }
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(width: 2),
          Icon(icon, color: const Color(0xFF6750A4), size: 30),
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
