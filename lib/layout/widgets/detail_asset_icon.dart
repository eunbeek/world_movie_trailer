import 'package:flutter/material.dart';

/// Shared PNG action icons for the native and web movie detail pages.
class DetailAssetIcon extends StatelessWidget {
  const DetailAssetIcon({
    super.key,
    required this.name,
    required this.active,
    this.color,
  });

  final String name;
  final bool active;
  final Color? color;

  static const _activeGradient = LinearGradient(
    colors: [Color(0xFF3288FF), Color(0xFFB21FE8)],
  );

  @override
  Widget build(BuildContext context) {
    if (color == null) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      final themeCode = dark ? 'DT' : 'LT';
      final state = active ? 'on' : 'off';
      final assetName = name == 'bookmark'
          ? 'icon_bookmark02_${state}_${themeCode}_xxhdpi.png'
          : 'icon_translate_${state}_${themeCode}_xxhdpi.png';
      return Image.asset(
        'assets/images/${dark ? 'dark' : 'light'}/$assetName',
        key: ValueKey('detail-$name-$themeCode-$state'),
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
    }

    final inactiveColor = (color ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface))
        .withValues(alpha: 0.4);
    if (name == 'bookmark') {
      return active
          ? const CustomPaint(
              key: ValueKey('active-gradient-bookmark'),
              size: Size.square(32),
              painter: _GradientBookmarkPainter(),
            )
          : Icon(
              Icons.bookmark_border_rounded,
              size: 32,
              color: inactiveColor,
            );
    }
    final icon = Image.asset(
      'assets/images/v2/$name.png',
      width: 29,
      height: 29,
      fit: BoxFit.contain,
      color: active ? Colors.white : inactiveColor,
      excludeFromSemantics: true,
    );
    if (!active) return icon;
    return ShaderMask(
      shaderCallback: _activeGradient.createShader,
      blendMode: BlendMode.srcIn,
      child: icon,
    );
  }
}

class _GradientBookmarkPainter extends CustomPainter {
  const _GradientBookmarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = DetailAssetIcon._activeGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * .25, size.height * .08)
      ..quadraticBezierTo(
        size.width * .18,
        size.height * .08,
        size.width * .18,
        size.height * .18,
      )
      ..lineTo(size.width * .18, size.height * .9)
      ..lineTo(size.width * .5, size.height * .7)
      ..lineTo(size.width * .82, size.height * .9)
      ..lineTo(size.width * .82, size.height * .18)
      ..quadraticBezierTo(
        size.width * .82,
        size.height * .08,
        size.width * .75,
        size.height * .08,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBookmarkPainter oldDelegate) => false;
}
