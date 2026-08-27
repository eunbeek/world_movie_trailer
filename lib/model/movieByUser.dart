import 'package:hive/hive.dart';
import 'package:world_movie_trailer/model/movie.dart';

part 'movieByUser.g.dart';

@HiveType(typeId: 3)
class MovieByUser extends HiveObject {
  @HiveField(0)
  Movie movie;

  @HiveField(1)
  DateTime? savedDate;

  @HiveField(2)
  String? sourceFeedCode;

  MovieByUser({
    required this.movie,
    this.savedDate,
    this.sourceFeedCode,
  });

  Map<String, dynamic> toJson() => {
        'movie': movie.toJson(),
        'savedDate': savedDate?.toIso8601String(),
        'sourceFeedCode': sourceFeedCode,
      };

  factory MovieByUser.fromJson(Map<dynamic, dynamic> json) {
    return MovieByUser(
      movie: Movie.fromJson(json['movie']),
      savedDate:
          json['savedDate'] != null ? DateTime.parse(json['savedDate']) : null,
      sourceFeedCode: json['sourceFeedCode']?.toString(),
    );
  }
}
