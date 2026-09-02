import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';

class _OtherApp {
  const _OtherApp(this.name, this.link, this.iconPath);

  final String name;
  final String link;
  final String iconPath;
}

const _otherApps = <_OtherApp>[
  _OtherApp(
    'Sky Peacemaker',
    'https://skypeacemaker.onelink.me/YQxG/8s9sx66i',
    'assets/images/other_apps/Sky Peacemaker - Finger Force Icon.png',
  ),
  _OtherApp(
    'World Movie Trailer',
    'https://wmt.onelink.me/YPN9/m428wgpq',
    'icons/appstore.png',
  ),
  _OtherApp(
    'World Book Ranking',
    'https://worldbookranking.onelink.me/so3H/gff32rq',
    'assets/images/other_apps/World Book Ranking Icon.png',
  ),
  _OtherApp(
    'Simply Multi Timer',
    'https://simplymultitime.onelink.me/6kU2/v7i9ke1m',
    'assets/images/other_apps/Simply Multi Timer Icon.png',
  ),
  _OtherApp(
    'Watermelon Checker',
    'https://watermelonchecker.onelink.me/zF1F/obulncrt',
    'assets/images/other_apps/Watermelon Checker Icon 1024.jpg',
  ),
  _OtherApp(
    'LED POP',
    'https://ledpop.onelink.me/ZM1Z/2myfwcif',
    'assets/images/other_apps/LED POP Icon.png',
  ),
  _OtherApp(
    'Wisdom Qclock',
    'https://wisdomqclock.onelink.me/SVr2/b7qs4og1',
    'assets/images/other_apps/Wisdom Qclock Icon.png',
  ),
  _OtherApp(
    'Dual Flashlight',
    'https://dualflashlight.onelink.me/7qkg/qpbc8y65',
    'assets/images/other_apps/Dual Flashlight Icon.png',
  ),
  _OtherApp(
    'Histree',
    'https://histree.onelink.me/c9TM/bfbeczgq',
    'assets/images/other_apps/Histree Icon.png',
  ),
  _OtherApp(
    'Scanatory',
    'https://scanatory.onelink.me/zzpK/2tr21itp',
    'assets/images/other_apps/Scanatory Icon.png',
  ),
  _OtherApp(
    'Play Memo',
    'https://playmemo.onelink.me/LdOZ/6bbfoohf',
    'assets/images/other_apps/Play Memo Icon.png',
  ),
  _OtherApp(
    'Find Four',
    'https://findfour.onelink.me/vurA/0tfteiuf',
    'assets/images/other_apps/Find Four Icon.png',
  ),
  _OtherApp(
    'decibella',
    'https://decibella.onelink.me/Ve6i/vydwhkh4',
    'assets/images/other_apps/decibella Icon 1024.png',
  ),
];

class AppListPage extends StatelessWidget {
  const AppListPage({super.key});

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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isEven) return const Divider(height: 1);
                return _buildAppListTile(context, _otherApps[index ~/ 2]);
              },
              childCount: _otherApps.length * 2 + 1,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SettingsFooter(),
    );
  }

  Widget _buildAppListTile(BuildContext context, _OtherApp app) {
    return ListTile(
      leading: Image.asset(
        app.iconPath,
        width: MediaQuery.of(context).size.height * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
        fit: BoxFit.cover,
      ),
      title: Text(
        app.name,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.02,
        ),
      ),
      onTap: () => _openApp(app),
      trailing: TextButton(
        onPressed: () => _openApp(app),
        child: Text(
          "Link",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.02,
          ),
        ),
      ),
    );
  }

  Future<void> _openApp(_OtherApp app) async {
    final uri = Uri.parse(app.link);
    if (await canLaunchUrl(uri)) {
      LogHelper().logEvent('other_app_opened', parameters: {
        'app': app.name,
      });
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
