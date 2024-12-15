import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_ad_manager.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
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

  MobileAds.instance.initialize();

  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(QuoteAdapter());
  Hive.registerAdapter(MovieByUserAdapter());

  var settingsBox = await Hive.openBox<Settings>('settings');
  Settings initSettings = settingsBox.get('app_settings') ?? Settings.defaultSettings();
  bool isInitialSetting = settingsBox.get('app_settings') == null;

  LogHelper();

  final alarmService = AlarmService(); // `main`에서 생성
  await alarmService.initialize();
  await alarmService.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(initSettings, isInitialSetting),
        ),
      ],
      child: MyApp(isInitialSetting: isInitialSetting),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isInitialSetting;

  const MyApp({super.key, required this.isInitialSetting});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin, WidgetsBindingObserver {
  late RewardedAdManager _appAdManager;
  bool _isAdDismissed = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _appAdManager = RewardedAdManager();
    if (widget.isInitialSetting) {
      LogHelper().logEvent('new_user_installed');
      _isAdDismissed = true;
    } else {
      _loadAd();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await initializeAlarms(settingsProvider);
      settingsProvider.resetOpenCount();
      settingsProvider.updateIsQuotes(!settingsProvider.isQuotes);
      _updateNewShownStatus(settingsProvider);
    });
  }

  void _loadAd() async {
    _appAdManager.loadAd(
      onAdLoaded: () {
        _showAd();
      },
      onAdFailed: () {
        setState(() {
          _isAdDismissed = true;
        });
      }
    );
  }

  void _showAd() {
    setState(() {
      _isAdDismissed = false;
    });

    _appAdManager.showAdIfAvailable(() {
      setState(() {
        _isAdDismissed = true;
      });
    });
  }

  void _updateNewShownStatus(SettingsProvider settingsProvider) {
    DateTime lastOpenDate = settingsProvider.lastDate;
    DateTime currentDate = DateTime.now();

    DateTime lastDateOnly = DateTime(lastOpenDate.year, lastOpenDate.month, lastOpenDate.day);
    DateTime currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int gap = currentDateOnly.difference(lastDateOnly).inDays;

    settingsProvider.updateLastDate(currentDate);

    if (gap > 6) {
      settingsProvider.markAllIsNewShown();
    } else {
      for (int i = 1; i <= gap; i++) {
        DateTime dateToUpdate = lastOpenDate.add(Duration(days: i));
        int dayIndex = (dateToUpdate.weekday - 1) % 7;
        settingsProvider.markIsNewShown(dayIndex);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: MaterialApp(
        title: appTitle,
        scaffoldMessengerKey: scaffoldMessengerKey,
        themeMode: settingsProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: _isAdDismissed
            ? CountryListPage(isInit: widget.isInitialSetting)
            : Scaffold(
                body: Stack(
                  children: [
                    BackgroundWidget(isPausePage: false),
                    Center(
                      child: RotationTransition(
                        turns: _controller,
                        child: Image.asset(
                          settingsProvider.isDarkTheme
                              ? 'assets/images/dark/loading_DT_xxhdpi.png'
                              : 'assets/images/light/loading_LT_xxhdpi.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Future<void> initializeAlarms(SettingsProvider settingsProvider) async {
  if (settingsProvider.isAlarmOnByDay.isEmpty) {
    settingsProvider.resetAlarms(); // 알람 상태를 초기화
    await AlarmService().registerDailyAlarms(settingsProvider); // 알람 등록
  } else {
    // 기존 알람 상태에 따라 알람 재등록
    await AlarmService().registerDailyAlarms(settingsProvider);
  }
}
