class FeaturedSectionRotation {
  const FeaturedSectionRotation._();

  static const specialSection = 3;
  static const quotesSection = 4;

  static int sectionForLaunch({required bool showQuotes}) =>
      showQuotes ? quotesSection : specialSection;

  static bool preferenceForNextLaunch({required bool showQuotes}) =>
      !showQuotes;
}
