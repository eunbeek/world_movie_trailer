import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_manager/interstitial_ad_manager.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/services/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/error_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BoxOfficeListPage extends StatefulWidget {
  const BoxOfficeListPage({super.key});

  @override
  _BoxOfficeListPageState createState() => _BoxOfficeListPageState();
}

class _BoxOfficeListPageState extends State<BoxOfficeListPage>
    with SingleTickerProviderStateMixin {
  List<Movie> allMovies = [];
  bool fetchComplete = false;
  late InterstitialAdManager _appAdManager;

  @override
  void initState() {
    super.initState();
    _appAdManager = InterstitialAdManager();
    _loadAd();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final language = settingsProvider.language;

      final movies = await MovieService.fetchMovie(boxOffice, language);
      setState(() {
        allMovies = movies;
        fetchComplete = true;
      });
    } catch (e) {
      print('Error fetching movies: $e');
      setState(() {
        fetchComplete = true;
      });
    }
  }

  void _loadAd() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.isAdsFree) return;

    _appAdManager.loadAd(onAdLoaded: () {}, onAdFailed: () {});
  }

  void _showAd(Function onAdDismiss) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.isAdsFree) {
      print('adsFree');
      onAdDismiss();
      return;
    }

    _appAdManager.showAdIfAvailable(() {
      onAdDismiss();
    });
  }

  String getFormattedDateRange(
      String languageCode, DateTime startDate, DateTime endDate) {
    if (languageCode == 'ko') {
      // 한국어: 1월 30일 - 2월 2일
      String startFormatted = DateFormat("M월 d일", 'ko').format(startDate);
      String endFormatted =
          DateFormat(startDate.month == endDate.month ? "d일" : "M월 d일", 'ko')
              .format(endDate);
      return "$startFormatted - $endFormatted";
    } else if (languageCode == 'ja' ||
        languageCode == 'zh' ||
        languageCode == 'tw') {
      // 일본어/중국어: 1月30日 - 2月2日
      String startFormatted = DateFormat("M月d日", 'ja').format(startDate);
      String endFormatted =
          DateFormat(startDate.month == endDate.month ? "d日" : "M月d日", 'ja')
              .format(endDate);
      return "$startFormatted - $endFormatted";
    } else {
      // 기본 (영어): Jan 30 - Feb 2
      String startFormatted = DateFormat("MMM d", 'en').format(startDate);
      String endFormatted =
          DateFormat(startDate.month == endDate.month ? "d" : "MMM d", 'en')
              .format(endDate);
      return "$startFormatted - $endFormatted";
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const BackgroundWidget(isPausePage: false, isTapeExist: false),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: MediaQuery.of(context).size.height * 0.03,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          getBoxOfficeLabel(
                              settingsProvider.language, 'box_usa'),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SizedBox(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 10.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: getBoxOfficeLabel(settingsProvider.language,
                              'this_week'), // "이번 주 순위"
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.019,
                            fontWeight: FontWeight.bold,
                            color: settingsProvider.isDarkTheme
                                ? Colors.white
                                : Color(0xFF333333),
                          ),
                        ),
                        TextSpan(
                          text: allMovies.isNotEmpty
                              ? ' (${getFormattedDateRange(settingsProvider.language, DateTime.parse(allMovies[0].weekStartDate!), DateTime.parse(allMovies[0].weekEndDate!))})'
                              : '',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.019,
                            fontWeight: FontWeight.bold,
                            color: settingsProvider.isDarkTheme
                                ? Colors.amberAccent
                                : const Color(0xFF00AEEF), // 하늘색
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1.2, // 조금 두껍게
                  color: Colors.grey.withOpacity(0.4), // 연한 색상
                  indent: 16, // 좌측 여백 추가
                  endIndent: 16, // 우측 여백 추가
                ),
                _buildMovieList(allMovies),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieList(List<Movie> movies) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (movies.isEmpty) {
      return fetchComplete
          ? ErrorPage()
          : const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  LogHelper().logEvent(
                      'movie ${movie.localTitle} clicked in Box Office');

                  if (settingsProvider.openCount > adLimitNum) {
                    if (_appAdManager.interstitialAd != null) {
                      _showAd(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MovieDetailPageYouTube(
                                    movie: movie,
                                    captionFlag: settingsProvider.isCaptionOn,
                                    captionLan: settingsProvider.language,
                                    isCustomized: false,
                                  )),
                        );
                      });
                    }
                    settingsProvider.resetOpenCount();
                  } else {
                    settingsProvider.updateOpenCount();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MovieDetailPageYouTube(
                                movie: movie,
                                captionFlag: settingsProvider.isCaptionOn,
                                captionLan: settingsProvider.language,
                                isCustomized: false,
                              )),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: movie.posterUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  settingsProvider.isDarkTheme
                                      ? 'assets/images/dark/blank_DT_xxhdpi.png'
                                      : 'assets/images/light/blank_LT_xxhdpi.png',
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                settingsProvider.isDarkTheme
                                    ? 'assets/images/dark/blank_DT_xxhdpi.png'
                                    : 'assets/images/light/blank_LT_xxhdpi.png',
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.transparent, width: 0.1),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${index + 1}. ${movie.localTitle}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: settingsProvider.isDarkTheme
                                            ? Colors.white
                                            : Color(0xFF333333),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.019,
                                      ),
                                    ),
                                  ),
                                  if (movie.isNewThisWeek == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text(
                                        'NEW',
                                        style: TextStyle(
                                          color: settingsProvider.isDarkTheme
                                              ? Colors.amberAccent
                                              : const Color(0xFF00AEEF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.019,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${getBoxOfficeLabel(settingsProvider.language, 'last_week')}: ${movie.lastRank ?? "-"}',
                                style: TextStyle(
                                  color: settingsProvider.isDarkTheme
                                      ? Colors.grey
                                      : Color(0xFF333333),
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.017,
                                ),
                              ),
                              Text(
                                '${getBoxOfficeLabel(settingsProvider.language, 'total_gross')}: ${movie.totalGross}',
                                style: TextStyle(
                                  color: settingsProvider.isDarkTheme
                                      ? Colors.grey
                                      : Color(0xFF333333),
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.017,
                                ),
                              ),
                              Text(
                                '${getBoxOfficeLabel(settingsProvider.language, 'screening_weeks')}: ${movie.weeks}',
                                style: TextStyle(
                                  color: settingsProvider.isDarkTheme
                                      ? Colors.grey
                                      : Color(0xFF333333),
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.017,
                                ),
                              ),
                              Text(
                                '${getBoxOfficeLabel(settingsProvider.language, 'distributor')}: ${movie.distributor}',
                                style: TextStyle(
                                  color: settingsProvider.isDarkTheme
                                      ? Colors.grey
                                      : Color(0xFF333333),
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.017,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 1.2,
                color: Colors.grey.withOpacity(0.4),
              ),
            ],
          );
        },
      ),
    );
  }
}
