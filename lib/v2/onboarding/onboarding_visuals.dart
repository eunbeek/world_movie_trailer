import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/translate.dart';

const _purple = Color(0xFF9E25E9);
const _deepPurple = Color(0xFF5628EE);
const _panel = Color(0xFF111214);
const _border = Color(0xFF45464B);

class OnboardingFeatureVisual extends StatelessWidget {
  const OnboardingFeatureVisual(
      {super.key,
      required this.index,
      required this.active,
      required this.language});
  final int index;
  final bool active;
  final String language;
  @override
  Widget build(BuildContext context) {
    final locale = supportedLanguages.contains(language) ? language : 'en';
    return switch (index) {
      0 => _Countries(language: locale),
      1 => _Translation(language: locale, active: active),
      2 => _Autoplay(language: locale, active: active),
      _ => _Detail(language: locale, active: active),
    };
  }
}

class _Countries extends StatefulWidget {
  const _Countries({required this.language});
  final String language;

  @override
  State<_Countries> createState() => _CountriesState();
}

class _CountriesState extends State<_Countries>
    with SingleTickerProviderStateMixin {
  late final AnimationController _jiggleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  bool _isAnimating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shouldAnimate = !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate && !_isAnimating) {
      _jiggleController.repeat();
      _isAnimating = true;
    } else if (!shouldAnimate && _isAnimating) {
      _jiggleController
        ..stop()
        ..value = 0;
      _isAnimating = false;
    }
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final names =
        localizedCountries[widget.language] ?? localizedCountries['en']!;
    const rows = [
      ['korea', 'usa', 'japan'],
      ['china', 'france', 'taiwan'],
      ['india', 'germany', 'spain'],
      ['thailand'],
    ];
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: AnimatedBuilder(
          animation: _jiggleController,
          builder: (context, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows.asMap().entries.map((rowEntry) {
              final row = rowEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: row.asMap().entries.map((chipEntry) {
                      final phase = rowEntry.key * 3 + chipEntry.key;
                      final angle = math.sin(
                            _jiggleController.value * math.pi * 2 + phase * .85,
                          ) *
                          .018;
                      return Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: Transform.rotate(
                          angle: angle,
                          child: _CountryChip(
                            names[chipEntry.value] ?? chipEntry.value,
                            highlighted: chipEntry.value == 'usa',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip(this.label, {this.highlighted = false});
  final String label;
  final bool highlighted;
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 76),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        decoration: BoxDecoration(
            color: _panel.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: highlighted ? _purple : _border),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: _purple.withValues(alpha: .38),
                      blurRadius: 12,
                    ),
                  ]
                : null),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.drag_indicator_rounded,
              size: 15, color: Colors.white70),
          const SizedBox(width: 4),
          Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color:
                          highlighted ? const Color(0xFFD9B9FF) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700))),
        ]),
      );
}

class _Translation extends StatefulWidget {
  const _Translation({required this.language, required this.active});
  final String language;
  final bool active;

  @override
  State<_Translation> createState() => _TranslationState();
}

class _TranslationState extends State<_Translation> {
  Timer? _timer;
  Timer? _cardTimer;
  bool _toggleShowsEnglish = true;
  bool _cardsShowEnglish = true;

  @override
  void initState() {
    super.initState();
    if (widget.active) _startAnimation();
  }

  @override
  void didUpdateWidget(covariant _Translation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _startAnimation();
      } else {
        _cancelTimers();
      }
    }
  }

  void _startAnimation() {
    _cancelTimers();
    _toggleShowsEnglish = true;
    _cardsShowEnglish = true;
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
      if (mounted && widget.active) {
        final nextShowsEnglish = !_toggleShowsEnglish;
        setState(() => _toggleShowsEnglish = nextShowsEnglish);
        _cardTimer?.cancel();
        _cardTimer = Timer(const Duration(milliseconds: 360), () {
          if (mounted && widget.active) {
            setState(() => _cardsShowEnglish = nextShowsEnglish);
          }
        });
      }
    });
  }

  void _cancelTimers() {
    _timer?.cancel();
    _cardTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _LanguageToggle(showEnglish: _toggleShowsEnglish),
      const SizedBox(height: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/onboarding/trailer_hope.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 6),
      _TranslationCard(
        _cardsShowEnglish ? 'Original' : 'English',
        _cardsShowEnglish ? '희망' : 'Hope',
        _cardsShowEnglish
            ? '절망 속에서도 한 가족은 희망을 놓지 않는다.'
            : 'Even in despair, one family refuses to give up hope.',
        false,
      ),
      const Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Icon(Icons.arrow_downward_rounded,
              key: ValueKey('onboarding-translation-arrow'),
              color: _purple,
              size: 26)),
      _TranslationCard(
          _cardsShowEnglish ? 'English' : 'Original',
          _cardsShowEnglish ? 'Hope' : '희망',
          _cardsShowEnglish
              ? 'Even in despair, one family refuses to give up hope.'
              : '절망 속에서도 한 가족은 희망을 놓지 않는다.',
          true),
    ]);
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.showEnglish});
  final bool showEnglish;

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFF29282D),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border)),
        child: Stack(children: [
          AnimatedAlign(
            key: const ValueKey('onboarding-language-toggle-thumb'),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOut,
            alignment:
                showEnglish ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: .5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient:
                      const LinearGradient(colors: [_deepPurple, _purple]),
                ),
              ),
            ),
          ),
          Row(children: [
            _ToggleLabel(label: 'English', selected: showEnglish),
            _ToggleLabel(label: 'Original', selected: !showEnglish),
          ]),
        ]),
      );
}

