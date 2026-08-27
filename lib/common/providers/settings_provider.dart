import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/common/content_update_schedule.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/common/constants.dart';

class SettingsProvider with ChangeNotifier {
  static const boxName = 'app_settings';
  static const settingsKey = 'current';
  final Settings _settings;
  final alarmService = AlarmService();

  SettingsProvider(Settings newSettings) : _settings = newSettings {
    _normalizeContentUpdateSettings();
    _normalizeAlarmSettings();
    _saveSettings();
  }
  // property & getter
  bool get isDarkTheme => _settings.theme == 'dark';

  String get language => _settings.language;

  List<String> get countryOrder => getLocalizedCountryNames();

  List<String> get countryOrderKeys =>
      List.unmodifiable(_settings.countryOrder);

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

  Map<int, Map<String, bool>> get isAlarmOn =>
      _settings.isAlarmOn ?? _initializeAlarms();

  bool get isDailyAlarmOn => _settings.isDailyAlarmOn ?? true;

  bool get isBookmarkAlarmOn => _settings.isBookmarkAlarmOn ?? true;

  bool get isAdsFree => _settings.isAdsFree ?? false;

  bool get hasTranslationAdAccess =>
      _settings.translationAdAccessUntil?.isAfter(DateTime.now()) == true;

  bool get canTranslate => isAdsFree || hasTranslationAdAccess;

  bool get canUseRewardedFeatures => isAdsFree || hasTranslationAdAccess;

  bool? get translatedContentPreference => _settings.showTranslatedContent;

  bool get shouldShowVideoAds => !isAdsFree && !hasTranslationAdAccess;

  String get userId {
    if (_settings.userId == null || _settings.userId!.isEmpty) {
      // Generate a new UUID if the userId is null or empty
      var uuid = Uuid();
      String newUserId = uuid.v4(); // Generate new UUID
      _settings.userId = newUserId; // Assign it to userId
      _saveSettings(); // Save it in Hive
      notifyListeners(); // Notify listeners for the change
      return newUserId; // Return the newly generated userId
    } else {
      return _settings.userId!; // Return existing userId
    }
  }

  // update & setter
  set language(String newLanguage) {
    _settings.language =
        supportedLanguages.contains(newLanguage) ? newLanguage : 'en';
    _settings.countryOrder = getLocalizedCountryKeys();
    _saveSettings();
    notifyListeners();
  }

  void updateBackground(String background) {
    _settings.theme = background;
    _saveSettings();
    notifyListeners();
  }

  void updateCountryOrder(List<String> newCountryOrder) {
    // Convert localized country names to their keys
    List<String> countryKeysToSave = newCountryOrder
        .map((localizedCountryName) {
          String? key = localizedCountries[_settings.language]!
              .entries
              .firstWhere((entry) => entry.value == localizedCountryName,
                  orElse: () => MapEntry('', ''))
              .key;
          return key;
        })
        .where((key) => key.isNotEmpty)
        .toList();
    _settings.countryOrder = countryKeysToSave;
    _saveSettings();
    notifyListeners();
  }

  void updateCountryOrderKeys(List<String> countryKeys) {
    _settings.countryOrder = List<String>.from(countryKeys);
    _saveSettings();
    notifyListeners();
  }

  void updateIsVibrate(bool vibrate) {
    _settings.isVibrate = vibrate;
    _saveSettings();
    notifyListeners();
  }

  void updateIsCaptionOn(bool caption) {
    _settings.isCaptionOn = caption;
    _saveSettings();
    notifyListeners();
  }

  void updateIsQuotes(bool quote) {
    _settings.isQuotes = quote;
    _saveSettings();
    notifyListeners();
  }

  void updateOpenCount() {
    _settings.openCount++;
    _settings.totalOpen++;
    _saveSettings();
    notifyListeners();
  }

  void resetOpenCount() {
    _settings.openCount = 0;
    _saveSettings();
    notifyListeners();
  }

  void refreshContentUpdateIndicators({DateTime? now}) {
    final checkedAt = now ?? DateTime.now();
    final updatedFeeds = ContentUpdateSchedule.feedsUpdatedBetween(
      _settings.lastDate,
      checkedAt,
    );
    for (final feed in updatedFeeds) {
      final statusKey = ContentUpdateSchedule.statusKeys[feed];
      if (statusKey == null) continue;
      for (final countries in _settings.isNewShown.values) {
        if (countries.containsKey(statusKey)) countries[statusKey] = true;
      }
    }
    _settings.lastDate = checkedAt;
    _saveSettings();
  }

