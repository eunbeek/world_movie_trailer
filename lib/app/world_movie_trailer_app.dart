import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/in_app_purchase_service.dart';
import 'package:world_movie_trailer/v2/home/home_shell.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class WorldMovieTrailerApp extends StatefulWidget {
  const WorldMovieTrailerApp({super.key, required this.isFirstLaunch});

  final bool isFirstLaunch;

  @override
  State<WorldMovieTrailerApp> createState() => _WorldMovieTrailerAppState();
}

class _WorldMovieTrailerAppState extends State<WorldMovieTrailerApp> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: appTitle,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const HomeShell(),
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
