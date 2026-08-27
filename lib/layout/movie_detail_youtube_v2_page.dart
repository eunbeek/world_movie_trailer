import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
import 'package:world_movie_trailer/app/world_movie_trailer_app.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/layout/widgets/tmdb_credit_info.dart';
import 'package:world_movie_trailer/layout/widgets/detail_asset_icon.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieDetailPageYouTube extends StatefulWidget {
  const MovieDetailPageYouTube({
    super.key,
    required this.movie,
    required this.captionFlag,
    required this.captionLan,
    required this.isCustomized,
    this.initialShowOriginal,
    this.onShowOriginalChanged,
    this.sourceFeedCode,
    this.cIdx,
  });

  final Movie movie;
  final bool captionFlag;
  final String captionLan;
  final bool isCustomized;
  final bool? initialShowOriginal;
  final ValueChanged<bool>? onShowOriginalChanged;
  final String? sourceFeedCode;
  final int? cIdx;

  @override
  State<MovieDetailPageYouTube> createState() => _MovieDetailPageYouTubeState();
}

class _MovieDetailPageYouTubeState extends State<MovieDetailPageYouTube> {
  YoutubePlayerController? _playerController;
  bool _isBookmarked = false;
  bool _showOriginal = false;

  SettingsProvider get _settings => context.read<SettingsProvider>();

  @override
  void initState() {
    super.initState();
    _showOriginal = widget.initialShowOriginal ?? false;
    if (widget.movie.trailerUrl.isNotEmpty) {
      _playerController = YoutubePlayerController.fromVideoId(
        videoId: widget.movie.trailerUrl,
        params: YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: widget.captionFlag,
          captionLanguage: widget.captionLan,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Apply after the previous movie's player has finished disposing.
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      _checkBookmark();
    });
    LogHelper().logEvent(
      widget.movie.special?.isNotEmpty == true
          ? 'special_trailer_watched'
          : 'trailer_watched',
      parameters: {
        'movie': widget.movie.localTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void dispose() {
    _playerController?.close();
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
    final language = aliases[_settings.language] ?? _settings.language;
    final translation = widget.movie.translations[language];
    if (translation is Map && translation[field] != null) {
      final value = translation[field].toString().trim();
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
    final unique = await MovieByUserService.getIsUnique(
      widget.movie.id.isNotEmpty ? widget.movie.id : widget.movie.localTitle,
    );
    if (mounted) setState(() => _isBookmarked = !unique);
  }

  Future<void> _toggleBookmark() async {
    final movies = await MovieByUserService.getBookmarks();
    final key =
        widget.movie.id.isNotEmpty ? widget.movie.id : widget.movie.localTitle;
    final index = movies.indexWhere((item) {
      final itemKey =
          item.movie.id.isNotEmpty ? item.movie.id : item.movie.localTitle;
      return itemKey == key;
    });
    if (_isBookmarked && index >= 0) {
      await MovieByUserService.deleteMovie(index);
      _showMessage('movieDeleted');
    } else if (!_isBookmarked) {
      if (!mounted) return;
      if (!await MovieByUserService.getIsAvailable(_settings)) {
        _showMessage('maxMoviesReached');
        return;
      }
      await MovieByUserService.addMovie(
        MovieByUser(
          movie: widget.movie,
          savedDate: DateTime.now(),
          sourceFeedCode: widget.sourceFeedCode,
        ),
        _settings,
      );
      _showMessage('addToBookmark');
    }
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  void _showMessage(String key) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(getMessage(_settings.language, key)),
      duration: const Duration(milliseconds: 900),
    ));
  }

  Future<void> _translate() async {
    void toggle() {
      if (!mounted) return;
      setState(() => _showOriginal = !_showOriginal);
      widget.onShowOriginalChanged?.call(_showOriginal);
    }

    if (!kIsWeb && !_settings.canTranslate) {
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
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_showOriginal);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const BackgroundWidget(isPausePage: true, isTapeExist: true),
            SafeArea(
              child: YoutubePlayerScaffold(
                controller: _playerController ?? YoutubePlayerController(),
                defaultOrientations: const [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ],
                builder: (context, player) => Column(
                  children: [
                    _header(),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _video(player),
                            if (!widget.isCustomized) _actions(),
                            Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor),
                            _metadata(),
                            Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor),
                            _overviewSection(),
                            Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => SizedBox(
        height: 70,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(_showOriginal),
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

  Widget _video(Widget player) {
    if (_playerController == null) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Text(
              getMenuItemTitle(_settings.language, 'Trailer unavailable'),
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
        ),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: SizedBox(
          width: _detailContentWidth(constraints.maxWidth),
          child: AspectRatio(aspectRatio: 16 / 9, child: player),
        ),
      );
    });
  }

  double _detailContentWidth(double availableWidth) {
    if (!kIsWeb) return availableWidth;
    final maxByHeight = MediaQuery.sizeOf(context).height * 0.58 * 16 / 9;
    return availableWidth.clamp(0.0, maxByHeight).toDouble();
  }

  Widget _actions() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _action(
              icon: DetailAssetIcon(name: 'bookmark', active: _isBookmarked),
              label: getMenuItemTitle(_settings.language, 'Bookmark'),
              onTap: _toggleBookmark,
            ),
            const SizedBox(width: 42),
            _action(
              icon: DetailAssetIcon(name: 'translate', active: _showOriginal),
              label: getMenuItemTitle(
                _settings.language,
                _showOriginal ? 'Translate' : 'Original',
              ),
              onTap: _translate,
            ),
            const SizedBox(width: 42),
            _action(
              icon: Icon(
                !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
                    ? Icons.ios_share_outlined
                    : Icons.share_outlined,
                color: Theme.of(context).colorScheme.onSurface,
                size: 29,
              ),
              label: getSettingsLabel(_settings.language, 'share'),
              onTap: _share,
            ),
          ],
        ),
      );

