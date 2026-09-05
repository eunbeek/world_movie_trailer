import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';
import 'package:world_movie_trailer/layout/widgets/settings_sliver_header.dart';

class UserData extends StatelessWidget {
  const UserData({super.key}); // 앱 링크

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsSliverHeader(
            title: getSettingsLabel(settingsProvider.language, "userdata"),
            darkIconAsset: 'assets/images/dark/icon_config_DT_xxhdpi.png',
            lightIconAsset: 'assets/images/light/icon_config_LT_xxhdpi.png',
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Divider(),
              ListTile(
                title: Text(
                  getSettingsLabel(settingsProvider.language, "initdate"),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                trailing: Text(
                  DateFormat('yyyy-MM-dd').format(settingsProvider.startDate),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  getSettingsLabel(settingsProvider.language, "totalOpen"),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                trailing: Text(
                  '${settingsProvider.totalOpen} ${getSettingsLabel(settingsProvider.language, "views")}',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: const SettingsFooter(),
    );
  }
}
