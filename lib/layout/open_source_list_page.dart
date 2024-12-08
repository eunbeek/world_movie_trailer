import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class OpenSourceList extends StatelessWidget {
  OpenSourceList({super.key});

  final List<Map<String, String>> _openSourcePackages = [
    {'name': 'youtube_player_flutter', 'version': '9.1.0', 'url': 'https://pub.dev/packages/youtube_player_flutter'},
    {'name': 'hive', 'version': '2.2.3', 'url': 'https://pub.dev/packages/hive'},
    {'name': 'hive_flutter', 'version': '1.1.0', 'url': 'https://pub.dev/packages/hive_flutter'},
    {'name': 'provider', 'version': '6.0.0', 'url': 'https://pub.dev/packages/provider'},
    {'name': 'url_launcher', 'version': '6.3.0', 'url': 'https://pub.dev/packages/url_launcher'},
    {'name': 'simple_animations', 'version': '5.0.2', 'url': 'https://pub.dev/packages/simple_animations'},
    {'name': 'video_player', 'version': '2.5.1', 'url': 'https://pub.dev/packages/video_player'},
    {'name': 'chewie', 'version': '1.3.4', 'url': 'https://pub.dev/packages/chewie'},
    {'name': 'share_plus', 'version': '10.0.2', 'url': 'https://pub.dev/packages/share_plus'},
    {'name': 'google_mobile_ads', 'version': '5.1.0', 'url': 'https://pub.dev/packages/google_mobile_ads'},
    {'name': 'amplitude_flutter', 'version': '3.9.0', 'url': 'https://pub.dev/packages/amplitude_flutter'},
    {'name': 'cached_network_image', 'version': '3.4.1', 'url': 'https://pub.dev/packages/cached_network_image'},
    {'name': 'flutter_local_notifications', 'version': '18.0.1', 'url': 'https://pub.dev/packages/flutter_local_notifications'},
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            getSettingsLabel(settingsProvider.language, "opensource"),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: settingsProvider.isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: <Widget>[
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
