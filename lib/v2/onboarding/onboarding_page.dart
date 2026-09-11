import 'package:flutter/material.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/v2/onboarding/onboarding_content.dart';
import 'package:world_movie_trailer/v2/onboarding/onboarding_visuals.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.language,
    required this.onComplete,
  });

  final String language;
  final Future<void> Function() onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _page = 0;
  bool _finishing = false;

  List<OnboardingCopy> get _pages =>
      onboardingCopies[widget.language] ?? onboardingCopies['en']!;

  Map<String, String> get _actions =>
      onboardingActionLabels[widget.language] ?? onboardingActionLabels['en']!;

  Future<void> _complete() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastPage = _page == _pages.length - 1;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BackgroundWidget(isPausePage: false, isTapeExist: true),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finishing ? null : _complete,
                    child: Text(_actions['skip']!),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (context, index) => _OnboardingFeature(
                      copy: _pages[index],
                      index: index,
                      language: widget.language,
                    ),
                  ),
                ),
                SizedBox(
                  height: 88,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: index == _page ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: index == _page
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF3288FF),
                                        Color(0xFFB21FE8),
                                      ],
                                    )
                                  : null,
                              color: index == _page
                                  ? null
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: lastPage
                            ? SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3288FF),
                                        Color(0xFFB21FE8),
                                      ],
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: _finishing ? null : _complete,
                                    child: _finishing
                                        ? const SizedBox.square(
                                            dimension: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _actions['start']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                  ),
                                ),
                              )
                            : const SizedBox(height: 54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingFeature extends StatelessWidget {
  const _OnboardingFeature({
    required this.copy,
    required this.index,
    required this.language,
  });

  final OnboardingCopy copy;
  final int index;
  final String language;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 360 ? 22.0 : 32.0;
          final compactHeight = constraints.maxHeight < 480;
          final titleHeight = compactHeight ? 64.0 : 70.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(
                  height: compactHeight ? 120 : 136,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: compactHeight ? 0 : 4),
                      SizedBox(
                        width:
                            (constraints.maxWidth * 0.86).clamp(240.0, 320.0),
                        height: titleHeight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: Text(
                            copy.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compactHeight ? 27 : 29,
                              height: 1.22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compactHeight ? 6 : 8),
                      SizedBox(
                        height: compactHeight ? 50 : 54,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            copy.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: compactHeight ? 12 : 14,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: OnboardingFeatureVisual(
                    index: index,
                    language: language,
                  ),
                ),
              ],
            ),
          );
        },
      );
}
