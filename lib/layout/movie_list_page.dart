import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_manager/interstitial_ad_manager.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/services/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_youtube_page.dart';
import 'package:world_movie_trailer/layout/movie_detail_chewie_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/common/TabBarGradientIndicator.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/error_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieListPage extends StatefulWidget {
  final String country;
  final List<Movie>? specialList;

  const MovieListPage({super.key, required this.country, this.specialList});

  @override
  _MovieListPageState createState() => _MovieListPageState();
}
class _MovieListPageState extends State<MovieListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Movie> allMovies = [];
  bool fetchComplete = false;
  late InterstitialAdManager _appAdManager;
  String _selectedFilterAll = 'date_new';
  String _selectedFilterRun = 'date_new';
  String _selectedFilterUp = 'date_new';

  @override
  void initState() {
    super.initState();
    _appAdManager = InterstitialAdManager();
    _loadAd();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.country == special ? 0 : 1);
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      if (widget.country == special && widget.specialList != null) {
        setState(() {
          allMovies = widget.specialList!;
          fetchComplete = true;
        });
      } else {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final language = settingsProvider.language;
        
        final movies = await MovieService.fetchMovie(widget.country, language);

        setState(() {
          allMovies = movies;
          fetchComplete = true;
        });
      }
    } catch (e) {
      print('Error fetching movies: $e');
      setState(() {
        fetchComplete = true;
      });
    }
  }

  void _loadAd() {
      
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settingsProvider.isAdsFree) return;

    _appAdManager.loadAd(
      onAdLoaded: () {},
      onAdFailed: () {}
    );
  }

  void _showAd(Function onAdDismiss) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.isAdsFree) {
      print('adsFree');
      onAdDismiss();
      return;
    }

    _appAdManager.showAdIfAvailable(() {
      onAdDismiss();
    });
  }

