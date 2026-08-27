import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/v2/home/widgets/main_text_scale_cap.dart';

void main() {
  Widget subject(double systemScale, {bool enabled = true}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(systemScale)),
          child: MainTextScaleCap(
            enabled: enabled,
            child: Builder(
                builder: (context) => Text(
                      '${MediaQuery.textScalerOf(context).scale(10)}',
                      textDirection: TextDirection.ltr,
                    )),
          ),
        ),
      );

  testWidgets('native main screen allows scaling only up to 1.2',
      (tester) async {
    for (final scenario
        in {0.8: 8.0, 1.0: 10.0, 1.2: 12.0, 2.0: 12.0, 3.0: 12.0}.entries) {
      await tester.pumpWidget(subject(scenario.key));
      expect(find.text('${scenario.value}'), findsOneWidget,
          reason: 'system scale ${scenario.key}');
    }
  });

  testWidgets('disabled scope leaves web text scaling unchanged',
      (tester) async {
    await tester.pumpWidget(subject(3, enabled: false));
    expect(find.text('30.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
