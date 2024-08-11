import 'package:flutter/material.dart';
import 'package:world_movie_trailer/layout/movie_list_page.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'dart:async';

class VideoAdPage extends StatefulWidget {
  final String country;

  const VideoAdPage({super.key, required this.country});

  @override
  _VideoAdPageState createState() => _VideoAdPageState();
}

class _VideoAdPageState extends State<VideoAdPage> {
  List<Movie> allMovies = [];
  bool hasError = false;
  bool fetchComplete = false; 
  bool delayComplete = false;

  @override
  void initState() {
    super.initState();
    _fetchMovies(); 
    _startDelayTimer();
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await MovieService.fetchMovie(widget.country);
      setState(() {
        allMovies = movies;
        fetchComplete = true; 
        _checkTransitionReady();
      });
    } catch (e) {
      setState(() {
        hasError = true;
        fetchComplete = true;
        _checkTransitionReady();
      });
    }
  }

  void _startDelayTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        delayComplete = true;
        _checkTransitionReady();
      });
    });
  }

  void _checkTransitionReady() {
    if (fetchComplete && delayComplete) {
      _navigateToMovieList();
    }
  }

  void _navigateToMovieList() {
    if (!hasError) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MovieListPage(
            country: widget.country,
            movies: allMovies,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading movies'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Page'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
