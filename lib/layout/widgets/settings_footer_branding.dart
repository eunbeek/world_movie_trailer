import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/ad_manager/settings_banner_ad.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key, this.showBanner = false});

  final bool showBanner;

  static final Uri _homeUri = Uri.parse(
    'https://marmalade-neptune-dbe.notion.site/Home-Page-7589a833b4f6482e90844b9fe49c8ae0',
  );
  static final Uri _termsUri = Uri.parse(
    'https://sunnyinnolab.notion.site/Terms-and-Conditions-0601612ffa404317a4ddaf5a094e5471',
  );
  static final Uri _privacyUri = Uri.parse(
    'https://sunnyinnolab.notion.site/Privacy-Policy-2919720d6e7848669b9d5e1170c6cabc',
  );

  Future<void> _open(Uri uri) => launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ColoredBox(
      color: settings.isDarkTheme
          ? const Color(0xff3c3c3c)
          : const Color(0xfff2f2f2),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsFooterBranding(
              isDark: settings.isDarkTheme,
              termsLabel: 'Terms',
              privacyLabel: 'Privacy',
              onLogoTap: () => _open(_homeUri),
              onTermsTap: () => _open(_termsUri),
              onPrivacyTap: () => _open(_privacyUri),
            ),
            if (showBanner && !settings.isAdsFree) ...[
              const SizedBox(height: 6),
              const SettingsBannerAd(),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsFooterBranding extends StatelessWidget {
  const SettingsFooterBranding({
    super.key,
    required this.isDark,
    required this.termsLabel,
    required this.privacyLabel,
    required this.onLogoTap,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final bool isDark;
  final String termsLabel;
  final String privacyLabel;
  final VoidCallback onLogoTap;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            InkWell(
              onTap: onLogoTap,
              child: Image.asset(
                isDark
                    ? 'assets/images/dark/logo_sil_white_1024.png'
                    : 'assets/images/light/logo_sil_black_1024.png',
                width: 96,
                height: 32,
                fit: BoxFit.contain,
                semanticLabel: 'Sunny Innovation Lab',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onTermsTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(termsLabel),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('|'),
                        ),
                        InkWell(
                          onTap: onPrivacyTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(privacyLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
