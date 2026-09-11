import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/common/translate.dart';

const _blue = Color(0xFF3288FF);
const _purple = Color(0xFF9E25E9);
const _panel = Color(0xFF111214);
const _border = Color(0xFF45464B);
const _posterPaths = [
  'assets/images/onboarding/poster_odyssey.jpg',
  'assets/images/onboarding/poster_obsession.jpg',
  'assets/images/onboarding/poster_bikwang.jpg',
];

const _movieTitles = <String, List<String>>{
  'ko': ['오디세이', '옵세션', '비광'],
  'en': ['Odyssey', 'Obsession', 'Big Light'],
  'ja': ['オデッセイ', 'オプション', '光'],
  'zh': ['奥德赛', '痴迷', '大光'],
  'tw': ['奧德賽', '迷戀', '大光'],
  'fr': ['Odyssée', 'Obsession', 'Grande Lumière'],
  'de': ['Odyssee', 'Besessenheit', 'Großes Licht'],
  'es': ['Odisea', 'Obsesión', 'Gran luz'],
  'hi': ['ओडिसी', 'जुनून', 'बड़ी रोशनी'],
  'th': ['โอดิสซี', 'ความหมกมุ่น', 'แสงสว่างจ้า'],
};

const _obsessionOverviews = <String, String>{
  'ko': '‘베어’는 마법의 버드나무에 ‘니키’가 자신을 가장 사랑하게 해달라고 소원을 빕니다.',
  'en':
      'Bear wishes on a magical willow for Nikki to love him more than anyone.',
  'ja': 'ベアは魔法の柳に、ニッキーが自分を誰よりも愛してくれるよう願います。',
  'zh': '贝尔向魔法柳树许愿，希望妮基比任何人都更爱他。',
  'tw': '貝爾向魔法柳樹許願，希望妮基比任何人都更愛他。',
  'fr':
      'Bear souhaite auprès d’un saule magique que Nikki l’aime plus que tout.',
  'de':
      'Bear wünscht sich von einer magischen Weide, dass Nikki ihn am meisten liebt.',
  'es': 'Bear pide a un sauce mágico que Nikki lo ame más que a nadie.',
  'hi': 'बेयर जादुई विलो से इच्छा करता है कि निक्की उसे सबसे अधिक प्यार करे।',
  'th': 'แบร์ขอพรจากต้นหลิววิเศษให้นิกกี้รักเขามากกว่าใคร',
};

const _bikwangOverviews = <String, String>{
  'ko': '톱스타 부부의 가족이 충격적인 사건 뒤 감춰진 진실을 추적하기 시작합니다.',
  'en':
      'A celebrity family begins uncovering the truth behind a shocking incident.',
  'ja': 'トップスター一家が、衝撃的な事件の裏に隠された真実を追い始めます。',
  'zh': '明星家庭开始追查一场惊人事件背后隐藏的真相。',
  'tw': '明星家庭開始追查一場驚人事件背後隱藏的真相。',
  'fr':
      'Une famille de stars recherche la vérité cachée derrière un incident bouleversant.',
  'de':
      'Eine prominente Familie sucht nach der Wahrheit hinter einem schockierenden Vorfall.',
  'es':
      'Una familia de estrellas busca la verdad tras un incidente impactante.',
  'hi':
      'एक स्टार परिवार चौंकाने वाली घटना के पीछे छिपे सच की खोज शुरू करता है।',
  'th':
      'ครอบครัวดาราเริ่มตามหาความจริงที่ซ่อนอยู่เบื้องหลังเหตุการณ์สะเทือนขวัญ',
};

class OnboardingFeatureVisual extends StatelessWidget {
  const OnboardingFeatureVisual({
    super.key,
    required this.index,
    required this.language,
  });

  final int index;
  final String language;

  String get _language => _movieTitles.containsKey(language) ? language : 'en';

  @override
  Widget build(BuildContext context) => switch (index) {
        0 => _CountryOrderVisual(language: _language),
        1 => _TranslationVisual(language: _language),
        2 => _AutoplayVisual(language: _language),
        _ => _DetailSwipeVisual(language: _language),
      };
}

