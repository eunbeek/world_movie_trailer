import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/layout/movie_list_page.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'dart:async';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final language = settingsProvider.language; // Get the current language
    try {
      final movies = await MovieService.fetchMovie(widget.country, language);
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(settingsProvider.background), // Replace with your actual background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
