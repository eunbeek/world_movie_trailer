import 'dart:io';

import 'package:flutter/material.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:world_movie_trailer/common/premium_translation_prompt.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/common/translation_access.dart';
import 'package:world_movie_trailer/app/world_movie_trailer_app.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailPageYouTube extends StatefulWidget {
  const MovieDetailPageYouTube({
    super.key,
    required this.movie,
    required this.captionFlag,
    required this.captionLan,
    required this.isCustomized,
    this.initialShowOriginal = false,
    this.cIdx,
  });

  final Movie movie;
  final bool captionFlag;
  final String captionLan;
  final bool isCustomized;
  final bool initialShowOriginal;
  final int? cIdx;

  @override
  State<MovieDetailPageYouTube> createState() => _MovieDetailPageYouTubeState();
}

class _MovieDetailPageYouTubeState extends State<MovieDetailPageYouTube> {
  YoutubePlayerController? _controller;
  bool _isBookmarked = false;
  bool _showOriginal = false;

  SettingsProvider get _settings => context.read<SettingsProvider>();

  @override
  void initState() {
    super.initState();
    _showOriginal = widget.initialShowOriginal ||
        !TranslationAccess.defaultToTranslation(isPremium: _settings.isAdsFree);
    if (widget.movie.trailerUrl.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.movie.trailerUrl,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          enableCaption: widget.captionFlag,
          captionLanguage: widget.captionLan,
          useHybridComposition: false,
        ),
      );
    }
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBookmark();
    });
    LogHelper().logEvent('trailer_watched', parameters: {
      'movie': widget.movie.localTitle,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String _localizedField(String field, String fallback) {
    if (_showOriginal) {
      return (widget.movie.originSource[field] ?? fallback).toString();
    }
    const aliases = {'zh': 'cn', 'hi': 'in'};
    final key = aliases[_settings.language] ?? _settings.language;
    final translation = widget.movie.translations[key];
    if (translation is Map) {
      final value = (translation[field] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String get _title => _localizedField('title', widget.movie.localTitle);
  String get _overview => _localizedField('overview', widget.movie.spec);
  String get _country {
    final value = _localizedField('country', widget.movie.country).trim();
    return RegExp(r'^[A-Za-z]{2}$').hasMatch(value)
        ? convertCountryCodeToName(value)
        : value;
  }

  Future<void> _checkBookmark() async {
    final key =
        widget.movie.id.isNotEmpty ? widget.movie.id : widget.movie.localTitle;
    final unique = await MovieByUserService.getIsUnique(key);
    if (mounted) setState(() => _isBookmarked = !unique);
  }

  Future<void> _toggleBookmark() async {
    final items = await MovieByUserService.getBookmarks();
    final key =
        widget.movie.id.isNotEmpty ? widget.movie.id : widget.movie.localTitle;
    final index = items.indexWhere((item) {
      final storedKey =
          item.movie.id.isNotEmpty ? item.movie.id : item.movie.localTitle;
      return storedKey == key;
    });
    if (_isBookmarked && index >= 0) {
      await MovieByUserService.deleteMovie(index);
      _message('movieDeleted');
    } else if (!_isBookmarked) {
      if (!await MovieByUserService.getIsAvailable(_settings)) {
        _message('maxMoviesReached');
        return;
      }
      await MovieByUserService.addMovie(
        MovieByUser(movie: widget.movie, savedDate: DateTime.now()),
        _settings,
      );
      _message('addToBookmark');
    }
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  void _message(String key) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(getMessage(_settings.language, key)),
      duration: const Duration(milliseconds: 900),
    ));
  }

  Future<void> _translate() async {
    void toggle() {
      if (mounted) setState(() => _showOriginal = !_showOriginal);
    }

    if (!_settings.canTranslate) {
      final granted =
          await showPremiumTranslationPrompt(context, _settings.language);
      if (!granted) return;
    }
    toggle();
  }

  void _share() {
    Share.share(
      'https://www.youtube.com/watch?v=${widget.movie.trailerUrl}',
      subject: 'Share $_title Movie Trailer',
      sharePositionOrigin: Rect.fromLTWH(
        0,
        0,
        MediaQuery.sizeOf(context).width,
        MediaQuery.sizeOf(context).height / 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return _page(SizedBox(
        height: 240,
        child: Center(
          child: Text('Trailer is not available',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
        ),
      ));
    }
    final player = YoutubePlayer(
      controller: _controller!,
      aspectRatio: 16 / 9,
    );
    return YoutubePlayerBuilder(
      player: player,
      builder: (context, builtPlayer) => _page(builtPlayer),
    );
  }

  Widget _page(Widget player) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const BackgroundWidget(isPausePage: true, isTapeExist: true),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          player,
                          if (!widget.isCustomized) _actions(),
                          Divider(
                              height: 1, color: Theme.of(context).dividerColor),
                          _metadata(),
                          Divider(
                              height: 1, color: Theme.of(context).dividerColor),
                          _overviewSection(),
                          Divider(
                              height: 1, color: Theme.of(context).dividerColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _header() => SizedBox(
        height: 70,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            Expanded(
              child: Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      );

  Widget _actions() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _action(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
              getMenuItemTitle(_settings.language, 'Bookmark'),
              _toggleBookmark,
            ),
            const SizedBox(width: 34),
            _action(
              Icons.translate,
              _showOriginal
                  ? (_settings.language == 'ko' ? '번역' : 'Translate')
                  : (_settings.language == 'ko' ? '원본' : 'Original'),
              _translate,
            ),
            const SizedBox(width: 34),
            _action(
              Platform.isIOS ? Icons.ios_share_outlined : Icons.share_outlined,
              getSettingsLabel(_settings.language, 'share'),
              _share,
            ),
          ],
        ),
      );

  Widget _action(IconData icon, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 74,
          child: Column(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.onSurface, size: 29),
              const SizedBox(height: 7),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _metadata() {
    final lang = _settings.language;
    final crew = widget.movie.credits?['crew'];
    final cast = widget.movie.credits?['cast'];
    String director = '';
    if (crew is List && crew.isNotEmpty) {
      final directors =
          crew.where((item) => item is Map && item['job'] == 'Director');
      final selected = directors.isNotEmpty ? directors.first : crew.first;
      if (selected is Map) director = (selected['name'] ?? '').toString();
    }
    final stars = cast is List
        ? cast
            .take(4)
            .map((item) => item is Map ? item['name'] : '')
            .where((name) => name.toString().isNotEmpty)
            .join(', ')
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (director.isNotEmpty)
            _info('${getTranslatedDetail('Director', lang)}', director),
          if (stars.isNotEmpty)
            _info('${getTranslatedDetail('Stars', lang)}', stars),
          if (_country.isNotEmpty)
            _info('${getTranslatedDetail('Country', lang)}', _country),
          if (widget.movie.runtime.toString().isNotEmpty)
            _info('${getTranslatedDetail('Running Time', lang)}',
                '${widget.movie.runtime} ${getTranslatedDetail('Minute', lang)}'),
        ],
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text.rich(TextSpan(
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 17),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: value),
          ],
        )),
      );

  Widget _overviewSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _overview == 'ERR404' ? '' : _overview,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontSize: 17,
              height: 1.5,
            ),
          ),
        ),
      );
}
