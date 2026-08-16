import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/common/services/movie_service.dart';
import 'package:world_movie_trailer/common/services/quote_service.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/layout/settings_page.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';

enum _BookmarkSort { recent, title, releaseDate }

const _bookmarkLabels = <String, Map<String, String>>{
  'en': {
    'title': 'Bookmarks',
    'countSuffix': '',
    'searchHint': 'Search bookmarks by title, people, or country...',
    'recent': 'Newest',
    'titleSort': 'Title',
    'releaseSort': 'Release date',
    'emptyTitle': 'No bookmarked movies yet.',
    'emptyDescription': 'Tap the bookmark icon on a movie to save it here.',
    'noResults': 'No bookmarks found.',
    'tryAgain': 'Try another search term.',
  },
  'ko': {
    'title': '북마크',
    'countSuffix': '편',
    'searchHint': '제목, 감독, 배우, 국가로 북마크 검색...',
    'recent': '최신순',
    'titleSort': '제목순',
    'releaseSort': '개봉일순',
    'emptyTitle': '북마크한 영화가 아직 없습니다.',
    'emptyDescription': '영화 목록에서 북마크를 눌러 저장하세요.',
    'noResults': '검색 결과가 없습니다.',
    'tryAgain': '다른 검색어를 입력해 보세요.',
  },
  'ja': {
    'title': 'お気に入り',
    'countSuffix': '件',
    'searchHint': 'タイトル、人物、国で検索...',
    'recent': '新しい順',
    'titleSort': 'タイトル順',
    'releaseSort': '公開日順',
    'emptyTitle': 'お気に入りの映画はまだありません。',
    'emptyDescription': '映画のブックマークをタップして保存してください。',
    'noResults': '検索結果がありません。',
    'tryAgain': '別のキーワードをお試しください。',
  },
  'zh': {
    'title': '书签',
    'countSuffix': '部',
    'searchHint': '按标题、人物或国家搜索...',
    'recent': '最新',
    'titleSort': '标题',
    'releaseSort': '上映日期',
    'emptyTitle': '还没有收藏的电影。',
    'emptyDescription': '点击电影的书签图标即可保存。',
    'noResults': '没有搜索结果。',
    'tryAgain': '请尝试其他关键词。',
  },
  'tw': {
    'title': '書籤',
    'countSuffix': '部',
    'searchHint': '依標題、人物或國家搜尋...',
    'recent': '最新',
    'titleSort': '標題',
    'releaseSort': '上映日期',
    'emptyTitle': '尚無收藏的電影。',
    'emptyDescription': '點選電影的書籤圖示即可儲存。',
    'noResults': '找不到搜尋結果。',
    'tryAgain': '請嘗試其他關鍵字。',
  },
};

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _defaultCountryByLanguage = <String, String>{
    'en': 'us',
    'ko': 'kr',
    'ja': 'jp',
    'zh': 'cn',
    'tw': 'tw',
    'fr': 'fr',
    'de': 'de',
    'es': 'es',
    'hi': 'in',
    'th': 'th',
  };
  static const _countryKeys = <String, String>{
    'us': 'usa',
    'kr': 'korea',
    'jp': 'japan',
    'tw': 'taiwan',
    'cn': 'china',
    'fr': 'france',
    'de': 'germany',
    'in': 'india',
    'ca': 'canada',
    'au': 'australia',
    'es': 'spain',
    'th': 'thailand',
  };

  int _section = 0;
  int _movieFilter = 1;
  String _countryCode = 'us';
  String _boxOfficeCode = 'box_office';
  bool _showEnglish = true;
  bool _loading = true;
  Object? _error;
  List<Movie> _movies = const [];
  List<MovieByUser> _bookmarks = const [];
  List<Quote> _quotes = const [];
  String _bookmarkQuery = '';
  _BookmarkSort _bookmarkSort = _BookmarkSort.recent;
  String? _lastLanguage;
  late final ScrollController _countryScrollController;
  bool _countryScrollPositioned = false;

  @override
  void initState() {
    super.initState();
    _countryScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _countryScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_countryScrollPositioned && MediaQuery.sizeOf(context).width < 700) {
      _countryScrollPositioned = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_countryScrollController.hasClients) {
          _countryScrollController.jumpTo(10000);
        }
      });
    }
    final language = context.watch<SettingsProvider>().language;
    if (_lastLanguage == null) {
      _countryCode = _defaultCountryByLanguage[language] ?? 'us';
    } else if (_lastLanguage != language) {
      _countryCode = _defaultCountryByLanguage[language] ?? 'us';
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
    _lastLanguage = language;
  }

  String get _contentLanguage {
    if (!_showEnglish) return '_origin';
    return context.read<SettingsProvider>().language;
  }

  String _displayMovieField(Movie movie, String field, String fallback) {
    if (!_showEnglish) {
      final value = (movie.originSource[field] ?? '').toString().trim();
      final selected = value.isEmpty ? fallback : value;
      return field == 'country' ? _countryDisplayName(selected) : selected;
    }
    const aliases = {'zh': 'cn', 'hi': 'in'};
    final language = context.read<SettingsProvider>().language;
    final key = aliases[language] ?? language;
    final translation = movie.translations[key];
    if (translation is Map) {
      final value = (translation[field] ?? '').toString().trim();
      if (value.isNotEmpty) {
        return field == 'country' ? _countryDisplayName(value) : value;
      }
    }
    return field == 'country' ? _countryDisplayName(fallback) : fallback;
  }

  String _countryDisplayName(String value) {
    final country = value.trim();
    return RegExp(r'^[A-Za-z]{2}$').hasMatch(country)
        ? convertCountryCodeToName(country)
        : country;
  }

  static const _originalLabels = <String, String>{
    'en': 'Original',
    'ko': '원본',
    'ja': '原文',
    'zh': '原文',
    'tw': '原文',
    'fr': 'Original',
    'de': 'Original',
    'es': 'Original',
    'hi': 'मूल',
    'th': 'ต้นฉบับ',
  };

  static const _navigationLabels = <String, Map<String, String>>{
    'en': {
      'countries': 'Countries',
      'boxOffice': 'Box Office',
      'bookmarks': 'Bookmarks',
      'special': 'Special',
      'quotes': 'Daily Quote',
    },
    'ko': {
      'countries': '국가별',
      'boxOffice': '박스오피스',
      'bookmarks': '북마크',
      'special': '특별기획',
      'quotes': '하루명언',
    },
    'ja': {
      'countries': '国別',
      'boxOffice': '興行ランキング',
      'bookmarks': 'お気に入り',
      'special': '特別企画',
      'quotes': '今日の名言',
    },
    'zh': {
      'countries': '国家',
      'boxOffice': '票房',
      'bookmarks': '书签',
      'special': '特别企划',
      'quotes': '每日名言',
    },
    'tw': {
      'countries': '國家',
      'boxOffice': '票房',
      'bookmarks': '書籤',
      'special': '特別企劃',
      'quotes': '每日名言',
    },
    'fr': {
      'countries': 'Pays',
      'boxOffice': 'Box-office',
      'bookmarks': 'Favoris',
      'special': 'Spécial',
      'quotes': 'Citation du jour',
    },
    'de': {
      'countries': 'Länder',
      'boxOffice': 'Kinokasse',
      'bookmarks': 'Lesezeichen',
      'special': 'Spezial',
      'quotes': 'Zitat des Tages',
    },
    'es': {
      'countries': 'Países',
      'boxOffice': 'Taquilla',
      'bookmarks': 'Marcadores',
      'special': 'Especial',
      'quotes': 'Cita del día',
    },
    'hi': {
      'countries': 'देश',
      'boxOffice': 'बॉक्स ऑफिस',
      'bookmarks': 'बुकमार्क',
      'special': 'विशेष',
      'quotes': 'आज का उद्धरण',
    },
    'th': {
      'countries': 'ประเทศ',
      'boxOffice': 'บ็อกซ์ออฟฟิศ',
      'bookmarks': 'บุ๊กมาร์ก',
      'special': 'พิเศษ',
      'quotes': 'คำคมประจำวัน',
    },
  };

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_section == 2) {
        _bookmarks = await MovieByUserService.getMoviesByFlag(3);
      } else if (_section == 4) {
        _quotes = await QuoteService.fetchQuote();
      } else {
        final code = _section == 1
            ? _boxOfficeCode
            : _section == 3
                ? special
                : _countryCode;
        _movies = await MovieService.fetchMovieByCode(code, _contentLanguage);
      }
    } catch (error) {
      _error = error;
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Movie> get _visibleMovies {
    if (_section == 2) return _bookmarks.map((item) => item.movie).toList();
    if (_section == 3) {
      final periods = _movies.map((movie) => movie.period ?? 0);
      final latest = periods.isEmpty
          ? 0
          : periods.reduce((current, next) => next > current ? next : current);
      return latest == 0
          ? _movies
          : _movies.where((movie) => movie.period == latest).toList();
    }
    if (_section == 1 || _movieFilter == 0) return _movies;
    return _movies.where((movie) {
      final release = DateTime.tryParse(movie.releaseDate);
      if (release == null) return _movieFilter == 1;
      final today = DateUtils.dateOnly(DateTime.now());
      final isUpcoming = release.isAfter(today);
      return _movieFilter == 2 ? isUpcoming : !isUpcoming;
    }).toList();
  }

  void _selectSection(int value) {
    if (_section == value) return;
    setState(() => _section = value);
    _load();
  }

  Future<void> _openMovie(Movie movie) async {
    final settings = context.read<SettingsProvider>();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MovieDetailPageYouTube(
        movie: movie,
        captionFlag: settings.isCaptionOn,
        captionLan: settings.language,
        isCustomized: false,
        initialShowOriginal: !_showEnglish,
      ),
    ));
    if (_section == 2) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: getAppBarTitle(language).replaceAll('\n', ' '),
              navigationLabels: navigation,
              section: _section,
              onSectionChanged: _selectSection,
              onTitleTap: () => _selectSection(0),
              languageLabel: countryNameByLan['ko']?[language] ?? 'English',
              originalLabel: _originalLabels[language] ?? 'Original',
              showEnglish: _showEnglish,
              onLanguageChanged: (value) {
                setState(() => _showEnglish = value);
                _load();
              },
              onSettings: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            if (_section == 0 || _section == 3) _countrySelector(),
            if (_section == 1) _boxOfficeSelector(),
            if (_section == 0) _filterSelector(),
            if (_section == 1) _weekTitle(),
            if (_section == 3) _specialTitle(),
            Expanded(child: _body()),
          ],
        ),
      ),
      bottomNavigationBar: kIsWeb ? null : _bottomNavigation(),
    );
  }

  Widget _countrySelector() {
    final countries = _countryKeys.entries.toList(growable: false);
    final itemCount = countries.length + 1;
    final infiniteScroll = MediaQuery.sizeOf(context).width < 700;
    return SizedBox(
      height: 42,
      child: ListView.builder(
        controller: _countryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: infiniteScroll ? null : itemCount,
        itemBuilder: (context, index) {
          final itemIndex = index % itemCount;
          if (itemIndex == countries.length) {
            return TextButton(
              onPressed: () => _selectSection(3),
              child: Text(
                (_navigationLabels[context.read<SettingsProvider>().language] ??
                    _navigationLabels['en']!)['special']!,
                style: TextStyle(
                  color: _section == 3
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                  fontWeight: _section == 3 ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            );
          }

          final entry = countries[itemIndex];
          final selected = _section == 0 && entry.key == _countryCode;
          return TextButton(
            onPressed: () {
              if (selected) return;
              setState(() {
                _section = 0;
                _countryCode = entry.key;
              });
              _load();
            },
            child: Text(
              localizedCountries[context.read<SettingsProvider>().language]
                      ?[entry.value] ??
                  entry.value,
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _boxOfficeSelector() {
    final language = context.read<SettingsProvider>().language;
    return Row(
      children: [
        _selectorButton('box_office', getBoxOfficeLabel(language, 'box_usa')),
        _selectorButton('box_office_kr',
            '${localizedCountries[language]?['korea'] ?? 'Korea'} ${getBoxOfficeLabel(language, 'box')}'),
      ],
    );
  }

  Widget _selectorButton(String code, String label) => TextButton(
        onPressed: () {
          if (_boxOfficeCode == code) return;
          setState(() => _boxOfficeCode = code);
          _load();
        },
        child: Text(label,
            style: TextStyle(
              color: _boxOfficeCode == code
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
              decoration:
                  _boxOfficeCode == code ? TextDecoration.underline : null,
              decorationColor: Colors.cyanAccent,
            )),
      );

  Widget _filterSelector() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
                3,
                (index) => getFilterLabel(
                    index, context.read<SettingsProvider>().language))
            .asMap()
            .entries
            .map((entry) => TextButton(
                  onPressed: () => setState(() => _movieFilter = entry.key),
                  child: Text(entry.value,
                      style: TextStyle(
                        color: _movieFilter == entry.key
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                        fontWeight: _movieFilter == entry.key
                            ? FontWeight.w800
                            : FontWeight.w500,
                      )),
                ))
            .toList(),
      );

  Widget _weekTitle() {
    final first = _movies.isEmpty ? null : _movies.first;
    final range = first == null || first.weekStartDate?.isEmpty != false
        ? ''
        : ' (${first.weekStartDate} - ${first.weekEndDate})';
    final language = context.read<SettingsProvider>().language;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Text('${getBoxOfficeLabel(language, 'this_week')}$range',
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontSize: 15)),
      ),
    );
  }

  Widget _specialTitle() {
    final movies = _visibleMovies;
    final concept = movies.isEmpty
        ? ''
        : _displayMovieField(
            movies.first,
            'concept',
            movies.first.special ?? '',
          );
    final language = context.read<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
        child: Text(
          concept.isEmpty
              ? navigation['special']!
              : '${navigation['special']} · $concept',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: getErrorMessage(context.read<SettingsProvider>().language),
        action: _load,
      );
    }
    if (_section == 2) return _bookmarkBody();
    if (_section == 4) return _quoteBody();
    final movies = _visibleMovies;
    if (movies.isEmpty) {
      return _MessageState(
        icon: _section == 2
            ? Icons.bookmark_border_rounded
            : Icons.movie_outlined,
        message: _section == 2
            ? getErrorByUserMessage(context.read<SettingsProvider>().language)
            : getErrorMessage(context.read<SettingsProvider>().language),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: movies.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (_, index) => _MovieRow(
          movie: movies[index],
          index: index,
          boxOffice: _section == 1,
          displayTitle: _displayMovieField(
            movies[index],
            'title',
            movies[index].localTitle,
          ),
          onTap: () => _openMovie(movies[index]),
        ),
      ),
    );
  }

  Widget _quoteBody() {
    final language = context.read<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    if (_quotes.isEmpty) {
      return _MessageState(
        icon: Icons.format_quote_rounded,
        message: getErrorMessage(language),
        action: _load,
      );
    }

    final day =
        DateUtils.dateOnly(DateTime.now()).difference(DateTime(2020)).inDays;
    final firstIndex = day % _quotes.length;
    final dailyQuotes = <Quote>[_quotes[firstIndex]];
    if (_quotes.length > 1) {
      dailyQuotes.add(_quotes[(firstIndex + 1) % _quotes.length]);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 80 : 22,
          vertical: kIsWeb ? 54 : 32,
        ),
        children: [
          Text(
            navigation['quotes']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB12DDB),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 30),
          ...dailyQuotes.indexed.map((entry) => Padding(
                padding: EdgeInsets.only(
                    bottom: entry.$1 == dailyQuotes.length - 1 ? 0 : 18),
                child: _quoteCard(entry.$2, language),
              )),
        ],
      ),
    );
  }

  Widget _quoteCard(Quote quote, String language) {
    final quoteText = !_showEnglish
        ? quote.quoteEN
        : language == 'ko'
            ? quote.quoteKR
            : language == 'ja'
                ? quote.quoteJP
                : quote.quoteEN;
    final movieTitle = !_showEnglish
        ? quote.movieEN
        : language == 'ko'
            ? quote.movieKR
            : language == 'ja'
                ? quote.movieJP
                : quote.movieEN;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 56 : 25,
            vertical: kIsWeb ? 42 : 32,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.055),
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.format_quote_rounded,
                  color: Color(0xFFB12DDB), size: 36),
              const SizedBox(height: 14),
              Text(
                quoteText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: kIsWeb ? 22 : 19,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              if (movieTitle.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  '— $movieTitle —',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.62),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookmarkBody() {
    final language = context.read<SettingsProvider>().language;
    final labels = _bookmarkLabels[language] ?? _bookmarkLabels['en']!;
    final query = _bookmarkQuery.trim().toLowerCase();
    final items = _bookmarks.where((item) {
      if (query.isEmpty) return true;
      final movie = item.movie;
      return [
        _displayMovieField(movie, 'title', movie.localTitle),
        _displayMovieField(movie, 'country', movie.country),
        movie.originSource['title'],
        movie.originSource['country'],
        movie.credits,
        movie.originSource['credits'],
      ].whereType<Object>().join(' ').toLowerCase().contains(query);
    }).toList();

    items.sort((a, b) {
      switch (_bookmarkSort) {
        case _BookmarkSort.title:
          return _displayMovieField(a.movie, 'title', a.movie.localTitle)
              .toLowerCase()
              .compareTo(
                _displayMovieField(b.movie, 'title', b.movie.localTitle)
                    .toLowerCase(),
              );
        case _BookmarkSort.releaseDate:
          return b.movie.releaseDate.compareTo(a.movie.releaseDate);
        case _BookmarkSort.recent:
          return (b.savedDate ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.savedDate ?? DateTime.fromMillisecondsSinceEpoch(0));
      }
    });

    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.fromLTRB(kIsWeb ? 40 : 16, 22, kIsWeb ? 40 : 16, 18),
          child: Column(
            children: [
              Row(
                children: [
                  Text(labels['title']!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: kIsWeb ? 28 : 23,
                        fontWeight: FontWeight.w800,
                      )),
                  const Spacer(),
                  Text('${items.length}${labels['countSuffix']}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.65),
                      )),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _bookmarkQuery = value),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: labels['searchHint'],
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  PopupMenuButton<_BookmarkSort>(
                    initialValue: _bookmarkSort,
                    onSelected: (value) =>
                        setState(() => _bookmarkSort = value),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: _BookmarkSort.recent,
                          child: Text(labels['recent']!)),
                      PopupMenuItem(
                          value: _BookmarkSort.title,
                          child: Text(labels['titleSort']!)),
                      PopupMenuItem(
                          value: _BookmarkSort.releaseDate,
                          child: Text(labels['releaseSort']!)),
                    ],
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_vert_rounded,
                              color: Color(0xFF9D00C6)),
                          if (kIsWeb) ...[
                            const SizedBox(width: 5),
                            Text(_bookmarkSortLabel(labels),
                                style: const TextStyle(
                                    color: Color(0xFF9D00C6),
                                    fontWeight: FontWeight.w700)),
                          ],
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF9D00C6)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: items.isEmpty
              ? _BookmarkEmptyState(
                  title: query.isEmpty
                      ? labels['emptyTitle']!
                      : labels['noResults']!,
                  description: query.isEmpty
                      ? labels['emptyDescription']!
                      : labels['tryAgain']!,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: Theme.of(context).dividerColor),
                    itemBuilder: (_, index) => _MovieRow(
                      movie: items[index].movie,
                      displayTitle: _displayMovieField(
                        items[index].movie,
                        'title',
                        items[index].movie.localTitle,
                      ),
                      displayCountry: _displayMovieField(
                        items[index].movie,
                        'country',
                        items[index].movie.country,
                      ),
                      index: index,
                      boxOffice: false,
                      onTap: () => _openMovie(items[index].movie),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _bookmarkSortLabel(Map<String, String> labels) =>
      switch (_bookmarkSort) {
        _BookmarkSort.recent => labels['recent']!,
        _BookmarkSort.title => labels['titleSort']!,
        _BookmarkSort.releaseDate => labels['releaseSort']!,
      };

  Widget _bottomNavigation() {
    final language = context.read<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    return BottomNavigationBar(
      currentIndex: _section == 3 ? 0 : _section,
      onTap: (index) => _selectSection(index),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: const Color(0xFFE9FF00),
      unselectedItemColor: Theme.of(context).colorScheme.onSurface,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: const SizedBox.shrink(), label: navigation['countries']),
        BottomNavigationBarItem(
            icon: const SizedBox.shrink(), label: navigation['boxOffice']),
        BottomNavigationBarItem(
            icon: const SizedBox.shrink(), label: navigation['bookmarks']),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.navigationLabels,
    required this.section,
    required this.onSectionChanged,
    required this.onTitleTap,
    required this.languageLabel,
    required this.originalLabel,
    required this.showEnglish,
    required this.onLanguageChanged,
    required this.onSettings,
  });

  final String title;
  final Map<String, String> navigationLabels;
  final int section;
  final ValueChanged<int> onSectionChanged;
  final VoidCallback onTitleTap;
  final String languageLabel;
  final String originalLabel;
  final bool showEnglish;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 8, 6),
        child: Row(
          crossAxisAlignment:
              kIsWeb ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (kIsWeb)
              InkWell(
                onTap: onTitleTap,
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 52,
                  child: Center(child: _title(context)),
                ),
              )
            else
              Expanded(child: _title(context)),
            if (kIsWeb) ...[
              const SizedBox(width: 30),
              _WebNavigationItem(
                label: navigationLabels['countries']!,
                selected: section == 0 || section == 3,
                onTap: () => onSectionChanged(0),
              ),
              _WebNavigationItem(
                label: navigationLabels['boxOffice']!,
                selected: section == 1,
                onTap: () => onSectionChanged(1),
              ),
              _WebNavigationItem(
                label: navigationLabels['bookmarks']!,
                selected: section == 2,
                onTap: () => onSectionChanged(2),
              ),
            ],
            if (kIsWeb) const Spacer(),
            if (kIsWeb)
              SizedBox(
                height: 52,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _StoreBadge.apple(),
                    const SizedBox(width: 5),
                    const _StoreBadge.googlePlay(),
                    const SizedBox(width: 14),
                    _languageSwitch(),
                    _settingsButton(context),
                  ],
                ),
              )
            else ...[
              _languageSwitch(),
              _settingsButton(context),
            ],
          ],
        ),
      );

  Widget _title(BuildContext context) {
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: kIsWeb
            ? const Color(0xFFB12DDB)
            : Theme.of(context).colorScheme.onSurface,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
    if (!kIsWeb) return titleText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.asset(
            'icons/appstore.png',
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF9D00C6),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.movie_outlined,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 9),
        titleText,
      ],
    );
  }

  Widget _languageSwitch() => SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: true,
            label: Text(languageLabel, maxLines: 1, softWrap: false),
          ),
          ButtonSegment(
            value: false,
            label: Text(originalLabel, maxLines: 1, softWrap: false),
          ),
        ],
        selected: {showEnglish},
        onSelectionChanged: (value) => onLanguageChanged(value.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.standard,
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          minimumSize: WidgetStatePropertyAll(Size(95, 42)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      );

  Widget _settingsButton(BuildContext context) => IconButton(
        tooltip: 'Settings',
        onPressed: onSettings,
        icon: Icon(Icons.settings_outlined,
            color: Theme.of(context).colorScheme.onSurface),
      );
}

