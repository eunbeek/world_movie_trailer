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

class MemoListPage extends StatefulWidget {

  const MemoListPage({super.key});

  @override
  _MemoListPageState createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  List<MovieByUser> allMovies = [];
  Map<int, TextEditingController> _memoControllers = {}; // Store controllers by index
  bool fetchComplete = false;
  late RewardedAdManager _appAdManager;

  @override
  void initState() {
    super.initState();
    _appAdManager = RewardedAdManager();
    _loadAd();
    _fetchMovies();
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is disposed
    _memoControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _fetchMovies() async {
    try {
      List<MovieByUser> movies = await MovieByUserService.getMoviesByFlag(4);
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
            const BackgroundWidget(isPausePage: false), // Background image
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
                          getMenuItemTitle(settingsProvider.language, 'Memo'),
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
                    ? Expanded(child: _buildMovieList(allMovies))
                    : const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieList(List<MovieByUser> movies) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (movies.isEmpty) {
      return ErrorByUserPage(); // Error page for empty movie list
    }

    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];

        // Initialize the TextEditingController for this movie if it doesn't exist
        if (!_memoControllers.containsKey(index)) {
          _memoControllers[index] = TextEditingController(text: '${movie.memo}\r\n');
        }

        String? releaseDate;
        if (movie.movie.releaseDate != '') {
          releaseDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(movie.movie.releaseDate));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: settingsProvider.isDarkTheme ? const Color(0xff444444) : const Color(0xfff0f0f0),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
              children: [
                // Movie card section
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (settingsProvider.openCount == 8) {
                        if (_appAdManager.rewardedAd != null) {
                          _showAd(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => movie.movie.isYoutube != false
                                    ? MovieDetailPageYouTube(
                                        movie: movie.movie,
                                        captionFlag: settingsProvider.isCaptionOn,
                                        captionLan: settingsProvider.language,
                                        isCustomized: true,
                                        flag: 4, 
                                        cIdx: index
                                      )
                                    : MovieDetailPageChewie(
                                        movie: movie.movie,
                                        captionFlag: settingsProvider.isCaptionOn,
                                        captionLan: settingsProvider.language,
                                        isCustomized: true,
                                        flag: 4, 
                                        cIdx: index
                                      ),
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
                                ? MovieDetailPageYouTube(
                                    movie: movie.movie,
                                    captionFlag: settingsProvider.isCaptionOn,
                                    captionLan: settingsProvider.language,
                                    isCustomized: true,
                                    flag: 4, 
                                    cIdx: index
                                  )
                                : MovieDetailPageChewie(
                                    movie: movie.movie,
                                    captionFlag: settingsProvider.isCaptionOn,
                                    captionLan: settingsProvider.language,
                                    isCustomized: true,
                                    flag: 4, 
                                    cIdx: index
                                  ),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _fetchMovies();
                          }
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: settingsProvider.isDarkTheme
                            ? const Color(0xff666666)
                            : const Color(0xff999999),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                            child: movie.movie.posterUrl != ""
                                ? Image.network(
                                    movie.movie.posterUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.2,
                                  )
                                : Image.asset(
                                    settingsProvider.isDarkTheme
                                        ? 'assets/images/dark/blank_DT_xxhdpi.png'
                                        : 'assets/images/light/blank_LT_xxhdpi.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.2,
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
                  ),
                ),

                const SizedBox(width: 16), // Space between movie card and memo section

                // Memo section
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getMenuItemTitle(settingsProvider.language, 'Memo'),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.018,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.save_outlined, size: MediaQuery.of(context).size.height * 0.030,),
                                onPressed: () async {
                                  // Update the memo in the movie object
                                  movie.memo = _memoControllers[index]!.text;
                                  await MovieByUserService.updateMovie(movie.flag, index, movie);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Memo updated successfully'), duration: Duration(milliseconds: 200),),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: MediaQuery.of(context).size.height * 0.030,),
                                onPressed: () async {
                                  // Delete the movie and refresh the list
                                  await MovieByUserService.deleteMovie(movie.flag, index);
                                  setState(() {
                                    movies.removeAt(index); // Remove the movie from the list
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Movie deleted successfully'), duration: Duration(milliseconds: 200),),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Scrollbar(
                        thumbVisibility: true,
                        child: TextField(
                          maxLines: 6, // Show up to 6 lines before enabling scrolling
                          controller: _memoControllers[index], // Use the stored controller
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.018,
                          ),
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
    );
  }
}
