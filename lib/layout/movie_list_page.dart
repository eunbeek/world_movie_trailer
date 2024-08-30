import 'package:flutter/material.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/common/TabBarGradientIndicator.dart';

class MovieListPage extends StatefulWidget {
  final String country;
  final List<Movie> movies;

  const MovieListPage({super.key, required this.country, required this.movies});

  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = listFilterAll;
  List<Movie> allMovies = [];
  List<Movie> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    allMovies = widget.movies;
    _applyFilter(false);
  }

  void _applyFilter(bool isMore) {
    setState(() {
      if (selectedFilter == listFilterAll) {
        filteredMovies = List.from(allMovies);
      } else if (selectedFilter == listFilterRunning) {
        filteredMovies = allMovies
            .where((movie) => movie.status == listFilterRunning)
            .toList();
      } else if (selectedFilter == listFilterUpcoming) {
        filteredMovies = allMovies
            .where((movie) => movie.status == listFilterUpcoming)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      listAppBar + widget.country,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Handle settings button press
                      },
                    ),
                  ],
                ),
              ),
              // Filter Tabs with gradient underline
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: const TabBarGradientIndicator(
                  gradientColor: [
                    Color(0xff2AAFDC),
                    Color(0xffF11ED6),
                  ],
                  insets: EdgeInsets.fromLTRB(0.0, 68.0, 0.0, 0.0),
                  indicatorWidth: 1.5
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(listFilterAll),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(listFilterRunning),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(listFilterUpcoming),
                    ),
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    if (index == 0) {
                      selectedFilter = listFilterAll;
                    } else if (index == 1) {
                      selectedFilter = listFilterRunning;
                    } else if (index == 2) {
                      selectedFilter = listFilterUpcoming;
                    }
                    _applyFilter(false);
                  });
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMovieGrid(filteredMovies),
                    _buildMovieGrid(filteredMovies),
                    _buildMovieGrid(filteredMovies),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55, 
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        String? releaseDate;
        // 날짜 형식 변경
        if(movie.releaseDate != '') releaseDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(movie.releaseDate));

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MovieDetailPage(country: widget.country, movie: movie),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(4.0), // 카드 간의 간격 설정
            decoration: BoxDecoration(
              color: Colors.grey[800], // 카드 배경색을 회색으로 설정
              borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게 설정
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ), // 상단 모서리만 둥글게 설정
                    child: Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.localTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold, // 텍스트를 조금 더 굵게 설정
                        ),
                      ),
                      const SizedBox(height: 4), // 텍스트 사이에 간격 추가
                      releaseDate != null?
                        Text(
                          '${releaseDate} 개봉', // 포맷된 개봉일을 사용
                          style: const TextStyle(
                            color: Colors.grey, // 개봉일 색상을 회색으로 설정
                            fontSize: 12,
                          ),
                        )
                      :const Text(''),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
