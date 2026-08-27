import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:world_movie_trailer/common/constants.dart';

part 'settings.g.dart'; // This is needed for the generated code

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  String language;

  @HiveField(1)
  String theme;

  @HiveField(2)
  List<String> countryOrder;

  @HiveField(3)
  bool isVibrate;

  @HiveField(4)
  bool isCaptionOn;

  @HiveField(5)
  bool isQuotes;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  int totalOpen;

  @HiveField(8)
  int openCount;

  @HiveField(9)
  String specialPeriod;

  @HiveField(10)
  Map<int, Map<String, bool>> isNewShown;

  @HiveField(11)
  DateTime lastDate;

  @HiveField(12)
  int lastSpecialNumber;

  @HiveField(13)
  DateTime lastSpecialFetched;

  // Future: Alarm
  @HiveField(14)
  Map<int, Map<String, bool>>? isAlarmOn;

  @HiveField(15)
  bool? isDailyAlarmOn;

  @HiveField(16)
  bool? isBookmarkAlarmOn;

  @HiveField(17)
  bool? isAdsFree;

  @HiveField(18)
  String? userId;

  @HiveField(19)
  DateTime? translationAdAccessUntil;

  @HiveField(21)
  bool? showTranslatedContent;

  Settings(
      {required this.language,
      required this.theme,
      required this.countryOrder,
      required this.isVibrate,
      required this.isCaptionOn,
      required this.isQuotes,
      required this.startDate,
      required this.totalOpen,
      required this.openCount,
      required this.specialPeriod,
      required this.isNewShown,
      required this.lastDate,
      this.lastSpecialNumber = 0,
      required this.lastSpecialFetched,
      this.isAlarmOn, // Future: Alarm
      this.isDailyAlarmOn,
      this.isBookmarkAlarmOn,
      this.isAdsFree,
      this.userId,
      this.translationAdAccessUntil,
      this.showTranslatedContent});

  // Factory constructor to create default settings
  factory Settings.defaultSettings() {
    final String newLanguage = PlatformDispatcher.instance.locale.languageCode;
    final String deviceLanguage =
        supportedLanguages.contains(newLanguage) ? newLanguage : 'en';

    // Country order based on the selected language
    List<String> getLocalizedCountryKeys(String lcode) {
      if (localizedCountries.containsKey(lcode)) {
        return localizedCountries[lcode]!.keys.toList();
      } else {
        return [];
      }
    }

    Map<int, Map<String, bool>> defaultNewShown = {
      0: {'korea': false}, // Monday
      1: {'japan': false}, // Tuesday
      2: {'usa': false, 'canada': false}, // Wednesday
      3: {'india': false, 'spain': false, 'taiwan': false}, // Thursday
      4: {'france': false, 'china': false}, // Friday
      5: {'germany': false}, // Saturday
      6: {'australia': false, 'thailand': false}, // Sunday
    };

    // Future: Alarm
    final defaultAlarmByLan = countryByLanguage[deviceLanguage];
    final defaultIsAlarmOn = countryByDay.map((day, countries) {
      return MapEntry(day, {
        for (var country in countries)
          country: defaultAlarmByLan?.contains(country) ?? false,
      });
    });

    // UUID 생성 (앱 실행 시마다 새로 생성)
    var uuid = Uuid();
    String generatedUuid = uuid.v4(); // 새로운 UUID 생성

    return Settings(
        language: deviceLanguage,
        theme: 'dark',
        countryOrder: getLocalizedCountryKeys(deviceLanguage),
        isVibrate: true,
        isCaptionOn: false,
        isQuotes: true,
        startDate: DateTime.now(),
        totalOpen: 0,
        openCount: 0,
        specialPeriod: '',
        isNewShown: defaultNewShown,
        lastDate: DateTime.now(),
        lastSpecialFetched: DateTime.now(),
        isAlarmOn: defaultIsAlarmOn,
        isDailyAlarmOn: true,
        isBookmarkAlarmOn: true,
        isAdsFree: false,
        userId: generatedUuid,
        translationAdAccessUntil: null,
        showTranslatedContent: null);
  }
}
