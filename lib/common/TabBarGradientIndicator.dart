import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class TabBarGradientIndicator extends Decoration {
  final List<Color>? gradientColor;
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final double indicatorWidth;

  const TabBarGradientIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.indicatorWidth = 2.0,
    this.gradientColor,
  });

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is TabBarGradientIndicator) {
      return TabBarGradientIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t) ??
            const EdgeInsets.all(0),
        gradientColor: gradientColor,
        indicatorWidth: indicatorWidth,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is TabBarGradientIndicator) {
      return TabBarGradientIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t) ??
            const EdgeInsets.all(0),
        gradientColor: gradientColor,
        indicatorWidth: indicatorWidth,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(
      decoration: this,
      gradientColor: gradientColor,
      indicatorWidth: indicatorWidth,
      onChanged: onChanged,
    );
  }
}

class _UnderlinePainter extends BoxPainter {
  final TabBarGradientIndicator decoration;
  final double indicatorWidth;
  final List<Color>? gradientColor;

  _UnderlinePainter({
    required this.decoration,
    required this.gradientColor,
    required this.indicatorWidth,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = offset &
        decoration.insets.deflateSize(
          (configuration.size ?? Size(indicatorWidth, indicatorWidth)),
        );
    Rect myRect = Rect.fromLTWH(
      rect.left - 15,
      rect.top + 47,
      rect.width + 30, 
      indicatorWidth,  // Ensures that the thickness is enough for visibility
    );

    final Paint paint = decoration.borderSide.toPaint()
      ..strokeWidth = indicatorWidth
      ..strokeCap = StrokeCap.square
      ..shader = ui.Gradient.linear(
        Offset(myRect.left, 0),
        Offset(myRect.right, 0),
        gradientColor ?? [],
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(myRect, Radius.circular(indicatorWidth * 0.25)),
      paint,
    );
  }
}

