import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Switches detail content within one route; only the active player is mounted.
class DetailSwipeNavigator extends StatefulWidget {
  const DetailSwipeNavigator({
    super.key,
    required this.itemCount,
    required this.initialIndex,
    required this.itemBuilder,
    this.showNavigationButtons = kIsWeb,
  }) : assert(initialIndex >= 0 && initialIndex < itemCount);

  final int itemCount;
  final int initialIndex;
  final IndexedWidgetBuilder itemBuilder;
  final bool showNavigationButtons;

  @override
  State<DetailSwipeNavigator> createState() => _DetailSwipeNavigatorState();
}

class _DetailSwipeNavigatorState extends State<DetailSwipeNavigator> {
  late int _index = widget.initialIndex;
  double _distance = 0;

  void _move(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.itemCount) return;
    setState(() => _index = next);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => _distance = 0,
        onHorizontalDragUpdate: (details) => _distance += details.delta.dx,
        onHorizontalDragCancel: () => _distance = 0,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          final delta = velocity.abs() >= 500 ? velocity : _distance;
          if (_distance.abs() < 60 && velocity.abs() < 500) return;
          _move(delta < 0 ? 1 : -1);
        },
        child: _content(context),
      );

  Widget _content(BuildContext context) {
    final detail = KeyedSubtree(
      key: ValueKey(_index),
      child: widget.itemBuilder(context, _index),
    );
    if (!widget.showNavigationButtons || widget.itemCount <= 1) return detail;

    // Overlay the full-width detail instead of reserving external side gutters.
    return LayoutBuilder(builder: (context, constraints) {
      final inset = constraints.maxWidth >= 700 ? 24.0 : 12.0;
      return Stack(
        fit: StackFit.expand,
        children: [
          detail,
          Positioned(
            left: inset,
            top: 0,
            bottom: 0,
            width: 40,
            child: Center(child: _navigationButton(context, previous: true)),
          ),
          Positioned(
            right: inset,
            top: 0,
            bottom: 0,
            width: 40,
            child: Center(child: _navigationButton(context, previous: false)),
          ),
        ],
      );
    });
  }

  Widget _navigationButton(BuildContext context, {required bool previous}) {
    final enabled = previous ? _index > 0 : _index < widget.itemCount - 1;
    const purple = Color(0xFF7C3AED);
    final colors = Theme.of(context).colorScheme;
    final labels = MaterialLocalizations.of(context);
    return PointerInterceptor(
      intercepting: kIsWeb,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          key: ValueKey(previous ? 'previous-movie' : 'next-movie'),
          tooltip:
              previous ? labels.previousPageTooltip : labels.nextPageTooltip,
          onPressed: enabled ? () => _move(previous ? -1 : 1) : null,
          style: IconButton.styleFrom(
            minimumSize: const Size(40, 48),
            padding: EdgeInsets.zero,
            foregroundColor: purple,
            backgroundColor: colors.surface.withValues(alpha: 0.8),
            disabledForegroundColor: purple.withValues(alpha: 0.4),
            disabledBackgroundColor: colors.surface.withValues(alpha: 0.5),
            side: BorderSide(color: colors.onSurface.withValues(alpha: 0.12)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: CustomPaint(
            key: ValueKey(
                previous ? 'previous-movie-chevron' : 'next-movie-chevron'),
            size: const Size(32, 32),
            painter: _ChevronPainter(
              previous: previous,
              color: purple.withValues(alpha: enabled ? 1 : 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draw directly so the web overlay does not depend on an icon-font glyph.
class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.previous, required this.color});

  final bool previous;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outerX = size.width * (previous ? 0.64 : 0.36);
    final tipX = size.width * (previous ? 0.36 : 0.64);
    final path = Path()
      ..moveTo(outerX, size.height * 0.22)
      ..lineTo(tipX, size.height * 0.5)
      ..lineTo(outerX, size.height * 0.78);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      previous != oldDelegate.previous || color != oldDelegate.color;
}