List<Movie> _getFilteredMovies(String filter) {
  List<Movie> filteredList = [];
  final now = DateTime.now();

  try {
    if (filter == listFilterAll) {
      filteredList = List.from(allMovies);

      try {
        if (_selectedFilterAll == 'date_new') {
          filteredList.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.releaseDate);
              DateTime dateB = DateTime.parse(b.releaseDate);
              return dateB.compareTo(dateA);
            } catch (e, stack) {
              print("🚨 Error parsing dates in date_new (All) - Movie: ${a.localTitle} | releaseDate: ${a.releaseDate}\n$e\n$stack");
              return 0;
            }
          });
        } else if (_selectedFilterAll == 'date_old') {
          filteredList.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.releaseDate);
              DateTime dateB = DateTime.parse(b.releaseDate);
              return dateA.compareTo(dateB);
            } catch (e, stack) {
              print("🚨 Error parsing dates in date_old (All) - Movie: ${a.localTitle} | releaseDate: ${a.releaseDate}\n$e\n$stack");
              return 0;
            }
          });
        } else if (_selectedFilterAll == 'alphabet_asc') {
          filteredList.sort((a, b) => a.localTitle.compareTo(b.localTitle));
        } else if (_selectedFilterAll == 'alphabet_desc') {
          filteredList.sort((a, b) => b.localTitle.compareTo(a.localTitle));
        }
      } catch (e, stack) {
        print("🚨 Error sorting movies in listFilterAll: $e\n$stack");
      }
    } 
    
    else if (filter == listFilterRunning) {
      try {
        filteredList = allMovies.where((movie) {
          try {
            if (movie.releaseDate.isEmpty) return false;
            final releaseDate = DateTime.parse(movie.releaseDate);
            return releaseDate.isBefore(now);
          } catch (e, stack) {
            print("🚨 Error filtering Running movies - Movie: ${movie.localTitle} | releaseDate: ${movie.releaseDate}\n$e\n$stack");
            return false;
          }
        }).toList();

        if (_selectedFilterRun == 'date_new') {
          filteredList.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.releaseDate);
              DateTime dateB = DateTime.parse(b.releaseDate);
              return dateB.compareTo(dateA);
            } catch (e, stack) {
              print("🚨 Error parsing dates in date_new (Running) - Movie: ${a.localTitle} | releaseDate: ${a.releaseDate}\n$e\n$stack");
              return 0;
            }
          });
        } else if (_selectedFilterRun == 'date_old') {
          filteredList.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.releaseDate);
              DateTime dateB = DateTime.parse(b.releaseDate);
              return dateA.compareTo(dateB);
            } catch (e, stack) {
              print("🚨 Error parsing dates in date_old (Running) - Movie: ${a.localTitle} | releaseDate: ${a.releaseDate}\n$e\n$stack");
              return 0;
            }
          });
        } else if (_selectedFilterRun == 'alphabet_asc') {
          filteredList.sort((a, b) => a.localTitle.compareTo(b.localTitle));
        } else if (_selectedFilterRun == 'alphabet_desc') {
          filteredList.sort((a, b) => b.localTitle.compareTo(a.localTitle));
        }
      } catch (e, stack) {
        print("🚨 Error sorting movies in listFilterRunning: $e\n$stack");
      }
    } 
    
    else if (filter == listFilterUpcoming) {
      try {
        filteredList = allMovies.where((movie) {
          try {
            if (movie.releaseDate.isEmpty) return false;
            final releaseDate = DateTime.parse(movie.releaseDate);
            return releaseDate.isAfter(now);
          } catch (e, stack) {
            print("🚨 Error filtering Upcoming movies - Movie: ${movie.localTitle} | releaseDate: ${movie.releaseDate}\n$e\n$stack");
            return false;
          }
        }).toList();

        if (_selectedFilterUp == 'date_new') {
          filteredList.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.releaseDate);
              DateTime dateB = DateTime.parse(b.releaseDate);
              return dateA.compareTo(dateB);
            } catch (e, stack) {
              print("🚨 Error parsing dates in date_new (Upcoming) - Movie: ${a.localTitle} | releaseDate: ${a.releaseDate}\n$e\n$stack");
              return 0;
            }
          });
        } else if (_selectedFilterUp == 'date_old') {
          filteredList.sort((a, b) {
            try {
              DateTime dateA = DateTime.parse(a.releaseDate);
              DateTime dateB = DateTime.parse(b.releaseDate);
              return dateB.compareTo(dateA);
            } catch (e, stack) {
              print("🚨 Error parsing dates in date_old (Upcoming) - Movie: ${a.localTitle} | releaseDate: ${a.releaseDate}\n$e\n$stack");
              return 0;
            }
          });
        } else if (_selectedFilterUp == 'alphabet_asc') {
          filteredList.sort((a, b) => a.localTitle.compareTo(b.localTitle));
        } else if (_selectedFilterUp == 'alphabet_desc') {
          filteredList.sort((a, b) => b.localTitle.compareTo(a.localTitle));
        }
      } catch (e, stack) {
        print("🚨 Error sorting movies in listFilterUpcoming: $e\n$stack");
      }
    } 
    
    else {
      return [];
    }
  } catch (e, stack) {
    print("🚨 Unexpected error in _getFilteredMovies: $e\n$stack");
    return [];
  }

  return filteredList;
}


  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const BackgroundWidget(isPausePage: false, isTapeExist: true),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
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
                          widget.country == special ? getNameBySpecialSource(allMovies[0], settingsProvider.language) : widget.country,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Image.asset(
                            settingsProvider.isDarkTheme
                                ? 'assets/images/dark/icon_sort_DT_xxhdpi.png'
                                : 'assets/images/light/icon_sort_LT_xxhdpi.png',
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        onSelected: (String value) {
                          setState(() {
                            if(_tabController.index == 0) _selectedFilterAll = value;
                            if(_tabController.index == 1) _selectedFilterRun = value;
                            if(_tabController.index == 2) _selectedFilterUp = value;
                          });
                        },
                        position: PopupMenuPosition.under,
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'date_new',
                              child: Container(
                                constraints: BoxConstraints(minWidth: 150), // 최소 너비 설정
                                child: Row(
                                  children: [
                                    if (_tabController.index == 0 && _selectedFilterAll == 'date_new')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ) 
                                    else if (_tabController.index == 1 && _selectedFilterRun == 'date_new')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ) 
                                    else if (_tabController.index == 2 && _selectedFilterUp == 'date_new')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _tabController.index == 2 ? getSortFilterLabel(settingsProvider.language, 'date_new_up') :  getSortFilterLabel(settingsProvider.language, 'date_new'),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'date_old',
                              child: Container(
                                constraints: BoxConstraints(minWidth: 150), // 최소 너비 설정
                                child: Row(
                                  children: [
                                    if (_tabController.index == 0 && _selectedFilterAll == 'date_old')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ) 
                                    else if (_tabController.index == 1 && _selectedFilterRun == 'date_old')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ) 
                                    else if (_tabController.index == 2 && _selectedFilterUp == 'date_old')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _tabController.index == 2 ? getSortFilterLabel(settingsProvider.language, 'date_old_up') : getSortFilterLabel(settingsProvider.language, 'date_old'),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'alphabet_asc',
                              child: Container(
                                constraints: BoxConstraints(minWidth: 150), // 최소 너비 설정
                                child: Row(
                                  children: [
                                    if (_tabController.index == 0 && _selectedFilterAll == 'alphabet_asc')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      )
                                   else if (_tabController.index == 1 && _selectedFilterRun == 'alphabet_asc')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ) 
                                    else if (_tabController.index == 2 && _selectedFilterUp == 'alphabet_asc')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      getSortFilterLabel(settingsProvider.language, 'alphabet_asc'),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'alphabet_desc',
                              child: Container(
                                constraints: BoxConstraints(minWidth: 150), // 최소 너비 설정
                                child: Row(
                                  children: [
                                    if (_tabController.index == 0 && _selectedFilterAll == 'alphabet_desc')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      )
                                    else if (_tabController.index == 1 && _selectedFilterRun == 'alphabet_desc')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      )
                                    else if (_tabController.index == 2 && _selectedFilterUp == 'alphabet_desc')
                                      Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_check_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_check_LT_xxhdpi.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      getSortFilterLabel(settingsProvider.language, 'alphabet_desc'),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),
                if (widget.country != special)
                  TabBar(
                    controller: _tabController,
                    dividerColor: settingsProvider.isDarkTheme ? const Color(0xff49454f) : const Color(0xffe7e0ec),
                    indicator: TabBarGradientIndicator(
                      gradientColor: [
                        settingsProvider.isDarkTheme ? const Color(0xff12d6df) : const Color(0xff00ffed),
                        settingsProvider.isDarkTheme ? const Color(0xfff70fff) : const Color(0xff9d00c6),
                      ],
                      insets: const EdgeInsets.fromLTRB(0.0, 68.0, 0.0, 0.0),
                      indicatorWidth: 1,
                    ),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: settingsProvider.isDarkTheme ? const Color(0xffececec) : const Color(0xff1a1713),
                    ),
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(0, settingsProvider.language),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.015,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(1, settingsProvider.language),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.015,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(2, settingsProvider.language),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.015,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onTap: (index) {
                      if (settingsProvider.isVibrate) HapticFeedback.mediumImpact();
                      LogHelper().logEvent('${index == 0? 'all': index == 1 ? 'running': 'upcoming'}_movie_tabs');
                    },
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                fetchComplete
                    ? Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildMovieGrid(_getFilteredMovies(listFilterAll), 0),
                            _buildMovieGrid(_getFilteredMovies(listFilterRunning), 1),
                            _buildMovieGrid(_getFilteredMovies(listFilterUpcoming), 2),
                          ],
                        ),
                      )
                    : const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies, int tabIndex) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (movies.isEmpty) {
      return fetchComplete ? ErrorPage() : const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          String? releaseDate;
          if (movie.releaseDate != '') {
            releaseDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(movie.releaseDate));
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              LogHelper().logEvent('movie ${movie.localTitle} clicked in ${tabIndex == 0 ? 'All' : index == 1 ? 'Running' : 'Upcoming'} tab');
              if (settingsProvider.openCount > adLimitNum) {
                if(_appAdManager.interstitialAd != null){
                  _showAd(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => movie.isYoutube != false
                            ? MovieDetailPageYouTube(movie: movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: false,)
                            : MovieDetailPageChewie(movie: movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: false,),
                      ),
                    );
                  });
                }
                settingsProvider.resetOpenCount();
              } else {
                settingsProvider.updateOpenCount(); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => movie.isYoutube != false
                        ? MovieDetailPageYouTube(movie: movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: false,)
                        : MovieDetailPageChewie(movie: movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: false,),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: settingsProvider.isDarkTheme ? const Color(0xff666666) : const Color(0xff999999),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: movie.posterUrl != ""
                          ? CachedNetworkImage(
                              imageUrl: movie.posterUrl, // 이미지 URL
                              fit: BoxFit.cover,         // 기존 BoxFit 설정 그대로 유지
                              width: double.infinity,    // 기존 너비
                              height: double.infinity,   // 기존 높이
                              errorWidget: (context, url, error) => Image.asset(
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
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.localTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xffececec),
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height * 0.017,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (releaseDate != null)
                          Text(
                            releaseDate,
                            style: TextStyle(
                              color: const Color(0xffc7c7c7),
                              fontSize: MediaQuery.of(context).size.height * 0.013,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
