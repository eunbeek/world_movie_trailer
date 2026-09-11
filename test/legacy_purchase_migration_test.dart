import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:world_movie_trailer/app/legacy_purchase_migration.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'world_movie_trailer_legacy_purchase_',
    );
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    await Hive.close();
    Hive.resetAdapters();
    await tempDirectory.delete(recursive: true);
  });

  test('preserves only the v1 ads-free entitlement', () async {
    Hive.registerAdapter<_V1Settings>(_V1SettingsAdapter());
    final legacyBox = await Hive.openBox<_V1Settings>('settings');
    await legacyBox.put('app_settings', const _V1Settings(isAdsFree: true));
    await legacyBox.close();
    Hive.resetAdapters();

    final result = await LegacyPurchaseMigration.read();

    expect(result.isAdsFree, isTrue);
    expect(result.registeredLegacyAdapter, isTrue);
  });

  test('does not register a legacy adapter for a fresh install', () async {
    final result = await LegacyPurchaseMigration.read();

    expect(result.isAdsFree, isFalse);
    expect(result.registeredLegacyAdapter, isFalse);
  });
}

class _V1Settings {
  const _V1Settings({required this.isAdsFree});

  final bool isAdsFree;
}

class _V1SettingsAdapter extends TypeAdapter<_V1Settings> {
  @override
  int get typeId => 1;

  @override
  _V1Settings read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };
    return _V1Settings(isAdsFree: fields[18] == true);
  }

  @override
  void write(BinaryWriter writer, _V1Settings obj) {
    writer
      ..writeByte(1)
      ..writeByte(18)
      ..write(obj.isAdsFree);
  }
}
