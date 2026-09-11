import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/in_app_purchase_service.dart';
import 'package:world_movie_trailer/common/system_ui.dart';
import 'package:world_movie_trailer/layout/widgets/movie_loading_indicator.dart';
import 'package:world_movie_trailer/v2/home/home_shell.dart';
import 'package:world_movie_trailer/v2/home/widgets/main_text_scale_cap.dart';
import 'package:world_movie_trailer/v2/onboarding/onboarding_page.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class WorldMovieTrailerApp extends StatefulWidget {
  const WorldMovieTrailerApp({
    super.key,
    required this.isFirstLaunch,
    required this.showOnboarding,
    required this.onOnboardingComplete,
  });

  final bool isFirstLaunch;
  final bool showOnboarding;
  final Future<void> Function() onOnboardingComplete;

  @override
  State<WorldMovieTrailerApp> createState() => _WorldMovieTrailerAppState();
}

class _WorldMovieTrailerAppState extends State<WorldMovieTrailerApp>
    with WidgetsBindingObserver {
  late bool _showOnboarding;
  late bool _homeReady;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !kIsWeb && widget.showOnboarding;
    _homeReady = kIsWeb || _showOnboarding;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => hideAndroidNavigationBar(),
    );
    if (widget.isFirstLaunch) {
      LogHelper().logEvent('new_user_installed');
    }
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => IapHelper.listenToPurchases(context),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) hideAndroidNavigationBar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _markHomeReady() {
    if (!_homeReady && mounted) setState(() => _homeReady = true);
  }

  Future<void> _completeOnboarding() async {
    await widget.onOnboardingComplete();
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
      _homeReady = kIsWeb;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: appTitle,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (context, child) => MainTextScaleCap(
        child: Stack(
          fit: StackFit.expand,
          children: [
            child ?? const SizedBox.shrink(),
            if (!_homeReady)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BackgroundWidget(
                        isPausePage: false,
                        isTapeExist: true,
                      ),
                      Center(child: MovieLoadingIndicator()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      home: _showOnboarding
          ? OnboardingPage(
              language: settings.language,
              onComplete: _completeOnboarding,
            )
          : HomeShell(onInitialLoadComplete: _markHomeReady),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final theme = ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9D00C6),
      brightness: brightness,
      surface: dark ? Colors.black : null,
    ),
    scaffoldBackgroundColor: dark ? Colors.black : const Color(0xFFFAFAFA),
    dividerColor: dark ? const Color(0xFF303030) : const Color(0xFFD8D8D8),
  );
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
  ) =>
      child;
}
