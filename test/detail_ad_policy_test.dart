import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/common/ad_manager/detail_ad_policy.dart';

void main() {
  test('detail ad is shown on every seventh detail entry', () {
    for (var count = 1; count <= 20; count++) {
      expect(
        DetailAdPolicy.shouldShow(count),
        count == 7 || count == 14,
        reason: 'unexpected ad decision for detail entry $count',
      );
    }
  });
}
