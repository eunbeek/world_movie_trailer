import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
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

class _CountryListPageState extends State<CountryListPage> {
  Movie? specialSection;
  bool isEditMode = false;
  bool isDropdownVisible = false; 
  List<String>? oldCountryOrder;
  List<Movie>? specialMovieList;

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
    double boxHeight = MediaQuery.of(context).size.height * 0.070;
    double specialHeight = MediaQuery.of(context).size.height * 0.09;
    double specialWidth =  MediaQuery.of(context).size.width * 0.95;
    double iconSize = MediaQuery.of(context).size.height * 0.035;

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageCode = settingsProvider.language;
    final countries = settingsProvider.countryOrder;
    int currentWeekday = DateTime.now().weekday-1;
    final countriesOfTheDay = countryByDay[currentWeekday] ?? []; // origin

    final localizedCountriesOfTheDay = countriesOfTheDay.map((countryCode) {
      return localizedCountries[languageCode]?[countryCode] ?? countryCode;
    }).toList();

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
                              case 'Like':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieByUserListPage(flag: 'Like',),
                                  ),
                                );
                              case 'Dislike':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieByUserListPage(flag: 'Dislike',),
                                  ),
                                );
                              case 'Bookmark':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieByUserListPage(flag: 'Bookmark',),
                                  ),
                                );
                              case 'Memo':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemoListPage(),
                                  ),
                                );
                            }
                            print('Selected: $newValue');
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
                                  Text('Button Order'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Like',
                              child: Row(
                                children: [
                                  Image.asset(
                                    settingsProvider.isDarkTheme
                                        ? 'assets/images/dark/icon_like_DT_xxhdpi.png'
                                        : 'assets/images/light/icon_like_LT_xxhdpi.png',
                                    height: iconSize,
                                    width: iconSize,
                                  ),
                                  SizedBox(width: 8,),
                                  Text('Like'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Dislike',
                              child: Row(
                                children: [
                                  Image.asset(
                                    settingsProvider.isDarkTheme
                                        ? 'assets/images/dark/icon_dislike_DT_xxhdpi.png'
                                        : 'assets/images/light/icon_dislike_LT_xxhdpi.png',
                                    height: iconSize,
                                    width: iconSize,
                                  ),
                                  SizedBox(width: 8,),
                                  Text('Dislike'),
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
                                  Text('Bookmark'),
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
                                  Text('Memo'),
                                ],
                              ),
                            ),
                          ],
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

                                final String? originCountry = localizedCountries[languageCode]?.entries
                                    .firstWhere((entry) => entry.value == countries[index], orElse: () => MapEntry('', '')).key;

                                if (originCountry != null && localizedCountriesOfTheDay.contains(countries[index])) {
                                  settingsProvider.unmarkIsNewShown(currentWeekday, originCountry);
                                }

                                LogHelper().logEvent('country_clicked', parameters: {'country_name': countries[index]});

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
                                      if (
                                        !isEditMode &&
                                        localizedCountries[languageCode] != null && 
                                        settingsProvider.isNewShown[currentWeekday] != null && 
                                        settingsProvider.isNewShown[currentWeekday]![
                                          localizedCountries[languageCode]!.entries
                                            .firstWhere((entry) => entry.value == countries[index], orElse: () => MapEntry('', '')).key
                                        ] == true // new 상태가 true인지 확인
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
                                      if (isEditMode)
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
