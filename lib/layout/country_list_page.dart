import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/layout/video_ad_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/movie_service.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/settings_page.dart';
import 'package:world_movie_trailer/common/background.dart';

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  Movie? specialSection;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSpecialMovies();
    });
  }

  Future<void> _fetchSpecialMovies() async {
    try {
      // Use listen: false to avoid listening to changes outside the build method
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      List<Movie> movies = await MovieService.fetchMovie(special, settingsProvider.language);
      setState(() {
        specialSection = movies[0];
      });
    } catch (e) {
      print('Error fetching special movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageCode = settingsProvider.language;
    final countries = settingsProvider.countryOrder;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundWidget(isPausePage: false,),
            // Main Content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 기존에 'between'으로 설정
                    crossAxisAlignment: CrossAxisAlignment.start, // 상단에 고정
                    children: [
                      Text(
                        getAppBarTitle(languageCode),
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          height: 1.2, // 줄 간격 조정
                        ),
                      ),
                      const Spacer(),
                      if (isEditMode) ...[
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            setState(() {
                              settingsProvider.updateCountryOrder(countries); 
                              isEditMode = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              isEditMode = false;
                            });
                          },
                        ),
                      ] else ...[
                        IconButton(
                          icon: Image.asset(
                                  settingsProvider.isDarkTheme ? 'assets/images/dark/icon_reorder_DT_xxhdpi.png' : 'assets/images/light/icon_reorder_LT_xxhdpi.png',
                                  height: 24,
                                  width: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              isEditMode = !isEditMode;
                            });
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                                  settingsProvider.isDarkTheme ? 'assets/images/dark/icon_config_DT_xxhdpi.png' : 'assets/images/light/icon_config_LT_xxhdpi.png',
                                  height: 24,
                                  width: 24,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ),
                            );
                          },
                        ),
                      ],
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
                            buildDefaultDragHandles: isEditMode,
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
                                        if (isEditMode) return;
                                        if (settingsProvider.isVibrate) HapticFeedback.vibrate();
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
                                            painter: GradientBorderPainter(isDark: settingsProvider.isDarkTheme),
                                            child: Container(
                                              height: 45,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(28),
                                              color: Colors.transparent,
                                            ),
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    countries[index],
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                if (isEditMode)
                                                  const Positioned(
                                                    top: 16,
                                                    right: 20, // This will position the icon to the far right
                                                    child: Icon(Icons.reorder, color: Colors.white),
                                                  ),
                                              ],
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          if(settingsProvider.isVibrate) HapticFeedback.vibrate();
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
                              getSpecialLable(specialSection!, languageCode),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getNameBySpecialSource(specialSection!, languageCode),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
      ), 
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final bool isDark;
  GradientBorderPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: isDark ? [Color(0xff12d6df), Color(0xfff70fff)]: [Color(0xff00ffed), Color(0xff9d00c6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = const Radius.circular(30.0);
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
