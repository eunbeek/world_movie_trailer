import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/common/movie_service_kr.dart';
import 'package:world_movie_trailer/common/utils.dart';
import 'package:world_movie_trailer/model/movie.dart';

class MovieDetailPage extends StatefulWidget {
  final String country;
  final Movie movie;

  MovieDetailPage({required this.country, required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  String _errorMessage = '';
  bool _isLoading = true;
  String? _trailerUrl;
  String? _engTitle;
  String? _tmdbOverview;
  String? _displayLink;

  @override
  void initState() {
    super.initState();
    _fetchDetailsAndInitializeVideo();
    _fetchMovieDetailsFromTMDB();
  }

  // Fetch details and initialize the video player
  void _fetchDetailsAndInitializeVideo() async {
    try {
      Map<String, String?> trailerData = await MovieService.fetchMovieDetails(widget.country, widget.movie);
    
      setState(() {
        _trailerUrl = trailerData['trailerUrl'];
        _engTitle = trailerData['engTitle'] ?? widget.movie.localTitle;
        _isLoading = false;
      });

      _initializeVideoPlayer();

    } catch (error) {
      print('Error fetching trailer details: $error');
      setState(() {
        _errorMessage = 'Error loading video: $error';
        _isLoading = false;
      });
    }
  }

  void _fetchMovieDetailsFromTMDB() async {
    try {
      final tmdbData = await MovieService.fetchMovieInfoFromTMDB(widget.country, widget.movie);
      setState(() {
        _tmdbOverview = tmdbData['overview'];
      });
    } catch (error) {
      print('Error fetching TMDB details: $error');
    }
  }

  void _initializeVideoPlayer() {
    if (_trailerUrl == null || _trailerUrl!.isEmpty) {
      setState(() {
        _errorMessage = 'Trailer not available';
        _isLoading = false;
      });
      return;
    }

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_trailerUrl!));

    _videoPlayerController.initialize().then((_) {
      print('Video Initialized'); 
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: true,
      );
      setState(() {});
    }).catchError((error) {
      print('Video Initialization Error: $error');
      setState(() {
        _errorMessage = 'Error initializing video: $error';
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
        title: Text(_engTitle ?? widget.movie.localTitle),
      ),
      body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _errorMessage.isNotEmpty
                      ? _buildErrorWidget()  // Build the error widget
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
                  _tmdbOverview != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // link 아래에 출력
                                  setState(() {
                                    _displayLink = _tmdbOverview;
                                  });
                                },
                                child: const Text('Details'),
                              ),
                              if (_displayLink != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'TMDB Link: $_displayLink',
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
                ],
              ),
            ),
    );
  }

  // Build the error widget with retry button
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
