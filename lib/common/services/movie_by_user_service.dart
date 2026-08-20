import 'package:hive/hive.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';

class MovieByUserService {
  static const String _boxNameBookmark = 'bookmarks';
  static final alarmService = AlarmService();

  // Open the box (this should be called during initialization)
  static Future<Box<MovieByUser>> _openBox() =>
      Hive.openBox<MovieByUser>(_boxNameBookmark);

  // Add a movie with a flag (like, dislike, bookmark)
  static Future<void> addMovie(
      MovieByUser movieByUser, SettingsProvider settingsProvider) async {
    final box = await _openBox();

    // Fetch current movies
    final movies = box.values.toList();
    movies.insert(0, movieByUser); // Add the new movie at the beginning

    // 알람 등록 조건 확인 및 실행
    if (settingsProvider.isDailyAlarmOn) {
      if (settingsProvider.isBookmarkAlarmOn) {
        // 북마크 알람 등록
        await alarmService.registerReleaseAlarmForMovie(
            settingsProvider, movieByUser);
      }
    }

    // Clear and add movies back in FILO order
    await box.clear();
    await box.addAll(movies);
  }

  // Update a movie by index
  // Delete a movie by index
  static Future<void> deleteMovie(int index) async {
    final box = await _openBox();
    final movieToDelete = box.getAt(index);
    if (movieToDelete != null) {
      // Cancel the alarm for the movie
      final movieKey = movieToDelete.movie.id.isNotEmpty
          ? movieToDelete.movie.id
          : movieToDelete.movie.trailerUrl;
      await alarmService.cancelReleaseAlarm(movieKey);

      // Delete the movie from the box
      await box.deleteAt(index);
    }
  }

  // Get all movies by flag
  static Future<List<MovieByUser>> getBookmarks() async =>
      (await _openBox()).values.toList();

  // Get the length of movies in each box
  static Future<bool> getIsAvailable(SettingsProvider settingsProvider) async {
    final box = await _openBox();
    return settingsProvider.isAdsFree || box.length < 30;
  }

  // Get the unique in flag
  static Future<bool> getIsUnique(String movieKey) async {
    final box = await _openBox();
    final exists = box.values.any((item) {
      final storedKey =
          item.movie.id.isNotEmpty ? item.movie.id : item.movie.localTitle;
      return storedKey == movieKey;
    });

    // Return the opposite since you want to check uniqueness
    return !exists;
  }
}
