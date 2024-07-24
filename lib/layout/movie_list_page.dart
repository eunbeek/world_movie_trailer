import 'package:flutter/material.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/common/constants.dart';

class MovieListPage extends StatelessWidget {
  final String country;

  const MovieListPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listAppBar + country),
      ),
      body: FutureBuilder<List<Movie>>(
        future: MovieService.fetchCgvThumbnails(),
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
    );
  }
}
