import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/common/constants.dart';

class SettingsProvider with ChangeNotifier {
  Settings _settings;

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

  int get totalHours => _settings.totalHours;

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

  void updateTotalHours(int hours){
    _settings.totalHours += hours;
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
