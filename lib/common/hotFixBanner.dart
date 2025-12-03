import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:world_movie_trailer/common/translate.dart';

class HotFixBanner extends StatelessWidget {
  final String language;

  const HotFixBanner({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: Colors.redAccent,
      child: Marquee(
        text: getHotFixLabel(language),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 100.0,
        velocity: 40.0,
        pauseAfterRound: Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
