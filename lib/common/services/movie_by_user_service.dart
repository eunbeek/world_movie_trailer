import 'package:hive/hive.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';

class MovieByUserService {
  static final String _boxNameLike = 'movieByUserBoxForLike';
  static final String _boxNameDislike = 'movieByUserBoxForDislike';
  static final String _boxNameBookmark = 'movieByUserBoxForBookmark';
  static final String _boxNameMemo = 'movieByUserBoxForMemo';

  // Open the box (this should be called during initialization)
  static Future<Box<MovieByUser>> _openBox(int flag) async {
    switch (flag){
      case 1:
        return await Hive.openBox<MovieByUser>(_boxNameLike);
      case 2: 
        return await Hive.openBox<MovieByUser>(_boxNameDislike);
      case 3: 
        return await Hive.openBox<MovieByUser>(_boxNameBookmark);
      case 4: 
        return await Hive.openBox<MovieByUser>(_boxNameMemo); 
      default:
        return await Hive.openBox<MovieByUser>(_boxNameLike);
    }
  }

  // Add a movie with a flag (like, dislike, bookmark)
  static Future<void> addMovie(int flag, MovieByUser movieByUser) async {
    final box = await _openBox(flag);
      // Fetch current movies
    final movies = box.values.toList();
    movies.insert(0, movieByUser);  // Add the new movie at the beginning

    await box.clear();  // Clear the current box
    await box.addAll(movies);  // Add the movies back in FILO order
  }

  // Update a movie by index
  static Future<void> updateMovie(int flag, int index, MovieByUser updatedMovie) async {
    final box = await _openBox(flag);
    await box.putAt(index, updatedMovie); // 해당 인덱스의 영화를 업데이트
  }
  
  // Delete a movie by index
  static Future<void> deleteMovie(int flag, int index) async {
    final box = await _openBox(flag);
    await box.deleteAt(index);
  }

  // Get all movies by flag
  static Future<List<MovieByUser>> getMoviesByFlag(int flag) async {
    final box = await _openBox(flag);
    return box.values.where((movie) => movie.flag == flag).toList();
  }

  // Get the length of movies in each box
  static Future<int> getMovieCount(int flag) async {
    final box = await _openBox(flag);
    return box.length; // 현재 박스의 length 반환
  }

  // Get the length of movies in each box
  static Future<bool> getIsAvailable(int flag) async {
    final box = await _openBox(flag);
    return box.length < 30;
  }

  // Get the unique in flag
  static Future<bool> getIsUnique(int flag, String title) async {
    final box = await _openBox(flag);
    
    // Check if any movie in the box has the same localTitle
    final exists = box.values.any((item) => item.movie.localTitle == title);
    
    // Return the opposite since you want to check uniqueness
    return !exists;
  }

  // Get a movie memo by title (for flag 4 - memos)
  static Future<MovieByUser?> getMovieMemoByTitle(String title) async {
    final box = await _openBox(4);
    try {
      return box.values.firstWhere((movie) => movie.movie.localTitle == title);
    } catch (e) {
      // Return null if not found, without throwing an error
      return null;
    }
  }

   // Update a movie memo by searching for its title
  static Future<void> updateMovieMemo(MovieByUser updatedMovie) async {
    final box = await _openBox(4);
    final index = box.values.toList().indexWhere((movie) => movie.movie.localTitle == updatedMovie.movie.localTitle);

    if (index != -1) {
      await box.putAt(index, updatedMovie); // Update the movie memo at the found index
    }
  }

}
