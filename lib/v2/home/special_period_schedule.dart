class SpecialPeriodSchedule {
  const SpecialPeriodSchedule._();

  static int periodFor({
    required DateTime startDate,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final startDay =
        DateTime.utc(startDate.year, startDate.month, startDate.day);
    final currentDay = DateTime.utc(current.year, current.month, current.day);
    final elapsedDays = currentDay.difference(startDay).inDays;
    return elapsedDays < 0 ? 1 : elapsedDays ~/ 7 + 1;
  }

  static int selectAvailablePeriod({
    required Iterable<int> availablePeriods,
    required DateTime startDate,
    DateTime? now,
  }) {
    final periods =
        availablePeriods.where((period) => period > 0).toSet().toList()..sort();
    if (periods.isEmpty) return 0;

    final requested = periodFor(startDate: startDate, now: now);
    var selected = periods.first;
    for (final period in periods) {
      if (period > requested) break;
      selected = period;
    }
    return selected;
  }
}
