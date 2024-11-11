import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';

class MovieDetailPageChewie extends StatefulWidget {
  final Movie movie;
  final bool captionFlag;
  final String captionLan;
  final bool isCustomized;
  final int? flag;
  final int? cIdx;

  const MovieDetailPageChewie({super.key, required this.movie, required this.captionFlag, required this.captionLan, required this.isCustomized, this.flag, this.cIdx});

  @override
  _MovieDetailPageChewieState createState() => _MovieDetailPageChewieState();
}

class _MovieDetailPageChewieState extends State<MovieDetailPageChewie> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String _errorMessage = '';
  bool _isFullScreen = false;
  late SettingsProvider _settingsProvider;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    LogHelper().logEvent(widget.movie.special!.isNotEmpty? "special_trailer_watched": "trailer_watched", parameters: {
      'movie': widget.movie.localTitle,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Check if movie is bookmarked asynchronously
    Future.microtask(() => _checkIfBookmarked());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = Provider.of<SettingsProvider>(context); 
  }

  // Async method to check if the movie is bookmarked
  Future<void> _checkIfBookmarked() async {
    bool isUnique = await MovieByUserService.getIsUnique(3, widget.movie.localTitle);
    setState(() {
      _isBookmarked = !isUnique; // If it's unique, it's not bookmarked
    });
  }

  void _initializeVideoPlayer() {
    if (widget.movie.trailerUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Trailer not available';
      });
      return;
    }

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.movie.trailerUrl))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            autoInitialize: true,
            looping: false,
            allowFullScreen: true,
            placeholder: Container(
              color: Colors.black,
            ),
          );

          _chewieController!.addListener(() {
            if (_chewieController!.isFullScreen && !_isFullScreen) {
              _enterFullScreen();
            } else if (!_chewieController!.isFullScreen && _isFullScreen) {
              _exitFullScreen();
            }
          });
        });
      });
  }

  // Force fullscreen mode
  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  // Force exit fullscreen mode and ensure portrait orientation
  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    });
  }

  @override
  void dispose() {
    // Ensure portrait mode is enforced upon exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  double _calculateAspectRatio(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return screenSize.height / screenSize.width;
  }

  Future<void> showMovieSnackbar(BuildContext context, messageType) async {
    // Show the Snackbar after the delay
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getMessage(_settingsProvider.language, messageType)),
        duration: const Duration(milliseconds: 500), // Adjusted duration for readability
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            if (!_isFullScreen) const BackgroundWidget(isPausePage: true),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _videoPlayerController != null &&
                                _videoPlayerController!.value.isInitialized
                            ? Container(
                                child: AspectRatio(
                                  aspectRatio: _isFullScreen
                                      ? 16 / 9
                                      : _calculateAspectRatio(context),
                                  child: Chewie(controller: _chewieController!),
                                ),
                              )
                            : widget.movie.trailerUrl.isEmpty
                                ? _buildErrorWidget()
                                : Center(child: CircularProgressIndicator()),
                        if (!_isFullScreen) _buildMovieDetails(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildMovieDetails() {
    double iconSize = MediaQuery.of(context).size.height * 0.035;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:10),
        if(!widget.isCustomized)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  if (_isBookmarked) {
                    // If the movie is already bookmarked, remove it
                    final existingMovies = await MovieByUserService.getMoviesByFlag(3);
                    final index = existingMovies.indexWhere((movie) => movie.movie.localTitle == widget.movie.localTitle);

                    if (index != -1) {
                      await MovieByUserService.deleteMovie(3, index);
                      showMovieSnackbar(context, 'movieDeleted');
                    }
                  }
                  bool isCount = await MovieByUserService.getIsAvailable(3);
                  if (!isCount) {
                    showMovieSnackbar(context, 'maxMoviesReached');
                    return;
                  }

                  if (isCount && !_isBookmarked) {
                    // Create MovieByUser object
                    MovieByUser addMovie = MovieByUser(
                      flag: 3, // Bookmark flag
                      movie: widget.movie, // Current movie object
                    );

                    // Add movie to MovieByUserService
                    await MovieByUserService.addMovie(3, addMovie).then((_) {
                      showMovieSnackbar(context, 'addToBookmark');
                    });
                  }
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                },
                icon: Image.asset(
                  _settingsProvider.isDarkTheme
                      ? (_isBookmarked
                          ? 'assets/images/dark/icon_bookmark_fill_DT_xxhdpi.png'
                          : 'assets/images/dark/icon_bookmark_DT_xxhdpi.png')
                      : (_isBookmarked
                          ? 'assets/images/light/icon_bookmark_fill_LT_xxhdpi.png'
                          : 'assets/images/light/icon_bookmark_LT_xxhdpi.png'),
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
                              getMessage(_settingsProvider.language, 'addMemo'),
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
                                  child: Text(getMessage(_settingsProvider.language, 'closeMemo')),
                                ),
                                ElevatedButton(
                                  onPressed: memoController.text.isEmpty || memoController.text.length >= 300
                                      ? null
                                      : () async {
                                          String memo = memoController.text;

                                          if (memo.length >= 300) {
                                            showMovieSnackbar(context,'maxMemosReached');
                                          } else {
                                            if (existingMovie != null) {
                                              existingMovie.memo = memo;
                                              existingMovie.savedDate = DateTime.now();
                                              await MovieByUserService.updateMovieMemo(existingMovie).then((_){
                                                showMovieSnackbar(context,'addToMemo');
                                              });
                                            } else {
                                              if (memo.isNotEmpty && await MovieByUserService.getIsAvailable(4)) {
                                                MovieByUser addMovie = MovieByUser(
                                                  flag: 4,
                                                  movie: widget.movie,
                                                  savedDate: DateTime.now(),
                                                  memo: memo,
                                                );
                                                await MovieByUserService.addMovie(4, addMovie).then((_){
                                                  showMovieSnackbar(context,'addToMemo');
                                                });
                                              } else {
                                                showMovieSnackbar(context,'maxMoviesReached');
                                              }
                                            }
                                            Navigator.pop(context);
                                          }
                                        },
                                  child: Text(getMessage(_settingsProvider.language, 'saveMemo')),
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
                  _settingsProvider.isDarkTheme
                      ? 'assets/images/dark/icon_memo_DT_xxhdpi.png'
                      : 'assets/images/light/icon_memo_LT_xxhdpi.png',
                  height: iconSize,
                  width: iconSize,
                ),
              ),
            ],
          ),
        if (widget.movie.special!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Year', _settingsProvider.language)}: ${widget.movie.year}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
            ),
          ),
        if (widget.movie.credits?["crew"] != null && widget.movie.credits?["crew"].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Director', _settingsProvider.language)}: ${widget.movie.credits?["crew"][0]["name"]}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
            ),
          ),
        if (widget.movie.credits?["cast"] != null && widget.movie.credits?["cast"].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Stars', _settingsProvider.language)}: ${widget.movie.credits?["cast"]
                  .take(4)
                  .map((castMember) => castMember["name"])
                  .join(", ")}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
            ),
          ),
        if (widget.movie.country != "")
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Country', _settingsProvider.language)}: ${convertCountryCodeToName(widget.movie.country)}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
            ),
          ),
        if (widget.movie.runtime != "")
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Running Time', _settingsProvider.language)}: ${widget.movie.runtime} minutes',
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
    );
  }
}
