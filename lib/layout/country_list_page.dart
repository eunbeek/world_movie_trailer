import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/layout/box_office_list_page.dart';
import 'package:world_movie_trailer/layout/memo_list_page.dart';
import 'package:world_movie_trailer/layout/movie_by_user_list_page.dart';
import 'package:world_movie_trailer/layout/movie_list_page.dart';
import 'package:world_movie_trailer/layout/quote_list_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/services/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/settings_page.dart';
import 'package:world_movie_trailer/common/background.dart';

class CountryListPage extends StatefulWidget {
  final bool isInit;

  const CountryListPage({super.key, required this.isInit});

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> with WidgetsBindingObserver {
  Movie? specialSection;
  bool isEditMode = false;
  bool isDropdownVisible = false; 
  List<String>? oldCountryOrder;
  List<Movie>? specialMovieList;
  String? promotionUrl;

  @override
  void initState() {
    super.initState();
    _fetchPromotionUrl();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSpecialMovies();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unmarkNewOnExit();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _unmarkNewOnExit();
    }
  }

  void _unmarkNewOnExit() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.unmarkAllIsNewShown();
    print("All 'NEW' flags unmarked due to app exit or navigation.");
  }


  Future<void> _fetchPromotionUrl() async {
    try {
      final url = await MovieService.fetchPromotionUrl();
      setState(() {
        promotionUrl = url;  // Update the state with the fetched URL
      });
    } catch (e) {
      print('Error fetching promotion URL: $e');
      setState(() {
        promotionUrl = '';  // In case of an error, reset the URL
      });
    }
  }

  Future<void> _fetchSpecialMovies() async {
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      List<Movie> movies = await MovieService.fetchMovie(special, settingsProvider.language);

      final now = DateTime.now();
      // 이전에 가져온 영화가 있는 경우
      if (settingsProvider.lastSpecialNumber != 0) {
        print('After Fetched');
        print(settingsProvider.lastSpecialFetched);
        final daysDifference = now.difference(settingsProvider.lastSpecialFetched!).inDays;

        if (daysDifference > 7) {
          print(' Greater than 7 days');
          // 7일 이상 경과: 새로운 영화(period = lastSpecialNumber + 1)를 가져옴
          var filteredMovies = movies.where((movie) => movie.period == settingsProvider.lastSpecialNumber + 1).toList();

          if (filteredMovies.isNotEmpty) {
            setState(() {
              specialSection = filteredMovies[0];
              specialMovieList = filteredMovies;  // 필터된 영화 리스트 설정
            });
            settingsProvider.updateLastSpecialNumber(settingsProvider.lastSpecialNumber + 1);

          } else {
            // 새로운 영화가 없으면 최신 영화로 설정
            var latestMovies = movies.where((movie) => movie.period == movies[0].period).toList();
            setState(() {
              specialSection = latestMovies[0];
              specialMovieList = latestMovies;
            });
            settingsProvider.updateLastSpecialNumber(movies[0].period!);
          }

          settingsProvider.updateLastSpecialFetched(now);

        } else {
          print(' Less than 7 days');
          // 7일 이내: 현재 lastSpecialNumber에 해당하는 영화 표시
          var filteredMovies = movies.where((movie) => movie.period == settingsProvider.lastSpecialNumber).toList();

          if (filteredMovies.isNotEmpty) {
            setState(() {
              specialSection = filteredMovies[0];
              specialMovieList = filteredMovies;
            });
          } else {
            // 만약 해당 period의 영화가 없을 경우 최신 영화로 설정
            var latestMovies = movies.where((movie) => movie.period == movies[0].period).toList();
            setState(() {
              specialSection = latestMovies[0];
              specialMovieList = latestMovies;
            });
          }
        }

      } else {
        print("First Fetched");
        // lastSpecialNumber가 0인 경우, 첫 번째 영화를 선택
        var latestMovies = movies.where((movie) => movie.period == movies[0].period).toList();
        setState(() {
          specialSection = latestMovies[0];
          specialMovieList = latestMovies;
        });
        settingsProvider.updateLastSpecialNumber(movies[0].period!);
      }

    } catch (e) {
      print('Error fetching special movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double titleHeight = MediaQuery.of(context).size.height * 0.21;
    double boxHeight = MediaQuery.of(context).size.height * 0.070;
    double specialHeight = MediaQuery.of(context).size.height * 0.09;
    double specialWidth =  MediaQuery.of(context).size.width * 0.95;
    double iconSize = MediaQuery.of(context).size.height * 0.035;

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageCode = settingsProvider.language;
    final countries = settingsProvider.countryOrder;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundWidget(isPausePage: false, isTapeExist: true,),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 16.0,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          getAppBarTitle(languageCode),
                          style: TextStyle(
                            fontSize: titleHeight * 0.25,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        height: titleHeight * 0.95,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
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
                                  PopupMenuButton<String>(
                                    icon: Image.asset(
                                      settingsProvider.isDarkTheme
                                          ? 'assets/images/dark/icon_menu_DT_xxhdpi.png'
                                          : 'assets/images/light/icon_menu_LT_xxhdpi.png',
                                      height: iconSize,
                                      width: iconSize,
                                    ),
                                    onSelected: (String newValue) {
                                      switch (newValue){
                                        case 'Rearrange':
                                          isEditMode = !isEditMode;
                                          oldCountryOrder = countries;
                                        case 'Bookmark':
                                          _unmarkNewOnExit();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MovieByUserListPage(flag: 'Bookmark',),
                                            ),
                                          );
                                        case 'Memo':
                                          _unmarkNewOnExit();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MemoListPage(),
                                            ),
                                          );
                                      }
                                      print('Selected: $newValue');
                                      LogHelper().logEvent('pchange_clicked');
                                      setState(() {
                                        isDropdownVisible = false;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem<String>(
                                        value: 'Rearrange',
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              settingsProvider.isDarkTheme
                                                  ? 'assets/images/dark/icon_reorder_DT_xxhdpi.png'
                                                  : 'assets/images/light/icon_reorder_LT_xxhdpi.png',
                                              height: iconSize,
                                              width: iconSize,
                                            ),
                                            SizedBox(width: 8,),
                                            Text(getMenuItemTitle(settingsProvider.language, 'Country Order')),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'Bookmark',
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              settingsProvider.isDarkTheme
                                                  ? 'assets/images/dark/icon_bookmark_DT_xxhdpi.png'
                                                  : 'assets/images/light/icon_bookmark_LT_xxhdpi.png',
                                              height: iconSize,
                                              width: iconSize,
                                            ),
                                            SizedBox(width: 8,),
                                            Text(getMenuItemTitle(settingsProvider.language, 'Bookmark')),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'Memo',
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              settingsProvider.isDarkTheme
                                                  ? 'assets/images/dark/icon_memo_DT_xxhdpi.png'
                                                  : 'assets/images/light/icon_memo_LT_xxhdpi.png',
                                              height: iconSize,
                                              width: iconSize,
                                            ),
                                            SizedBox(width: 8,),
                                            Text(getMenuItemTitle(settingsProvider.language, 'Memo')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // IconButton(
                                  //   icon: Image.asset(
                                  //     settingsProvider.isDarkTheme ? 'assets/images/dark/icon_store_DT_xxhdpi.png' : 'assets/images/light/icon_store_LT_xxhdpi.png',
                                  //     height: iconSize,
                                  //     width: iconSize,
                                  //   ),
                                  //   onPressed: () {
                                  //     _unmarkNewOnExit();
                                  //   },
                                  // ),
                                  IconButton(
                                    icon: Image.asset(
                                      settingsProvider.isDarkTheme ? 'assets/images/dark/icon_config_DT_xxhdpi.png' : 'assets/images/light/icon_config_LT_xxhdpi.png',
                                      height: iconSize,
                                      width: iconSize,
                                    ),
                                    onPressed: () {
                                      _unmarkNewOnExit();
                                      LogHelper().logEvent('setting_clicked');
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
                            IconButton(
                              onPressed: () async {
                                LogHelper().logEvent('promotion_url clicked');
                                _unmarkNewOnExit();
                                if (await canLaunchUrl(Uri.parse(promotionUrl!))) {
                                  await launchUrl(Uri.parse(promotionUrl!), mode: LaunchMode.externalApplication);
                                }
                              }, 
                              icon: Image.asset(
                                settingsProvider.isDarkTheme
                                    ? 'assets/images/dark/icon_popcorn_DT_xxhdpi.png'
                                    : 'assets/images/light/icon_popcorn_LT_xxhdpi.png',
                                height:  MediaQuery.of(context).size.height * 0.06 ,
                                width:  MediaQuery.of(context).size.height * 0.06,
                              ),
                            ),           
                          ],
                        ),
                      ),
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
                        // 'box'는 항상 첫 번째 위치에 고정
                        const boxIndex = 0;
                        if (oldIndex == boxIndex) return; // 'box'는 이동 금지
                        if (newIndex <= boxIndex) newIndex = boxIndex + 1; // 'box' 앞으로 이동 금지

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

                                _unmarkNewOnExit();
                                if(index == 0) LogHelper().logEvent('box_office_clicked');
                                LogHelper().logEvent('country_clicked', parameters: {'country_name': countries[index]});
                                if (index == 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BoxOfficeListPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieListPage(
                                        country: countries[index],
                                      ),
                                    ),
                                  );
                                }
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
                                        if (
                                          !isEditMode &&
                                          localizedCountries[languageCode] != null && 
                                          settingsProvider.getCountryStatus(localizedCountries[languageCode]!.entries
                                              .firstWhere((entry) => entry.value == countries[index], orElse: () => MapEntry('', '')).key)
                                        ) 
                                          Positioned(
                                            top: boxHeight * 0.35,
                                            right: 24,
                                            child: Text(
                                              "NEW", 
                                              style: TextStyle(
                                                color: settingsProvider.isDarkTheme ? Colors.yellow : Colors.red, 
                                                fontSize: boxHeight * 0.2,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (isEditMode && countries[index] != 'box')
                                          Positioned(
                                            top: boxHeight * 0.25,
                                            right: 24,
                                            child: Image.asset(
                                              settingsProvider.isDarkTheme ? 'assets/images/dark/icon_drag_handle_DT_xxhdpi.png' : 'assets/images/light/icon_drag_handle_LT_xxhdpi.png',
                                              height: iconSize,
                                              width: iconSize,
                                            ),
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
            if (specialSection != null || settingsProvider.isQuotes)
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
                        if(settingsProvider.isQuotes) {
                          _unmarkNewOnExit();
                          LogHelper().logEvent('special_quotes_clicked', parameters: {'section_name': 'quote'},);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuoteListPage(),
                            ),
                          );
                        } else {
                          _unmarkNewOnExit();
                          LogHelper().logEvent('special_movie_clicked', parameters: {'section_name': specialSection!.special},);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieListPage(
                                country: special,
                                specialList: specialMovieList,
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
