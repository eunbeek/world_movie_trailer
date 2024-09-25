import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/layout/movie_list_page.dart';
import 'package:world_movie_trailer/layout/quote_list_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/settings_page.dart';
import 'package:world_movie_trailer/common/background.dart';

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  Movie? specialSection;
  bool isEditMode = false;
  List<String>? oldCountryOrder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSpecialMovies();
    });
  }

  Future<void> _fetchSpecialMovies() async {
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      List<Movie> movies = await MovieService.fetchMovie(special, settingsProvider.language);
      setState(() {
        specialSection = movies[0];
      });
    } catch (e) {
      print('Error fetching special movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageCode = settingsProvider.language;
    final countries = settingsProvider.countryOrder;
    double boxHeight = MediaQuery.of(context).size.height * 0.070;
    double specialHeight = MediaQuery.of(context).size.height * 0.09;
    double specialWidth =  MediaQuery.of(context).size.width * 0.95;
    double iconSize = MediaQuery.of(context).size.height * 0.035;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundWidget(isPausePage: false,),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(
                        getAppBarTitle(languageCode),
                        style: TextStyle(
                          fontSize:  MediaQuery.of(context).size.height * 0.055,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      if (isEditMode) ...[
                        IconButton(
                          icon: Icon(Icons.check, size: iconSize),
                          onPressed: () {
                            setState(() {
                              settingsProvider.updateCountryOrder(countries);
                              oldCountryOrder = null;
                              isEditMode = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: iconSize),
                          onPressed: () {
                            setState(() {
                              if(oldCountryOrder != null) settingsProvider.updateCountryOrder(oldCountryOrder!);
                              oldCountryOrder = null;
                              isEditMode = false;
                            });
                          },
                        ),
                      ] else ...[
                        IconButton(
                          icon: Image.asset(
                                  settingsProvider.isDarkTheme ? 'assets/images/dark/icon_reorder_DT_xxhdpi.png' : 'assets/images/light/icon_reorder_LT_xxhdpi.png',
                                  height: iconSize,
                                  width: iconSize,
                          ),
                          onPressed: () {
                            setState(() {
                              isEditMode = !isEditMode;
                              oldCountryOrder = countries;
                            });
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                                  settingsProvider.isDarkTheme ? 'assets/images/dark/icon_config_DT_xxhdpi.png' : 'assets/images/light/icon_config_LT_xxhdpi.png',
                                  height: iconSize,
                                  width: iconSize,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: countries.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ReorderableListView(
                            buildDefaultDragHandles: isEditMode,
                            padding: const EdgeInsets.only(top:8.0, bottom: 8.0, left: 24.0, right: 24.0),
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final String item = countries.removeAt(oldIndex);
                                countries.insert(newIndex, item);
                                settingsProvider.updateCountryOrder(countries);
                              });
                            },
                            children: [
                              for (int index = 0; index < countries.length; index++)
                                Container(
                                  key: ValueKey(countries[index]),
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 9.0),
                                  width: MediaQuery.of(context).size.width * 0.86,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                     onTap: () {
                                      if (isEditMode) return;
                                      if (settingsProvider.isVibrate) HapticFeedback.mediumImpact();

                                      LogHelper().logEvent('country_clicked', parameters: {'country_name': countries[index]},);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MovieListPage(
                                            country: countries[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          painter: GradientBorderPainter(isDark: settingsProvider.isDarkTheme),
                                          child: Container(
                                            height: boxHeight,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: boxHeight,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(28),
                                            color: Colors.transparent,
                                          ),
                                          alignment: Alignment.center,
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  countries[index],
                                                  style:  TextStyle(
                                                    fontSize: boxHeight * 0.3,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              if (isEditMode)
                                                Positioned(
                                                  top: boxHeight * 0.3,
                                                  right: 24,
                                                  child: const Icon(Icons.reorder),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
                const Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
              ],
            ),
            if (specialSection != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: specialWidth,
                  child: Container(
                    height: specialHeight,
                    decoration: BoxDecoration(
                      color: settingsProvider.isDarkTheme ? const Color.fromARGB(255, 102, 102, 102).withOpacity(0.5) : const Color.fromARGB(255, 51, 51, 51).withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        if(settingsProvider.isVibrate) HapticFeedback.mediumImpact();
                        LogHelper().logEvent('country_clicked', parameters: {'country_name': 'special'},);
                        if(settingsProvider.isQuotes) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuoteListPage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MovieListPage(
                                country: special,
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            settingsProvider.isQuotes? getSpecialQuoteLable(languageCode) : getSpecialLable(specialSection!, languageCode),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: specialHeight * 0.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settingsProvider.isQuotes ? getSpecialQuoteSource(languageCode) : getNameBySpecialSource(specialSection!, languageCode),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: specialHeight * 0.22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),            
          ],
        ),
      ), 
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final bool isDark;
  GradientBorderPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: isDark ? [const Color(0xff12d6df), const Color(0xfff70fff)]: [const Color(0xff00ffed), const Color(0xff9d00c6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const radius = Radius.circular(30.0);
    final rrect = RRect.fromRectAndCorners(rect,
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
