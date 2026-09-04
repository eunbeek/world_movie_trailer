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

  @override
  Widget build(BuildContext context) {
    final resolvedColor = (color ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface))
        .withValues(alpha: active ? 1 : 0.4);
    if (name == 'bookmark') {
      return Icon(
        Icons.bookmark_border_rounded,
        size: 32,
        color: resolvedColor,
      );
    }
    return Image.asset(
      'assets/images/v2/$name.png',
      width: 29,
      height: 29,
      fit: BoxFit.contain,
      color: resolvedColor,
      excludeFromSemantics: true,
    );
  }
}
