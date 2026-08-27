import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/movie_loading_indicator.dart';

void main() {
  Widget loader(
          {Brightness brightness = Brightness.dark, bool reduced = false}) =>
      MaterialApp(
        themeAnimationDuration: Duration.zero,
        theme: ThemeData(brightness: brightness),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(body: Center(child: MovieLoadingIndicator())),
        ),
      );

  testWidgets('film reel uses the correct theme asset and rotates',
      (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(loader(brightness: brightness));
      final image = tester.widget<Image>(find.byType(Image));
      expect(
          (image.image as AssetImage).assetName,
          brightness == Brightness.dark
              ? 'assets/images/dark/loading_DT_xxhdpi.png'
              : 'assets/images/light/loading_LT_xxhdpi.png');
      expect(image.width, 72);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final rotation = tester.widget<RotationTransition>(find.descendant(
        of: find.byType(MovieLoadingIndicator),
        matching: find.byType(RotationTransition),
      ));
      final before = rotation.turns.value;
      await tester.pump(const Duration(milliseconds: 300));
      expect(rotation.turns.value, isNot(before));
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps the reel still', (tester) async {
    await tester.pumpWidget(loader(reduced: true));
    await tester.pump(const Duration(seconds: 1));
    final rotation = tester.widget<RotationTransition>(find.descendant(
      of: find.byType(MovieLoadingIndicator),
      matching: find.byType(RotationTransition),
    ));
    expect(rotation.turns.value, 0);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });
}
