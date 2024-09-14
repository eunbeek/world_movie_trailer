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
      nameKR: fields[12] as String?,
      nameJP: fields[13] as String?,
      nameCH: fields[14] as String?,
      nameTW: fields[15] as String?,
      nameFR: fields[16] as String?,
      nameDE: fields[17] as String?,
      nameES: fields[18] as String?,
      nameHI: fields[19] as String?,
      nameTH: fields[20] as String?,
      isYoutube: fields[21] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(22)
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
      ..write(obj.year)
      ..writeByte(12)
      ..write(obj.nameKR)
      ..writeByte(13)
      ..write(obj.nameJP)
      ..writeByte(14)
      ..write(obj.nameCH)
      ..writeByte(15)
      ..write(obj.nameTW)
      ..writeByte(16)
      ..write(obj.nameFR)
      ..writeByte(17)
      ..write(obj.nameDE)
      ..writeByte(18)
      ..write(obj.nameES)
      ..writeByte(19)
      ..write(obj.nameHI)
      ..writeByte(20)
      ..write(obj.nameTH)
      ..writeByte(21)
      ..write(obj.isYoutube);
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
