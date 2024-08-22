import 'package:flutter/material.dart';
import 'package:world_movie_trailer/layout/video_ad_page.dart';
import 'package:world_movie_trailer/common/constants.dart';

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<String> countries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arrangeCountriesBasedOnLocale();
    });
  }

  void _arrangeCountriesBasedOnLocale() {
    String languageCode = Localizations.localeOf(context).languageCode;
    setState(() {
      countries = countryKeys
          .map((key) =>
              localizedCountries[languageCode]?[key] ?? localizedCountries['en']![key]!)
          .toList();
    });
  }

  String _getAppBarTitle(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return countryAppBarKr;
      case 'ja':
        return countryAppBarJp;
      case 'en':
        return countryAppBarEn;
      default:
        return countryAppBarEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(languageCode)),
      ),
      body: countries.isEmpty
          ? const Center(child: CircularProgressIndicator()) 
          : ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final String item = countries.removeAt(oldIndex);
                countries.insert(newIndex, item);
              });
            },
            padding: const EdgeInsets.all(16.0),
            children: [
              for (int index = 0; index < countries.length; index++)
                Padding(
                  key: ValueKey(countries[index]),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoAdPage(country: countries[index]),
                          ),
                        );
                      },
                      highlightColor: Colors.blue.withOpacity(0.1),
                      splashColor: Colors.blue.withOpacity(0.2),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            countries[index],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );
  }
}
