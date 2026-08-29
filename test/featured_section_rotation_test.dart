import 'package:flutter_test/flutter_test.dart';
import 'package:world_movie_trailer/v2/home/featured_section_rotation.dart';

void main() {
  test('A fresh install shows Special before Movie Quotes', () {
    var showQuotes = false;

    expect(
      FeaturedSectionRotation.sectionForLaunch(showQuotes: showQuotes),
      FeaturedSectionRotation.specialSection,
    );

    showQuotes = FeaturedSectionRotation.preferenceForNextLaunch(
      showQuotes: showQuotes,
    );
    expect(
      FeaturedSectionRotation.sectionForLaunch(showQuotes: showQuotes),
      FeaturedSectionRotation.quotesSection,
    );
  });

  test('Special and Movie Quotes alternate on successive app launches', () {
    var showQuotes = true;
    final sections = <int>[];
    for (var launch = 0; launch < 6; launch++) {
      sections.add(FeaturedSectionRotation.sectionForLaunch(
        showQuotes: showQuotes,
      ));
      showQuotes = FeaturedSectionRotation.preferenceForNextLaunch(
        showQuotes: showQuotes,
      );
    }
    expect(sections, [4, 3, 4, 3, 4, 3]);
  });
}
