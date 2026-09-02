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
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SettingsAdapter());
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

  test('free translation is available once and persists across restart',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('wmt-free-translation-test-');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SettingsAdapter());
    try {
      var box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      final settings = Settings.defaultSettings();
      await box.put(SettingsProvider.settingsKey, settings);
      final provider = SettingsProvider(settings);

      expect(provider.useFreeTranslationIfAvailable(), true);
      expect(provider.translatedContentPreference, true);
      expect(provider.canTranslate, true);
      expect(provider.canUseRewardedFeatures, false);
      expect(provider.useFreeTranslationIfAvailable(), false);
      await box.flush();
      provider.dispose();
      await box.close();

      box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      final restarted =
          SettingsProvider(box.get(SettingsProvider.settingsKey)!);
      expect(restarted.hasUsedFreeTranslation, true);
      expect(restarted.translatedContentPreference, true);
      expect(restarted.canTranslate, true);
      expect(restarted.canUseRewardedFeatures, false);
      expect(restarted.useFreeTranslationIfAvailable(), false);
      restarted.updateTranslatedContentPreference(false);
      expect(restarted.canTranslate, false);
      restarted.dispose();
      await box.close();
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('rewarded access still expires after ten minutes', () async {
    final directory =
        await Directory.systemTemp.createTemp('wmt-reward-duration-test-');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SettingsAdapter());
    try {
      final box = await Hive.openBox<Settings>(SettingsProvider.boxName);
      final settings = Settings.defaultSettings();
      await box.put(SettingsProvider.settingsKey, settings);
      final provider = SettingsProvider(settings);
      final before = DateTime.now();

      provider.grantRewardedAdAccess();

      final remaining = settings.translationAdAccessUntil!.difference(before);
      expect(remaining, greaterThanOrEqualTo(const Duration(minutes: 10)));
      expect(remaining, lessThan(const Duration(minutes: 10, seconds: 1)));
      provider.dispose();
      await box.close();
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
