import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class AppListPage extends StatelessWidget {
  final String appFFName = "Find Four";
  final String appEWName = "English Wangza";

  final String appFFAndroidLink = "https://play.google.com/store/apps/details?id=com.mwm.findfour.gg&pcampaignid=web_share";
  final String appFFIosLink = "https://apps.apple.com/ca/app/find-four-find-4-differences/id6478101361";
  final String appTwoLink = "https://jaemitree.com/game/wangza";

  const AppListPage({super.key}); // 앱 링크

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
                padding: const EdgeInsets.only(top: 10.0), // Adjust padding to move the arrow down
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
                    opacity: top < MediaQuery.of(context).size.height * 0.1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      getSettingsLabel(settingsProvider.language, "other"),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.bold,
                        color: settingsProvider.isDarkTheme ? Colors.white : Colors.black
                      ),
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
                              ? 'assets/images/dark/icon_apps_DT_xxhdpi.png'
                              : 'assets/images/light/icon_apps_LT_xxhdpi.png',
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          getSettingsLabel(settingsProvider.language, "other"),
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
            delegate: SliverChildListDelegate(
              [
                const Divider(),
                Platform.isAndroid
                  ? _buildAppListTile(context, settingsProvider, appFFName, appFFAndroidLink, 'assets/images/Find_Four_Icon.png')
                  : _buildAppListTile(context, settingsProvider, appFFName, appFFIosLink, 'assets/images/Find_Four_Icon.png'),
                const Divider(),
                _buildAppListTile(context, settingsProvider, appEWName, appTwoLink, 'assets/images/English_WangZa_Icon.png'),
              ]
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        color: settingsProvider.isDarkTheme ? const Color(0xff3c3c3c) : const Color(0xff435555),
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
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
              child: Image.asset(
                'assets/images/SIL_logo_h_xxhdpi.png',
                height: MediaQuery.of(context).size.height * 0.045, // Adjust size as needed
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
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
                  padding: EdgeInsets.symmetric(horizontal: 8.0), // Space around the separator
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
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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

  Widget _buildAppListTile(BuildContext context, SettingsProvider settingsProvider, String appName, String appLink, String logoPath) {
    return ListTile(
      leading: Image.asset(
        logoPath,
        width: MediaQuery.of(context).size.height * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
      ),
      title: Text(
        getOtherAppName(settingsProvider.language, appName),
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.02,
        ),
      ),
      trailing: GestureDetector(
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(appLink))) {
            await launchUrl(Uri.parse(appLink), mode: LaunchMode.externalApplication);
          }
        },
        child: Text(
          "Link",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.02,
          ),
        ),
      ),
    );
  }
}
