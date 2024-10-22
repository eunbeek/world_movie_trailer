import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_ad_manager.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

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
      _isAdDismissed = true;
    } else {
      _loadAd();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.resetOpenCount();
      settingsProvider.updateIsQuotes(!settingsProvider.isQuotes);
      _updateNewShownStatus(settingsProvider);
    });
  }

  void _loadAd() async {
    _appAdManager.loadAd(onAdLoaded: () {
      _showAd();
    });
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
    int gap = currentDate.difference(lastOpenDate).inDays;

    settingsProvider.updateLastDate(currentDate);

    if (gap >= 7) {
      for (int i = 0; i < 7; i++) {
        settingsProvider.markIsNewShown(i);
      }
    } else {
      for (int i = 1; i <= gap; i++) {
        DateTime dateToUpdate = lastOpenDate.add(Duration(days: i));
        int dayIndex = (dateToUpdate.weekday - 1) % 7;
        settingsProvider.markIsNewShown(dayIndex);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // 앱이 백그라운드에서 복귀할 때 필요한 작업 수행
      if (_appAdManager.isShowingAd) {
        _loadAd();
      }
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 전환될 때 필요한 작업 수행
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