class _ToggleLabel extends StatelessWidget {
  const _ToggleLabel({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      );
}

class _TranslationCard extends StatelessWidget {
  const _TranslationCard(this.label, this.title, this.overview, this.selected);
  final String label, title, overview;
  final bool selected;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
            color: _panel.withValues(alpha: .94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _purple : _border),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: _purple.withValues(alpha: .22), blurRadius: 14)
                  ]
                : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: selected
                      ? _purple.withValues(alpha: .28)
                      : Colors.white10,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15))),
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color:
                          selected ? const Color(0xFFD9B9FF) : Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800))),
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 7),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10, height: 1.3)),
                  ])),
        ]),
      );
}

class _Autoplay extends StatefulWidget {
  const _Autoplay({required this.language, required this.active});
  final String language;
  final bool active;

  @override
  State<_Autoplay> createState() => _AutoplayState();
}

class _AutoplayState extends State<_Autoplay> {
  static const _posterPaths = [
    'assets/images/onboarding/poster_thesunneversets.webp',
    'assets/images/onboarding/poster_findingemily.webp',
    'assets/images/onboarding/poster_thesaltpath.webp',
  ];
  static const _posterTitles = [
    'The Sun Never Sets',
    'Finding Emily',
    'The Salt Path',
  ];
  Timer? _timer;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    if (widget.active) _startAnimation();
  }

  @override
  void didUpdateWidget(covariant _Autoplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      widget.active ? _startAnimation() : _timer?.cancel();
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    _selected = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.active) {
        setState(() => _selected = (_selected + 1) % _posterPaths.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final compact = box.maxHeight < 390;
        return Column(children: [
          Container(
              width: compact ? 62 : 76,
              height: compact ? 62 : 76,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_deepPurple, _purple])),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 46)),
          SizedBox(height: compact ? 8 : 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('1 / 3',
                style: const TextStyle(color: Colors.white, fontSize: 17)),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('→',
                    key: ValueKey('onboarding-autoplay-arrow'),
                    style: TextStyle(
                        color: _purple,
                        fontSize: 26,
                        fontWeight: FontWeight.w800))),
            Text('3 / 3',
                style: const TextStyle(
                    color: _purple, fontSize: 17, fontWeight: FontWeight.w800)),
          ]),
          SizedBox(height: compact ? 10 : 18),
          SizedBox(
            height: (box.maxHeight * .43).clamp(128.0, 205.0),
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _MovieCard(
                      _posterPaths[i],
                      _posterTitles[i],
                      i == _selected,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 7 : 13),
          const Text('→',
              key: ValueKey('onboarding-progress-arrow'),
              style: TextStyle(
                  color: _purple, fontSize: 28, fontWeight: FontWeight.w800)),
        ]);
      });
}

class _DetailMovie {
  const _DetailMovie({
    required this.title,
    required this.trailerAsset,
    required this.director,
    required this.stars,
    required this.runtime,
    required this.overview,
  });

  final String title;
  final String trailerAsset;
  final String director;
  final String stars;
  final String runtime;
  final String overview;
}

const _detailMovies = [
  _DetailMovie(
    title: 'The Odyssey',
    trailerAsset: 'assets/images/onboarding/trailer_odyssey.png',
    director: 'Christopher Nolan',
    stars: 'Matt Damon · Tom Holland · Anne Hathaway',
    runtime: '172',
    overview: 'Odysseus begins a perilous journey home after the Trojan War.',
  ),
  _DetailMovie(
    title: 'Toy Story 5',
    trailerAsset: 'assets/images/onboarding/trailer_toystory5.png',
    director: 'Andrew Stanton',
    stars: 'Tom Hanks · Tim Allen · Joan Cusack',
    runtime: '102',
    overview: 'The toys face a new challenge when playtime meets technology.',
  ),
  _DetailMovie(
    title: 'The Invite',
    trailerAsset: 'assets/images/onboarding/trailer_theinvite.png',
    director: 'Olivia Wilde',
    stars: 'Seth Rogen · Olivia Wilde · Penélope Cruz · Edward Norton',
    runtime: '107',
    overview:
        'A dinner with enigmatic neighbors spirals into unexpected places.',
  ),
];

