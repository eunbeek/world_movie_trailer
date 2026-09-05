import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';
import 'package:world_movie_trailer/layout/widgets/settings_sliver_header.dart';

class CreditsList extends StatelessWidget {
  const CreditsList({super.key}); // 앱 링크

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsSliverHeader(
            title: getSettingsLabel(settingsProvider.language, "credits"),
            darkIconAsset: 'assets/images/dark/icon_credits_DT_xxhdpi.png',
            lightIconAsset: 'assets/images/light/icon_credits_LT_xxhdpi.png',
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Divider(),
              ListTile(
                title: Text(
                  'Producer',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                trailing: Text(
                  'R.S.',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Programmer',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                trailing: Text(
                  'Eunbee Kim',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'UI/UX Designer',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                trailing: Text(
                  'Eugene Song, Jenny Kim',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'QA Testers',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                  ),
                ),
                trailing: Text(
                  'YC, SJ',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Localization Managers',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.0),
                    Text(
                      '  Mary, Kota, Carol, Edward, Carmack',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.017,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Special Thanks',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Jisu, Rene, Yiseo, Steve, Sylbee, Kim and Choi Family, Esther, Marcus, Danop, Stojan, DVDPrime, Toronto Korean Developers',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.017,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.visible,
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
