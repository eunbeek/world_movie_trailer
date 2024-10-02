import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/layout/credits_list_apge.dart';

import 'package:world_movie_trailer/layout/other_app_page.dart';
import 'package:world_movie_trailer/layout/user_data_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});


 Widget _buildThemeButton(BuildContext context, String theme, SettingsProvider settingsProvider) {
    bool isSelected = (theme == 'dark' && settingsProvider.isDarkTheme) ||
                      (theme == 'light' && !settingsProvider.isDarkTheme);

    return ElevatedButton(
      onPressed: () {
        settingsProvider.updateBackground(theme);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ?const Color.fromARGB(255, 110, 14, 127): Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: Color.fromARGB(255, 110, 14, 127),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        theme == 'dark' ? getSettingsLabel(settingsProvider.language, "dark") : getSettingsLabel(settingsProvider.language, "light"),
        style: TextStyle(
          color:  Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.015,
        ),
      ),
    );
  }

  String _formatHoursMinutes(double totalHours) {
    int hours = totalHours.floor(); // Get the whole number part as hours
    int minutes = ((totalHours - hours) * 60).round(); // Get the decimal part and convert to minutes
    return '$hours hours $minutes minutes';
  }

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
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      getSettingsLabel(settingsProvider.language, "setting"),
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
                              ? 'assets/images/dark/icon_config_DT_xxhdpi.png'
                              : 'assets/images/light/icon_config_LT_xxhdpi.png',
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          getSettingsLabel(settingsProvider.language, "setting"),
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
                ListTile(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                          UserData(),
                      ),
                    )
                  },
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "userdata"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "caption"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: Switch(
                    value: settingsProvider.isCaptionOn,
                    onChanged: (bool value) {
                      settingsProvider.updateIsCaptionOn(value);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "vibrate"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: Switch(
                    value: settingsProvider.isVibrate,
                    onChanged: (bool value) {
                      settingsProvider.updateIsVibrate(value);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "language"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: settingsProvider.language,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.language = newValue;
                        }
                      },
                      items: supportedLanguages.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            getLanguageName(value,),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.02,
                            ),
                            overflow: TextOverflow.ellipsis, // This ensures text does not overflow
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Divider(),
                ListTile(
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "theme"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildThemeButton(context, 'dark', settingsProvider),
                      _buildThemeButton(context, 'light', settingsProvider),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "sns"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      const url = 'https://x.com/Sunnyinnolab';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text(
                      "Link",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    String url;

                    if (Platform.isAndroid) {
                      url = 'https://play.google.com/store/apps/details?id=com.mwm.findfour.gg&pcampaignid=web_share';
                    } else {
                      url = 'https://apps.apple.com/ca/app/find-four-find-4-differences/id6478101361';
                    }

                    Share.share(
                      'Check out this app: $url',
                      subject: 'Check out this App',
                      sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
                    );
                  },
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "share"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () async {
                    String url;

                    if (Platform.isAndroid) {
                      url = 'https://play.google.com/store/apps/details?id=com.mwm.findfour.gg';
                    } else if (Platform.isIOS) {
                      url = 'https://apps.apple.com/app/id6478101361?action=write-review';
                    } else {
                      throw 'Platform not supported for this operation';
                    }
                    
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "review"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                          AppListPage(),
                      ),
                    )
                  },
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "other"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right), // Add arrow icon
                ),
                const Divider(),
                ListTile(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                          CreditsList(),
                      ),
                    )
                  },
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "credits"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    getSettingsLabel(settingsProvider.language, "version"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                  trailing: Text(
                    'v 1.0.0',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),
              ],
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
}
