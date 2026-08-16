import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:world_movie_trailer/firebase_options_dev.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/v2/home/home_shell.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
// `flutter run -d chrome` uses this entry point. Web currently exists only in
// the V2/dev Firebase project, while native default builds retain V1/prod.
void main() => bootstrap(kIsWeb
    ? DevFirebaseOptions.currentPlatform
    : DefaultFirebaseOptions.currentPlatform);

Future<void> bootstrap(FirebaseOptions firebaseOptions) async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Draw a Flutter frame before Firebase/Hive initialization. WebKit would
  // otherwise keep showing the HTML loader forever when browser storage is
  // slow or unavailable.
  runApp(_BootstrapLoader(firebaseOptions: firebaseOptions));
}

Future<Widget> _initializeApplication(FirebaseOptions firebaseOptions) async {
  if (!kIsWeb) {
    await _runInitializationStage(
        'Firebase', () => _initializeFirebase(firebaseOptions));
  }

  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }

  await _runInitializationStage('Hive init', Hive.initFlutter);
  Hive.registerAdapter(MovieAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(QuoteAdapter());
  Hive.registerAdapter(MovieByUserAdapter());

  Box<Settings> settingsBox;
  try {
    settingsBox = await Hive.openBox<Settings>('settings');
  } catch (error) {
    if (!kIsWeb) rethrow;
    // Web storage can retain a partially written adapter record after a
    // schema change. V2 web has no legacy user data to preserve yet.
    await Hive.deleteBoxFromDisk('settings');
    settingsBox = await Hive.openBox<Settings>('settings');
  }
  // V2 intentionally starts with a clean preference record. V1 data remains
  // untouched for rollback, but is never loaded by the new application.
  final v2Settings = await _runInitializationStage(
      'Settings read', () async => settingsBox.get('app_settings_v2'));
  final legacySettings = await _runInitializationStage(
      'Legacy settings read', () async => settingsBox.get('app_settings'));
  final bool isInitialSetting = v2Settings == null;
  final Settings initSettings = v2Settings ??
      await _runInitializationStage(
          'Default settings', () async => Settings.defaultSettings());
  if (isInitialSetting) {
    // User content and UI state start clean in 2.0. Only the paid entitlement
    // survives locally; StoreKit/Play Billing remains the source of truth.
    initSettings.isAdsFree = legacySettings?.isAdsFree ?? false;
    await _runInitializationStage('Settings write',
        () => settingsBox.put('app_settings_v2', initSettings));
  }

  LogHelper();

  final alarmService = AlarmService();
  if (!kIsWeb) {
    await alarmService.initialize();
  }

  await _runInitializationStage('Date formatting', initializeDateFormatting);

  final settingsProviderInstance =
      SettingsProvider(initSettings, isInitialSetting);
  // 신규 유저일 경우 notification permission request
  if (isInitialSetting && !kIsWeb) {
    await alarmService.requestPermission(settingsProviderInstance);
  }

  bool isAdsFree = settingsProviderInstance.isAdsFree;

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => settingsProviderInstance),
    ],
    child: MyApp(
      isInitialSetting: isInitialSetting,
      isAdsFree: isAdsFree,
    ),
  );
}

Future<T> _runInitializationStage<T>(
    String stage, Future<T> Function() action) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    debugPrint('App initialization failed at $stage: $error\n$stackTrace');
    throw StateError('$stage: $error');
  }
}

class _BootstrapLoader extends StatefulWidget {
  final FirebaseOptions firebaseOptions;

  const _BootstrapLoader({required this.firebaseOptions});

  @override
  State<_BootstrapLoader> createState() => _BootstrapLoaderState();
}

class _BootstrapLoaderState extends State<_BootstrapLoader> {
  late final Future<Widget> _initialization;

  @override
  void initState() {
    super.initState();
    final initialization = _initializeApplication(widget.firebaseOptions);
    _initialization = kIsWeb
        ? initialization.timeout(const Duration(seconds: 30))
        : initialization;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasData) return snapshot.data!;
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '앱 초기화에 실패했습니다.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFB12DDB)),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _initializeFirebase(FirebaseOptions options) async {
  FirebaseApp app;
  if (Firebase.apps.isEmpty) {
    try {
      app = await Firebase.initializeApp(options: options);
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') rethrow;
      app = Firebase.app();
    }
  } else {
    app = Firebase.app();
  }

