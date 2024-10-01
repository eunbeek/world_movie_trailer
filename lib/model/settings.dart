import 'dart:ui';
import 'package:hive/hive.dart';
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

  Settings({
    required this.language,
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
  });

  // Factory constructor to create default settings
  factory Settings.defaultSettings() {
    final String newLanguage = PlatformDispatcher.instance.locale.languageCode;
    final String deviceLanguage = supportedLanguages.contains(newLanguage) ? newLanguage : 'en';

    // Country order based on the selected language
    List<String> getLocalizedCountryKeys(String lcode) {
      if (localizedCountries.containsKey(lcode)) {
        return localizedCountries[lcode]!.keys.toList();
      } else {
        return [];
      }
    }

    // 현재 요일을 기반으로 초기화
    int currentWeekday = DateTime.now().weekday - 1;
    Map<int, Map<String, bool>> defaultNewShown = {
      0: {'korea': false},                // Monday
      1: {'japan': false},                // Tuesday
      2: {'usa': false, 'canada': false}, // Wednesday
      3: {'india': false, 'spain': false, 'taiwan': false, 'china': false}, // Thursday
      4: {'france': false},               // Friday
      5: {'germany': false},              // Saturday
      6: {'australia': false, 'thailand': false}, // Sunday
    };

    // 현재 요일에 해당하는 국가들의 상태를 모두 true로 설정
    if (defaultNewShown.containsKey(currentWeekday)) {
      defaultNewShown[currentWeekday]!.updateAll((key, value) => true);
    }

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
    );
  }
}
