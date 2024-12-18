import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

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

    tz.initializeTimeZones();
        debugTimezones();
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

  /// 알림 권한 요청 (iOS만 해당)
  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      final bool? granted = await flutterLocalNotificationsPlugin
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
    }
  }

  /// 알람 등록
  Future<void> registerDailyAlarms(SettingsProvider settingsProvider) async {
    const platformChannel = NotificationDetails(
      android: AndroidNotificationDetails(
        'Daily Update Movie',
        'Daily Alarms',
        channelDescription: 'Daily alarms for country-specific updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,
        ongoing: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    settingsProvider.isAlarmOnByDay.forEach((day, countries) {
      countries.forEach((country, isOn) async {
        if (isOn) {
          final nextNotificationTime = nextInstanceOfDay(day);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            getAlarmId(day, country),
            'Reminder',
            'Check updates for $country!',
            nextNotificationTime,
            platformChannel,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, 
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      });
    });
  }

  /// 특정 알람 취소
  Future<void> cancelAlarm(int day, String country) async {
    final alarmId = getAlarmId(day, country);
    await flutterLocalNotificationsPlugin.cancel(alarmId);
    print('Alarm canceled for $country on day $day');
  }

  /// 다음 알람 시간 계산
  tz.TZDateTime nextInstanceOfDay(int day) {
    final now = tz.TZDateTime.now(tz.local);
    final daysToNext = (day - now.weekday + 7) % 7;
    final nextDate = now.add(Duration(days: daysToNext));
    return tz.TZDateTime(tz.local, nextDate.year, nextDate.month, nextDate.day, 9, 24);
  }

  /// 고유 ID 생성
  int getAlarmId(int day, String country) {
    return day.hashCode ^ country.hashCode;
  }

  void debugTimezones() {
    final now = tz.TZDateTime.now(tz.local); // 현재 지역 시간 가져오기
    final utcNow = tz.TZDateTime.now(tz.UTC); // UTC 기준 현재 시간 가져오기
    
    print('Local Timezone: ${now.location}');
    print('Local Time: $now');
    print('UTC Time: $utcNow');
  }
}
