import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_ad_manager.dart';
import 'package:world_movie_trailer/common/error_page_by_user.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/layout/movie_detail_youtube_page.dart';
import 'package:world_movie_trailer/layout/movie_detail_chewie_page.dart';
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';

class MovieByUserListPage extends StatefulWidget {
  final String flag;

  const MovieByUserListPage({super.key, required this.flag});

  @override
  _MovieByUserListPageState createState() => _MovieByUserListPageState();
}

class _MovieByUserListPageState extends State<MovieByUserListPage> {
  List<MovieByUser> allMovies = [];
  bool fetchComplete = false;
  late RewardedAdManager _appAdManager;
  int customizedFlag = 0;

  @override
  void initState() {
    super.initState();
    _appAdManager = RewardedAdManager();
    _loadAd();
    _fetchMovies();  // Fetch movies
  }

  Future<void> _fetchMovies() async {
    try {
      // Fetch the movies from the service
      List<MovieByUser> movies = [];

      switch (widget.flag) {
        case 'Like':
          movies = await MovieByUserService.getMoviesByFlag(1);
          customizedFlag = 1;
          break;
        case 'Dislike':
          movies = await MovieByUserService.getMoviesByFlag(2);
          customizedFlag = 2;
          break;
        case 'Bookmark':
          movies = await MovieByUserService.getMoviesByFlag(3);
          customizedFlag = 3;
          break;
        default:
          print('Unknown flag');
          break; 
      }

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
    _appAdManager.loadAd(onAdLoaded: () {});
  }

  void _showAd(Function onAdDismiss) {
    print('showAd');
    _appAdManager.showAdIfAvailable(() {
      onAdDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            const BackgroundWidget(isPausePage: false),

            // Main Content
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
                          getMenuItemTitle(settingsProvider.language, widget.flag),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                fetchComplete
                    ? Expanded(child: _buildMovieGrid(allMovies))
                    : const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieGrid(List<MovieByUser> movies) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (movies.isEmpty) {
      return ErrorByUserPage();
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
          if (movie.movie.releaseDate != '') {
            releaseDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(movie.movie.releaseDate));
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (settingsProvider.openCount == 8) {
                if (_appAdManager.rewardedAd != null) {
                  _showAd(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => movie.movie.isYoutube != false
                            ? MovieDetailPageYouTube(movie: movie.movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: true, flag: customizedFlag, cIdx:index)
                            : MovieDetailPageChewie(movie: movie.movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: true, flag: customizedFlag, cIdx:index),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _fetchMovies();
                      }
                    });
                  });
                }
                settingsProvider.resetOpenCount();
              } else {
                settingsProvider.updateOpenCount();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => movie.movie.isYoutube != false
                        ? MovieDetailPageYouTube(movie: movie.movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: true, flag: customizedFlag, cIdx:index)
                        : MovieDetailPageChewie(movie: movie.movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language, isCustomized: true, flag: customizedFlag, cIdx:index),
                  ),
                ).then((result) {
                  if (result == true) {
                    _fetchMovies();
                  }
                });
              }
            },
            child: Stack(
              children: [
                Container(
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
                          child: movie.movie.posterUrl != ""
                              ? Image.network(
                                  movie.movie.posterUrl,
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
                              movie.movie.localTitle,
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
                Positioned(
                  top: 8, // Padding from the top
                  right: 8, // Padding from the right
                  child: IconButton(
                    icon: Opacity(
                      opacity: 0.6, // Adjust the opacity between 0.0 (invisible) and 1.0 (fully visible)
                      child: Image.asset(
                        'assets/images/icon_list_delete_xxhdpi.png',
                        height: MediaQuery.of(context).size.height * 0.03,
                        width: MediaQuery.of(context).size.height * 0.03,
                      ),
                    ),
                    onPressed: () async {
                      // Delete movie logic
                      await MovieByUserService.deleteMovie(movie.flag, index);
                      setState(() {
                        movies.removeAt(index); // Remove the movie from the list
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(getMessage(settingsProvider.language, 'movieDeleted')),
                          duration: Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
