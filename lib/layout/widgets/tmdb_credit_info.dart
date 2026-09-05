import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String localizedTmdbCreditName({
  required Map<String, dynamic> translations,
  required String language,
  required Object? tmdbId,
  required String fallback,
}) {
  final id = tmdbId?.toString() ?? '';
  if (id.isEmpty) return fallback;
  const aliases = {'zh': 'cn', 'hi': 'in'};
  final translation = translations[aliases[language] ?? language];
  if (translation is! Map) return fallback;
  final names = translation['creditNames'];
  if (names is! Map) return fallback;
  final localized = (names[id] ?? '').toString().trim();
  return localized.isEmpty ? fallback : localized;
}

List<String> splitTmdbCreditNames(String value) => value
    .split(value.contains('|||') ? RegExp(r'\s*\|\|\|\s*') : RegExp(r'[,，]'))
    .map((name) => name.trim())
    .where((name) => name.isNotEmpty)
    .toList();

/// Keeps the Sheet's localized names while attaching matching TMDB person IDs.
List<TmdbCreditPerson> specialTmdbCreditPeople({
  required String displayCredits,
  required String originalCredits,
  required Map<String, dynamic>? credits,
}) {
  String normalized(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  final displayNames = splitTmdbCreditNames(displayCredits);
  final originalNames = splitTmdbCreditNames(originalCredits);
  final people = <dynamic>[
    ...?credits?['cast'] as List?,
    ...?credits?['crew'] as List?,
  ];
  return List.generate(displayNames.length, (index) {
    final originalName = index < originalNames.length
        ? originalNames[index]
        : displayNames[index];
    final target = normalized(originalName);
    Map? match;
    for (final person in people) {
      if (person is Map && normalized('${person['name'] ?? ''}') == target) {
        match = person;
        break;
      }
    }
    return TmdbCreditPerson(
      name: displayNames[index],
      tmdbId: match?['id'],
    );
  });
}

class TmdbCreditPerson {
  const TmdbCreditPerson({required this.name, this.tmdbId});

  final String name;
  final Object? tmdbId;

  Uri get uri {
    final id = int.tryParse(tmdbId?.toString() ?? '');
    if (id != null && id > 0) {
      return Uri.parse('https://www.themoviedb.org/person/$id');
    }
    return Uri.https(
      'www.themoviedb.org',
      '/search/person',
      <String, String>{'query': name},
    );
  }
}

class TmdbCreditInfo extends StatelessWidget {
  const TmdbCreditInfo({
    super.key,
    required this.label,
    required this.people,
    this.alignment = WrapAlignment.start,
  });

  final String label;
  final List<TmdbCreditPerson> people;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 17,
    );
    final linkStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        alignment: alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$label: ',
              style: baseStyle.copyWith(fontWeight: FontWeight.w800)),
          for (var index = 0; index < people.length; index++) ...[
            InkWell(
              onTap: () => launchUrl(
                people[index].uri,
                mode: LaunchMode.externalApplication,
              ),
              child: Text(people[index].name, style: linkStyle),
            ),
            if (index < people.length - 1) Text(', ', style: baseStyle),
          ],
        ],
      ),
    );
  }
}
