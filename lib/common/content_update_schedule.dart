import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ContentUpdateSchedule {
  const ContentUpdateSchedule._();

  static const _timeZone = 'America/Toronto';

  // Mirrors the Sheet-to-Storage schedules in functions/index.js.
  static const feeds = <String, ({int weekday, int hour, int minute})>{
    'kr': (weekday: DateTime.monday, hour: 5, minute: 10),
    'jp': (weekday: DateTime.tuesday, hour: 5, minute: 0),
    'ca': (weekday: DateTime.wednesday, hour: 6, minute: 0),
    'tw': (weekday: DateTime.thursday, hour: 7, minute: 0),
    'fr': (weekday: DateTime.friday, hour: 6, minute: 0),
    'de': (weekday: DateTime.saturday, hour: 5, minute: 0),
    'us': (weekday: DateTime.wednesday, hour: 5, minute: 0),
    'th': (weekday: DateTime.sunday, hour: 6, minute: 0),
    'au': (weekday: DateTime.sunday, hour: 5, minute: 0),
    'es': (weekday: DateTime.thursday, hour: 6, minute: 0),
    'in': (weekday: DateTime.thursday, hour: 5, minute: 10),
    'cn': (weekday: DateTime.friday, hour: 5, minute: 0),
  };

  static const statusKeys = <String, String>{
    'kr': 'korea',
    'jp': 'japan',
    'ca': 'canada',
    'tw': 'taiwan',
    'fr': 'france',
    'de': 'germany',
    'us': 'usa',
    'th': 'thailand',
    'au': 'australia',
    'es': 'spain',
    'in': 'india',
    'cn': 'china',
  };

  static Set<String> feedsUpdatedBetween(DateTime since, DateTime now) {
    tz_data.initializeTimeZones();
    final location = tz.getLocation(_timeZone);
    final localNow = tz.TZDateTime.from(now, location);
    final sinceUtc = since.toUtc();
    final updated = <String>{};

    for (final entry in feeds.entries) {
      final schedule = entry.value;
      var daysAgo = (localNow.weekday - schedule.weekday + 7) % 7;
      var date = localNow.subtract(Duration(days: daysAgo));
      var latest = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        schedule.hour,
        schedule.minute,
      );
      if (latest.isAfter(localNow)) {
        date = date.subtract(const Duration(days: 7));
        latest = tz.TZDateTime(
          location,
          date.year,
          date.month,
          date.day,
          schedule.hour,
          schedule.minute,
        );
      }
      if (latest.toUtc().isAfter(sinceUtc)) updated.add(entry.key);
    }
    return updated;
  }
}
