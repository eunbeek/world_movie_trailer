import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/detail_asset_icon.dart';

void main() {
  testWidgets('detail PNGs load for both actions, states, and themes',
      (tester) async {
    for (final brightness in Brightness.values) {
      final theme = ThemeData(brightness: brightness);
      for (final name in ['bookmark', 'translate']) {
        for (final active in [false, true]) {
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: Scaffold(body: DetailAssetIcon(name: name, active: active)),
          ));
          await tester.pumpAndSettle();
          final image = tester.widget<Image>(find.byType(Image));
          expect((image.image as AssetImage).assetName,
              'assets/images/v2/${name}_inactive.png');
          expect(
              image.color,
              (brightness == Brightness.dark
                      ? Colors.white
                      : theme.colorScheme.onSurface)
                  .withValues(alpha: active ? 1 : 0.4));
          expect(image.width, 29);
          expect(image.height, 29);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
