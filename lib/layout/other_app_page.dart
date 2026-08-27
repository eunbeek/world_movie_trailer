import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';

class AppListPage extends StatelessWidget {
  final String appFFName = "Find Four";
  final String appEWName = "English Wangza";
  final String appDFName = "Dual Flashlight";
  final String appSPName = "Sky Peacemaker";

  final String appFFAndroidLink =
      "https://play.google.com/store/apps/details?id=com.mwm.findfour.gg&pcampaignid=web_share";
  final String appFFIosLink =
      "https://apps.apple.com/ca/app/find-four-find-4-differences/id6478101361";
  final String appDFLink = "https://dualflashlig.onelink.me/Wccx/qnv6yh8s";
  final String appFFLink = "https://findfour.onelink.me/vurA/0tfteiuf";
  final String appTwoLink = "https://jaemitree.com/game/wangza";
  final String appSPLink = "https://skypeacemaker.onelink.me/YQxG/8s9sx66i";

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
                      getSettingsLabel(settingsProvider.language, "other"),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.010,
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
                              ? 'assets/images/dark/icon_apps_DT_xxhdpi.png'
                              : 'assets/images/light/icon_apps_LT_xxhdpi.png',
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          getSettingsLabel(settingsProvider.language, "other"),
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.025,
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
              _buildAppListTile(context, settingsProvider, appSPName, appSPLink,
                  'assets/images/other_apps/Sky_Peacemaker.png'),
              const Divider(),
              _buildAppListTile(context, settingsProvider, appDFName, appDFLink,
                  'assets/images/other_apps/Dual Flashlight_icon_1024.png'),
              const Divider(),
              _buildAppListTile(context, settingsProvider, appFFName, appFFLink,
                  'assets/images/other_apps/Find_Four_Icon.png'),
              const Divider(),
              _buildAppListTile(
                  context,
                  settingsProvider,
                  appEWName,
                  appTwoLink,
                  'assets/images/other_apps/English_WangZa_Icon.png'),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: const SettingsFooter(),
    );
  }

  Widget _buildAppListTile(
      BuildContext context,
      SettingsProvider settingsProvider,
      String appName,
      String appLink,
      String logoPath) {
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
            await launchUrl(Uri.parse(appLink),
                mode: LaunchMode.externalApplication);
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
