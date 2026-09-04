import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/v2/home/special_period_schedule.dart';

void main() {
  test('starts at period 1 and advances once every seven calendar days', () {
    final installedAt = DateTime(2026, 9, 2, 23, 30);

    expect(
      SpecialPeriodSchedule.periodFor(
        startDate: installedAt,
        now: DateTime(2026, 9, 2),
      ),
      1,
    );
    expect(
      SpecialPeriodSchedule.periodFor(
        startDate: installedAt,
        now: DateTime(2026, 9, 8, 23, 59),
      ),
      1,
    );
    expect(
      SpecialPeriodSchedule.periodFor(
        startDate: installedAt,
        now: DateTime(2026, 9, 9),
      ),
      2,
    );
    expect(
      SpecialPeriodSchedule.periodFor(
        startDate: installedAt,
        now: DateTime(2026, 9, 16),
      ),
      3,
    );
  });

  test('opening the app repeatedly during a week keeps the same period', () {
    final installedAt = DateTime(2026, 9, 2);

    for (var day = 7; day <= 13; day++) {
      expect(
        SpecialPeriodSchedule.periodFor(
          startDate: installedAt,
          now: installedAt.add(Duration(days: day, hours: day)),
        ),
        2,
      );
    }
  });

  test('uses the latest available period without skipping ahead', () {
    final installedAt = DateTime(2026, 1, 1);

    expect(
      SpecialPeriodSchedule.selectAvailablePeriod(
        availablePeriods: const [1, 2, 3],
        startDate: installedAt,
        now: DateTime(2026, 3, 1),
      ),
      3,
    );
    expect(
      SpecialPeriodSchedule.selectAvailablePeriod(
        availablePeriods: const [1, 3, 4],
        startDate: installedAt,
        now: DateTime(2026, 1, 9),
      ),
      1,
    );
  });
}
