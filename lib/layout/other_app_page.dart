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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Sunny's Apps & Games",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: settingsProvider.isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // arrow_back 아이콘 설정
            onPressed: () {
              Navigator.of(context).pop(); // 뒤로 가기 기능
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Platform.isAndroid
                  ? _buildAppListTile(context, settingsProvider, appFFName, appFFAndroidLink, 'assets/images/Find_Four_Icon.png')
                  : _buildAppListTile(context, settingsProvider, appFFName, appFFIosLink, 'assets/images/Find_Four_Icon.png'),
              const Divider(),
              _buildAppListTile(context, settingsProvider, appEWName, appTwoLink, 'assets/images/English_WangZa_Icon.png'),
            ],
          ),
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
                      'https://sunnyinnolab.notion.site/About-Sunny-Innovation-Lab-4a09c94d4b6d4a0f8113f16660b6add3';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                child: Image.asset(
                  'assets/images/dark/logo_sil_white_1024.png',
                  height: MediaQuery.of(context).size.height * 0.05, // Adjust size as needed
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
