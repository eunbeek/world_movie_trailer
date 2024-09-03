import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 115.0, 
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.arrow_back),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(bottom: 13),
                  centerTitle: true,
                  title: AnimatedOpacity(
                    opacity: top < 80.0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Text("설정하기"),
                  ),
                  background: Container(
                    margin: EdgeInsets.only(top: 40),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 15),
                        top > 80.0
                            ? Image.asset(
                                settingsProvider.isDarkTheme ? 'assets/images/dark/icon_config_DT_xxhdpi.png' : 'assets/images/light/icon_config_LT_xxhdpi.png',
                                height: 32,
                                width: 32,
                              )
                            : SizedBox.shrink(),
                        const SizedBox(width: 20),
                        const Text(
                          "설정하기",
                          style: TextStyle(
                            fontSize: 30,
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
            delegate: SliverChildListDelegate(
              [
                const Divider(),
                ListTile(
                  title: const Text('진동'),
                  trailing: Switch(
                    value: settingsProvider.isVibrate,
                    onChanged: (bool value) {
                      settingsProvider.updateIsVibrate(value);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('영화 예고편 자막'),
                  trailing: Switch(
                    value: settingsProvider.isCaptionOn,
                    onChanged: (bool value) {
                      settingsProvider.updateIsCaptionOn(value);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('언어'),
                  trailing: DropdownButton<String>(
                    value: settingsProvider.language,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        settingsProvider.language = newValue;
                      }
                    },
                    items: supportedLanguages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(getLanguageName(value)),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('다크 모드'),
                  trailing: Switch(
                    value: settingsProvider.isDarkTheme,
                    onChanged: (bool value) {
                      settingsProvider.updateBackground(value ? 'dark' : 'light');
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('SNS 링크'),
                  trailing: TextButton(
                    onPressed: () async {
                      const url = 'https://x.com/Sunnyinnolab';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Text('트위터'),
                  ),
                ),
                const Divider(),
                const ListTile(
                  title: Text('앱 버전'),
                  trailing: Text('v 1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SUNNY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    const url = 'https://sunnyinnolab.notion.site/Terms-and-Conditions-0601612ffa404317a4ddaf5a094e5471';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text(
                    '서비스 이용약관',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const Text(
                  ' | ',
                ),
                GestureDetector(
                  onTap: () async {
                    const url = 'https://sunnyinnolab.notion.site/Privacy-Policy-2919720d6e7848669b9d5e1170c6cabc';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text(
                    '개인정보처리방침',
                    style: TextStyle(decoration: TextDecoration.underline),
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
