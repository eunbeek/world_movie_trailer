// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      language: fields[0] as String,
      theme: fields[1] as String,
      countryOrder: (fields[2] as List).cast<String>(),
      isVibrate: fields[3] as bool,
      isCaptionOn: fields[4] as bool,
      isQuotes: fields[5] as bool,
      startDate: fields[6] as DateTime,
      totalOpen: fields[7] as int,
      openCount: fields[8] as int,
      specialPeriod: fields[9] as String,
      isNewShown: (fields[10] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as Map).cast<String, bool>())),
      lastDate: fields[11] as DateTime,
      lastSpecialNumber: fields[12] as int,
      lastSpecialFetched: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.countryOrder)
      ..writeByte(3)
      ..write(obj.isVibrate)
      ..writeByte(4)
      ..write(obj.isCaptionOn)
      ..writeByte(5)
      ..write(obj.isQuotes)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.totalOpen)
      ..writeByte(8)
      ..write(obj.openCount)
      ..writeByte(9)
      ..write(obj.specialPeriod)
      ..writeByte(10)
      ..write(obj.isNewShown)
      ..writeByte(11)
      ..write(obj.lastDate)
      ..writeByte(12)
      ..write(obj.lastSpecialNumber)
      ..writeByte(13)
      ..write(obj.lastSpecialFetched);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
