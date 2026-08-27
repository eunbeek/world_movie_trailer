import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/settings_footer_branding.dart';

void main() {
  testWidgets('logo left and legal links right stay in one row',
      (tester) async {
    final taps = <String>[];
    for (final width in [320.0, 375.0, 1200.0]) {
      for (final dark in [true, false]) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
                  child: SizedBox(
            width: width,
            child: SettingsFooterBranding(
              isDark: dark,
              termsLabel: 'Terms',
              privacyLabel: 'Privacy',
              onLogoTap: () => taps.add('logo'),
              onTermsTap: () => taps.add('terms'),
              onPrivacyTap: () => taps.add('privacy'),
            ),
          ))),
        ));
        await tester.pumpAndSettle();
        final logo = tester.getRect(find.byType(Image));
        final terms = tester.getRect(find.text('Terms'));
        final privacy = tester.getRect(find.text('Privacy'));
        final footer = tester.getRect(find.byType(SettingsFooterBranding));
        expect(logo.left, closeTo(footer.left + 16, 0.1));
        expect(privacy.right, closeTo(footer.right - 16, 0.1));
        expect(terms.left, greaterThan(logo.right));
        expect(terms.center.dy, closeTo(logo.center.dy, 0.1));
        expect(privacy.center.dy, closeTo(logo.center.dy, 0.1));
        final image = tester.widget<Image>(find.byType(Image));
        expect((image.image as AssetImage).assetName,
            contains(dark ? 'white' : 'black'));
        await tester.tap(find.byType(Image));
        await tester.tap(find.text('Terms'));
        await tester.tap(find.text('Privacy'));
        expect(taps.sublist(taps.length - 3), ['logo', 'terms', 'privacy']);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
