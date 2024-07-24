import 'package:flutter/material.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
import 'package:world_movie_trailer/common/constants.dart';

void main() {
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