class _StoreBadge extends StatelessWidget {
  const _StoreBadge.apple()
      : apple = true,
        url = 'https://apps.apple.com/us/app/world-movie-trailer/id6670228768';

  const _StoreBadge.googlePlay()
      : apple = false,
        url =
            'https://play.google.com/store/apps/details?id=com.sunnyinnolab.worldMovieTrailer';

  final bool apple;
  final String url;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          height: apple ? 32 : 42,
          width: apple ? 96 : 108,
          child: apple
              ? SvgPicture.asset(
                  'assets/images/store_badges/app_store_badge.svg',
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => const SizedBox.shrink(),
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                )
              : Image.asset(
                  'assets/images/store_badges/google_play_badge.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
        ),
      );
}

class _WebNavigationItem extends StatelessWidget {
  const _WebNavigationItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected
              ? const Color(0xFFB12DDB)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          overlayColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(0, 52),
          shape: const RoundedRectangleBorder(),
          side: BorderSide.none,
        ),
        child: Transform.translate(
          offset: const Offset(0, 2),
          child: Text(label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              )),
        ),
      );
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({
    required this.movie,
    required this.index,
    required this.boxOffice,
    required this.onTap,
    this.displayTitle,
    this.displayCountry,
  });

  final Movie movie;
  final int index;
  final bool boxOffice;
  final VoidCallback onTap;
  final String? displayTitle;
  final String? displayCountry;

  @override
  Widget build(BuildContext context) {
    final language = context.read<SettingsProvider>().language;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 82,
                  height: 126,
                  child: movie.posterUrl.isEmpty
                      ? const ColoredBox(color: Color(0xFF9D1D25))
                      : CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const ColoredBox(color: Color(0xFF9D1D25)),
                        ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boxOffice
                          ? '${movie.rank?.isNotEmpty == true ? movie.rank : index + 1}. ${displayTitle ?? movie.localTitle}'
                          : displayTitle ?? movie.localTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (boxOffice)
                      Text(
                          '${getBoxOfficeLabel(language, 'last_week')}: ${movie.lastRank?.isNotEmpty == true ? movie.lastRank : '-'}',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12)),
                    if (boxOffice && movie.distributor?.isNotEmpty == true)
                      Text(
                          '${getBoxOfficeLabel(language, 'distributor')}: ${movie.distributor}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12)),
                    if (!boxOffice && movie.releaseDate.isNotEmpty)
                      Text(movie.releaseDate,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12)),
                    if (!boxOffice && displayCountry?.isNotEmpty == true)
                      Text(displayCountry!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12)),
                  ],
                ),
              ),
              if (boxOffice && movie.isNewThisWeek == true)
                const Align(
                  alignment: Alignment.topRight,
                  child: Text('NEW',
                      style: TextStyle(
                        color: Color(0xFFE9FF00),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
                size: 42),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7))),
            if (action != null)
              TextButton(onPressed: action, child: const Text('Retry')),
          ],
        ),
      );
}

class _BookmarkEmptyState extends StatelessWidget {
  const _BookmarkEmptyState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 42,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
}
