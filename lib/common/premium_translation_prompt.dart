import 'package:flutter/material.dart';
import 'package:world_movie_trailer/layout/donation_page.dart';

const _labels = <String, Map<String, String>>{
  'ko': {
    'title': '번역 기능은 Premium 전용입니다',
    'body': 'Premium으로 업그레이드하면 영화 정보 번역과 광고 제거 기능을 사용할 수 있습니다.',
    'cancel': '나중에',
    'upgrade': '구매하기',
  },
  'en': {
    'title': 'Translation is a Premium feature',
    'body': 'Upgrade to Premium to translate movie details and remove ads.',
    'cancel': 'Not now',
    'upgrade': 'Upgrade',
  },
};

Future<void> showPremiumTranslationPrompt(
  BuildContext context,
  String language,
) async {
  final label = _labels[language] ?? _labels['en']!;
  final upgrade = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(label['title']!),
      content: Text(label['body']!),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(label['cancel']!),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(label['upgrade']!),
        ),
      ],
    ),
  );
  if (upgrade == true && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DonationPage()),
    );
  }
}
