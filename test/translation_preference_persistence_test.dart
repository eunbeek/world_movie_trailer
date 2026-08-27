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

      final restarted =
          SettingsProvider(box.get(SettingsProvider.settingsKey)!);
      expect(restarted.translatedContentPreference, true);
      restarted.updateTranslatedContentPreference(false);
      await box.flush();
      await box.close();
      box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      expect(
          box.get(SettingsProvider.settingsKey)!.showTranslatedContent, false);
      await box.close();
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
