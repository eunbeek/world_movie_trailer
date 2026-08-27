import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/detail_swipe_navigator.dart';
import 'package:world_movie_trailer/v2/home/widgets/selection_indicator_width.dart';
import 'package:world_movie_trailer/v2/home/widgets/selection_tab_label.dart';

void main() {
  Widget detail(
          {int initialIndex = 0,
          int itemCount = 3,
          bool showButtons = false}) =>
      MaterialApp(
        home: DetailSwipeNavigator(
          itemCount: itemCount,
          initialIndex: initialIndex,
          showNavigationButtons: showButtons,
          itemBuilder: (_, index) => Scaffold(
            body: Center(child: Text('Movie $index')),
          ),
        ),
      );

  testWidgets('web arrows switch in place and disable at list boundaries',
      (tester) async {
    await tester.pumpWidget(detail(showButtons: true));
    final previous = find.byKey(const ValueKey('previous-movie'));
    final next = find.byKey(const ValueKey('next-movie'));
    final pageBounds = tester.getRect(find.byType(Scaffold));
    expect(pageBounds, tester.getRect(find.byType(DetailSwipeNavigator)));
    expect(pageBounds.contains(tester.getCenter(previous)), isTrue);
    expect(pageBounds.contains(tester.getCenter(next)), isTrue);
    expect(tester.widget<IconButton>(previous).onPressed, isNull);
    final activeStyle = tester.widget<IconButton>(next).style!;
    final colors = Theme.of(tester.element(next)).colorScheme;
    expect(activeStyle.backgroundColor!.resolve({}),
        colors.surface.withValues(alpha: 0.8));
    expect(activeStyle.foregroundColor!.resolve({}), const Color(0xFF7C3AED));
    expect(activeStyle.backgroundColor!.resolve({WidgetState.disabled}),
        colors.surface.withValues(alpha: 0.5));
    for (final index in [1, 2]) {
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('Movie $index'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    }
    expect(tester.widget<IconButton>(next).onPressed, isNull);
    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
  });

  testWidgets('arrows are absent on app and for single-movie lists',
      (tester) async {
    await tester.pumpWidget(detail());
    expect(find.byType(IconButton), findsNothing);
    await tester.pumpWidget(detail(itemCount: 1, showButtons: true));
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('web arrows fit a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(detail(showButtons: true));
    await tester.tap(find.byKey(const ValueKey('next-movie')));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SE-sized web arrows paint visible purple strokes without fonts',
      (tester) async {
    tester.view.physicalSize = const Size(750, 1106);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(detail(initialIndex: 1, showButtons: true));
    for (final direction in ['previous', 'next']) {
      final arrow = find.byKey(ValueKey('$direction-movie-chevron'));
      expect(tester.getSize(arrow), const Size(32, 32));
      final painter = tester.widget<CustomPaint>(arrow).painter!;
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), const Size(32, 32));
      final picture = recorder.endRecording();
      final image = (await tester.runAsync(() => picture.toImage(32, 32)))!;
      final pixels = (await tester.runAsync(
          () => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
      var purplePixels = 0;
      for (var i = 0; i < pixels.lengthInBytes; i += 4) {
        if (pixels.getUint8(i) == 0x7C &&
            pixels.getUint8(i + 1) == 0x3A &&
            pixels.getUint8(i + 2) == 0xED &&
            pixels.getUint8(i + 3) > 200) {
          purplePixels++;
        }
      }
      expect(purplePixels, greaterThan(50), reason: direction);
      image.dispose();
      picture.dispose();
    }
    await tester.tap(find.byKey(const ValueKey('next-movie')));
    await tester.pumpAndSettle();
    expect(find.text('Movie 2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('previous-movie')));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('left advances, right returns, boundaries never wrap',
      (tester) async {
    await tester.pumpWidget(detail());
    final target = find.byType(DetailSwipeNavigator);
    await tester.drag(target, const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Movie 0'), findsOneWidget);
    for (final index in [1, 2, 2]) {
      await tester.drag(target, const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(find.text('Movie $index'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    }
    await tester.drag(target, const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
  });

  testWidgets('starts at selected item; vertical and short drags do not switch',
      (tester) async {
    await tester.pumpWidget(detail(initialIndex: 1));
    final target = find.byType(DetailSwipeNavigator);
    await tester.drag(target, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
    await tester.drag(target, const Offset(-30, 0));
    await tester.pumpAndSettle();
    expect(find.text('Movie 1'), findsOneWidget);
  });

  testWidgets('single movie stays in place', (tester) async {
    await tester.pumpWidget(detail(itemCount: 1));
    for (final offset in [-200.0, 200.0]) {
      await tester.drag(find.byType(DetailSwipeNavigator), Offset(offset, 0));
      await tester.pumpAndSettle();
      expect(find.text('Movie 0'), findsOneWidget);
    }
  });

  testWidgets('indicators measure text, respect scaling and clamp width',
      (tester) async {
    final widths = <String, double>{};
    Future<void> measure(double scale) => tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Builder(builder: (context) {
              for (final label in [
                'United States',
                'Korea',
                '한국',
                '미국',
                '日本',
                'All Trailers',
                'Now Showing',
                'Coming Soon',
                'A very very very long translation'
              ]) {
                widths[label] = selectionIndicatorWidth(
                  context,
                  label,
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                );
              }
              return const SizedBox();
            }),
          ),
        ));
    await measure(1);
    expect(widths['United States']!, greaterThan(widths['Korea']!));
    expect(widths['한국'], 32);
    expect(widths['A very very very long translation'], 120);
    expect(widths.values.every((width) => width >= 32 && width <= 120), isTrue);
    final normalWidth = widths['Korea']!;
    await measure(1.5);
    expect(widths['Korea']!, greaterThan(normalWidth));
  });

  testWidgets('indicator stays centered under translated labels',
      (tester) async {
    for (final label in ['개봉 예정', 'United States', '한국', '日本', 'Coming Soon']) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: TextButton(
          onPressed: () {},
          child: SelectionTabLabel(label: label, selected: true),
        ))),
      ));
      await tester.pumpAndSettle();
      final indicator = find.descendant(
          of: find.byType(SelectionTabLabel),
          matching: find.byType(AnimatedContainer));
      expect(tester.getCenter(indicator).dx,
          closeTo(tester.getCenter(find.text(label)).dx, 0.1),
          reason: label);
      expect(tester.takeException(), isNull);
    }
  });
}
