// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      localTitle: fields[0] as String,
      posterUrl: fields[1] as String,
      trailerUrl: fields[2] as String,
      country: fields[3] as String,
      source: fields[4] as String,
      spec: fields[5] as String,
      releaseDate: fields[6] as String,
      runtime: fields[7] as dynamic,
      credits: (fields[8] as Map?)?.cast<String, dynamic>(),
      status: fields[9] as String?,
      special: fields[10] as String?,
      year: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.localTitle)
      ..writeByte(1)
      ..write(obj.posterUrl)
      ..writeByte(2)
      ..write(obj.trailerUrl)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.spec)
      ..writeByte(6)
      ..write(obj.releaseDate)
      ..writeByte(7)
      ..write(obj.runtime)
      ..writeByte(8)
      ..write(obj.credits)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.special)
      ..writeByte(11)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
