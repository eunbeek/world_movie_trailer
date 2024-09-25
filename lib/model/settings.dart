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
  double totalHours;

  Settings({
    required this.language,
    required this.theme,
    required this.countryOrder,
    required this.isVibrate,
    required this.isCaptionOn,
    required this.isQuotes,
    required this.startDate,
    required this.totalHours,
  });

  // Factory constructor to create default settings
  factory Settings.defaultSettings() {
    // Determine the device's locale and brightness 
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

    return Settings(
      language: deviceLanguage,
      theme: 'dark',
      countryOrder: getLocalizedCountryKeys(deviceLanguage),
      isVibrate: true,
      isCaptionOn: false,
      isQuotes: true,
      startDate: DateTime.now(), 
      totalHours: 0.0, 
    );
  }
}
