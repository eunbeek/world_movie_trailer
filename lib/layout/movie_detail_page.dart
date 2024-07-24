import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    print(widget.movie.engTitle);
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.movie.trailerUrl))
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.engTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _videoPlayerController.value.isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 50.0,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              _videoPlayerController.pause();
                            } else {
                              _videoPlayerController.play();
                            }
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                    ],
                  )
                : Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
