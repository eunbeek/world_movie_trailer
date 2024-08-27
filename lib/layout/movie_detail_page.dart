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
      initialVideoId: YoutubePlayer.convertUrlToId(widget.movie.trailerUrl)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.localTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : YoutubePlayer(
                    controller: _youtubePlayerController,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                  ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Movie Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            widget.movie.spec != "ERR404"
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            widget.movie.spec,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            widget.movie.runtime != 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Runtime: ${widget.movie.runtime} minutes',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            widget.movie.credits?["crew"] != null && widget.movie.credits?["crew"].isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Crew: ${widget.movie.credits?["crew"].map((crewMember) => crewMember["name"]).join(", ")}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            widget.movie.credits?["cast"] != null && widget.movie.credits?["cast"].isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Cast: ${widget.movie.credits?["cast"].map((castMember) => castMember["name"]).join(", ")}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
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
              'Trailer is not released yet',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
