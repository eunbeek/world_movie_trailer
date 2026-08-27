import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Keeps the native main-screen layout usable at very large system font sizes.
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
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: child,
    );
  }
}
