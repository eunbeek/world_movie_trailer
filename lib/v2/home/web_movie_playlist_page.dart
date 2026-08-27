import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/model/movie.dart';

class WebMoviePlaylistPage extends StatefulWidget {
  const WebMoviePlaylistPage({
    super.key,
    required this.movies,
    required this.sourceFeedCodes,
    required this.initialShowOriginal,
  });

  final List<Movie> movies;
  final List<String?> sourceFeedCodes;
  final bool initialShowOriginal;

  @override
  State<WebMoviePlaylistPage> createState() => _WebMoviePlaylistPageState();
}

class _WebMoviePlaylistPageState extends State<WebMoviePlaylistPage> {
  int _index = 0;
  bool _completed = false;
  bool _transitioning = false;
  late bool _showOriginal = widget.initialShowOriginal;

  void _next() {
    if (!mounted || _transitioning || _completed) return;
    _transitioning = true;
    if (_index < widget.movies.length - 1) {
      setState(() => _index++);
    } else {
      setState(() => _completed = true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transitioning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final progress = _completed
        ? _completedLabels[settings.language] ?? _completedLabels['en']!
        : '${_playingLabels[settings.language] ?? _playingLabels['en']!} '
            '${_index + 1} / ${widget.movies.length}';
    return KeyedSubtree(
      key: ValueKey(_index),
      child: MovieDetailPageYouTube(
        movie: widget.movies[_index],
        captionFlag: settings.isCaptionOn,
        captionLan: settings.language,
        isCustomized: false,
        initialShowOriginal: _showOriginal,
        onShowOriginalChanged: (value) {
          _showOriginal = value;
          settings.updateTranslatedContentPreference(!value);
        },
        sourceFeedCode: widget.sourceFeedCodes[_index],
        autoPlay: true,
        onPlaybackEnded: _completed ? null : _next,
        playbackProgressLabel: progress,
        onPlaybackProgressTap: _completed ? null : _next,
      ),
    );
  }
}

const _playingLabels = <String, String>{
  'ko': '재생 중',
  'en': 'Playing',
  'ja': '再生中',
  'zh': '播放中',
  'tw': '播放中',
  'fr': 'Lecture',
  'de': 'Wiedergabe',
  'es': 'Reproduciendo',
  'hi': 'चल रहा है',
  'th': 'กำลังเล่น',
};

const _completedLabels = <String, String>{
  'ko': '재생 완료',
  'en': 'Completed',
  'ja': '再生完了',
  'zh': '播放完成',
  'tw': '播放完成',
  'fr': 'Terminé',
  'de': 'Abgeschlossen',
  'es': 'Completado',
  'hi': 'पूर्ण',
  'th': 'เล่นจบแล้ว',
};
