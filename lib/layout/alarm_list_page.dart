import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class AlarmListPage extends StatelessWidget {
  const AlarmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            getSettingsLabel(settingsProvider.language, "alarm"),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: settingsProvider.isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Back arrow icon
            onPressed: () {
              Navigator.of(context).pop(); // Go back
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // All Alarm
              _buildAllAlarmOn(context, settingsProvider),

              // Bookmark & Memo Group
              _buildBookmarkAndMemoGroup(context, settingsProvider),

              // Divider
              const Divider(height: 20),

              // Country List
              ..._buildCountryList(context, settingsProvider),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, settingsProvider),
      ),
    );
  }

  Widget _buildAllAlarmOn(BuildContext context, SettingsProvider settingsProvider) {
    return Column(
      children: [
        ListTile(
          title: Text(
            getAlarmsLabel(settingsProvider.language, 'alarmAll'),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
            ),
          ),
          trailing: Switch(
            value: settingsProvider.isDailyAlarmOn,
            onChanged: (bool value) {
              settingsProvider.updateIsDailyAlarmOn(value);
            },
          ),
        ),
        const Divider(height: 20),
      ],
    );
  }

   /// Builds the Bookmark and Memo group with switches.
  Widget _buildBookmarkAndMemoGroup(BuildContext context, SettingsProvider settingsProvider) {
    return Column(
      children: [
        ListTile(
          title: Text(
            getMenuItemTitle(settingsProvider.language, 'Bookmark'),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
            ),
          ),
          trailing: Switch(
            value: !settingsProvider.isDailyAlarmOn ? false : settingsProvider.isBookmarkAlarmOn,
            onChanged: (bool value) {
              if(settingsProvider.isDailyAlarmOn) settingsProvider.updateIsBookmarkAlarmOn(value);
            },
          ),
        ),
        Divider(
          color: Colors.grey[700], 
          thickness: 0.2, 
        ),
        ListTile(
          title: Text(
            getMenuItemTitle(settingsProvider.language, 'Memo'),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
            ),
          ),
          trailing: Switch(
            value: !settingsProvider.isDailyAlarmOn ? false : settingsProvider.isMemoAlarmOn,
            onChanged: (bool value) {
              if(settingsProvider.isDailyAlarmOn) settingsProvider.updateIsMemoAlarmOn(value);
            },
          ),
        ),
      ],
    );
  }

  /// Builds the list of countries with alarm toggles.
  List<Widget> _buildCountryList(BuildContext context, SettingsProvider settingsProvider) {
    List<Widget> countryWidgets = [];

    // Flatten all countries from countryByDay
    final allCountries = countryByDay.values.expand((countries) => countries).toList();

    for (int i = 0; i < allCountries.length; i++) {
      countryWidgets.add(_buildCountryListTile(context, settingsProvider, allCountries[i]));

      // Add a divider after every country except the last one
      if (i < allCountries.length - 1) {
        // countryWidgets.add(const Divider());
        countryWidgets.add( 
          Divider(
            color: Colors.grey[700], 
            thickness: 0.2, 
          )
        );
      }
    }

    return countryWidgets;
  }

  /// Builds a single country list tile with alarm toggle.
  Widget _buildCountryListTile(BuildContext context, SettingsProvider settingsProvider, String countryKey) {
    final localizedCountryName = localizedCountries[settingsProvider.language]?[countryKey] ?? countryKey;
    bool isSwitchValue = settingsProvider.isAlarmOn?.values.any((countryMap) => countryMap[countryKey] == true) ??
    false; // 초기 값을 설정
    return ListTile(
      title: Text(
        localizedCountryName,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.02,
        ),
      ),
      trailing: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Switch(
            value: !settingsProvider.isDailyAlarmOn ? false : isSwitchValue,
            onChanged: (bool value) {
              if (settingsProvider.isDailyAlarmOn) {
                // 즉시 반영
                setState(() {
                  isSwitchValue = value;
                });

                // Provider 상태 업데이트
                _toggleCountryAlarms(settingsProvider, countryKey, value);
              }
            },
          );
        },
      ),
    );
  }

  /// Toggles the alarm for the specified country across all days.
  void _toggleCountryAlarms(SettingsProvider settingsProvider, String countryKey, bool isOn) {
    settingsProvider.isAlarmOn?.forEach((day, countryMap) {
      if (countryMap.containsKey(countryKey)) {
        settingsProvider.updateAlarmForCountryByDay(day, countryKey, isOn);
      }
    });
  }

  /// Builds the bottom navigation bar.
  Widget _buildBottomNavigationBar(BuildContext context, SettingsProvider settingsProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.12,
      color: settingsProvider.isDarkTheme ? const Color(0xff3c3c3c) : const Color(0xff435555),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.12 * 0.1,
        bottom: MediaQuery.of(context).size.height * 0.12 * 0.1,
      ),
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
              height: MediaQuery.of(context).size.height * 0.05,
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
                padding: EdgeInsets.symmetric(horizontal: 8.0),
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
    );
  }
}
