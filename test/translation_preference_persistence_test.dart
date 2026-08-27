import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/model/settings.dart';

void main() {
  test('translated/original preference survives a settings-box restart',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('wmt-settings-test-');
    Hive.init(directory.path);
    Hive.registerAdapter(SettingsAdapter());
    try {
      var box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      await box.put(SettingsProvider.settingsKey, Settings.defaultSettings());
      final provider = SettingsProvider(box.get(SettingsProvider.settingsKey)!);

      provider.updateTranslatedContentPreference(true);
      await box.flush();
      await box.close();
      box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      expect(
          box.get(SettingsProvider.settingsKey)!.showTranslatedContent, true);
      provider.dispose();

      final restarted =
          SettingsProvider(box.get(SettingsProvider.settingsKey)!);
      expect(restarted.translatedContentPreference, true);
      restarted.updateTranslatedContentPreference(false);
      await box.flush();
      await box.close();
      box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      expect(
          box.get(SettingsProvider.settingsKey)!.showTranslatedContent, false);
      restarted.dispose();
      await box.close();
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('expired rewarded access automatically restores original content',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('wmt-expired-access-test-');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      final settings = Settings.defaultSettings()
        ..translationAdAccessUntil =
            DateTime.now().subtract(const Duration(seconds: 1))
        ..showTranslatedContent = true;
      await box.put(SettingsProvider.settingsKey, settings);

      final provider = SettingsProvider(settings);
      expect(provider.hasTranslationAdAccess, false);
      expect(provider.translatedContentPreference, false);
      expect(settings.translationAdAccessUntil, isNull);

      provider.dispose();
      await box.close();
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
