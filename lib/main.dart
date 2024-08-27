import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/model/movie.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  // Register the Movie adapter
  Hive.registerAdapter(MovieAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountryListPage(),
    );
  }
}
