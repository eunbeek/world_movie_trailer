import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
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

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.movie.trailerUrl,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    _youtubePlayerController.addListener(() {
      if (_youtubePlayerController.value.isFullScreen && !_isFullScreen) {
        setState(() {
          _isFullScreen = true;
        });
      } else if (!_youtubePlayerController.value.isFullScreen && _isFullScreen) {
        setState(() {
          _isFullScreen = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          if (!_isFullScreen)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(settingsProvider.background), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Custom AppBar
          Column(
            children: [
              if (!_isFullScreen)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(top:10.0),
                          child: Text(
                          widget.movie.localTitle.length > 25
                              ? '${widget.movie.localTitle.substring(0, 25)}...'
                              : widget.movie.localTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded( // This will allow the player and content to scroll within the available space
                child: YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _youtubePlayerController,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
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
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${getTranslatedDetail('Year', settingsProvider.language)}: ${widget.movie.year}',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color set to white
                                  ),
                                ),
                              ),
                            if (widget.movie.credits?["crew"] != null &&
                                widget.movie.credits?["crew"].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${getTranslatedDetail('Director', settingsProvider.language)}: ${widget.movie.credits?["crew"][0]["name"]}',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
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
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
                            if(widget.movie.country != "")
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${getTranslatedDetail('Country', settingsProvider.language)}: ${widget.movie.country}',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
                            if (widget.movie.runtime != "")
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${getTranslatedDetail('Running Time', settingsProvider.language)}: ${widget.movie.runtime} minutes',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            if (widget.movie.spec != "ERR404")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.movie.spec,
                                  style: const TextStyle(
                                    color: Colors.white,
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
