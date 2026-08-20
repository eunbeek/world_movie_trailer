import 'package:flutter/foundation.dart';
import 'package:world_movie_trailer/app/app_bootstrap.dart';
import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/firebase_options_dev.dart';

export 'package:world_movie_trailer/app/app_bootstrap.dart' show bootstrap;

void main() => bootstrap(
      kIsWeb
          ? DevFirebaseOptions.currentPlatform
          : DefaultFirebaseOptions.currentPlatform,
    );
