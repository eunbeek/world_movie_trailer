import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

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
          SliverAppBar.large(
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10.0), // Adjust padding to move the arrow down
                child: Icon(
                  Icons.arrow_back,
                  size: MediaQuery.of(context).size.height * 0.03,
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 13),
                  centerTitle: true,
                  title: AnimatedOpacity(
                    opacity: top < MediaQuery.of(context).size.height * 0.1
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      getSettingsLabel(settingsProvider.language, "opensource"),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          fontWeight: FontWeight.bold,
                          color: settingsProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                  background: Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 15),
                        Image.asset(
                          settingsProvider.isDarkTheme
                              ? 'assets/images/dark/icon_config_DT_xxhdpi.png'
                              : 'assets/images/light/icon_config_LT_xxhdpi.png',
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          getSettingsLabel(
                              settingsProvider.language, "opensource"),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        color: settingsProvider.isDarkTheme
            ? const Color(0xff3c3c3c)
            : const Color(0xff435555),
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.12 * 0.1,
            bottom: MediaQuery.of(context).size.height * 0.12 * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                const url =
                    'https://marmalade-neptune-dbe.notion.site/Home-Page-7589a833b4f6482e90844b9fe49c8ae0';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
              child: Image.asset(
                'assets/images/SIL_logo_h_xxhdpi.png',
                height: MediaQuery.of(context).size.height *
                    0.045, // Adjust size as needed
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.12 * 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    const url =
                        'https://sunnyinnolab.notion.site/Terms-and-Conditions-0601612ffa404317a4ddaf5a094e5471';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    getSettingsLabel(settingsProvider.language, "terms"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.0), // Space around the separator
                  child: Text(
                    '|',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    const url =
                        'https://sunnyinnolab.notion.site/Privacy-Policy-2919720d6e7848669b9d5e1170c6cabc';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    getSettingsLabel(settingsProvider.language, "privacy"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
