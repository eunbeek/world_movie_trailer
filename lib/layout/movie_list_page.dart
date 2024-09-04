import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:intl/intl.dart';
import 'package:world_movie_trailer/common/TabBarGradientIndicator.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/common/background.dart';

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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            const BackgroundWidget(isPausePage: false,),
            // Main Content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          widget.country == special ? allMovies[0].source : widget.country,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                      ),
                      // Add an invisible icon button for spacing
                      const IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.transparent), // Invisible icon to balance the space
                        onPressed: null, // No action
                      ),
                    ],
                  ),
                ),
                if(widget.country != special)
                  // Filter Tabs with gradient underline
                  TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: TabBarGradientIndicator(
                      gradientColor: [
                        settingsProvider.isDarkTheme ? Color(0xff12d6df) : Color(0xff00ffed),
                        settingsProvider.isDarkTheme? Color(0xfff70fff) : Color(0xff9d00c6),
                      ],
                      insets: EdgeInsets.fromLTRB(0.0, 68.0, 0.0, 0.0),
                      indicatorWidth: 1.5
                    ),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: settingsProvider.isDarkTheme ? Color(0xffececec): Color(0xff1a1713)),
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(0,settingsProvider.language), 
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(1,settingsProvider.language), 
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            getFilterLabel(2,settingsProvider.language), 
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onTap: (index) {                                        
                      if(settingsProvider.isVibrate) HapticFeedback.vibrate();
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
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
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
                    MovieDetailPage(movie: movie, captionFlag: settingsProvider.isCaptionOn, captionLan: settingsProvider.language),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), 
                      releaseDate != null?
                        Text(
                          '${releaseDate} ' + getReleaseLabel(settingsProvider.language), 
                          style: const TextStyle(
                            color: Colors.grey, 
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
