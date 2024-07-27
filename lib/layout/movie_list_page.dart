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
  String selectedFilter = 'All';

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
                  label: Text('All'),
                  selected: selectedFilter == 'All',
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = 'All';
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text('Running'),
                  selected: selectedFilter == 'Running',
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = 'Running';
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text('Upcoming'),
                  selected: selectedFilter == 'Upcoming',
                  showCheckmark: false,
                  selectedColor: Colors.blue.withOpacity(0.5),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = 'Upcoming';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: MovieService.fetchCgvThumbnails(selectedFilter),
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
