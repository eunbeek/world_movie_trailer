import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  MovieDetailPageYouTube({required this.movie, required this.captionFlag, required this.captionLan});

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
  }

  void _initializeYoutubePlayer() {
    if (widget.movie.trailerUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Trailer not available';
      });
      return;
    }

    final youtubeFlags = YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
      captionLanguage: widget.captionLan,
      enableCaption: widget.captionFlag,
      controlsVisibleAtStart: true,
    );

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.movie.trailerUrl,
      flags: youtubeFlags,
    );

    _youtubePlayerController.addListener(() {
      if (_youtubePlayerController.value.isFullScreen && !_isFullScreen) {
        setState(() {
          _isFullScreen = true;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        });
      } else if (!_youtubePlayerController.value.isFullScreen && _isFullScreen) {
        setState(() {
          _isFullScreen = false;
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        });
      }
    });
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  double _calculateAspectRatio(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return screenSize.height / screenSize.width;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
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
                            widget.movie.localTitle.length > 25 ? '${widget.movie.localTitle.substring(0, 25)}...' :  widget.movie.localTitle,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ),
                        // Add an invisible icon button for spacing
                        const IconButton(
                          icon: Icon(
                            Icons.arrow_back, 
                            color: Colors.transparent,
                          ), // Invisible icon to balance the space
                          onPressed: null, // No action
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: YoutubePlayerBuilder(
                    player: YoutubePlayer(
                      controller: _youtubePlayerController,
                      aspectRatio: _isFullScreen ? 16 / 9 : _calculateAspectRatio(context),
                    ),
                    builder: (context, player) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage.isNotEmpty)
                              _buildErrorWidget()
                            else
                              player,
                            if (!_isFullScreen) ...[
                              const SizedBox(height: 20),
                              if (widget.movie.special!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Year', settingsProvider.language)}: ${widget.movie.year}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.02,
                                    ),
                                  ),
                                ),
                              if (widget.movie.credits?["crew"] != null &&
                                  widget.movie.credits?["crew"].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '${getTranslatedDetail('Director', settingsProvider.language)}: ${widget.movie.credits?["crew"][0]["name"]}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.02,
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