  void acknowledgeContentUpdate(String feedCode) {
    final country = ContentUpdateSchedule.statusKeys[feedCode];
    if (country == null) return;
    for (final day in _settings.isNewShown.keys) {
      if (_settings.isNewShown[day]?.containsKey(country) == true) {
        _settings.isNewShown[day]![country] = false;
        _saveSettings();
        notifyListeners();
        return; // Exit the loop once the country is found and updated
      }
    }
  }

  bool hasContentUpdate(String feedCode) {
    final country = ContentUpdateSchedule.statusKeys[feedCode];
    if (country == null) return false;
    return _settings.isNewShown.values
        .any((countries) => countries[country] == true);
  }

  void updateLastSpecialNumber(int num) {
    _settings.lastSpecialNumber = num;
    _saveSettings();
    notifyListeners();
  }

  void updateLastSpecialFetched(DateTime lastFetched) {
    _settings.lastSpecialFetched = lastFetched;
    _saveSettings();
    notifyListeners();
  }

  Future<void> updateAlarmForCountryByDay(
      int day, String country, bool isOn) async {
    _settings.isAlarmOn ??= _initializeAlarms();

    if (_settings.isAlarmOn![day]?.containsKey(country) == true) {
      _settings.isAlarmOn![day]![country] = isOn;

      if (isOn) {
        await alarmService.registerDailyAlarms(this);
      } else {
        await alarmService.cancelAlarm(day, country);
      }

      _saveSettings();
      notifyListeners();
    }
  }

  void resetAlarms() {
    _settings.isAlarmOn = _initializeAlarms();
    _settings.isBookmarkAlarmOn = true;
    _saveSettings();
    notifyListeners();
  }

  Future<bool> updateIsDailyAlarmOn(bool dailyAlarm) async {
    _settings.isDailyAlarmOn = dailyAlarm;
    _saveSettings();
    if (dailyAlarm) {
      bool hasPermission = await alarmService.hasNotificationPermission();
      if (!hasPermission) {
        bool granted = await alarmService.requestPermissionOnly(this);
        if (!granted) return false;
      }

      await alarmService.registerDailyAlarms(this);
      if (isBookmarkAlarmOn) {
        await alarmService.registerReleaseAlarmsFromList(this);
      }
    } else {
      await alarmService.cancelAllAlarms();
    }
    notifyListeners();
    return true;
  }

  void updateIsBookmarkAlarmOn(bool bookmarkAlarmOn) async {
    _settings.isBookmarkAlarmOn = bookmarkAlarmOn;
    _saveSettings();

    if (bookmarkAlarmOn) {
      await alarmService.registerReleaseAlarmsFromList(this);
    } else {
      await alarmService.cancelReleaseAlarms();
    }

    notifyListeners();
  }

  void updateIsAdsFree(bool adsFree) {
    _settings.isAdsFree = adsFree;
    _saveSettings();
    notifyListeners();
  }

  void grantRewardedAdAccess() {
    _settings.translationAdAccessUntil =
        DateTime.now().add(const Duration(minutes: 10));
    _saveSettings();
    notifyListeners();
  }

  void grantTranslationAdAccess() => grantRewardedAdAccess();

  void updateTranslatedContentPreference(bool showTranslatedContent) {
    _settings.showTranslatedContent = showTranslatedContent;
    _saveSettings();
    notifyListeners();
  }

  // save the setting change in hive
  void _saveSettings() {
    Hive.box<Settings>(boxName).put(settingsKey, _settings);
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

  Map<int, Map<String, bool>> _initializeAlarms() {
    final defaultLanguageCountries =
        countryByLanguage[_settings.language] ?? [];
    return _settings.isAlarmOn ??= countryByDay.map((day, countries) {
      return MapEntry(
        day,
        {
          for (var country in countries)
            country: defaultLanguageCountries.contains(country),
        },
      );
    });
  }

  void _normalizeAlarmSettings() {
    final defaults = countryByLanguage[_settings.language] ?? const [];
    final current = _settings.isAlarmOn ?? const {};
    _settings.isAlarmOn = countryByDay.map((day, countries) {
      final existing = current[day] ?? const {};
      return MapEntry(day, {
        for (final country in countries)
          country: existing[country] ?? defaults.contains(country),
      });
    });
  }

  void _normalizeContentUpdateSettings() {
    const countriesByDay = <int, List<String>>{
      0: ['korea'],
      1: ['japan'],
      2: ['usa', 'canada'],
      3: ['india', 'spain', 'taiwan'],
      4: ['france', 'china'],
      5: ['germany'],
      6: ['australia', 'thailand'],
    };
    final current = _settings.isNewShown;
    _settings.isNewShown = countriesByDay.map((day, countries) {
      final existing = current[day] ?? const {};
      return MapEntry(day, {
        for (final country in countries) country: existing[country] ?? false,
      });
    });
  }
}