class _Detail extends StatefulWidget {
  const _Detail({required this.language, required this.active});
  final String language;
  final bool active;

  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  Timer? _timer;
  Timer? _cursorMoveTimer;
  Timer? _cursorHideTimer;
  int _selected = 0;
  bool _cursorAtRight = true;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    if (widget.active) _startAnimation();
  }

  @override
  void didUpdateWidget(covariant _Detail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _startAnimation();
      } else {
        _cancelTimers();
      }
    }
  }

  void _startAnimation() {
    _cancelTimers();
    _selected = 0;
    _cursorAtRight = true;
    _showCursor = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.active) {
        setState(() => _selected = (_selected + 1) % _detailMovies.length);
      }
    });
    _cursorMoveTimer = Timer(const Duration(milliseconds: 220), () {
      if (mounted && widget.active) setState(() => _cursorAtRight = false);
    });
    _cursorHideTimer = Timer(const Duration(milliseconds: 1550), () {
      if (mounted && widget.active) setState(() => _showCursor = false);
    });
  }

  void _cancelTimers() {
    _timer?.cancel();
    _cursorMoveTimer?.cancel();
    _cursorHideTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  String label(String key) =>
      movieDetailTranslations[key]?[widget.language] ??
      movieDetailTranslations[key]?['en'] ??
      key;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final compact = box.maxHeight < 390;
        final preferredVideoHeight = (box.maxWidth / 1.6).clamp(150.0, 210.0);
        final videoHeight = math.min(preferredVideoHeight, box.maxHeight * .5);
        final font = compact ? 9.0 : 10.5;
        final movie = _detailMovies[_selected];
        return Column(children: [
          Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                    height: videoHeight,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _border)),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: Image.asset(
                        movie.trailerAsset,
                        key: ValueKey(movie.trailerAsset),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 260),
                      opacity: _showCursor ? 1 : 0,
                      child: AnimatedAlign(
                        key: const ValueKey('onboarding-detail-swipe-cursor'),
                        duration: const Duration(milliseconds: 1050),
                        curve: Curves.easeInOut,
                        alignment: _cursorAtRight
                            ? const Alignment(1, .55)
                            : const Alignment(-1, .55),
                        child: Transform.rotate(
                          angle: -.16,
                          child: const Icon(
                            Icons.touch_app_rounded,
                            color: Colors.white,
                            size: 52,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 8),
                              Shadow(color: _purple, blurRadius: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                    left: -14, child: _SideArrow(Icons.chevron_left_rounded)),
                const Positioned(
                    right: -14, child: _SideArrow(Icons.chevron_right_rounded)),
              ]),
          SizedBox(height: compact ? 5 : 8),
          SizedBox(
              height: compact ? 44 : 54,
              child: Row(children: [
                _Action(
                  icon: const Icon(Icons.bookmark_border_rounded,
                      color: Colors.white, size: 22),
                  label: getMenuItemTitle(widget.language, 'Bookmark'),
                ),
                _Action(
                  icon: Image.asset(
                    'assets/images/v2/translate.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                  label: getMenuItemTitle(widget.language, 'Translate'),
                ),
                _Action(
                  icon: Icon(
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? Icons.ios_share_outlined
                        : Icons.share_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: getMenuItemTitle(widget.language, 'Share'),
                ),
              ])),
          Container(height: 1, color: _border),
          SizedBox(height: compact ? 5 : 8),
          _Info(label('Director'), movie.director, font),
          _Info(label('Stars'), movie.stars, font),
          _Info(
              label('Country'),
              localizedCountries[widget.language]?['usa'] ?? 'United States',
              font),
          _Info(label('Running Time'), '${movie.runtime} ${label('Minute')}',
              font),
          const SizedBox(height: 4),
          ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.transparent])
                  .createShader(bounds),
              child: Text(movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white60, fontSize: font, height: 1.3))),
        ]);
      });
}

class _SideArrow extends StatelessWidget {
  const _SideArrow(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _panel,
          border: Border.all(color: _purple)),
      child: Icon(icon, color: _purple, size: 24));
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label});
  final Widget icon;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon,
        const SizedBox(height: 2),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
      ]));
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value, this.font);
  final String label, value;
  final double font;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w900)),
            TextSpan(text: value)
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: font)));
}

class _MovieCard extends StatelessWidget {
  const _MovieCard(this.poster, this.title, this.selected);
  final String poster, title;
  final bool selected;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
          color: const Color(0xFF27282B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? _purple : _border, width: selected ? 2 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: _purple.withValues(alpha: .35), blurRadius: 12)
                ]
              : null),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Expanded(
            child:
                SizedBox.expand(child: Image.asset(poster, fit: BoxFit.cover))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              const Text('2026.09.02',
                  style: TextStyle(color: Colors.white54, fontSize: 8)),
            ])),
      ]));
}
