// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movieByUser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieByUserAdapter extends TypeAdapter<MovieByUser> {
  @override
  final int typeId = 3;

  @override
  MovieByUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieByUser(
      flag: fields[0] as int,
      movie: fields[2] as Movie,
      memo: fields[3] as String?,
      savedDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieByUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.flag)
      ..writeByte(2)
      ..write(obj.movie)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.savedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieByUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
