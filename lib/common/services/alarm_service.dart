import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/iana.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 초기화 메소드 (iOS와 Android 모두)
  Future<void> initialize() async {
    const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsDarwin,
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    initializeTimeZone();
    // debugTimezones();
  }

  Future<void> initializeTimeZone() async {
    tz.initializeTimeZones();

    // 현재 시간대 약어와 사용자 지역 감지
    final String timeZoneAbbreviation = DateTime.now().timeZoneName;
    final String ianaTimeZone = getIANATimeZone(timeZoneAbbreviation);

    try {
      tz.setLocalLocation(tz.getLocation(ianaTimeZone));
      print('TimeZone set to: $ianaTimeZone');
    } catch (e) {
      print('Error setting TimeZone: $e');
      tz.setLocalLocation(tz.UTC); // 기본값: UTC
    }
  }

  /// iOS 알림 수신 처리
  static Future<void> onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    print('iOS Local Notification: $title, $body, $payload');
  }

  /// 알림 선택 시 동작
  static void onSelectNotification(NotificationResponse notificationResponse) {
    print('Notification Selected: ${notificationResponse.payload}');
  }

  /// 알림 권한 요청 (iOS 및 Android 모두)
  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      // iOS specific notification permission
      final bool? granted = await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      if (granted == true) {
        print('iOS Notification Permission Granted');
      } else {
        print('iOS Notification Permission Denied');
      }
    } else if (Platform.isAndroid) {
      print('android permission ready');
      // Check and request POST_NOTIFICATIONS for Android 13+
      if (await Permission.notification.isDenied) {
        final PermissionStatus status = await Permission.notification.request();
        if (status.isGranted) {
          print('Android Notification Permission Granted');
        } else {
          print('Android Notification Permission Denied');
        }
      }

      // Check and request SCHEDULE_EXACT_ALARM for Android 12+
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? exactAlarmGranted = await androidPlugin?.requestExactAlarmsPermission();
      if (exactAlarmGranted == true) {
        print('Android Exact Alarm Permission Granted');
      } else {
        print('Android Exact Alarm Permission Denied');
      }
    }
  }

  /// 다음 알람 시간 계산
  tz.TZDateTime nextInstanceOfDay(int day) {
    final now = tz.TZDateTime.now(tz.local);
    final daysToNext = (day - now.weekday + 7) % 7;
    final nextDate = now.add(Duration(days: daysToNext));
    return tz.TZDateTime(tz.local, nextDate.year, nextDate.month, nextDate.day, 18, 00);
  }

  /// register daily alarm for country update
  Future<void> registerDailyAlarms(SettingsProvider settingsProvider) async {
    const platformChannel = NotificationDetails(
      android: AndroidNotificationDetails(
        'Daily Update Movie',
        'Daily Notification',
        channelDescription: 'Daily Notification for country-specific updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,
        ongoing: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    for (var day in settingsProvider.isAlarmOn.keys) {
      for (var entry in settingsProvider.isAlarmOn[day]!.entries) {
        final country = entry.key;
        final isOn = entry.value;

        if (isOn) {
          // Cancel existing alarm before registering to avoid duplication
          await cancelAlarm(day, country);

          // Register the new alarm
          final nextNotificationTime = nextInstanceOfDay(day);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            getAlarmId(day, country),
            getAlarmsLabel(settingsProvider.language, 'title'),
            getAlarmsLabel(settingsProvider.language, 'country', localizedCountries[settingsProvider.language]?[country]),
            nextNotificationTime,
            platformChannel,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
    print(settingsProvider.isAlarmOn);
  }

  /// cancel one daily alarm
  Future<void> cancelAlarm(int day, String country) async {
    final alarmId = getAlarmId(day, country);
    await flutterLocalNotificationsPlugin.cancel(alarmId);
    print('Alarm canceled for $country on day $day');
  }

  /// create unique daily alarm id for country update
  int getAlarmId(int day, String country) {
    return day.hashCode ^ country.hashCode;
  }

  /// Register release alarms for all movies stored in the list(only 1 time for existing user)
  Future<void> registerReleaseAlarmsFromList(SettingsProvider settingsProvider, bool isBookmark) async {
    // Fetch all movies based on the flag
    final movies = await MovieByUserService.getMoviesByFlag(isBookmark ? 3 : 4);

    for (var movieByUser in movies) {
      final movie = movieByUser.movie;

      // Ensure releaseDate is not null or invalid
      if (movie.releaseDate == null || movie.releaseDate.isEmpty) {
        print('Skipping movie "${movie.localTitle}" due to missing release date.');
        continue;
      }

      try {
        final releaseDate = DateTime.parse(movie.releaseDate);

        // Ensure the release date is in the future
        if (releaseDate.isBefore(DateTime.now())) {
          print('Skipping movie "${movie.localTitle}" due to past release date.');
          continue;
        }

        // Schedule the release alarm
        final tz.TZDateTime scheduleTime = tz.TZDateTime(
          tz.local,
          releaseDate.year,
          releaseDate.month,
          releaseDate.day - 1,
          11, // Notification time at 11:00 AM
          0,
        );

        final platformChannel = NotificationDetails(
          android: AndroidNotificationDetails(
            'Release Notification',
            'Movie Release Notification',
            channelDescription: 'Notification for movie release dates',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        cancelReleaseAlarmsByFlag(isBookmark);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          getReleaseAlarmId(isBookmark, movie.trailerUrl),
          getAlarmsLabel(settingsProvider.language, 'title'),
          '${getAlarmsLabel(settingsProvider.language, isBookmark ? 'bookmark' : 'memo')} ${movie.localTitle} ${getAlarmsLabel(settingsProvider.language, 'release')}',
          scheduleTime,
          platformChannel,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );

        print('Release alarm set for "${movie.localTitle}" on $scheduleTime');
      } catch (e) {
        print('Failed to schedule alarm for "${movie.localTitle}": $e');
      }
    }
  }

  // register release alarm by bookmark, memo
  Future<void> registerReleaseAlarmForMovie(SettingsProvider settingsProvider, MovieByUser movieByUser, bool isBookmark) async {
    final movie = movieByUser.movie;

    // Ensure releaseDate is not null or invalid
    if (movie.releaseDate == null || movie.releaseDate.isEmpty) {
      print('Skipping movie "${movie.localTitle}" due to missing release date.');
      return;
    }

    try {
      final releaseDate = DateTime.parse(movie.releaseDate);

      // 하루 전날 오전 3시
      final preReleaseAlarmTime = tz.TZDateTime(
        tz.local,
        releaseDate.year,
        releaseDate.month,
        releaseDate.day - 1,
        3, // 오전 3시
        0,
      );

      final releaseAlarmTime = tz.TZDateTime(
        tz.local,
        releaseDate.year,
        releaseDate.month,
        releaseDate.day - 1,
        11, // 오후 3시
        0,
      );

      // 현재 시간
      final now = tz.TZDateTime.now(tz.local);

      // 조건: 현재 시간이 하루 전날 오후 3시 이후라면 알람 등록 안 함
      if (now.isAfter(preReleaseAlarmTime)) {
        print('Skipping alarm for "${movie.localTitle}" as it was bookmarked after 3 PM the day before.');
        return;
      }

      // Generate unique alarm ID
      final alarmId = getReleaseAlarmId(isBookmark, movie.trailerUrl);

      // Cancel existing alarm to avoid duplicates
      await flutterLocalNotificationsPlugin.cancel(alarmId);
      print('Existing alarm canceled for "${movie.localTitle}" with ID: $alarmId');

      // Schedule the release alarm
      final platformChannel = NotificationDetails(
        android: AndroidNotificationDetails(
          'Release Notification',
          'Movie Release Notification',
          channelDescription: 'Notification for movie release dates',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmId,
        getAlarmsLabel(settingsProvider.language, 'title'),
        '${getAlarmsLabel(settingsProvider.language, isBookmark ? 'bookmark' : 'memo')} ${movie.localTitle} ${getAlarmsLabel(settingsProvider.language, 'release')}',
        releaseAlarmTime,
        platformChannel,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );

      print('Release alarm set for "${movie.localTitle}" on $releaseAlarmTime');
    } catch (e) {
      print('Failed to schedule alarm for "${movie.localTitle}": $e');
    }
  }

  // create unique release alarm id
  int getReleaseAlarmId(bool isBookmark, String trailer) {
    return isBookmark.hashCode ^ trailer.hashCode;
  }

  /// cancel release alarm
  Future<void> cancelReleaseAlarm(bool isBookmark, String trailer) async {
    final alarmId = getReleaseAlarmId(isBookmark, trailer);
    await flutterLocalNotificationsPlugin.cancel(alarmId);
    print('Release alarm canceled for movie ID: $alarmId');
  }

  Future<void> cancelReleaseAlarmsByFlag(bool isBookmark) async {
    // 북마크된 모든 영화 가져오기
    final movies = await MovieByUserService.getMoviesByFlag(isBookmark ? 3 : 4);

    for (var movieByUser in movies) {
      final movie = movieByUser.movie;

      try {
        // 알람 ID 생성 및 삭제
        final alarmId = getReleaseAlarmId(isBookmark, movie.trailerUrl);
        await flutterLocalNotificationsPlugin.cancel(alarmId);
        print('Release alarm canceled for "${movie.localTitle}" with ID: $alarmId');
      } catch (e) {
        print('Failed to cancel alarm for "${movie.localTitle}": $e');
      }
    }
  }

  Future<void> cancelAllAlarms() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All alarms have been canceled.');
  }

  void debugTimezones() {
    final now = tz.TZDateTime.now(tz.local); // 현재 지역 시간 가져오기
    final utcNow = tz.TZDateTime.now(tz.UTC); // UTC 기준 현재 시간 가져오기
    print('Local Timezone: ${now.location}');
    print('Local Time: $now');
    print('UTC Time: $utcNow');
  }
}
