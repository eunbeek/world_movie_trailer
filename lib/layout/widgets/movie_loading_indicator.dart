import 'package:flutter/material.dart';

/// Uses the supplied film-reel artwork for full-page loading states.
class MovieLoadingIndicator extends StatefulWidget {
  const MovieLoadingIndicator({super.key, this.size = 72});

  final double size;

  @override
  State<MovieLoadingIndicator> createState() => _MovieLoadingIndicatorState();
}

class _MovieLoadingIndicatorState extends State<MovieLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Loading',
      child: RepaintBoundary(
        child: RotationTransition(
          turns: MediaQuery.disableAnimationsOf(context)
              ? const AlwaysStoppedAnimation(0.0)
              : _controller,
          child: Image.asset(
            dark
                ? 'assets/images/dark/loading_DT_xxhdpi.png'
                : 'assets/images/light/loading_LT_xxhdpi.png',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
