import 'package:world_movie_trailer/app/app_bootstrap.dart';
import 'package:world_movie_trailer/firebase_options.dart';

export 'package:world_movie_trailer/app/app_bootstrap.dart' show bootstrap;

void main() => bootstrap(DefaultFirebaseOptions.currentPlatform);
