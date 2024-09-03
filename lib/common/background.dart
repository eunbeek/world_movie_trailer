import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/animation_builder/loop_animation_builder.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

class BackgroundWidget extends StatefulWidget {
  final bool isPausePage;
  const BackgroundWidget({Key? key, required  this.isPausePage}) : super(key: key);

  @override
  _BackgroundWidgetState createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Container(
      color: settingsProvider.isDarkTheme ? Color(0x232323) : Color(0xFFF2F3EC),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: Stack(
                children: [
                  LoopAnimationBuilder(
                    duration: const Duration(seconds: 50),
                    tween: Tween(begin: 0.0, end: -1300),
                    builder: (context, value, _) {
                      return Transform.translate(
                        offset: widget.isPausePage ? Offset.zero : Offset(value.toDouble(), 0),
                        child: OverflowBox(
                          maxWidth: 1300,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  settingsProvider.isDarkTheme
                                    ? "assets/images/dark/deco_world_map_DT_xxhdpi.png"
                                    : "assets/images/light/deco_world_map_LT_xxhdpi.png",
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                    },
                  ),
                  LoopAnimationBuilder(
                    duration: const Duration(seconds: 50),
                    tween: Tween(begin: 1300, end: 0.0),
                    builder: (context, value, _) {
                      return Transform.translate(
                        offset: widget.isPausePage ? Offset.zero : Offset(value.toDouble(), 0),
                        child: OverflowBox(
                          maxWidth: 1300,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  settingsProvider.isDarkTheme
                                    ? "assets/images/dark/deco_world_map_DT_xxhdpi.png"
                                    : "assets/images/light/deco_world_map_LT_xxhdpi.png",
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Film reel background on the left
          Positioned(
            bottom: 0,
            left: 0,
            right: MediaQuery.of(context).size.width / 3, // Occupy half the screen width
            child: Image.asset(
              settingsProvider.isDarkTheme
                  ? 'assets/images/dark/deco_film_reel_DT_xxhdpi.png'
                  : 'assets/images/light/deco_film_reel_LT_xxhdpi.png',
              fit: BoxFit.contain, // Maintain aspect ratio and fit within half the screen width
            ),
          ),
        ],
      ),
    );
  }
}

