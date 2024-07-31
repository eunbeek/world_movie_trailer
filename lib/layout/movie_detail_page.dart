import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:world_movie_trailer/common/utils.dart';
import 'package:world_movie_trailer/model/movie.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.movie.trailerUrl));

    _videoPlayerController.initialize().then((_) {
      print('Video Initialized'); 
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
      );
      setState(() {});
    }).catchError((error) {
      print('Video Initialization Error: $error');
      setState(() {
        _errorMessage = 'Error loading video: $error';
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
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
                ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                : _chewieController != null && _videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Chewie(
                          controller: _chewieController!,
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Movie Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: parseHtml(widget.movie.spec),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
