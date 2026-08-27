// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuoteAdapter extends TypeAdapter<Quote> {
  @override
  final int typeId = 2;

  @override
  Quote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quote(
      quoteEN: fields[0] as String,
      movieEN: fields[1] as String,
      quoteKR: fields[2] as String,
      movieKR: fields[3] as String,
      quoteJP: fields[4] as String,
      movieJP: fields[5] as String,
      isShowed: fields[6] as bool,
      quoteKey: fields[7] as int,
      timestamp: fields[8] as String,
      quoteTranslations: (fields[9] as Map).cast<String, String>(),
      movieTranslations: (fields[10] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Quote obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.quoteEN)
      ..writeByte(1)
      ..write(obj.movieEN)
      ..writeByte(2)
      ..write(obj.quoteKR)
      ..writeByte(3)
      ..write(obj.movieKR)
      ..writeByte(4)
      ..write(obj.quoteJP)
      ..writeByte(5)
      ..write(obj.movieJP)
      ..writeByte(6)
      ..write(obj.isShowed)
      ..writeByte(7)
      ..write(obj.quoteKey)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.quoteTranslations)
      ..writeByte(10)
      ..write(obj.movieTranslations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
