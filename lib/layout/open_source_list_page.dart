import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';
import 'package:world_movie_trailer/layout/widgets/settings_sliver_header.dart';

class OpenSourceList extends StatelessWidget {
  OpenSourceList({super.key});

  final List<Map<String, String>> _openSourcePackages = [
    {
      'name': 'youtube_player_flutter',
      'version': '9.0.0',
      'url': 'https://pub.dev/packages/youtube_player_flutter'
    },
    {
      'name': 'hive',
      'version': '2.2.3',
      'url': 'https://pub.dev/packages/hive'
    },
    {
      'name': 'hive_flutter',
      'version': '1.1.0',
      'url': 'https://pub.dev/packages/hive_flutter'
    },
    {
      'name': 'provider',
      'version': '6.0.0',
      'url': 'https://pub.dev/packages/provider'
    },
    {
      'name': 'url_launcher',
      'version': '6.3.0',
      'url': 'https://pub.dev/packages/url_launcher'
    },
    {
      'name': 'share_plus',
      'version': '10.0.2',
      'url': 'https://pub.dev/packages/share_plus'
    },
    {
      'name': 'google_mobile_ads',
      'version': '5.3.1',
      'url': 'https://pub.dev/packages/google_mobile_ads'
    },
    {
      'name': 'amplitude_flutter',
      'version': '3.16.7',
      'url': 'https://pub.dev/packages/amplitude_flutter'
    },
    {
      'name': 'cached_network_image',
      'version': '3.4.1',
      'url': 'https://pub.dev/packages/cached_network_image'
    },
    {
      'name': 'flutter_local_notifications',
      'version': '19.3.0',
      'url': 'https://pub.dev/packages/flutter_local_notifications'
    },
    {
      'name': 'permission_handler',
      'version': '11.3.1',
      'url': 'https://pub.dev/packages/permission_handler'
    },
    {
      'name': 'in_app_purchase',
      'version': '3.1.8',
      'url': 'https://pub.dev/packages/in_app_purchase'
    },
    {
      'name': 'uuid',
      'version': '4.4.2',
      'url': 'https://pub.dev/packages/uuid'
    },
    {
      'name': 'firebase_core',
      'version': '3.5.0',
      'url': 'https://pub.dev/packages/firebase_core'
    },
    {
      'name': 'firebase_storage',
      'version': '12.1.3',
      'url': 'https://pub.dev/packages/firebase_storage'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsSliverHeader(
            title: getSettingsLabel(settingsProvider.language, "opensource"),
            darkIconAsset: 'assets/images/dark/icon_config_DT_xxhdpi.png',
            lightIconAsset: 'assets/images/light/icon_config_LT_xxhdpi.png',
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Divider(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final package = _openSourcePackages[index];
                  return ListTile(
                    title: Text(
                      package['name']!,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      package['version']!,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: _openSourcePackages.length,
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: const SettingsFooter(),
    );
  }
}
