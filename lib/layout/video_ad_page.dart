import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/quote_service.dart';
import 'package:world_movie_trailer/layout/movie_list_page.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/layout/quote_list_page.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/model/quote.dart'; // Assuming this is the background widget

class VideoAdPage extends StatefulWidget {
  final String country;
  final RewardedAd? preloadedAd; // Pass preloaded ad

  const VideoAdPage({super.key, required this.country, required this.preloadedAd});

  @override
  _VideoAdPageState createState() => _VideoAdPageState();
}

class _VideoAdPageState extends State<VideoAdPage> {
  List<Movie> allMovies = [];
  List<Quote> allQuotes = [];
  bool hasError = false;
  bool fetchComplete = false;

  @override
  void initState() {
    super.initState();
    _fetchMovies();

    if (widget.preloadedAd != null) {
      _showPreloadedAd(widget.preloadedAd!);
    } else {
      _navigateToMovieList();
    }
  }

  Future<void> _fetchMovies() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final language = settingsProvider.language;
    try {
      if(settingsProvider.isQuotes){
        final quotes = await QuoteService.fetchQuote();
        setState(() {
          allQuotes = quotes;
          fetchComplete = true;
        });
      } else {
        final movies = await MovieService.fetchMovie(widget.country, language);
        setState(() {
          allMovies = movies;
          fetchComplete = true;
        });
      }

    } catch (e) {
      setState(() {
        hasError = true;
        fetchComplete = true;
      });
    }
  }

  void _navigateToMovieList() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (!hasError) {
      if (settingsProvider.isQuotes) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuoteListPage(quotes: allQuotes),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MovieListPage(country: widget.country, movies: allMovies),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading movies'),
        ),
      );
    }
  }

  void _showPreloadedAd(RewardedAd? ad) {
    if (ad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad is not loaded. Please try again later.')),
      );
      _navigateToMovieList();
      return;
    }

    DateTime adStartTime = DateTime.now();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        print('Ad shown');
        LogHelper().logEvent('ad_start', parameters: {'startTime': adStartTime.toIso8601String()});
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        DateTime adEndTime = DateTime.now();
        Duration adWatchDuration = adEndTime.difference(adStartTime);

        LogHelper().logEvent('ad_duration', parameters: {'duration': adWatchDuration.inSeconds},);
        ad.dispose(); // Dispose of the ad after it's dismissed
        _navigateToMovieList(); // Navigate to the next screen
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        print('Ad failed to show: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to show ad: $error')),
        );
        _navigateToMovieList(); // Navigate if ad fails to show
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('User earned reward: ${reward.amount} ${reward.type}');
      // Handle the reward here, if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundWidget(isPausePage: false), // Your background widget
            if (!fetchComplete)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/deco_film_reel_02_DT_xxhdpi.png', // Your film reel image asset
                      width: 100, // Adjust size as needed
                      height: 100,
                    ),
                    const SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        strokeWidth: 5.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
