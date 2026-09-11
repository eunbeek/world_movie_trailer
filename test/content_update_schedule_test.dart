import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/common/content_update_schedule.dart';

void main() {
  test('US indicator follows the Wednesday 06:40 Toronto store batch', () {
    final updated = ContentUpdateSchedule.feedsUpdatedBetween(
      DateTime.utc(2026, 8, 19, 10, 30),
      DateTime.utc(2026, 8, 19, 10, 45),
    );
    expect(updated, contains('us'));
    expect(updated, isNot(contains('ca')));
  });

  test('Thursday feeds respect their different store times', () {
    final updated = ContentUpdateSchedule.feedsUpdatedBetween(
      DateTime.utc(2026, 8, 20, 10, 35),
      DateTime.utc(2026, 8, 20, 10, 45),
    );
    expect(updated, contains('es'));
    expect(updated, isNot(contains('tw')));
  });
}
