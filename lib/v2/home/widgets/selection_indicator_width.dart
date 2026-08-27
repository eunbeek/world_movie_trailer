import 'package:flutter/material.dart';

/// Uses the same style, direction and scaling as the rendered tab label.
double selectionIndicatorWidth(
    BuildContext context, String label, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
    maxLines: 1,
  )..layout();
  final width = (painter.width * .75).clamp(32.0, 120.0).toDouble();
  painter.dispose();
  return width;
}
