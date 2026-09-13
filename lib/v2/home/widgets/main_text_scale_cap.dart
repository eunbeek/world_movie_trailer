import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Keeps native Flutter text independent of the system font-size setting.
class MainTextScaleCap extends StatelessWidget {
  const MainTextScaleCap({
    super.key,
    required this.child,
    this.enabled = !kIsWeb,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return MediaQuery.withNoTextScaling(
      child: child,
    );
  }
}
