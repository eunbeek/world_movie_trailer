import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
