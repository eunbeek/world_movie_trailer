import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class ErrorByUserPage extends StatelessWidget {

  ErrorByUserPage({super.key});

  final List<String> errorExpressions = ['(≥o≤)', ' (˚Δ˚)b', ' \\(o_o)/', ' (^-^*)', ' (>_<) ', '\\(^Д^)/'];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final randomExpression = errorExpressions[Random().nextInt(errorExpressions.length)]; // Pick a random expression

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Move it 100 pixels upwards
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              randomExpression, // Use the random expression
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: settingsProvider.isDarkTheme ? Color(0xffffcc00) : Color(0xff00ccff),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              getErrorByUserMessage(settingsProvider.language),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: settingsProvider.isDarkTheme ? Color(0xffececec) : Color(0xff1a1713),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
