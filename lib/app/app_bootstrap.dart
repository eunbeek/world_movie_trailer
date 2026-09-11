import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/app/legacy_purchase_migration.dart';
import 'package:world_movie_trailer/app/world_movie_trailer_app.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/ad_manager/rewarded_translation_ad_manager.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/alarm_service.dart';
import 'package:world_movie_trailer/common/system_ui.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/model/settings.dart';
import 'package:world_movie_trailer/layout/widgets/movie_loading_indicator.dart';

const _obsoleteHiveBoxes = [
  'settings',
  'settings_v3',
  'bookmarks_v3',
  'moviesBoxV2',
  'quotesBox',
  'movieByUserBoxForBookmarkV2',
  'movieByUserBoxForMemoV2',
  'movieByUserBoxForBookmark',
  'movieByUserBoxForMemo',
];
const _onboardingBoxName = 'onboarding_state';
// Shown once for a fresh v2 install or an upgrade from v1. Keep this key for
// every 2.x release so ordinary v2 updates do not show onboarding again.
const _onboardingCompletedKey = 'v2_completed';

Future<void> bootstrap(FirebaseOptions firebaseOptions) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isAndroidApp) {
    await hideAndroidNavigationBar();
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(_BootstrapLoader(firebaseOptions: firebaseOptions));
}

class _BootstrapLoader extends StatefulWidget {
  const _BootstrapLoader({required this.firebaseOptions});

  final FirebaseOptions firebaseOptions;

  @override
  State<_BootstrapLoader> createState() => _BootstrapLoaderState();
}

class _BootstrapLoaderState extends State<_BootstrapLoader> {
  late final Future<Widget> _initialization =
      _initializeApplication(widget.firebaseOptions);

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasData) return snapshot.data!;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  const BackgroundWidget(
                    isPausePage: false,
                    isTapeExist: true,
                  ),
                  Center(
                    child: snapshot.hasError
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              '앱 초기화에 실패했습니다.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const MovieLoadingIndicator(),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

Future<Widget> _initializeApplication(FirebaseOptions options) async {
  if (!kIsWeb) {
    await _runStage('Firebase', () => _initializeFirebase(options));
    await MobileAds.instance.initialize();
    unawaited(RewardedTranslationAdManager.preload());
  }

  await _runStage('Hive', Hive.initFlutter);
  final legacyPurchase = await LegacyPurchaseMigration.read();
  _registerHiveAdapters(
    overrideLegacySettingsAdapter: legacyPurchase.registeredLegacyAdapter,
  );
  await Future.wait(_obsoleteHiveBoxes.map(Hive.deleteBoxFromDisk));

  final settingsBox = await _openSettingsBox();
  final storedSettings = settingsBox.get(SettingsProvider.settingsKey);
  final isFirstLaunch = storedSettings == null;
  final settings = storedSettings ?? Settings.defaultSettings();
  if (isFirstLaunch && legacyPurchase.isAdsFree) {
    settings.isAdsFree = true;
  }
  if (isFirstLaunch) {
    await settingsBox.put(SettingsProvider.settingsKey, settings);
  }

  final settingsProvider = SettingsProvider(settings);
  final onboardingBox = await Hive.openBox<bool>(_onboardingBoxName);
  final showOnboarding = onboardingBox.get(_onboardingCompletedKey) != true;
  settingsProvider.refreshContentUpdateIndicators();
  await _initializeNativeNotifications(settingsProvider, isFirstLaunch);
  await _runStage('Date formatting', initializeDateFormatting);
  LogHelper().setUserId(settingsProvider.userId);

  return ChangeNotifierProvider.value(
    value: settingsProvider,
    child: WorldMovieTrailerApp(
      isFirstLaunch: isFirstLaunch,
      showOnboarding: showOnboarding,
      onOnboardingComplete: () =>
          onboardingBox.put(_onboardingCompletedKey, true),
    ),
  );
}

void _registerHiveAdapters({required bool overrideLegacySettingsAdapter}) {
  Hive
    ..registerAdapter(MovieAdapter())
    ..registerAdapter(
      SettingsAdapter(),
      override: overrideLegacySettingsAdapter,
    )
    ..registerAdapter(QuoteAdapter())
    ..registerAdapter(MovieByUserAdapter());
}

Future<Box<Settings>> _openSettingsBox() async {
  try {
    return await Hive.openBox<Settings>(SettingsProvider.boxName);
  } catch (_) {
    await Hive.deleteBoxFromDisk(SettingsProvider.boxName);
    return Hive.openBox<Settings>(SettingsProvider.boxName);
  }
}

Future<void> _initializeNativeNotifications(
  SettingsProvider settings,
  bool isFirstLaunch,
) async {
  if (kIsWeb) return;
  final alarms = AlarmService();
  await alarms.initialize();
  await alarms.cancelAllAlarms();
  if (isFirstLaunch) {
    await alarms.requestPermission(settings);
  }
  if (settings.isDailyAlarmOn) {
    await alarms.registerDailyAlarms(settings);
    if (settings.isBookmarkAlarmOn) {
      await alarms.registerReleaseAlarmsFromList(settings);
    }
  }
}

Future<void> _initializeFirebase(FirebaseOptions options) async {
  final app = Firebase.apps.isEmpty
      ? await Firebase.initializeApp(options: options)
      : Firebase.app();
  if (app.options.projectId != options.projectId) {
    throw StateError(
      'Firebase project mismatch: expected ${options.projectId}, '
      'but ${app.options.projectId} is already initialized.',
    );
  }
}

Future<T> _runStage<T>(String name, Future<T> Function() action) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    debugPrint('App initialization failed at $name: $error\n$stackTrace');
    throw StateError('$name: $error');
  }
}