  if (app.options.projectId != options.projectId) {
    throw StateError(
      'Firebase project mismatch: expected ${options.projectId}, '
      'but ${app.options.projectId} is already initialized.',
    );
  }
}

class MyApp extends StatefulWidget {
  final bool isInitialSetting;
  final bool isAdsFree;

  const MyApp(
      {super.key, required this.isInitialSetting, required this.isAdsFree});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      if (!kIsWeb) {
        IapHelper.listenToPurchases(context);
      }

      if (!kIsWeb) {
        await initializeAlarms(settingsProvider, widget.isInitialSetting);
      }
      settingsProvider.resetOpenCount();
      _updateNewShownStatus(settingsProvider, widget.isInitialSetting);
    });
  }

  void _loadAd() async {
    if (kIsWeb) {
      setState(() {
        _isAdDismissed = true;
      });
      return;
    }
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.isAdsFree) {
      setState(() {
        _isAdDismissed = true;
      });
      return;
    }

    _appAdManager.loadAd(onAdLoaded: () {
      _showAd();
    }, onAdFailed: () {
      setState(() {
        _isAdDismissed = true;
      });
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

  void _updateNewShownStatus(
      SettingsProvider settingsProvider, bool isInitialSetting) {
    DateTime lastOpenDate = settingsProvider.lastDate;
    DateTime currentDate = DateTime.now();

    DateTime lastDateOnly =
        DateTime(lastOpenDate.year, lastOpenDate.month, lastOpenDate.day);
    DateTime currentDateOnly =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

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
        builder: (context, child) {
          return child ?? const SizedBox.shrink();
        },
        themeMode:
            settingsProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        theme: _webTransitionTheme(ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9D00C6),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          dividerColor: const Color(0xFFD8D8D8),
        )),
        darkTheme: _webTransitionTheme(ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9D00C6),
            brightness: Brightness.dark,
            surface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
          dividerColor: const Color(0xFF303030),
        )),
        debugShowCheckedModeBanner: false,
        home: _isAdDismissed
            ? const HomeShell()
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

ThemeData _webTransitionTheme(ThemeData theme) {
  if (!kIsWeb) return theme;

  return theme.copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _NoPageTransitionsBuilder(),
        TargetPlatform.iOS: _NoPageTransitionsBuilder(),
        TargetPlatform.macOS: _NoPageTransitionsBuilder(),
        TargetPlatform.windows: _NoPageTransitionsBuilder(),
        TargetPlatform.linux: _NoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: _NoPageTransitionsBuilder(),
      },
    ),
  );
}

class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

Future<void> initializeAlarms(
    SettingsProvider settingsProvider, bool isInitialSetting) async {
  // new user
  if (isInitialSetting) {
    await AlarmService().registerDailyAlarms(settingsProvider);
  }

  // Reset or verify existing alarm states
  final currentAlarms = settingsProvider.isAlarmOn;
  bool hasBox =
      currentAlarms.values.any((alarmMap) => alarmMap.containsKey('box'));
  bool hasChinaOnThurs = currentAlarms[4]?.containsKey('china') == true;

  // existing user(only 1 time run)
  if (currentAlarms.isEmpty) {
    settingsProvider.resetAlarms();
    await AlarmService().registerDailyAlarms(settingsProvider);
    await AlarmService().registerReleaseAlarmsFromList(settingsProvider, true);
    await AlarmService().registerReleaseAlarmsFromList(settingsProvider, false);
  } else if (!hasBox) {
    // Save the updated settings
    settingsProvider.addAlarmForBoxOffice();
  }

  if (hasChinaOnThurs) {
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
  if (currentSettings != null &&
      (currentSettings.userId == null || currentSettings.userId!.isEmpty)) {
    var uuid = Uuid();
    String newUserId = uuid.v4(); // 새 UUID 생성

    currentSettings.userId = newUserId; // userId 업데이트
    settingsBox.put('app_settings', currentSettings); // 변경된 설정을 Hive에 저장

    print("Generated new userId: $newUserId");
  }
}
