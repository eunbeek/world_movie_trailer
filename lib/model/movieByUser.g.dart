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
      movie: fields[0] as Movie,
      savedDate: fields[1] as DateTime?,
      sourceFeedCode: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieByUser obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.movie)
      ..writeByte(1)
      ..write(obj.savedDate)
      ..writeByte(2)
      ..write(obj.sourceFeedCode);
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
