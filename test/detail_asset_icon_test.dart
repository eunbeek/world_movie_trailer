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
          final dark = brightness == Brightness.dark;
          final themeCode = dark ? 'DT' : 'LT';
          final state = active ? 'on' : 'off';
          final assetName = name == 'bookmark'
              ? 'icon_bookmark02_${state}_${themeCode}_xxhdpi.png'
              : 'icon_translate_${state}_${themeCode}_xxhdpi.png';
          expect((image.image as AssetImage).assetName,
              'assets/images/${dark ? 'dark' : 'light'}/$assetName');
          expect(image.width, 32);
          expect(image.height, 32);
          expect(image.color, isNull);
          expect(find.byType(ShaderMask), findsNothing);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
