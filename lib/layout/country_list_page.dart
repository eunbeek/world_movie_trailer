import 'package:flutter/material.dart';
import 'package:world_movie_trailer/layout/video_ad_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<String> countries = [];
  Movie? specialSection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arrangeCountriesBasedOnLocale();
      _fetchSpecialMovies();
    });
  }

  void _arrangeCountriesBasedOnLocale() {
    String languageCode = Localizations.localeOf(context).languageCode;
    setState(() {
      countries = countryKeys
          .map((key) =>
              localizedCountries[languageCode]?[key] ?? localizedCountries['en']![key]!)
          .toList();
    });
  }

  Future<void> _fetchSpecialMovies() async {
    try {
      List<Movie> movies = await MovieService.fetchMovie('Special');
      setState(() {
        specialSection = movies[0];
      });
    } catch (e) {
      print('Error fetching special movies: $e');
    }
  }

  String _getAppBarTitle(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return countryAppBarKr;
      case 'ja':
        return countryAppBarJp;
      case 'zh':
        return countryAppBarTw;
      case 'fr':
        return countryAppBarFr;
      case 'de':
        return countryAppBarDe;
      case 'en':
        return countryAppBarEn;
      default:
        return countryAppBarEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 기존에 'between'으로 설정
                  crossAxisAlignment: CrossAxisAlignment.start, // 상단에 고정
                  children: [
                    Text(
                      _getAppBarTitle(languageCode),
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2, // 줄 간격 조정
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // 설정 버튼 클릭 시 처리할 로직
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: countries.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: ReorderableListView(
                          padding: const EdgeInsets.all(16.0),
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final String item = countries.removeAt(oldIndex);
                              countries.insert(newIndex, item);
                            });
                          },
                          children: [
                            for (int index = 0; index < countries.length; index++)
                              Padding(
                                key: ValueKey(countries[index]),
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoAdPage(country: countries[index]),
                                        ),
                                      );
                                    },
                                    highlightColor: Colors.blue.withOpacity(0.05),
                                    splashColor: Colors.blue.withOpacity(0.1),
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          painter: GradientBorderPainter(),
                                          child: Container(
                                            height: 60, // Adjust height as needed
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(28),
                                            color: Colors.transparent,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            countries[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              if (specialSection != null)
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VideoAdPage(country: special),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Special - ${specialSection!.special}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialSection!.originName != '' && specialSection!.source == specialSection!.originName
                                ? '${specialSection!.source} (${specialSection!.country})'
                                : '${specialSection!.source} | ${specialSection!.originName} (${specialSection!.country})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [Colors.cyanAccent, Colors.purpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = Radius.circular(30.0);
    final rrect = RRect.fromRectAndCorners(rect,
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