  Widget _action({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              icon,
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
    Map? directorCredit;
    final originalCreditNames = <String>[];
    if (cast is List) {
      for (final item in cast) {
        final name = item is Map ? (item['name'] ?? '').toString() : '$item';
        if (name.isNotEmpty && !originalCreditNames.contains(name)) {
          originalCreditNames.add(name);
        }
      }
    }
    if (crew is List && crew.isNotEmpty) {
      final directors =
          crew.where((item) => item is Map && item['job'] == 'Director');
      final selected = directors.isNotEmpty ? directors.first : crew.first;
      if (selected is Map) {
        directorCredit = selected;
        director = (selected['name'] ?? '').toString();
      }
      for (final item in crew) {
        final name = item is Map ? (item['name'] ?? '').toString() : '$item';
        if (name.isNotEmpty && !originalCreditNames.contains(name)) {
          originalCreditNames.add(name);
        }
      }
    }
    final originalStars = cast is List
        ? cast
            .take(4)
            .map((item) => item is Map ? item['name'] : '')
            .where((name) => name.toString().isNotEmpty)
            .join(', ')
        : '';
    final localizedCredits = _localizedField('credits', originalStars);
    final localizedNames = localizedCredits
        .split(RegExp(r'[,，]'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (!_showOriginal && director.isNotEmpty) {
      final directorIndex = originalCreditNames.indexOf(director);
      if (directorIndex >= 0 && directorIndex < localizedNames.length) {
        director = localizedNames[directorIndex];
      }
    }
    final stars =
        _showOriginal ? originalStars : localizedNames.take(4).join(', ');
    final castCredits = cast is List ? cast.take(4).toList() : const [];
    final starPeople = <TmdbCreditPerson>[];
    for (var index = 0; index < castCredits.length; index++) {
      final item = castCredits[index];
      final originalName =
          item is Map ? (item['name'] ?? '').toString() : item.toString();
      final displayName = _showOriginal
          ? originalName
          : index < localizedNames.length
              ? localizedNames[index]
              : originalName;
      if (displayName.isNotEmpty) {
        starPeople.add(TmdbCreditPerson(
          name: displayName,
          tmdbId: item is Map ? item['id'] : null,
        ));
      }
    }
    if (starPeople.isEmpty && stars.isNotEmpty) {
      starPeople.addAll(
        stars
            .split(RegExp(r'[,，]'))
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .map((name) => TmdbCreditPerson(name: name)),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: kIsWeb ? 40 : 14,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment:
            kIsWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (widget.movie.special?.isNotEmpty == true)
            _info('${getTranslatedDetail('Year', lang)}',
                widget.movie.year ?? ''),
          if (director.isNotEmpty)
            TmdbCreditInfo(
              label: getTranslatedDetail('Director', lang) ?? 'Director',
              alignment: kIsWeb ? WrapAlignment.center : WrapAlignment.start,
              people: [
                TmdbCreditPerson(
                  name: director,
                  tmdbId: directorCredit?['id'],
                ),
              ],
            ),
          if (stars.isNotEmpty)
            TmdbCreditInfo(
              label: getTranslatedDetail('Stars', lang) ?? 'Stars',
              alignment: kIsWeb ? WrapAlignment.center : WrapAlignment.start,
              people: starPeople,
            ),
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
        child: Text.rich(
          TextSpan(
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 17),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(text: value),
            ],
          ),
          textAlign: kIsWeb ? TextAlign.center : TextAlign.left,
        ),
      );

  Widget _overviewSection() => LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SizedBox(
            width: _detailContentWidth(constraints.maxWidth),
            child: _overviewContent(),
          ),
        ),
      );

  Widget _overviewContent() => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 40 : 14,
          vertical: 24,
        ),
        child: Align(
          alignment: kIsWeb ? Alignment.center : Alignment.centerLeft,
          child: Text(
            _overview == 'ERR404' ? '' : _overview,
            textAlign: kIsWeb ? TextAlign.center : TextAlign.left,
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
