import 'package:flutter/material.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieListPage extends StatefulWidget {
  final String country;

  const MovieListPage({super.key, required this.country});

  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  String selectedFilter = listFilterAll;

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
                  label: Text(listFilterAll),
                  selected: selectedFilter == listFilterAll,
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = listFilterAll;
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text(listFilterRunning),
                  selected: selectedFilter == listFilterRunning,
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = listFilterRunning;
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text(listFilterUpcoming),
                  selected: selectedFilter == listFilterUpcoming,
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = listFilterUpcoming;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: MovieService.fetchMovie(selectedFilter, widget.country),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final movies = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailPage(movie: movie),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                          child: Image.network(movie.posterUrl, fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
