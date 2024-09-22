import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // adMob
  MobileAds.instance.initialize(); 

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(QuoteAdapter());

  // Open the settings box
  var settingsBox = await Hive.openBox<Settings>('settings');

  // Load initial settings or default settings if not present
  Settings initSettings = settingsBox.get('app_settings') ?? Settings.defaultSettings();
  bool isInitialSetting = settingsBox.get('app_settings') == null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(initSettings, isInitialSetting),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    
    // 앱이 시작되거나 포그라운드로 전환될 때 시작 시간을 기록
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async => _recordStartTime(),
      suspendingCallBack: () async => _saveUsageTime(),
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      bool currentQuote = settingsProvider.isQuotes;
      settingsProvider.updateIsQuotes(!currentQuote);
    });
  }

  // 앱이 포그라운드로 돌아왔을 때 시작 시간 기록
  void _recordStartTime() {
    _startTime = DateTime.now();
  }

  // 앱이 백그라운드로 전환될 때 사용 시간 저장
  void _saveUsageTime() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final endTime = DateTime.now();
    
    // 사용 시간을 계산 (초 단위로 변환 후 시간으로 저장)
    final usageSeconds = endTime.difference(_startTime).inSeconds;
    final usageHours = usageSeconds / 3600;
    
    // 사용 시간을 누적하여 저장
    settingsProvider.updateTotalHours(usageHours.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: MaterialApp(
        title: appTitle,
        themeMode: settingsProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const CountryListPage(),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? resumeCallBack;
  final Future<void> Function()? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      resumeCallBack?.call();
    } else if (state == AppLifecycleState.paused) {
      suspendingCallBack?.call();
    }
  }
}
