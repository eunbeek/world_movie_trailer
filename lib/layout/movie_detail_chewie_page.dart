import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:world_movie_trailer/common/background.dart';

class MovieDetailPageChewie extends StatefulWidget {
  final Movie movie;
  final bool captionFlag;
  final String captionLan;

  MovieDetailPageChewie({required this.movie, required this.captionFlag, required this.captionLan});

  @override
  _MovieDetailPageChewieState createState() => _MovieDetailPageChewieState();
}

class _MovieDetailPageChewieState extends State<MovieDetailPageChewie> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String _errorMessage = '';
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.movie.trailerUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Trailer not available';
      });
    return;
    }

    // Example of using a video URL, you can replace with your real movie trailer URL
    // _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.movie.trailerUrl))
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.movie.trailerUrl))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            autoInitialize: true, // 자동 초기화 설정
            looping: false,
            allowFullScreen: true,
            allowPlaybackSpeedChanging: true,
          );

          _chewieController!.addListener(() {
            if (_chewieController!.isFullScreen && !_isFullScreen) {
              setState(() {
                _isFullScreen = true;
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              });
            } else if (!_chewieController!.isFullScreen && _isFullScreen) {
              setState(() {
                _isFullScreen = false;
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              });
            }
          });

        });
      });
  }

  double _calculateAspectRatio(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return screenSize.height / screenSize.width;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // 기본 UI로 복구
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            if (!_isFullScreen) 
              const BackgroundWidget(isPausePage: true,),
            Column(
              children: [
                if (!_isFullScreen)
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            widget.movie.localTitle.length > 25 ? '${widget.movie.localTitle.substring(0, 25)}...' : widget.movie.localTitle,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.03,
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
                Expanded(
                  child: SingleChildScrollView( // 스크롤 가능하게 수정
                    child: Column(
                      children: [
                        _videoPlayerController != null &&
                                _videoPlayerController!.value.isInitialized
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: _isFullScreen ? 16 / 9 : _calculateAspectRatio(context), // 비디오 플레이어 비율 맞추기
                                  child: Chewie(controller: _chewieController!),
                                ),
                              )
                            : _buildErrorWidget(),
                        if (!_isFullScreen) _buildMovieDetails(settingsProvider),
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

  Widget _buildMovieDetails(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        if (widget.movie.special!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Year', settingsProvider.language)}: ${widget.movie.year}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
        if (widget.movie.credits?["crew"] != null && widget.movie.credits?["crew"].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Director', settingsProvider.language)}: ${widget.movie.credits?["crew"][0]["name"]}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
        if (widget.movie.credits?["cast"] != null && widget.movie.credits?["cast"].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Stars', settingsProvider.language)}: ${widget.movie.credits?["cast"]
                  .map((castMember) => castMember["name"])
                  .join(", ")}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
        if(widget.movie.country != "")
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Country', settingsProvider.language)}: ${convertCountryCodeToName(widget.movie.country)}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
        if (widget.movie.runtime != "")
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${getTranslatedDetail('Running Time', settingsProvider.language)}: ${widget.movie.runtime} minutes',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
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
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
      ],
    );
  }
}
