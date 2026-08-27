import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/providers/show_permission.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({super.key});

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final alarmService = AlarmService();

    if (settingsProvider.isDailyAlarmOn) {
      final hasPermission = await alarmService.hasNotificationPermission();
      if (!hasPermission) {
        settingsProvider.updateIsDailyAlarmOn(false);
        await showPermissionDialog(context);
      }
    }
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
                padding: const EdgeInsets.only(top: 10.0),
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
                      getSettingsLabel(settingsProvider.language, "alarm"),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.bold,
                        color: settingsProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
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
                          getSettingsLabel(settingsProvider.language, "alarm"),
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
              _buildAllAlarmOn(context, settingsProvider),
              _buildBookmarkAlarm(context, settingsProvider),
              const Divider(height: 20),
              ..._buildCountryList(context, settingsProvider),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: const SettingsFooter(),
    );
  }

  Widget _buildAllAlarmOn(
      BuildContext context, SettingsProvider settingsProvider) {
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
            onChanged: (bool value) async {
              final alarmService = AlarmService();
              if (value) {
                if (await alarmService.hasNotificationPermission()) {
                  settingsProvider.updateIsDailyAlarmOn(true);
                } else {
                  await showPermissionDialog(context);
                  if (await alarmService.hasNotificationPermission()) {
                    settingsProvider.updateIsDailyAlarmOn(true);
                  }
                }
              } else {
                settingsProvider.updateIsDailyAlarmOn(false);
              }
            },
          ),
        ),
        const Divider(height: 20),
      ],
    );
  }

  Widget _buildBookmarkAlarm(
      BuildContext context, SettingsProvider settingsProvider) {
    return ListTile(
      title: Text(
        getMenuItemTitle(settingsProvider.language, 'Bookmark'),
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.02,
        ),
      ),
      trailing: Switch(
        value: !settingsProvider.isDailyAlarmOn
            ? false
            : settingsProvider.isBookmarkAlarmOn,
        onChanged: (bool value) {
          if (settingsProvider.isDailyAlarmOn) {
            settingsProvider.updateIsBookmarkAlarmOn(value);
          }
        },
      ),
    );
  }

  List<Widget> _buildCountryList(
      BuildContext context, SettingsProvider settingsProvider) {
    List<Widget> countryWidgets = [];
    final allCountries =
        countryByDay.values.expand((countries) => countries).toList();

    for (int i = 0; i < allCountries.length; i++) {
      countryWidgets.add(
          _buildCountryListTile(context, settingsProvider, allCountries[i]));
      if (i < allCountries.length - 1) {
        countryWidgets.add(Divider(color: Colors.grey[700], thickness: 0.2));
      }
    }

    return countryWidgets;
  }

  Widget _buildCountryListTile(BuildContext context,
      SettingsProvider settingsProvider, String countryKey) {
    final localizedCountryName = countryKey == 'box_us'
        ? getBoxOfficeLabel(settingsProvider.language, 'box_usa')
        : countryKey == 'box_kr'
            ? '${localizedCountries[settingsProvider.language]?['korea'] ?? 'Korea'} ${getBoxOfficeLabel(settingsProvider.language, 'box')}'
            : localizedCountries[settingsProvider.language]?[countryKey] ??
                countryKey;
    bool isSwitchValue = settingsProvider.isAlarmOn.values
        .any((countryMap) => countryMap[countryKey] == true);
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
                setState(() {
                  isSwitchValue = value;
                });
                _toggleCountryAlarms(settingsProvider, countryKey, value);
              }
            },
          );
        },
      ),
    );
  }

  void _toggleCountryAlarms(
      SettingsProvider settingsProvider, String countryKey, bool isOn) {
    settingsProvider.isAlarmOn.forEach((day, countryMap) {
      if (countryMap.containsKey(countryKey)) {
        settingsProvider.updateAlarmForCountryByDay(day, countryKey, isOn);
      }
    });
  }
}
