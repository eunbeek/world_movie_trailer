import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:flutter/services.dart';
import 'package:world_movie_trailer/common/background.dart';

class MovieDetailPageYouTube extends StatefulWidget {
  final Movie movie;
  final bool captionFlag;
  final String captionLan;
  final bool isCustomized;
  final int? flag;
  final int? cIdx;

  const MovieDetailPageYouTube({super.key, required this.movie, required this.captionFlag, required this.captionLan, required this.isCustomized, this.flag, this.cIdx});

  @override
  _MovieDetailPageYouTubeState createState() => _MovieDetailPageYouTubeState();
}

class _MovieDetailPageYouTubeState extends State<MovieDetailPageYouTube> {
  late YoutubePlayerController _youtubePlayerController;
  String _errorMessage = '';
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();

    // Enable both landscape and portrait mode when the page is opened
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _initializeYoutubePlayer() {
    if (widget.movie.trailerUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Trailer not available';
      });
      return;
    }

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.movie.trailerUrl,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: widget.captionFlag,
        captionLanguage: widget.captionLan,
        useHybridComposition: false,
      ),
    );

    _youtubePlayerController.addListener(() {
      if (_youtubePlayerController.value.isFullScreen && !_isFullScreen) {
        _enterFullScreen();
      } else if (!_youtubePlayerController.value.isFullScreen && _isFullScreen) {
        _exitFullScreen();
      }
    });

  }

  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    // Ensure the portrait mode is enforced when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  double _calculateAspectRatio(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return screenSize.height / screenSize.width;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    double iconSize = MediaQuery.of(context).size.height * 0.035;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            if (!_isFullScreen)
              const BackgroundWidget(isPausePage: true,),
            // Custom AppBar
            Column(
              children: [
                if (!_isFullScreen)
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: MediaQuery.of(context).size.height * 0.03,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            widget.movie.localTitle.length > 25
                                ? '${widget.movie.localTitle.substring(0, 25)}...'
                                : widget.movie.localTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                Expanded(
                  child: YoutubePlayerBuilder(
                    player: YoutubePlayer(
                      controller: _youtubePlayerController,
                      aspectRatio: _isFullScreen ? 16 / 9 : _calculateAspectRatio(context),
                    ),
                    builder: (context, player)  {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage.isNotEmpty)
                              _buildErrorWidget()
                            else
                              player,
                            if (!_isFullScreen) ...[
                              if(!widget.isCustomized)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        bool isUnique = await MovieByUserService.getIsUnique(1, widget.movie.localTitle);

                                        if (!isUnique) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'duplicateMovie')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                          return;  // Exit early if movie is duplicated
                                        }

                                        if (await MovieByUserService.getIsAvailable(1)) {
                                          // Create MovieByUser object
                                          MovieByUser addMovie = MovieByUser(
                                            flag: 1, // Like flag
                                            movie: widget.movie, // Current movie object
                                          );

                                          await MovieByUserService.addMovie(1, addMovie);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'addToLike')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'maxMoviesReached')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                        }
                                      },
                                      icon: Image.asset(
                                        settingsProvider.isDarkTheme ? 'assets/images/dark/icon_like_DT_xxhdpi.png' : 'assets/images/light/icon_like_LT_xxhdpi.png',
                                        height: iconSize,
                                        width: iconSize,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        bool isUnique = await MovieByUserService.getIsUnique(2, widget.movie.localTitle);

                                        if (!isUnique) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'duplicateMovie')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                          return;  // Exit early if movie is duplicated
                                        }

                                        if (await MovieByUserService.getIsAvailable(2)) {
                                          // Create MovieByUser object
                                          MovieByUser addMovie = MovieByUser(
                                            flag: 2, // Dislike flag
                                            movie: widget.movie, // Current movie object
                                          );

                                          await MovieByUserService.addMovie(2, addMovie);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'addToDislike')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'maxMoviesReached')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                        }
                                      },
                                      icon: Image.asset(
                                        settingsProvider.isDarkTheme ? 'assets/images/dark/icon_dislike_DT_xxhdpi.png' : 'assets/images/light/icon_dislike_LT_xxhdpi.png',
                                        height: iconSize,
                                        width: iconSize,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        bool isCount = await MovieByUserService.getIsAvailable(3);
                                        bool isUnique = await MovieByUserService.getIsUnique(3, widget.movie.localTitle);

                                        if (!isUnique) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'duplicateMovie')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                          return;  // Exit early if movie is duplicated
                                        }

                                        if (!isCount) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'maxMoviesReached')),
                                              duration: Duration(milliseconds: 500), // Adjusted duration for readability
                                            ),
                                          );
                                          return;  // Exit early if count exceeded
                                        }

                                        if (isCount && isUnique) {
                                          // Create MovieByUser object
                                          MovieByUser addMovie = MovieByUser(
                                            flag: 3, // Bookmark flag
                                            movie: widget.movie, // Current movie object
                                          );

                                          // Add movie to MovieByUserService
                                          await MovieByUserService.addMovie(3, addMovie);

                                          // Show success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(getMessage(settingsProvider.language, 'addToBookmark')),
                                              duration: Duration(milliseconds: 500),  // Adjusted duration for readability
                                            ),
                                          );
                                        }
                                      },
                                      icon: Image.asset(
                                        settingsProvider.isDarkTheme ? 'assets/images/dark/icon_bookmark_fill_DT_xxhdpi.png' : 'assets/images/light/icon_bookmark_fill_LT_xxhdpi.png',
                                        height: iconSize,
                                        width: iconSize,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        MovieByUser? existingMovie = await MovieByUserService.getMovieMemoByTitle(widget.movie.localTitle);
                                        FocusNode memoFocusNode = FocusNode();
                                        // Show memo input modal bottom sheet
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (BuildContext context) {
                                            String initialMemo = existingMovie != null
                                                ? '${existingMovie.memo}\r\n'
                                                : '${DateFormat('yyyy/MM/dd').format(DateTime.now())}\r\n';

                                            TextEditingController memoController = TextEditingController(text: initialMemo);

                                            memoController.selection = TextSelection.fromPosition(
                                              TextPosition(offset: memoController.text.length),
                                            );

                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context).viewInsets.bottom,
                                                left: 16,
                                                right: 16,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    getMessage(settingsProvider.language, 'addMemo'),
                                                    style: TextStyle(
                                                      fontSize: MediaQuery.of(context).size.height * 0.019,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Scrollbar(
                                                    thumbVisibility: true,
                                                    child: TextField(
                                                      controller: memoController,
                                                      focusNode: memoFocusNode,
                                                      maxLines: 6,
                                                      decoration: InputDecoration(
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(getMessage(settingsProvider.language, 'closeMemo')),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: memoController.text.isEmpty || memoController.text.length >= 300
                                                            ? null
                                                            : () async {
                                                                String memo = memoController.text;

                                                                if (memo.length >= 300) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(getMessage(settingsProvider.language, 'maxMemosReached')),
                                                                      duration: Duration(milliseconds: 500),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  if (existingMovie != null) {
                                                                    existingMovie.memo = memo;
                                                                    existingMovie.savedDate = DateTime.now();
                                                                    await MovieByUserService.updateMovieMemo(existingMovie);

                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      SnackBar(
                                                                        content: Text(getMessage(settingsProvider.language, 'addToMemo')),
                                                                        duration: Duration(milliseconds: 500),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    if (memo.isNotEmpty && await MovieByUserService.getIsAvailable(4)) {
                                                                      MovieByUser addMovie = MovieByUser(
                                                                        flag: 4,
                                                                        movie: widget.movie,
                                                                        savedDate: DateTime.now(),
                                                                        memo: memo,
                                                                      );
                                                                      await MovieByUserService.addMovie(4, addMovie);

                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(getMessage(settingsProvider.language, 'addToMemo')),
                                                                          duration: Duration(milliseconds: 500),
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(getMessage(settingsProvider.language, 'maxMoviesReached')),
                                                                          duration: Duration(milliseconds: 500),
                                                                        ),
                                                                      );
                                                                    }
                                                                  }
                                                                  Navigator.pop(context);
                                                                }
                                                              },
                                                        child: Text(getMessage(settingsProvider.language, 'saveMemo')),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            );
                                          },
                                        ).whenComplete(() {
                                          memoFocusNode.requestFocus();
                                        });
                                      },
                                      icon: Image.asset(
                                        settingsProvider.isDarkTheme
                                            ? 'assets/images/dark/icon_memo_DT_xxhdpi.png'
                                            : 'assets/images/light/icon_memo_LT_xxhdpi.png',
                                        height: iconSize,
                                        width: iconSize,
                                      ),
                                    ),
                                    // Add an invisible icon button for spacing
                                    IconButton(
                                      icon: Icon(
                                        Platform.isIOS 
                                          ? Icons.ios_share_outlined  // iOS에서 사용할 아이콘
                                          : Icons.share_outlined,     // Android에서 사용할 아이콘
                                      ),
                                      iconSize: iconSize,
                                      onPressed: () => {
                                        Share.share(
                                          'https://www.youtube.com/watch?v=${widget.movie.trailerUrl}',
                                          subject: 'Share ${widget.movie.localTitle} Movie Trailer',
                                          sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
                                        )
                                      }, // No action
                                    ),
                                  ],
                                ),
                              
                              if (widget.movie.special!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Year', settingsProvider.language)}: ${widget.movie.year}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.018,
                                    ),
                                  ),
                                ),
                              if (widget.movie.credits?["crew"] != null &&
                                  widget.movie.credits?["crew"].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Director', settingsProvider.language)}: ${widget.movie.credits?["crew"].firstWhere((crewMember) => crewMember["job"] == "Director",  orElse: () => widget.movie.credits?["crew"][0])["name"]}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.018,
                                    ),
                                  ),
                                ),
                              if (widget.movie.credits?["cast"] != null &&
                                  widget.movie.credits?["cast"].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Stars', settingsProvider.language)}: ${widget.movie.credits?["cast"]
                                        .map((castMember) => castMember["name"])
                                        .join(", ")}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.018,
                                    ),
                                  ),
                                ),
                              if(widget.movie.country != "")
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Country', settingsProvider.language)}: ${convertCountryCodeToName(widget.movie.country)}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.018,
                                    ),
                                  ),
                                ),
                              if (widget.movie.runtime != "")
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Running Time', settingsProvider.language)}: ${widget.movie.runtime} ${getTranslatedDetail('Minute', settingsProvider.language)}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.018,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              if (widget.movie.spec != "ERR404")
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.movie.spec,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.018,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ); 
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'Trailer is not available',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
