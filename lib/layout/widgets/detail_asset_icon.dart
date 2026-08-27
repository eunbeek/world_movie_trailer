import 'package:flutter/material.dart';

/// Shared PNG action icons for the native and web movie detail pages.
class DetailAssetIcon extends StatelessWidget {
  const DetailAssetIcon({
    super.key,
    required this.name,
    required this.active,
  });

  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/v2/${name}_inactive.png',
        width: 29,
        height: 29,
        fit: BoxFit.contain,
        color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface)
            .withValues(alpha: active ? 1 : 0.4),
        excludeFromSemantics: true,
      );
}
