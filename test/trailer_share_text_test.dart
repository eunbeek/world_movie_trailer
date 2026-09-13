import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/layout/widgets/trailer_share_text.dart';

void main() {
  test('shares title, trailer link and app attribution', () {
    expect(
      buildTrailerShareText(
        title: 'The Odyssey',
        trailerId: 'AyIZ9tiiN8I',
      ),
      'The Odyssey\n'
      'https://www.youtube.com/watch?v=AyIZ9tiiN8I\n\n'
      'From World Movie Trailer',
    );
  });
}
