import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_translation_ad_manager.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/layout/donation_page.dart';
import 'package:world_movie_trailer/layout/widgets/detail_asset_icon.dart';

const _labels = <String, Map<String, String>>{
  'ko': {
    'title': '번역 무제한',
    'bookmarks': '북마크 저장 및 조회',
    'specialQuotes': '특별 정보 및 명대사',
    'body': '광고를 시청하면 모든 기능을\n2시간 동안 사용 가능!',
    'watch': '광고 보기',
    'failed': '광고를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
    'premiumTitle': '번역 기능은 Premium 전용입니다',
    'premiumBody': 'Premium으로 업그레이드하면 영화 정보 번역과 광고 제거 기능을 사용할 수 있습니다.',
    'cancel': '나중에',
    'upgrade': 'Pro로 업그레이드',
  },
  'en': {
    'title': 'Unlimited Translations',
    'bookmarks': 'Save & View Bookmarks',
    'specialQuotes': 'Special Info & Quotes',
    'body': 'Watch an Ad to Unlock\nAll Features for 2 Hours',
    'watch': 'Watch Ad',
    'failed': 'The ad is unavailable. Please try again shortly.',
    'premiumTitle': 'Translation is a Premium feature',
    'premiumBody':
        'Upgrade to Premium to translate movie details and remove ads.',
    'cancel': 'Not now',
    'upgrade': 'Upgrade to Pro',
  },
  'ja': {
    'title': '翻訳無制限',
    'bookmarks': 'お気に入りの保存と閲覧',
    'specialQuotes': '特別情報と名言',
    'body': '広告を視聴すると2時間\nすべての機能が利用可能！',
    'watch': '広告を見る',
    'failed': '広告を読み込めませんでした。しばらくしてからもう一度お試しください。',
    'premiumTitle': '翻訳はPremium限定機能です',
    'premiumBody': 'Premiumにアップグレードすると、映画情報の翻訳と広告削除を利用できます。',
    'cancel': '後で',
    'upgrade': 'Proにアップグレード',
  },
  'zh': {
    'title': '无限制翻译',
    'bookmarks': '保存与查看收藏',
    'specialQuotes': '独家信息与金句',
    'body': '观看广告即可在2小时内\n使用全部功能！',
    'watch': '观看广告',
    'failed': '无法加载广告，请稍后重试。',
    'premiumTitle': '翻译是Premium专属功能',
    'premiumBody': '升级Premium即可翻译电影信息并移除广告。',
    'cancel': '稍后',
    'upgrade': '升级到Pro版',
  },
  'tw': {
    'title': '無限制翻譯',
    'bookmarks': '儲存與檢視收藏',
    'specialQuotes': '獨家資訊與金句',
    'body': '觀看廣告即可在2小時內\n使用全部功能！',
    'watch': '觀看廣告',
    'failed': '無法載入廣告，請稍後再試。',
    'premiumTitle': '翻譯是Premium專屬功能',
    'premiumBody': '升級Premium即可翻譯電影資訊並移除廣告。',
    'cancel': '稍後',
    'upgrade': '升級到Pro版',
  },
  'fr': {
    'title': 'Traductions illimitées',
    'bookmarks': 'Enregistrer et voir les signets',
    'specialQuotes': 'Infos spéciales et citations',
    'body':
        'Regardez une pub pour débloquer\ntoutes les fonctionnalités pendant 2 h',
    'watch': 'Regarder la pub',
    'failed': 'La publicité est indisponible. Réessayez plus tard.',
    'premiumTitle': 'La traduction est réservée à Premium',
    'premiumBody':
        'Passez à Premium pour traduire les films et supprimer les publicités.',
    'cancel': 'Plus tard',
    'upgrade': 'Passer à la version Pro',
  },
  'de': {
    'title': 'Unbegrenzte Übersetzungen',
    'bookmarks': 'Lesezeichen speichern & ansehen',
    'specialQuotes': 'Spezial-Infos & Zitate',
    'body':
        'Werbeanzeige ansehen, um alle\nFunktionen für 2 Std. freizuschalten',
    'watch': 'Werbung ansehen',
    'failed': 'Die Anzeige ist nicht verfügbar. Bitte später erneut versuchen.',
    'premiumTitle': 'Übersetzen ist eine Premium-Funktion',
    'premiumBody':
        'Mit Premium kannst du Filminfos übersetzen und Werbung entfernen.',
    'cancel': 'Später',
    'upgrade': 'Auf Pro upgraden',
  },
  'es': {
    'title': 'Traducciones ilimitadas',
    'bookmarks': 'Guardar y ver marcadores',
    'specialQuotes': 'Información especial y citas',
    'body':
        'Mira un anuncio para desbloquear\ntodas las funciones durante 2 horas',
    'watch': 'Ver anuncio',
    'failed': 'El anuncio no está disponible. Inténtalo más tarde.',
    'premiumTitle': 'La traducción es una función Premium',
    'premiumBody':
        'Mejora a Premium para traducir películas y eliminar anuncios.',
    'cancel': 'Más tarde',
    'upgrade': 'Actualizar a Pro',
  },
  'hi': {
    'title': 'असीमित अनुवाद',
    'bookmarks': 'बुकमार्क सहेजें और देखें',
    'specialQuotes': 'विशेष जानकारी और विचार',
    'body': '2 घंटे के लिए सभी सुविधाएं अनलॉक\nकरने के लिए एक विज्ञापन देखें',
    'watch': 'विज्ञापन देखें',
    'failed': 'विज्ञापन उपलब्ध नहीं है। कृपया बाद में फिर कोशिश करें।',
    'premiumTitle': 'अनुवाद एक Premium सुविधा है',
    'premiumBody':
        'फ़िल्म जानकारी का अनुवाद और विज्ञापन हटाने के लिए Premium लें।',
    'cancel': 'बाद में',
    'upgrade': 'प्रो पर अपग्रेड करें',
  },
  'th': {
    'title': 'แปลภาษาไม่จำกัด',
    'bookmarks': 'บันทึกและดูบุ๊กมาร์ก',
    'specialQuotes': 'ข้อมูลพิเศษและคำคม',
    'body': 'รับชมโฆษณาเพื่อปลดล็อก\nฟีเจอร์ทั้งหมดเป็นเวลา 2 ชั่วโมง',
    'watch': 'ดูโฆษณา',
    'failed': 'ไม่สามารถโหลดโฆษณาได้ โปรดลองอีกครั้งภายหลัง',
    'premiumTitle': 'การแปลเป็นฟีเจอร์ Premium',
    'premiumBody': 'อัปเกรดเป็น Premium เพื่อแปลข้อมูลภาพยนตร์และลบโฆษณา',
    'cancel': 'ไว้ภายหลัง',
    'upgrade': 'อัปเกรดเป็น Pro',
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

  LogHelper().logEvent('reward_prompt_opened');
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
    LogHelper().logEvent('reward_ad_clicked');
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

  void _upgradeToPro() {
    if (_loading) return;
    LogHelper().logEvent('pro_upgrade_clicked', parameters: {
      'location': 'reward_prompt',
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DonationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkTheme;
    final cardColor =
        isDark ? const Color(0xFF2B292D) : const Color(0xFFF5F2F7);
    final secondaryColor = isDark ? Colors.white70 : Colors.black87;

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
              Transform.translate(
                offset: const Offset(14, -10),
                child: Align(
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
              ),
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
                child: _BenefitList(
                  translation: widget.label['title']!,
                  bookmarks: widget.label['bookmarks']!,
                  specialQuotes: widget.label['specialQuotes']!,
                ),
              ),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label['body']!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    color: secondaryColor,
                  ),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _upgradeToPro,
                  style: FilledButton.styleFrom(
                    backgroundColor: cardColor,
                    foregroundColor:
                        isDark ? Colors.white : const Color(0xFF28252B),
                    disabledBackgroundColor: cardColor.withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _accentColor.withValues(
                          alpha: isDark ? 0.42 : 0.18,
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.label['upgrade']!,
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
}

class _BenefitList extends StatelessWidget {
  const _BenefitList({
    required this.translation,
    required this.bookmarks,
    required this.specialQuotes,
  });

  final String translation;
  final String bookmarks;
  final String specialQuotes;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          const maximumFontSize = 18.0;
          final availableTextWidth = constraints.maxWidth - 52;
          final textScaler = MediaQuery.textScalerOf(context);
          var sharedFontSize = maximumFontSize;
          for (final label in [translation, bookmarks, specialQuotes]) {
            final painter = TextPainter(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: maximumFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              maxLines: 1,
              textDirection: Directionality.of(context),
              textScaler: textScaler,
            )..layout();
            if (painter.width > availableTextWidth) {
              final fittedSize =
                  (maximumFontSize * availableTextWidth / painter.width)
                      .clamp(12.0, maximumFontSize)
                      .toDouble();
              if (fittedSize < sharedFontSize) sharedFontSize = fittedSize;
            }
          }
          return Column(
            children: [
              _BenefitRow(
                icon: const DetailAssetIcon(
                  name: 'translate',
                  active: true,
                  color: Color(0xFF6750A4),
                ),
                label: translation,
                fontSize: sharedFontSize,
              ),
              const SizedBox(height: 18),
              _BenefitRow(
                icon: const DetailAssetIcon(
                  name: 'bookmark',
                  active: true,
                  color: Color(0xFF6750A4),
                ),
                label: bookmarks,
                fontSize: sharedFontSize,
              ),
              const SizedBox(height: 18),
              _BenefitRow(
                icon: const Icon(
                  Icons.videocam_outlined,
                  color: Color(0xFF6750A4),
                  size: 30,
                ),
                label: specialQuotes,
                fontSize: sharedFontSize,
              ),
            ],
          );
        },
      );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.label,
    required this.fontSize,
  });

  final Widget icon;
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(width: 2),
          SizedBox(width: 32, height: 32, child: Center(child: icon)),
          const SizedBox(width: 20),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
}
