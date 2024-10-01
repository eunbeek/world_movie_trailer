import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class CreditsList extends StatelessWidget {
  const CreditsList({super.key}); // 앱 링크

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            getSettingsLabel(settingsProvider.language, "credits"),
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
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: <Widget>[
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
                    'Eugune',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
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
                  trailing: Text(
                    'Mary, Kota, Carol, Edward',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.018,
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
                    'Special Thanks',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.018,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.0), 
                      Text(
                        'Jisu, Rene, Steve, Sylbee',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.017,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
