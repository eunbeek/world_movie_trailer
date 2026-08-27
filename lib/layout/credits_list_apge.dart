import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';

class CreditsList extends StatelessWidget {
  const CreditsList({super.key}); // 앱 링크

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
                      getSettingsLabel(settingsProvider.language, "credits"),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
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
                              ? 'assets/images/dark/icon_credits_DT_xxhdpi.png'
                              : 'assets/images/light/icon_credits_LT_xxhdpi.png',
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          getSettingsLabel(
                              settingsProvider.language, "credits"),
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
                  'Eunbee',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Artist',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                trailing: Text(
                  'Eugene',
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
                    'Jisu, Rene, Steve, Sylbee, Kim and Choi Family, Esther, Marcus, Danop, Stojan, DVDPrime, Toronto Korean Developers',
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
