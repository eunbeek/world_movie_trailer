import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:world_movie_trailer/model/movie.dart';

class MovieDetailPage extends StatefulWidget {
  final String country;
  final Movie movie;

  MovieDetailPage({required this.country, required this.movie});

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
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          if (!_isFullScreen)
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'), // Replace with your actual background image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Custom AppBar
          Column(
            children: [
              if (!_isFullScreen)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
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
                        child: Text(
                          widget.movie.localTitle.length > 15
                              ? '${widget.movie.localTitle.substring(0, 15)}...'
                              : widget.movie.localTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Released Year: ${widget.movie.year}',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
                            if (widget.movie.credits?["crew"] != null &&
                                widget.movie.credits?["crew"].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Director: ${widget.movie.credits?["crew"][0]["name"]}',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
                            if (widget.movie.credits?["cast"] != null &&
                                widget.movie.credits?["cast"].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Stars: ${widget.movie.credits?["cast"]
                                      .map((castMember) => castMember["name"])
                                      .join(", ")}',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
                            if (widget.movie.runtime != "")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Running Time: ${widget.movie.runtime} minutes',
                                  style: const TextStyle(
                                    color: Colors.white, // Text color changed to white
                                  ),
                                ),
                              ),
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
