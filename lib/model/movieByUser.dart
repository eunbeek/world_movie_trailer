import 'package:hive/hive.dart';
import 'package:world_movie_trailer/model/movie.dart';

part 'movieByUser.g.dart';

@HiveType(typeId: 3)
class MovieByUser extends HiveObject {
  @HiveField(0)
  int flag;

  @HiveField(2)
  Movie movie;

  @HiveField(3)
  String? memo;

  @HiveField(4)
  DateTime? savedDate;

  MovieByUser({
    required this.flag,
    required this.movie,
    this.memo,
    this.savedDate,
  });

  Map<String, dynamic> toJson() => {
    'flag': flag,
    'movie': movie.toJson(),
    'memo' : memo,
    'savedDate': savedDate?.toIso8601String(),
  };

  factory MovieByUser.fromJson(Map<dynamic, dynamic> json) {
    return MovieByUser(
      flag: json['flag'] ?? 0,
      movie: Movie.fromJson(json['movie']),
      memo: json['memo'] ?? '',
      savedDate: json['savedDate'] != null ? DateTime.parse(json['savedDate']) : null,
    );
  }
}

