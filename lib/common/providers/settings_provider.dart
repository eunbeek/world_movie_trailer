import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/common/constants.dart';

class SettingsProvider with ChangeNotifier {
  final Settings _settings;
  final alarmService = AlarmService();
  
  SettingsProvider(Settings newSettings, bool isInitialSetting) 
    : _settings = newSettings {
    if (isInitialSetting) _saveSettings();
  }
  // property & getter
  bool get isDarkTheme => _settings.theme == 'dark';

  String get language => _settings.language;
  
  List<String> get countryOrder => getLocalizedCountryNames();
  
  bool get isVibrate => _settings.isVibrate;

  bool get isCaptionOn => _settings.isCaptionOn;
  
  bool get isQuotes => _settings.isQuotes;

  DateTime get startDate => _settings.startDate;

  int get totalOpen => _settings.totalOpen;

  int get openCount => _settings.openCount;

  Map<int, Map<String, bool>> get isNewShown => _settings.isNewShown;

  DateTime get lastDate => _settings.lastDate;

  int get lastSpecialNumber => _settings.lastSpecialNumber;

  DateTime? get lastSpecialFetched => _settings.lastSpecialFetched;

  Map<int, Map<String, bool>> get isAlarmOnByDay =>
    _settings.isAlarmOnByDay ?? countryByDay.map((day, countries) =>
      MapEntry(day, {for (var country in countries) country: true}));

  // update & setter
  set language(String newLanguage) {
    print('updateLanguage');
    _settings.language = supportedLanguages.contains(newLanguage) ? newLanguage : 'en';
    _settings.countryOrder = getLocalizedCountryKeys();
    _saveSettings();
    notifyListeners();
  }

  void updateBackground(String background) {
    print('updateBackground');
    _settings.theme = background;
    _saveSettings();
    notifyListeners();
  }

  void updateCountryOrder(List<String> newCountryOrder) {
    print('updateCountryOrder');
    // Convert localized country names to their keys
    List<String> countryKeysToSave = newCountryOrder.map((localizedCountryName) {
      String? key = localizedCountries[_settings.language]!.entries
          .firstWhere((entry) => entry.value == localizedCountryName, orElse: () => MapEntry('', ''))
          .key;
      return key;
    }).where((key) => key.isNotEmpty).toList();
    _settings.countryOrder = countryKeysToSave;
    _saveSettings();
    notifyListeners();
  }

  void updateIsVibrate(bool vibrate) {
    print('updateVibrate');
    _settings.isVibrate = vibrate;
    _saveSettings();
    notifyListeners();
  }

  void updateIsCaptionOn(bool caption) {
    print('updateCaption');
    _settings.isCaptionOn = caption;
    _saveSettings();
    notifyListeners();
  }

  void updateIsQuotes(bool quote) {
    print('updateQuote');
    _settings.isQuotes = quote;
    _saveSettings();
    notifyListeners();
  }

  void updateOpenCount(){
    _settings.openCount++;
    _settings.totalOpen++;
    _saveSettings();
    notifyListeners();
  }

  void resetOpenCount(){
    _settings.openCount = 0;
    _saveSettings();
    notifyListeners();
  }

  void markIsNewShown(int day){
    print('markIsNewShown');
    _settings.isNewShown[day]!.updateAll((key, value)=> true);
    _saveSettings();
    notifyListeners();
  }

  void unmarkIsNewShown(String country) {
    print('unmarkIsNewShown');
    for (final day in _settings.isNewShown.keys) {
      if (_settings.isNewShown[day]?.containsKey(country) == true) {
        _settings.isNewShown[day]![country] = false;
        _saveSettings();
        notifyListeners();
        return; // Exit the loop once the country is found and updated
      }
    }
    print('Country not found in any day');
  }

  void markAllIsNewShown(){
    print('markAllIsNewShown');
    _settings.isNewShown.forEach((day, countries) {
      countries.updateAll((key, value) => true);
    });
    _saveSettings();
    notifyListeners();
  }

  void unmarkAllIsNewShown(){
    print('unmarkAllIsNewShown');
    _settings.isNewShown.forEach((day, countries) {
      countries.updateAll((key, value) => false);
    });
    _saveSettings();
    notifyListeners();
  }

  bool getCountryStatus(String country) {
    return _settings.isNewShown.values.any((countries) => countries[country] == true);
  }

  void updateLastDate(DateTime openDate){
    _settings.lastDate = openDate;
    _saveSettings();
    notifyListeners();
  }

  void updateLastSpecialNumber(int num){
    _settings.lastSpecialNumber = num;
    _saveSettings();
    notifyListeners();
  }

  void updateLastSpecialFetched(DateTime lastFetched){
    print('updateLastSpecialFetched');
    _settings.lastSpecialFetched = lastFetched;
    _saveSettings();
    notifyListeners();
  }

  Future<void> updateAlarmForCountryByDay(int day, String country, bool isOn) async {
    print('updateAlarmForCountryByDay: ${country} : ${isOn}');
    _settings.isAlarmOnByDay ??= countryByDay.map((day, countries) =>
      MapEntry(day, {for (var country in countries) country: true}));

    if (_settings.isAlarmOnByDay![day] != null) {
      _settings.isAlarmOnByDay![day]![country] = isOn;
      if(isOn) {
        await alarmService.registerDailyAlarms(this);
      } else {
        await alarmService.cancelAlarm(day, country);
      }
      _saveSettings();
      notifyListeners();
    }
  }

  void resetAlarms() {
    _settings.isAlarmOnByDay = countryByDay.map((day, countries) =>
      MapEntry(day, {for (var country in countries) country: true}));
    _saveSettings();
    notifyListeners();
  }

  // save the setting change in hive
  void _saveSettings() {
    print('_saveSettings');
    Hive.box<Settings>('settings').put('app_settings', _settings);
  }

  List<String> getLocalizedCountryKeys() {
    if (localizedCountries.containsKey(_settings.language)) {
      return localizedCountries[_settings.language]!.keys.toList();
    } else {
      return [];
    }
  }

  List<String> getLocalizedCountryNames() {
    return _settings.countryOrder.map((countryKey) {
      return localizedCountries[_settings.language]?[countryKey] ?? countryKey;
    }).toList();
  }
}
