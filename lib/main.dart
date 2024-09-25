import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_interstitial_ad_manager.dart';
import 'package:world_movie_trailer/common/background.dart';

import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
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
      child: MyApp(isInitialSetting: isInitialSetting),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isInitialSetting;

  MyApp({required this.isInitialSetting});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DateTime _startTime;
  late RewardedInterstitialAdManager _appAdManager;
  bool _isAdDismissed = false;

  @override
  void initState() {
    super.initState();
    _appAdManager = RewardedInterstitialAdManager();
    if(widget.isInitialSetting){
      _isAdDismissed = true;
    } else {
      _loadAd();
    }

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async => _recordStartTime(),
      suspendingCallBack: () async => _saveUsageTime(),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {;
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      bool currentQuote = settingsProvider.isQuotes;
      settingsProvider.updateIsQuotes(!currentQuote);
    });
    if(_appAdManager.isShowingAd) _showAd();
  }

  void _recordStartTime() {
    print('recordStartTIme');
    _startTime = DateTime.now();
  }

  void _saveUsageTime() {
    print('saveUsageTime');
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final endTime = DateTime.now();
    
    // Calculate usage time in seconds
    final usageSeconds = endTime.difference(_startTime).inSeconds;
    
    // Convert the usage time to minutes as a double
    final usageMinutes = usageSeconds / 60;
    
    // Save the total usage time in minutes as a double
    settingsProvider.updateTotalHours(usageMinutes);
  }

  void _loadAd() {
    _appAdManager.loadAd(onAdLoaded: () {
      _showAd(); 
    });
  }

  void _showAd() {
    print('showAd');
    _appAdManager.showAdIfAvailable(() {
      setState(() {
        _isAdDismissed = true;
      });
    });
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
          ? const CountryListPage()
          :  Scaffold(
              body: Stack(
                children: [
                  BackgroundWidget(isPausePage: false,),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/deco_film_reel_02_DT_xxhdpi.png', 
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            strokeWidth: 5.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