class _CountryOrderVisual extends StatelessWidget {
  const _CountryOrderVisual({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final countries = localizedCountries[language] ?? localizedCountries['en']!;
    final names = ['korea', 'usa', 'japan', 'taiwan']
        .map((key) => countries[key] ?? key)
        .toList();
    final titles = _movieTitles[language]!;
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 58,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    names.length,
                    (index) => Flexible(
                      child: Transform.rotate(
                        angle: index == 2 ? -0.045 : 0,
                        child: _CountryChip(
                          label: names[index],
                          active: index == 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 43,
                bottom: -17,
                child: Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 34,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Opacity(
                opacity: 0.48,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => _MovieCard(
                    poster: _posterPaths[index % 3],
                    title: titles[index % 3],
                    compact: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 64),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _panel.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _purple : _border),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: _purple.withValues(alpha: 0.4), blurRadius: 14)
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_indicator_rounded,
                size: 15, color: Colors.white70),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _TranslationVisual extends StatelessWidget {
  const _TranslationVisual({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final titles = _movieTitles[language]!;
    return Column(
      children: [
        _LanguageToggle(language: language),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox.expand(
                    child: Image.asset(_posterPaths[1], fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _TranslationPanel(
                    label: languageDisplayNames[language]!,
                    title: titles[1],
                    overview: _obsessionOverviews[language]!,
                    highlighted: true,
                  ),
                ),
                SizedBox(
                  height: 26,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(height: 1, color: _border),
                      Container(
                        color: _panel,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          key: ValueKey('onboarding-translation-arrow'),
                          color: _purple,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _TranslationPanel(
                    label: getMenuItemTitle(language, 'Original'),
                    title: 'Obsession',
                    overview:
                        'Bear makes a wish for Nikki to love him the most.',
                    highlighted: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF29282D),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [_blue, _purple]),
                ),
                alignment: Alignment.center,
                child: Text(
                  languageDisplayNames[language]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  getMenuItemTitle(language, 'Original'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
}

class _TranslationPanel extends StatelessWidget {
  const _TranslationPanel({
    required this.label,
    required this.title,
    required this.overview,
    required this.highlighted,
  });

  final String label;
  final String title;
  final String overview;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final dense = constraints.maxHeight < 72;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 13,
              vertical: dense ? 3 : 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color:
                        highlighted ? const Color(0xFF5EA7FF) : Colors.white54,
                    fontSize: dense ? 9 : 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: dense ? 1 : 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: dense ? 11 : 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: dense ? 1 : 2),
                Text(
                  overview,
                  maxLines: dense ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: dense ? 8.5 : 10,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _AutoplayVisual extends StatelessWidget {
  const _AutoplayVisual({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final titles = _movieTitles[language]!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final playSize =
            (constraints.maxHeight * 0.2).clamp(66.0, 88.0).toDouble();
        final cardsHeight =
            (constraints.maxHeight * 0.46).clamp(135.0, 225.0).toDouble();
        final gap = (constraints.maxHeight * 0.035).clamp(8.0, 18.0).toDouble();
        return Column(
          children: [
            Container(
              width: playSize,
              height: playSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_purple, _blue]),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: playSize * 0.61,
              ),
            ),
            SizedBox(height: gap),
            const SizedBox(
              height: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('1 / 6',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '→',
                      key: ValueKey('onboarding-autoplay-arrow'),
                      style: TextStyle(
                        color: _purple,
                        fontSize: 27,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '2 / 6',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gap),
            SizedBox(
              height: cardsHeight,
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _MovieCard(
                        poster: _posterPaths[(index + 1) % 3],
                        title: titles[(index + 1) % 3],
                        selected: index == 0,
                        compact: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: gap),
            const _ProgressTrack(),
          ],
        );
      },
    );
  }
}

class _DetailSwipeVisual extends StatelessWidget {
  const _DetailSwipeVisual({required this.language});

  final String language;

  String _detailLabel(String key) =>
      movieDetailTranslations[key]?[language] ??
      movieDetailTranslations[key]?['en'] ??
      key;

  @override
  Widget build(BuildContext context) {
    final title = _movieTitles[language]![2];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 430;
        final extraCompact = constraints.maxHeight < 350;
        final videoHeight = extraCompact
            ? (constraints.maxWidth / 2.4).clamp(108.0, 130.0).toDouble()
            : (constraints.maxWidth / (compact ? 2.05 : 1.78))
                .clamp(140.0, 190.0)
                .toDouble();
        final swipeHeight = extraCompact ? 32.0 : (compact ? 38.0 : 44.0);
        final actionHeight = extraCompact ? 46.0 : (compact ? 54.0 : 62.0);
        final infoFontSize = extraCompact ? 9.0 : (compact ? 11.0 : 12.0);
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(-150, 0),
                  child: _SidePreview(
                    poster: _posterPaths[1],
                    height: videoHeight,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(150, 0),
                  child: _SidePreview(
                    poster: _posterPaths[0],
                    height: videoHeight,
                  ),
                ),
                Container(
                  height: videoHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _border),
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/images/onboarding/poster_bikwang.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 10,
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: swipeHeight,
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: _purple, size: 30),
                      SizedBox(width: 75),
                      Icon(Icons.arrow_forward_rounded,
                          color: _purple, size: 30),
                    ],
                  ),
                  Icon(Icons.touch_app_rounded, color: Colors.white, size: 31),
                ],
              ),
            ),
            Container(height: 1, color: _border),
            SizedBox(
              height: actionHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Action(
                    icon: Icons.bookmark_border_rounded,
                    label: getMenuItemTitle(language, 'Bookmark'),
                  ),
                  _Action(
                    icon: Icons.translate_rounded,
                    label: getMenuItemTitle(language, 'Translate'),
                  ),
                  _Action(
                    icon: Icons.share_outlined,
                    label: getMenuItemTitle(language, 'Share'),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: _border),
            SizedBox(height: extraCompact ? 4 : (compact ? 6 : 8)),
            _InfoLine(
              label: _detailLabel('Director'),
              value: 'Lee Ji-won',
              fontSize: infoFontSize,
            ),
            _InfoLine(
              label: _detailLabel('Stars'),
              value: 'Ryu Seung-ryong · Ha Ji-won',
              fontSize: infoFontSize,
            ),
            _InfoLine(
              label: _detailLabel('Country'),
              value: localizedCountries[language]?['korea'] ?? 'Korea',
              fontSize: infoFontSize,
            ),
            _InfoLine(
              label: _detailLabel('Running Time'),
              value: '110 ${_detailLabel('Minute')}',
              fontSize: infoFontSize,
            ),
            SizedBox(height: extraCompact ? 4 : (compact ? 5 : 7)),
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.transparent],
              ).createShader(bounds),
              child: Text(
                _bikwangOverviews[language]!,
                maxLines: 2,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: extraCompact ? 9 : (compact ? 11 : 12),
                  height: 1.35,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SidePreview extends StatelessWidget {
  const _SidePreview({required this.poster, required this.height});

  final String poster;
  final double height;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.34,
        child: Container(
          width: 130,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image:
                DecorationImage(image: AssetImage(poster), fit: BoxFit.cover),
          ),
        ),
      );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    required this.fontSize,
  });

  final String label;
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              TextSpan(text: value),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
      );
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.poster,
    required this.title,
    required this.compact,
    this.selected = false,
  });

  final String poster;
  final String title;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF27282B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? _purple : _border, width: selected ? 2 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: _purple.withValues(alpha: 0.35), blurRadius: 12)
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
                child: SizedBox.expand(
                    child: Image.asset(poster, fit: BoxFit.cover))),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 7, vertical: compact ? 6 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  const Text('2026.09.02',
                      style: TextStyle(color: Colors.white54, fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue,
                border: Border.all(color: _purple, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: _purple.withValues(alpha: 0.5), blurRadius: 10)
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 24,
                child: const Center(
                  child: Text(
                    '→',
                    key: ValueKey('onboarding-progress-arrow'),
                    style: TextStyle(
                      color: _purple,
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue,
                border: Border.all(color: _purple, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: _purple.withValues(alpha: 0.5), blurRadius: 10)
                ],
              ),
            ),
          ],
        ),
      );
}
