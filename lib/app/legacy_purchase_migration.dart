import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LegacyPurchaseMigrationResult {
  const LegacyPurchaseMigrationResult({
    required this.isAdsFree,
    required this.registeredLegacyAdapter,
  });

  final bool isAdsFree;
  final bool registeredLegacyAdapter;
}

/// Reads only the v1 purchase entitlement before the obsolete v1 boxes are
/// deleted. All other v1 settings remain intentionally unmigrated.
class LegacyPurchaseMigration {
  const LegacyPurchaseMigration._();

  static const _settingsBoxName = 'settings';
  static const _settingsKey = 'app_settings';

  static Future<LegacyPurchaseMigrationResult> read() async {
    if (!await Hive.boxExists(_settingsBoxName)) {
      return const LegacyPurchaseMigrationResult(
        isAdsFree: false,
        registeredLegacyAdapter: false,
      );
    }

    Hive.registerAdapter<_LegacySettingsPurchase>(
      _LegacySettingsPurchaseAdapter(),
    );
    Box<_LegacySettingsPurchase>? box;
    try {
      box = await Hive.openBox<_LegacySettingsPurchase>(_settingsBoxName);
      return LegacyPurchaseMigrationResult(
        isAdsFree: box.get(_settingsKey)?.isAdsFree ?? false,
        registeredLegacyAdapter: true,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unable to read the v1 purchase entitlement: $error\n$stackTrace',
      );
      return const LegacyPurchaseMigrationResult(
        isAdsFree: false,
        registeredLegacyAdapter: true,
      );
    } finally {
      await box?.close();
    }
  }
}

class _LegacySettingsPurchase {
  const _LegacySettingsPurchase({required this.isAdsFree});

  final bool isAdsFree;
}

class _LegacySettingsPurchaseAdapter
    extends TypeAdapter<_LegacySettingsPurchase> {
  @override
  int get typeId => 1;

  @override
  _LegacySettingsPurchase read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };
    return _LegacySettingsPurchase(isAdsFree: fields[18] == true);
  }

  @override
  void write(BinaryWriter writer, _LegacySettingsPurchase obj) {
    throw UnsupportedError('The v1 settings adapter is read-only.');
  }
}
