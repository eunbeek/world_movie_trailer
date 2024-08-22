import 'package:flutter/material.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieListPage extends StatefulWidget {
  final String country;
  final List<Movie> movies;

  const MovieListPage({super.key, required this.country, required this.movies});

  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  String selectedFilter = listFilterAll;
  List<Movie> allMovies = [];
  List<Movie> filteredMovies = [];

  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    allMovies = widget.movies;
    _applyFilter(false);
  }

  void _applyFilter(bool isMore) {
    setState(() {
      if (selectedFilter == listFilterAll) {
        filteredMovies = List.from(allMovies);
      } else if (selectedFilter == listFilterRunning) {
        filteredMovies = allMovies.where((movie) => movie.status == listFilterRunning).toList();
      } else if (selectedFilter == listFilterUpcoming) {
        filteredMovies = allMovies.where((movie) => movie.status == listFilterUpcoming).toList();
      }
    });

    if (!isMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listAppBar + widget.country),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text(listFilterAll),
                  selected: selectedFilter == listFilterAll,
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = listFilterAll;
                      _applyFilter(false);
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text(listFilterRunning),
                  selected: selectedFilter == listFilterRunning,
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = listFilterRunning;
                      _applyFilter(false);
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text(listFilterUpcoming),
                  selected: selectedFilter == listFilterUpcoming,
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = listFilterUpcoming;
                      _applyFilter(false);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(country: widget.country, movie: movie),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                          child: Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity, // Make sure the image takes up full width
                            height: double.infinity, // Make sure the image takes up full height
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          movie.localTitle,
                          overflow: TextOverflow.ellipsis, // Handle text overflow
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
