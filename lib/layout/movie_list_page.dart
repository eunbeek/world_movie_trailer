import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_ad_manager.dart';
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
  late RewardedAdManager _appAdManager;

  @override
  void initState() {
    super.initState();
    _appAdManager = RewardedAdManager();
    _loadAd();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMovies();  // Fetch movies
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
    _appAdManager.loadAd(
      onAdLoaded: () {},
      onAdFailed: () {}
    );
  }

  void _showAd(Function onAdDismiss) {
    print('showAd');
    _appAdManager.showAdIfAvailable(() {
      onAdDismiss();
    });
  }

  // List<Movie> _getFilteredMovies(String filter) {
  //   print(allMovies.first.releaseDate);
  //   if (filter == listFilterAll) {
  //     return List.from(allMovies);
  //   } else if (filter == listFilterRunning) {
  //     return allMovies.where((movie) => movie.status == listFilterRunning).toList();
  //   } else if (filter == listFilterUpcoming) {
  //     return allMovies.where((movie) => movie.status == listFilterUpcoming).toList();
  //   } else {
  //     return [];
  //   }
  // }

List<Movie> _getFilteredMovies(String filter) {
  List<Movie> filteredList;

  if (filter == listFilterAll) {
    filteredList = List.from(allMovies);
  } else if (filter == listFilterRunning) {
    filteredList = allMovies.where((movie) => movie.status == listFilterRunning).toList();
    // Sort by releaseDate (newest first), if releaseDate is null or empty, push to the end
    filteredList.sort((a, b) {
      DateTime dateA = (a.releaseDate != null && a.releaseDate.isNotEmpty)
          ? DateTime.parse(a.releaseDate)
          : DateTime(9999); // If releaseDate is null or empty, use a far future date
      DateTime dateB = (b.releaseDate != null && b.releaseDate.isNotEmpty)
          ? DateTime.parse(b.releaseDate)
          : DateTime(9999); // If releaseDate is null or empty, use a far future date

      return dateB.compareTo(dateA); // Sort in descending order (newest first)
    });
  } else if (filter == listFilterUpcoming) {
    filteredList = allMovies.where((movie) => movie.status == listFilterUpcoming).toList();
  } else {
    return []; // Return empty if no filter matches
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
            const BackgroundWidget(isPausePage: false),
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
                      const IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.transparent,
                        ),
                        onPressed: null,
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
                    },
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                fetchComplete
                    ? Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildMovieGrid(_getFilteredMovies(listFilterAll)),
                            _buildMovieGrid(_getFilteredMovies(listFilterRunning)),
                            _buildMovieGrid(_getFilteredMovies(listFilterUpcoming)),
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

  Widget _buildMovieGrid(List<Movie> movies) {
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
              if (settingsProvider.openCount > 8) {
                if(_appAdManager.rewardedAd != null){
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
                          ? Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
                            '$releaseDate ${getReleaseLabel(settingsProvider.language)}',
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
