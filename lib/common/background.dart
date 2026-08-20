import 'package:flutter/material.dart';

/// Legacy world-map background, adapted to tile across wide web viewports.
class BackgroundWidget extends StatefulWidget {
  const BackgroundWidget({
    super.key,
    required this.isPausePage,
    required this.isTapeExist,
  });

  final bool isPausePage;
  final bool isTapeExist;

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    );
    if (!widget.isPausePage) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant BackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPausePage) {
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
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final reelWidth = viewportWidth >= 700
        ? (viewportWidth * 0.32).clamp(320.0, 520.0)
        : viewportWidth * 0.67;
    final mapAsset = dark
        ? 'assets/images/dark/deco_world_map_DT_xxhdpi.png'
        : 'assets/images/light/deco_world_map_LT_xxhdpi.png';
    final reelAsset = dark
        ? 'assets/images/dark/deco_film_reel_DT_xxhdpi.png'
        : 'assets/images/light/deco_film_reel_LT_xxhdpi.png';

    return ColoredBox(
      color: dark ? const Color(0xFF000000) : const Color(0xFFF2F3EC),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Transform.translate(
                offset: Offset(-1300 * _controller.value, 0),
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: 3900,
                  maxWidth: 3900,
                  child: Row(
                    children: List.generate(
                      3,
                      (_) => SizedBox(
                        width: 1300,
                        height: MediaQuery.sizeOf(context).height,
                        child: Image.asset(
                          mapAsset,
                          fit: BoxFit.cover,
                          color: dark && !widget.isTapeExist
                              ? Colors.black.withValues(alpha: 0.3)
                              : null,
                          colorBlendMode: BlendMode.dstATop,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.isTapeExist)
            Positioned(
              left: 0,
              bottom: 0,
              width: reelWidth,
              child: IgnorePointer(
                child: Image.asset(
                  reelAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
