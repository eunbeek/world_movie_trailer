import 'package:hive/hive.dart';

part 'settings.g.dart'; // This is needed for the generated code

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  String language;

  @HiveField(1)
  String theme;

  @HiveField(2)
  List<String> countryOrder;

  Settings({required this.language, required this.theme, required this.countryOrder});

  // Factory constructor to create default settings
  factory Settings.defaultSettings() {
    return Settings(
      language: 'ko',
      theme: 'dark',
      // countryOrder: ['U.S.A', 'South Korea', 'Japan', 'France', 'Taiwan', 'Germany', 'Canada' ],
      countryOrder: ['usa', 'korea', 'japan', 'france', 'taiwan', 'germany', 'canada' ],
    );
  }
}
