import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/premium_translation_prompt.dart';
import 'package:world_movie_trailer/common/services/movie_by_user_service.dart';
import 'package:world_movie_trailer/common/services/movie_service.dart';
import 'package:world_movie_trailer/common/services/quote_service.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/common/translation_access.dart';
import 'package:world_movie_trailer/layout/movie_detail_page.dart';
import 'package:world_movie_trailer/layout/widgets/detail_swipe_navigator.dart';
import 'package:world_movie_trailer/layout/widgets/movie_loading_indicator.dart';
import 'package:world_movie_trailer/v2/home/widgets/selection_tab_label.dart';
import 'package:world_movie_trailer/layout/settings_page.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/model/movieByUser.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/v2/home/widgets/home_state_widgets.dart';
import 'package:world_movie_trailer/v2/home/featured_section_rotation.dart';
import 'package:world_movie_trailer/v2/home/web_movie_playlist_page.dart';

enum _BookmarkSort { recent, title, releaseDate }

const _navigationGradient = LinearGradient(
  colors: [Color(0xFF168CFF), Color(0xFFC000FF)],
);

const _playLabels = <String, Map<String, String>>{
  'ko': {'play': '플레이', 'unavailable': '영화명언에서는 사용할 수 없습니다'},
  'en': {'play': 'Play', 'unavailable': 'Unavailable for Movie Quotes'},
  'ja': {'play': '再生', 'unavailable': '映画の名言では利用できません'},
  'zh': {'play': '播放', 'unavailable': '电影名言中不可用'},
  'tw': {'play': '播放', 'unavailable': '電影名言中無法使用'},
  'fr': {'play': 'Lecture', 'unavailable': 'Indisponible pour les citations'},
  'de': {'play': 'Abspielen', 'unavailable': 'Für Filmzitate nicht verfügbar'},
  'es': {'play': 'Reproducir', 'unavailable': 'No disponible para frases'},
  'hi': {'play': 'चलाएँ', 'unavailable': 'फ़िल्मी उद्धरण में उपलब्ध नहीं'},
  'th': {'play': 'เล่น', 'unavailable': 'ใช้ไม่ได้กับคำคมภาพยนตร์'},
};

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
  'fr': {
    'title': 'Favoris',
    'countSuffix': '',
    'searchHint': 'Rechercher par titre, personne ou pays...',
    'recent': 'Plus récents',
    'titleSort': 'Titre',
    'releaseSort': 'Date de sortie',
    'emptyTitle': 'Aucun film enregistré.',
    'emptyDescription': 'Touchez le signet d’un film pour l’enregistrer.',
    'noResults': 'Aucun favori trouvé.',
    'tryAgain': 'Essayez une autre recherche.',
  },
  'de': {
    'title': 'Lesezeichen',
    'countSuffix': '',
    'searchHint': 'Nach Titel, Person oder Land suchen...',
    'recent': 'Neueste',
    'titleSort': 'Titel',
    'releaseSort': 'Kinostart',
    'emptyTitle': 'Noch keine Filme gespeichert.',
    'emptyDescription': 'Tippe auf das Lesezeichen eines Films.',
    'noResults': 'Keine Lesezeichen gefunden.',
    'tryAgain': 'Versuche einen anderen Suchbegriff.',
  },
  'es': {
    'title': 'Marcadores',
    'countSuffix': '',
    'searchHint': 'Buscar por título, persona o país...',
    'recent': 'Más recientes',
    'titleSort': 'Título',
    'releaseSort': 'Fecha de estreno',
    'emptyTitle': 'Aún no hay películas guardadas.',
    'emptyDescription': 'Toca el marcador de una película para guardarla.',
    'noResults': 'No se encontraron marcadores.',
    'tryAgain': 'Prueba otra búsqueda.',
  },
  'hi': {
    'title': 'बुकमार्क',
    'countSuffix': '',
    'searchHint': 'शीर्षक, व्यक्ति या देश से खोजें...',
    'recent': 'नवीनतम',
    'titleSort': 'शीर्षक',
    'releaseSort': 'रिलीज़ की तारीख',
    'emptyTitle': 'अभी कोई फ़िल्म बुकमार्क नहीं है।',
    'emptyDescription': 'फ़िल्म सहेजने के लिए बुकमार्क दबाएँ।',
    'noResults': 'कोई बुकमार्क नहीं मिला।',
    'tryAgain': 'कोई दूसरा शब्द खोजें।',
  },
  'th': {
    'title': 'บุ๊กมาร์ก',
    'countSuffix': '',
    'searchHint': 'ค้นหาจากชื่อ บุคคล หรือประเทศ...',
    'recent': 'ล่าสุด',
    'titleSort': 'ชื่อเรื่อง',
    'releaseSort': 'วันเข้าฉาย',
    'emptyTitle': 'ยังไม่มีภาพยนตร์ที่บุ๊กมาร์ก',
    'emptyDescription': 'แตะไอคอนบุ๊กมาร์กเพื่อบันทึกภาพยนตร์',
    'noResults': 'ไม่พบบุ๊กมาร์ก',
    'tryAgain': 'ลองใช้คำค้นอื่น',
  },
};

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.onInitialLoadComplete});

  final VoidCallback? onInitialLoadComplete;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  static const double _desktopBreakpoint = 1040;
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
  bool _showEnglish = false;
  bool _loading = true;
  bool _initialLoadReported = false;
  Object? _error;
  List<Movie> _movies = const [];
  List<MovieByUser> _bookmarks = const [];
  List<Quote> _quotes = const [];
  String _bookmarkQuery = '';
  _BookmarkSort _bookmarkSort = _BookmarkSort.recent;
  String? _lastLanguage;
  bool _translationPreferenceInitialized = false;
  bool _featuredPreferenceInitialized = false;
  int _featuredSection = FeaturedSectionRotation.specialSection;
  late final ScrollController _countryScrollController;
  bool _editingCountryOrder = false;
  late final AnimationController _countryJiggleController;

  @override
  void initState() {
    super.initState();
    _countryScrollController = ScrollController();
    _countryJiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _countryScrollController.dispose();
    _countryJiggleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    if (!_translationPreferenceInitialized) {
      _translationPreferenceInitialized = true;
      _showEnglish = settings.translatedContentPreference ??
          TranslationAccess.defaultToTranslation(isPremium: settings.isAdsFree);
    } else if (!kIsWeb && !settings.canTranslate && _showEnglish) {
      _showEnglish = false;
    }
    if (!_featuredPreferenceInitialized) {
      _featuredPreferenceInitialized = true;
      if (!kIsWeb) {
        _featuredSection = FeaturedSectionRotation.sectionForLaunch(
          showQuotes: settings.isQuotes,
        );
        final nextShowQuotes = FeaturedSectionRotation.preferenceForNextLaunch(
          showQuotes: settings.isQuotes,
        );
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => settings.updateIsQuotes(nextShowQuotes),
        );
      }
    }
    final language = settings.language;
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

  static const _navigationLabels = <String, Map<String, String>>{
    'en': {
      'countries': 'Countries',
      'boxOffice': 'Box Office',
      'bookmarks': 'Bookmarks',
      'special': 'Special',
      'quotes': 'Movie Quotes',
    },
    'ko': {
      'countries': '국가별',
      'boxOffice': '박스오피스',
      'bookmarks': '북마크',
      'special': '특별기획',
      'quotes': '영화명언',
    },
    'ja': {
      'countries': '国別',
      'boxOffice': '興行ランキング',
      'bookmarks': 'お気に入り',
      'special': '特別企画',
      'quotes': '映画の名言',
    },
    'zh': {
      'countries': '国家',
      'boxOffice': '票房',
      'bookmarks': '书签',
      'special': '特别企划',
      'quotes': '电影名言',
    },
    'tw': {
      'countries': '國家',
      'boxOffice': '票房',
      'bookmarks': '書籤',
      'special': '特別企劃',
      'quotes': '電影名言',
    },
    'fr': {
      'countries': 'Pays',
      'boxOffice': 'Box-office',
      'bookmarks': 'Favoris',
      'special': 'Spécial',
      'quotes': 'Citations de films',
    },
    'de': {
      'countries': 'Länder',
      'boxOffice': 'Kinokasse',
      'bookmarks': 'Lesezeichen',
      'special': 'Spezial',
      'quotes': 'Filmzitate',
    },
    'es': {
      'countries': 'Países',
      'boxOffice': 'Taquilla',
      'bookmarks': 'Marcadores',
      'special': 'Especial',
      'quotes': 'Frases de películas',
    },
    'hi': {
      'countries': 'देश',
      'boxOffice': 'बॉक्स ऑफिस',
      'bookmarks': 'बुकमार्क',
      'special': 'विशेष',
      'quotes': 'फ़िल्मी उद्धरण',
    },
    'th': {
      'countries': 'ประเทศ',
      'boxOffice': 'บ็อกซ์ออฟฟิศ',
      'bookmarks': 'บุ๊กมาร์ก',
      'special': 'พิเศษ',
      'quotes': 'คำคมจากภาพยนตร์',
    },
  };

  Future<void> _load({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_section == 2) {
        _bookmarks = await MovieByUserService.getBookmarks();
      } else if (_section == 4) {
        _quotes = await QuoteService.fetchQuote();
      } else {
        final code = _section == 1
            ? _boxOfficeCode
            : _section == 3
                ? special
                : _countryCode;
        _movies = await MovieService.fetchMovieByCode(
          code,
          _contentLanguage,
          forceRefresh: forceRefresh,
        );
      }
    } catch (error) {
      if (_section == 4) {
        try {
          _section = FeaturedSectionRotation.specialSection;
          _movies = await MovieService.fetchMovieByCode(
            special,
            _contentLanguage,
            forceRefresh: forceRefresh,
          );
          _error = null;
        } catch (fallbackError) {
          _error = fallbackError;
        }
      } else {
        _error = error;
      }
    }
    if (mounted) {
      setState(() => _loading = false);
      if (!_initialLoadReported) {
        _initialLoadReported = true;
        widget.onInitialLoadComplete?.call();
      }
    }
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
    if (_section == 1) return _movies;
    final today = DateUtils.dateOnly(DateTime.now());
    final filtered = _movieFilter == 0
        ? List<Movie>.from(_movies)
        : _movies.where((movie) {
            final release = DateTime.tryParse(movie.releaseDate);
            if (release == null) return _movieFilter == 1;
            final isUpcoming = release.isAfter(today);
            return _movieFilter == 2 ? isUpcoming : !isUpcoming;
          }).toList();
    filtered.sort((first, second) {
      final firstDate = DateTime.tryParse(first.releaseDate);
      final secondDate = DateTime.tryParse(second.releaseDate);
      if (firstDate == null && secondDate == null) return 0;
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;
      return _movieFilter == 2
          ? firstDate.compareTo(secondDate)
          : secondDate.compareTo(firstDate);
    });
    return filtered;
  }

  Future<bool> _ensureRewardedAccess() async {
    final settings = context.read<SettingsProvider>();
    if (kIsWeb || settings.canUseRewardedFeatures) return true;
    return showPremiumTranslationPrompt(context, settings.language);
  }

  Future<void> _selectSection(int value) async {
    if (_section == value) return;
    if ((value == 2 || value == 3) && !await _ensureRewardedAccess()) return;
    if (!mounted) return;
    setState(() => _section = value);
    _load();
  }

  Future<void> _openMovie(Movie movie, {required List<Movie> movies}) async {
    final settings = context.read<SettingsProvider>();
    if (!mounted) return;
    final sequence = List<Movie>.unmodifiable(movies);
    final initialIndex = sequence.indexOf(movie);
    if (initialIndex < 0) return;
    final sourceCodes =
        sequence.map(_sourceFeedCodeFor).toList(growable: false);
    var currentShowOriginal = !_showEnglish;
    final showOriginal =
        await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => DetailSwipeNavigator(
        itemCount: sequence.length,
        initialIndex: initialIndex,
        itemBuilder: (_, index) => MovieDetailPageYouTube(
          movie: sequence[index],
          captionFlag: settings.isCaptionOn,
          captionLan: settings.language,
          isCustomized: false,
          initialShowOriginal: currentShowOriginal,
          onShowOriginalChanged: (value) {
            currentShowOriginal = value;
            settings.updateTranslatedContentPreference(!value);
          },
          sourceFeedCode: sourceCodes[index],
        ),
      ),
    ));
    if (mounted && showOriginal != null) {
      setState(() => _showEnglish = !showOriginal);
      settings.updateTranslatedContentPreference(_showEnglish);
    }
    if (_section == 2) await _load();
  }

  String? _sourceFeedCodeFor(Movie movie) {
    if (_section == 0) return _countryCode;
    if (_section == 1) return _boxOfficeCode;
    if (_section == 3) return special;
    if (_section != 2) return null;
    final movieKey = movie.id.isNotEmpty ? movie.id : movie.localTitle;
    for (final bookmark in _bookmarks) {
      final bookmarkedMovie = bookmark.movie;
      final bookmarkKey = bookmarkedMovie.id.isNotEmpty
          ? bookmarkedMovie.id
          : bookmarkedMovie.localTitle;
      if (bookmarkKey == movieKey) return bookmark.sourceFeedCode;
    }
    return null;
  }

  List<MovieByUser> _orderedBookmarkItems() {
    final query = _bookmarkQuery.trim().toLowerCase();
    final items = _bookmarks.where((item) {
      if (query.isEmpty) return true;
      final movie = item.movie;
      return [
        _displayMovieField(movie, 'title', movie.localTitle),
        _displayMovieField(movie, 'country', movie.country),
        movie.originSource['title'],
        movie.originSource['country'],
        _bookmarkCountrySearchTerms(item),
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
    return items;
  }

  List<Movie> get _currentPlaylistMovies {
    final movies = _section == 2
        ? _orderedBookmarkItems().map((item) => item.movie).toList()
        : List<Movie>.from(_visibleMovies);
    return movies
        .where((movie) => movie.trailerUrl.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _openPlaylist() async {
    if (_section == 4) return;
    final movies = _currentPlaylistMovies;
    if (movies.isEmpty || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebMoviePlaylistPage(
          movies: movies,
          sourceFeedCodes:
              movies.map(_sourceFeedCodeFor).toList(growable: false),
          initialShowOriginal: !_showEnglish,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    final compact = MediaQuery.sizeOf(context).width < _desktopBreakpoint;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BackgroundWidget(
            isPausePage: false,
            isTapeExist: true,
          ),
          SafeArea(
            child: Column(children: [
              _Header(
                title: getAppBarTitle(language).replaceAll('\n', ' '),
                navigationLabels: navigation,
                section: _section,
                onSectionChanged: _selectSection,
                onTitleTap: () => _selectSection(0),
                languageLabel: getLanguageName(language),
                originalLabel: getMenuItemTitle(language, 'Original'),
                settingsTooltip: getMenuItemTitle(language, 'Settings'),
                playLabel:
                    (_playLabels[language] ?? _playLabels['en']!)['play']!,
                playUnavailableLabel: (_playLabels[language] ??
                    _playLabels['en']!)['unavailable']!,
                playEnabled: !_loading &&
                    _error == null &&
                    _section != 4 &&
                    _currentPlaylistMovies.isNotEmpty,
                onPlay: _openPlaylist,
                showEnglish: _showEnglish,
                onLanguageChanged: (value) async {
                  final settings = context.read<SettingsProvider>();
                  if (value && !kIsWeb && !settings.canTranslate) {
                    final granted = await showPremiumTranslationPrompt(
                      context,
                      settings.language,
                    );
                    if (!granted) return;
                  }
                  setState(() => _showEnglish = value);
                  settings.updateTranslatedContentPreference(value);
                  _load();
                },
                onSettings: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              if (_section == 0) _countrySelector(),
              if (_section == 1 || _section == 3 || _section == 4)
                _boxOfficeSelector(),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
              if (_section == 0) _filterSelector(),
              if (_section == 1) _weekTitle(),
              if (_section == 3) _specialTitle(),
              if (_section == 4) _quoteTitle(),
              Expanded(child: _body()),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: compact ? _bottomNavigation() : null,
    );
  }

  Widget _countrySelector() {
    final settings = context.watch<SettingsProvider>();
    final countries = _orderedCountries(settings);
    if (_editingCountryOrder) {
      return SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.only(left: 10),
                itemCount: countries.length,
                onReorderItem: (oldIndex, newIndex) {
                  final reordered =
                      List<MapEntry<String, String>>.from(countries);
                  final moved = reordered.removeAt(oldIndex);
                  reordered.insert(newIndex, moved);
                  settings.updateCountryOrderKeys(
                    reordered.map((entry) => entry.value).toList(),
                  );
                },
                itemBuilder: (context, index) {
                  final entry = countries[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(entry.key),
                    index: index,
                    child: AnimatedBuilder(
                      animation: _countryJiggleController,
                      builder: (_, child) => Transform.rotate(
                        angle: (_countryJiggleController.value - .5) *
                            (index.isEven ? .025 : -.025),
                        child: child,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Chip(
                          avatar: const Icon(Icons.drag_indicator_rounded,
                              size: 17),
                          label: Text(
                            localizedCountries[settings.language]
                                    ?[entry.value] ??
                                entry.value,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              tooltip: getMenuItemTitle(settings.language, 'Done'),
              onPressed: _finishCountryOrderEditing,
              icon: const Icon(Icons.check_circle_rounded),
            ),
          ],
        ),
      );
    }
    final itemCount = countries.length;
    final mobile = MediaQuery.sizeOf(context).width < _desktopBreakpoint;
    return SizedBox(
      height: 34,
      child: ListView.separated(
        controller: _countryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final entry = countries[index];
          final selected = _section == 0 && entry.key == _countryCode;
          final hasUpdate = settings.hasContentUpdate(entry.key);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              TextButton(
                onLongPress: mobile ? _startCountryOrderEditing : null,
                style: TextButton.styleFrom(
                  minimumSize: const Size(56, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  settings.acknowledgeContentUpdate(entry.key);
                  if (selected) return;
                  setState(() {
                    _section = 0;
                    _countryCode = entry.key;
                  });
                  _load();
                },
                child: _selectionTabLabel(
                  localizedCountries[settings.language]?[entry.value] ??
                      entry.value,
                  selected,
                ),
              ),
              if (hasUpdate)
                const Positioned(
                  left: 3,
                  top: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 8, height: 8),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<MapEntry<String, String>> _orderedCountries(SettingsProvider settings) {
    final byName = {
      for (final entry in _countryKeys.entries) entry.value: entry
    };
    final ordered = <MapEntry<String, String>>[];
    for (final key in settings.countryOrderKeys) {
      final entry = byName.remove(key);
      if (entry != null) ordered.add(entry);
    }
    ordered.addAll(byName.values);
    return ordered;
  }

  void _startCountryOrderEditing() {
    setState(() => _editingCountryOrder = true);
    _countryJiggleController.repeat(reverse: true);
  }

  void _finishCountryOrderEditing() {
    _countryJiggleController.stop();
    _countryJiggleController.value = .5;
    setState(() => _editingCountryOrder = false);
  }

  Widget _boxOfficeSelector() {
    final language = context.read<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _selectorButton(
              1, 'box_office', localizedCountries[language]?['usa'] ?? 'USA'),
          _selectorButton(1, 'box_office_kr',
              localizedCountries[language]?['korea'] ?? 'Korea'),
          if (kIsWeb ||
              _featuredSection == FeaturedSectionRotation.specialSection)
            _selectorButton(3, null, navigation['special']!),
          if (kIsWeb ||
              _featuredSection == FeaturedSectionRotation.quotesSection)
            _selectorButton(4, null, navigation['quotes']!),
        ],
      ),
    );
  }

  Widget _selectorButton(int section, String? code, String label) => TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () async {
          if (_section == section && (code == null || _boxOfficeCode == code)) {
            return;
          }
          if (section == 3 || section == 4) {
            if (!await _ensureRewardedAccess()) return;
          }
          if (!mounted) return;
          setState(() {
            _section = section;
            if (code != null) _boxOfficeCode = code;
          });
          _load();
        },
        child: _selectionTabLabel(
          label,
          _section == section && (code == null || _boxOfficeCode == code),
        ),
      );

  Widget _filterSelector() => SizedBox(
        height: 38,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
                  3,
                  (index) => getFilterLabel(
                      index, context.read<SettingsProvider>().language))
              .asMap()
              .entries
              .map((entry) => TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      if (entry.key == 2 && !await _ensureRewardedAccess()) {
                        return;
                      }
                      if (mounted) setState(() => _movieFilter = entry.key);
                    },
                    child: _selectionTabLabel(
                      entry.value,
                      _movieFilter == entry.key,
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _selectionTabLabel(String label, bool selected) =>
      SelectionTabLabel(label: label, selected: selected);

  Widget _weekTitle() {
    final first = _movies.isEmpty ? null : _movies.first;
    final range = first == null
        ? ''
        : _formatBoxOfficeWeek(first.weekStartDate, first.weekEndDate);
    final language = context.read<SettingsProvider>().language;
    return _contentSectionTitle(
      '${getBoxOfficeLabel(language, 'this_week')}$range',
    );
  }

  Widget _contentSectionTitle(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(title,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  fontSize: 15)),
        ),
      );

  String _formatBoxOfficeWeek(String? startValue, String? endValue) {
    if (startValue?.isEmpty != false || endValue?.isEmpty != false) return '';
    final start = DateTime.tryParse(startValue!);
    final end = DateTime.tryParse(endValue!);
    if (start == null || end == null) return ' ($startValue - $endValue)';
    final startText = DateFormat('MMM d', 'en_US').format(start);
    if (start.year == end.year && start.month == end.month) {
      return ' ($startText-${end.day})';
    }
    return ' ($startText - ${DateFormat('MMM d', 'en_US').format(end)})';
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
    final title =
        (_navigationLabels[language] ?? _navigationLabels['en']!)['special']!;
    return _contentSectionTitle(concept.isEmpty ? title : '$title ($concept)');
  }

  Widget _quoteTitle() {
    final language = context.read<SettingsProvider>().language;
    return _contentSectionTitle(
      (_navigationLabels[language] ?? _navigationLabels['en']!)['quotes']!,
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: MovieLoadingIndicator());
    }
    if (_error != null) {
      return MessageState(
        icon: Icons.cloud_off_outlined,
        message: getErrorMessage(context.read<SettingsProvider>().language),
        action: () => _load(forceRefresh: true),
      );
    }
    if (_section == 2) return _bookmarkBody();
    if (_section == 4) return _quoteBody();
    final movies = _visibleMovies;
    if (movies.isEmpty) {
      return MessageState(
        icon: _section == 2
            ? Icons.bookmark_border_rounded
            : Icons.movie_outlined,
        message: _section == 2
            ? getErrorByUserMessage(context.read<SettingsProvider>().language)
            : getErrorMessage(context.read<SettingsProvider>().language),
        action: _section == 2 ? null : () => _load(forceRefresh: true),
      );
    }
    if (_section == 0 || _section == 3) {
      return _countryPosterGrid(
        movies: movies,
        onRefresh: () => _load(forceRefresh: true),
      );
    }
    return _responsiveMovieList(
      movies: movies,
      boxOffice: _section == 1,
      koreanBoxOffice: _section == 1 && _boxOfficeCode == 'box_office_kr',
      onRefresh: () => _load(forceRefresh: true),
      showCountry: _section == 3,
      specialSection: _section == 3,
    );
  }

  Widget _countryPosterGrid({
    required List<Movie> movies,
    required Future<void> Function() onRefresh,
  }) =>
      LayoutBuilder(builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 14 : 24,
              vertical: 12,
            ),
            gridDelegate: mobile
                ? const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  )
                : const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 235,
                    childAspectRatio: .58,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 20,
                  ),
            itemCount: movies.length,
            itemBuilder: (_, index) {
              final movie = movies[index];
              final dark = context.read<SettingsProvider>().isDarkTheme;
              return Material(
                color: dark ? const Color(0xFF666666) : const Color(0xFF999999),
                borderRadius: BorderRadius.circular(15),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openMovie(movie, movies: movies),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: movie.posterUrl.isEmpty
                              ? const ColoredBox(color: Color(0xFF9D1D25))
                              : CachedNetworkImage(
                                  imageUrl: movie.posterUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const ColoredBox(
                                      color: Color(0xFF9D1D25)),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayMovieField(
                                  movie, 'title', movie.localTitle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFECECEC),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_section == 3 && movie.year?.isNotEmpty == true)
                              Text(
                                movie.year!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFC7C7C7),
                                ),
                              )
                            else if (movie.releaseDate.isNotEmpty)
                              Text(
                                movie.releaseDate.replaceAll('-', '.'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFC7C7C7),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      });

  Widget _responsiveMovieList({
    required List<Movie> movies,
    required bool boxOffice,
    bool koreanBoxOffice = false,
    required Future<void> Function() onRefresh,
    bool showCountry = false,
    bool specialSection = false,
    List<String>? sourceFlags,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final cardColor = Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF292A2E)
          : const Color(0xFFE1E2E5);
      Widget row(int index) => _MovieRow(
            movie: movies[index],
            index: index,
            boxOffice: boxOffice,
            koreanBoxOffice: koreanBoxOffice,
            specialSection: specialSection,
            displayTitle: _displayMovieField(
              movies[index],
              'title',
              movies[index].localTitle,
            ),
            displayCountry: showCountry
                ? _displayMovieField(
                    movies[index],
                    'country',
                    movies[index].country,
                  )
                : null,
            sourceFlag: sourceFlags?[index],
            onTap: () => _openMovie(movies[index], movies: movies),
          );

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: wide
            ? GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      (constraints.maxWidth * 0.025).clamp(20, 42).toDouble(),
                  vertical: 12,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 620,
                  mainAxisExtent: 150,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                ),
                itemCount: movies.length,
                itemBuilder: (_, index) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: row(index),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: row(index),
                  ),
                ),
              ),
      );
    });
  }

  Widget _quoteBody() {
    final desktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;
    final language = context.read<SettingsProvider>().language;
    if (_quotes.isEmpty) {
      return MessageState(
        icon: Icons.format_quote_rounded,
        message: getErrorMessage(language),
        action: _load,
      );
    }

    final day =
        DateUtils.dateOnly(DateTime.now()).difference(DateTime(2020)).inDays;
    final firstIndex = day % _quotes.length;
    final quoteCount = _quotes.length < 3 ? _quotes.length : 3;
    final dailyQuotes = List<Quote>.generate(
      quoteCount,
      (index) => _quotes[(firstIndex + index) % _quotes.length],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final verticalPadding = desktop ? 16.0 : 8.0;
      final availableHeight = constraints.maxHeight - verticalPadding * 2;
      final contentHeight = availableHeight < 360 ? 360.0 : availableHeight;
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 80 : 20,
            vertical: verticalPadding,
          ),
          children: [
            SizedBox(
              height: contentHeight,
              child: Column(
                children: dailyQuotes.indexed
                    .map((entry) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  entry.$1 == dailyQuotes.length - 1 ? 0 : 14,
                            ),
                            child: _quoteCard(entry.$2, language),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _quoteCard(Quote quote, String language) {
    final desktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;
    final quoteText =
        _showEnglish ? quote.localizedQuote(language) : quote.quoteEN;
    final movieTitle =
        _showEnglish ? quote.localizedMovie(language) : quote.movieEN;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 48 : 22,
            vertical: desktop ? 24 : 14,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF383B41)
                : const Color(0xFFD9DCE1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                quoteText,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: desktop ? 19 : 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              if (movieTitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '— $movieTitle —',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.62),
                    fontSize: desktop ? 14 : 12,
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
    final desktop = MediaQuery.sizeOf(context).width >= _desktopBreakpoint;
    final language = context.read<SettingsProvider>().language;
    final labels = _bookmarkLabels[language] ?? _bookmarkLabels['en']!;
    final query = _bookmarkQuery.trim().toLowerCase();
    final items = _orderedBookmarkItems();

    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.fromLTRB(desktop ? 40 : 16, 10, desktop ? 40 : 16, 18),
          child: Column(
            children: [
              Row(
                children: [
                  Text(labels['title']!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: desktop ? 28 : 23,
                        fontWeight: FontWeight.w800,
                      )),
                  const Spacer(),
                  if (desktop)
                    Text('${items.length}${labels['countSuffix']}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.65),
                        )),
                  if (!desktop) _bookmarkSortMenu(labels),
                ],
              ),
              if (desktop) ...[
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
                    _bookmarkSortMenu(labels),
                  ],
                ),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: items.isEmpty
              ? BookmarkEmptyState(
                  title: query.isEmpty
                      ? labels['emptyTitle']!
                      : labels['noResults']!,
                  description: query.isEmpty
                      ? labels['emptyDescription']!
                      : labels['tryAgain']!,
                )
              : desktop
                  ? _responsiveBookmarkList(items)
                  : _mobileBookmarkList(items),
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

  Widget _bookmarkSortMenu(Map<String, String> labels) =>
      PopupMenuButton<_BookmarkSort>(
        initialValue: _bookmarkSort,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: .96),
        onSelected: (value) => setState(() => _bookmarkSort = value),
        itemBuilder: (_) => [
          PopupMenuItem(
              value: _BookmarkSort.recent, child: Text(labels['recent']!)),
          PopupMenuItem(
              value: _BookmarkSort.title, child: Text(labels['titleSort']!)),
          PopupMenuItem(
              value: _BookmarkSort.releaseDate,
              child: Text(labels['releaseSort']!)),
        ],
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            gradient: _navigationGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.5),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: .96),
              borderRadius: BorderRadius.circular(10.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.swap_vert_rounded, color: Colors.white),
                const SizedBox(width: 5),
                Text(_bookmarkSortLabel(labels),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white),
              ],
            ),
          ),
        ),
      );

  Widget _mobileBookmarkList(List<MovieByUser> items) => RefreshIndicator(
        onRefresh: _load,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .50,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final movie = item.movie;
            final dark = Theme.of(context).brightness == Brightness.dark;
            return Material(
              color: dark ? const Color(0xFF666666) : const Color(0xFF999999),
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openMovie(
                  movie,
                  movies: items.map((item) => item.movie).toList(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          movie.posterUrl.isEmpty
                              ? const ColoredBox(color: Color(0xFF9D1D25))
                              : CachedNetworkImage(
                                  imageUrl: movie.posterUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const ColoredBox(
                                    color: Color(0xFF9D1D25),
                                  ),
                                ),
                          Positioned(
                            top: 3,
                            right: 3,
                            child: IconButton.filled(
                              tooltip: getMenuItemTitle(
                                context.read<SettingsProvider>().language,
                                'Delete',
                              ),
                              onPressed: () => _deleteBookmark(item),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(32, 32),
                                fixedSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                backgroundColor:
                                    Colors.black.withValues(alpha: .52),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _bookmarkFlag(item),
                            maxLines: 1,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _displayMovieField(
                              movie,
                              'title',
                              movie.localTitle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFECECEC),
                              fontSize: 16,
                              height: 1.22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.sourceFeedCode == special
                                ? _displayMovieField(
                                    movie,
                                    'concept',
                                    movie.special ?? '',
                                  )
                                : movie.releaseDate.isEmpty
                                    ? '-'
                                    : movie.releaseDate.replaceAll('-', '.'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFC7C7C7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  String _bookmarkFlag(MovieByUser item) {
    final source = item.sourceFeedCode;
    if (source == special) return '🎬';
    if (source == 'box_office' || source == 'box_office_kr') return '🏆';
    var code = switch (source) {
      String value when value.length == 2 => value,
      _ => '',
    };
    if (code.isEmpty) {
      final fallback = (item.movie.originSource['country'] ?? '').toString();
      if (fallback.length == 2) code = fallback.toLowerCase();
    }
    if (code.length != 2) return '🎞️';
    return String.fromCharCodes(
      code.toUpperCase().codeUnits.map((unit) => unit + 0x1F1A5),
    );
  }

  String _bookmarkCountrySearchTerms(MovieByUser item) {
    final source = item.sourceFeedCode ?? '';
    final countryKey = switch (source) {
      'box_office' => 'usa',
      'box_office_kr' => 'korea',
      String value when value.length == 2 => _countryKeys[value],
      _ => null,
    };
    if (countryKey == null) return '';
    final terms = <String>{source, countryKey};
    for (final countries in localizedCountries.values) {
      final localized = countries[countryKey];
      if (localized?.isNotEmpty == true) terms.add(localized!);
    }
    return terms.join(' ');
  }

  Future<void> _deleteBookmark(MovieByUser item) async {
    final index = _bookmarks.indexOf(item);
    if (index < 0) return;
    await MovieByUserService.deleteMovie(index);
    await _load();
  }

  Widget _responsiveBookmarkList(List<MovieByUser> items) {
    if (kIsWeb) return _webBookmarkGrid(items);
    final movies = items.map((item) => item.movie).toList(growable: false);
    return _responsiveMovieList(
      movies: movies,
      sourceFlags: items.map(_bookmarkFlag).toList(growable: false),
      boxOffice: false,
      onRefresh: _load,
      showCountry: true,
    );
  }

  Widget _webBookmarkGrid(List<MovieByUser> items) {
    final movies = items.map((item) => item.movie).toList(growable: false);
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(30, 22, 30, 36),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisExtent: 535,
          crossAxisSpacing: 24,
          mainAxisSpacing: 28,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final movie = item.movie;
          final dark = Theme.of(context).brightness == Brightness.dark;
          return Material(
            color: dark ? const Color(0xFF666666) : const Color(0xFF999999),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openMovie(movie, movies: movies),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        movie.posterUrl.isEmpty
                            ? const ColoredBox(color: Color(0xFF9D1D25))
                            : CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const ColoredBox(color: Color(0xFF9D1D25)),
                              ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                            tooltip: getMenuItemTitle(
                              context.read<SettingsProvider>().language,
                              'Delete',
                            ),
                            onPressed: () => _deleteBookmark(item),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(32, 32),
                              fixedSize: const Size(32, 32),
                              padding: EdgeInsets.zero,
                              backgroundColor:
                                  Colors.black.withValues(alpha: .52),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bookmarkFlag(item),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _displayMovieField(movie, 'title', movie.localTitle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFECECEC),
                            fontSize: 16,
                            height: 1.22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.sourceFeedCode == special
                              ? _displayMovieField(
                                  movie,
                                  'concept',
                                  movie.special ?? '',
                                )
                              : movie.releaseDate.isEmpty
                                  ? '-'
                                  : movie.releaseDate.replaceAll('-', '.'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFC7C7C7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bottomNavigation() {
    final language = context.read<SettingsProvider>().language;
    final navigation = _navigationLabels[language] ?? _navigationLabels['en']!;
    final currentIndex = _section == 3 || _section == 4 ? 1 : _section;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _bottomNavigationDestination(
                index: 0,
                currentIndex: currentIndex,
                inactivePath: 'assets/images/v2/countries_inactive.png',
                activePath: 'assets/images/v2/countries_active.png',
                label: navigation['countries']!,
              ),
              _bottomNavigationDestination(
                index: 1,
                currentIndex: currentIndex,
                inactivePath: 'assets/images/v2/boxoffice_inactive.png',
                activePath: 'assets/images/v2/boxoffice_active.png',
                label: navigation['boxOffice']!,
              ),
              _bottomNavigationDestination(
                index: 2,
                currentIndex: currentIndex,
                inactivePath: 'assets/images/v2/bookmark_inactive.png',
                activePath: 'assets/images/v2/bookmark_inactive.png',
                label: navigation['bookmarks']!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigationDestination({
    required int index,
    required int currentIndex,
    required String inactivePath,
    required String activePath,
    required String label,
  }) {
    final selected = index == currentIndex;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () => _selectSection(index),
          child: Center(
            child: _bottomNavigationContent(
              selected ? activePath : inactivePath,
              label,
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigationContent(
    String path,
    String label, {
    required bool selected,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(path, width: 23, height: 23, fit: BoxFit.contain),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
    if (!selected) return Opacity(opacity: .68, child: content);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: _navigationGradient.createShader,
      child: content,
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
    required this.settingsTooltip,
    required this.playLabel,
    required this.playUnavailableLabel,
    required this.playEnabled,
    required this.onPlay,
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
  final String settingsTooltip;
  final String playLabel;
  final String playUnavailableLabel;
  final bool playEnabled;
  final VoidCallback onPlay;
  final bool showEnglish;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1040;
    return Padding(
      padding: EdgeInsets.fromLTRB(desktop ? 24 : 14, 10, 8, 0),
      child: Row(
        crossAxisAlignment:
            desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (desktop)
            InkWell(
              onTap: onTitleTap,
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 52,
                child: Center(child: _title(context)),
              ),
            )
          else if (kIsWeb)
            Expanded(child: _title(context)),
          if (!desktop && !kIsWeb)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _playButton(context),
              ),
            ),
          if (desktop) ...[
            const SizedBox(width: 30),
            _WebNavigationItem(
              label: navigationLabels['countries']!,
              selected: section == 0,
              onTap: () => onSectionChanged(0),
            ),
            _WebNavigationItem(
              label: navigationLabels['boxOffice']!,
              selected: section == 1 || section == 3 || section == 4,
              onTap: () => onSectionChanged(1),
            ),
            _WebNavigationItem(
              label: navigationLabels['bookmarks']!,
              selected: section == 2,
              onTap: () => onSectionChanged(2),
            ),
          ],
          if (desktop) const Spacer(),
          if (desktop)
            SizedBox(
              height: 52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const StoreBadge.apple(),
                  const SizedBox(width: 5),
                  const StoreBadge.googlePlay(),
                  if (kIsWeb) ...[
                    const SizedBox(width: 10),
                    _playButton(context),
                  ],
                  const SizedBox(width: 10),
                  _languageSwitch(context),
                  _settingsButton(context),
                ],
              ),
            )
          else ...[
            const SizedBox(width: 10),
            if (kIsWeb) ...[
              _playButton(context, compact: true),
              const SizedBox(width: 6),
            ],
            _languageSwitch(context),
            _settingsButton(context),
          ],
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1040;
    final titleText = Text(
      title,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        color: desktop
            ? const Color(0xFFB12DDB)
            : Theme.of(context).colorScheme.onSurface,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
    final fittedTitle = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: titleText,
    );
    if (!desktop) {
      return SizedBox(
        height: 32,
        child: Align(
          alignment: Alignment.centerLeft,
          child: fittedTitle,
        ),
      );
    }
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220, maxHeight: 32),
          child: fittedTitle,
        ),
      ],
    );
  }

  Widget _languageSwitch(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1040;
    return Container(
      width: desktop ? 150 : 124,
      height: 34,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF55545A)
            : const Color(0xFFD2D0D5),
        border: Border.all(
          color: const Color(0xFF9D00C6).withValues(alpha: .55),
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          _languageSwitchItem(
            context: context,
            label: languageLabel,
            selected: showEnglish,
            onTap: () => onLanguageChanged(true),
          ),
          _languageSwitchItem(
            context: context,
            label: originalLabel,
            selected: !showEnglish,
            onTap: () => onLanguageChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _languageSwitchItem({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          child: InkWell(
            onTap: selected ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected ? _navigationGradient : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x3D9D00C6),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .72),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _settingsButton(BuildContext context) => IconButton(
        tooltip: settingsTooltip,
        onPressed: onSettings,
        icon: Icon(Icons.settings_outlined,
            color: Theme.of(context).colorScheme.onSurface),
      );

  Widget _playButton(BuildContext context, {bool compact = false}) {
    final disabledColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: .12);
    return Tooltip(
      message: playEnabled ? playLabel : playUnavailableLabel,
      child: Semantics(
        button: true,
        enabled: playEnabled,
        label: playLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
            onTap: playEnabled ? onPlay : null,
            borderRadius: BorderRadius.circular(19),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 34,
              constraints: BoxConstraints(minWidth: compact ? 38 : 78),
              padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 13),
              decoration: BoxDecoration(
                gradient: playEnabled
                    ? _navigationGradient
                    : LinearGradient(colors: [disabledColor, disabledColor]),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: playEnabled
                      ? const Color(0xFF9D00C6).withValues(alpha: .55)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .08),
                ),
                boxShadow: playEnabled
                    ? const [
                        BoxShadow(
                          color: Color(0x3D9D00C6),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 19,
                    color: playEnabled
                        ? Colors.white
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .35),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 3),
                    Text(
                      playLabel,
                      style: TextStyle(
                        color: playEnabled
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: .35),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
          child: selected
              ? ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: _navigationGradient.createShader,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      );
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({
    required this.movie,
    required this.index,
    required this.boxOffice,
    this.koreanBoxOffice = false,
    this.specialSection = false,
    required this.onTap,
    this.displayTitle,
    this.displayCountry,
    this.sourceFlag,
  });

  final Movie movie;
  final int index;
  final bool boxOffice;
  final bool koreanBoxOffice;
  final bool specialSection;
  final VoidCallback onTap;
  final String? displayTitle;
  final String? displayCountry;
  final String? sourceFlag;

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
                    if (sourceFlag?.isNotEmpty == true) ...[
                      Text(sourceFlag!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                    ],
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
                    if (boxOffice && movie.totalGross?.isNotEmpty == true)
                      Text(
                          '${getBoxOfficeLabel(language, 'total_gross')}: ${_totalGrossLabel(movie.totalGross!)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: .6),
                              fontSize: 12)),
                    if (boxOffice && movie.weeks?.isNotEmpty == true)
                      Text(
                          '${getBoxOfficeLabel(language, 'screening_weeks')}: ${movie.weeks}',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: .6),
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
                    if (specialSection && movie.year?.isNotEmpty == true)
                      Text(movie.year!,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: .6),
                              fontSize: 12)),
                    if (specialSection && movie.source.isNotEmpty)
                      Text(movie.source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: .6),
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

  String _totalGrossLabel(String value) {
    if (!koreanBoxOffice) return value;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(digits);
    if (amount == null) return value.startsWith('₩') ? value : '₩$value';
    return '₩${NumberFormat.decimalPattern().format(amount)}';
  }
}
