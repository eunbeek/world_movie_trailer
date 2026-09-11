import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/v2/onboarding/onboarding_content.dart';
import 'package:world_movie_trailer/v2/onboarding/onboarding_page.dart';

void main() {
  test('all supported languages provide four pages and actions', () {
    for (final entry in onboardingCopies.entries) {
      expect(entry.value, hasLength(4), reason: entry.key);
      expect(onboardingActionLabels[entry.key], isNotNull);
      for (final page in entry.value) {
        expect(page.title, contains('\n'),
            reason: '${entry.key}: ${page.title}');
      }
    }
  });

  testWidgets('walks through four pages and completes onboarding',
      (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var completed = false;

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: OnboardingPage(
        language: 'ko',
        onComplete: () async => completed = true,
      ),
    ));

    expect(find.text('국가 순서도\n내 마음대로'), findsOneWidget);
    expect(find.text('다음'), findsNothing);
    expect(find.text('시작하기'), findsNothing);

    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('onboarding-translation-arrow')),
        findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('onboarding-autoplay-arrow')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-progress-arrow')),
        findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('스와이프로\n다음 영화 예고편'), findsOneWidget);
    await tester.tap(find.text('시작하기'));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets('all localized pages fit a compact phone', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final language in onboardingCopies.keys) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: OnboardingPage(
            key: ValueKey(language),
            language: language,
            onComplete: () async {},
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$language page 1');
      for (var page = 1; page < 4; page++) {
        await tester.drag(find.byType(PageView), const Offset(-320, 0));
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          tester.takeException(),
          isNull,
          reason: '$language page ${page + 1}',
        );
      }
    }
  });

  testWidgets('all pages fit a tall phone without changing their frame',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: OnboardingPage(
          language: 'ko',
          onComplete: () async {},
        ),
      ),
    );

    for (var page = 0; page < 4; page++) {
      expect(tester.takeException(), isNull,
          reason: 'tall phone page ${page + 1}');
      if (page < 3) {
        await tester.drag(find.byType(PageView), const Offset(-340, 0));
        await tester.pump(const Duration(milliseconds: 400));
      }
    }
  });
}
