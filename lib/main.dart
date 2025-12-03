import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';
import 'package:world_movie_trailer/common/ad_manager/interstitial_ad_manager.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/common/services/in_app_purchase_service.dart';
import 'package:world_movie_trailer/firebase_options.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  bool hasBox =  initSettings.countryOrder.contains('box');

  //temporary for box
  if (!hasBox) {
    // Add 'box' to day 1
    initSettings.countryOrder.insert(0, 'box');

    // Save the updated settings
    settingsBox.put('app_settings', initSettings);
  }

  // Move 'china' from Thursday (3) to Friday (4) if present
  if (initSettings.isNewShown[3]?.containsKey('china') == true) {
    final thursday = initSettings.isNewShown[3]!;
    final friday = initSettings.isNewShown[4] ?? {};

    // 복사 후 삭제
    friday['china'] = thursday['china']!;
    thursday.remove('china');

    // 변경사항 반영
    initSettings.isNewShown[3] = thursday;
    initSettings.isNewShown[4] = friday;
  }

  if (!isInitialSetting) {
    updateUserIdIfNeeded();  // 기존 사용자라면 userId를 새로 생성하여 저장
  }

  LogHelper();

  final alarmService = AlarmService();
  await alarmService.initialize();
  
  await initializeDateFormatting();

  final settingsProviderInstance = SettingsProvider(initSettings, isInitialSetting);
  // 신규 유저일 경우 notification permission request
  if(isInitialSetting){
    await alarmService.requestPermission(settingsProviderInstance);
  }

  bool isAdsFree = settingsProviderInstance.isAdsFree;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProviderInstance),
      ],
      child: MyApp(
        isInitialSetting: isInitialSetting,
        isAdsFree: isAdsFree,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isInitialSetting;
  final bool isAdsFree;

  const MyApp({super.key, required this.isInitialSetting, required this.isAdsFree});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin, WidgetsBindingObserver {
  late InterstitialAdManager _appAdManager;
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

    _appAdManager = InterstitialAdManager();
    if (widget.isInitialSetting) {
      LogHelper().logEvent('new_user_installed');
      _isAdDismissed = true;
    } else {
      _loadAd();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      IapHelper.listenToPurchases(context);

      await initializeAlarms(settingsProvider, widget.isInitialSetting);
      settingsProvider.resetOpenCount();
      settingsProvider.updateIsQuotes(!settingsProvider.isQuotes);
      _updateNewShownStatus(settingsProvider, widget.isInitialSetting);
    });
  }

  void _loadAd() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settingsProvider.isAdsFree) {
      setState(() {
        _isAdDismissed = true;
      });
      return;
    }

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

  void _updateNewShownStatus(SettingsProvider settingsProvider, bool isInitialSetting) {
    DateTime lastOpenDate = settingsProvider.lastDate;
    DateTime currentDate = DateTime.now();

    DateTime lastDateOnly = DateTime(lastOpenDate.year, lastOpenDate.month, lastOpenDate.day);
    DateTime currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int gap = currentDateOnly.difference(lastDateOnly).inDays;

    settingsProvider.updateLastDate(currentDate);

    if (isInitialSetting) {
      // 동일 날짜라면 현재 날짜만 업데이트
      int dayIndex = (currentDateOnly.weekday - 1) % 7;
      settingsProvider.markIsNewShown(dayIndex);
    } else if (gap > 6) {
      // 7일 이상 gap이 있는 경우 모든 국가를 표시로 설정
      settingsProvider.markAllIsNewShown();
    } else {
      // gap에 해당하는 날짜만 업데이트
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
                    BackgroundWidget(isPausePage: false, isTapeExist: true),
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

Future<void> initializeAlarms(SettingsProvider settingsProvider, bool isInitialSetting) async {

  // new user
  if(isInitialSetting){
    await AlarmService().registerDailyAlarms(settingsProvider);
  }

  // Reset or verify existing alarm states
  final currentAlarms = settingsProvider.isAlarmOn;
  bool hasBox = currentAlarms.values.any((alarmMap) => alarmMap.containsKey('box'));
  bool hasChinaOnThurs = currentAlarms[4]?.containsKey('china') == true;

  // existing user(only 1 time run)
  if(currentAlarms.isEmpty){
    settingsProvider.resetAlarms();
    await AlarmService().registerDailyAlarms(settingsProvider);
    await AlarmService().registerReleaseAlarmsFromList(settingsProvider, true);
    await AlarmService().registerReleaseAlarmsFromList(settingsProvider, false);
  } else if (!hasBox) {
    // Save the updated settings
    settingsProvider.addAlarmForBoxOffice();
  }

  if(hasChinaOnThurs) {
    final wednesday = currentAlarms[4]!;
    final thursday = currentAlarms[5] ?? {};

    thursday['china'] = wednesday['china']!;
    wednesday.remove('china');

    currentAlarms[4] = wednesday;
    currentAlarms[5] = thursday;

    settingsProvider.resetAlarms();
    await AlarmService().registerDailyAlarms(settingsProvider);
    await AlarmService().registerReleaseAlarmsFromList(settingsProvider, true);
    await AlarmService().registerReleaseAlarmsFromList(settingsProvider, false);
  }
}

void updateUserIdIfNeeded() async {
  var settingsBox = await Hive.openBox<Settings>('settings');
  Settings? currentSettings = settingsBox.get('app_settings');
  
  // If userId is empty, generate a new one
  if (currentSettings != null && (currentSettings.userId == null || currentSettings.userId!.isEmpty)) {
    var uuid = Uuid();
    String newUserId = uuid.v4(); // 새 UUID 생성

    currentSettings.userId = newUserId; // userId 업데이트
    settingsBox.put('app_settings', currentSettings); // 변경된 설정을 Hive에 저장

    print("Generated new userId: $newUserId");
  }
}