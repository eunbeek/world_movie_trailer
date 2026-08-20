class DetailAdPolicy {
  static const int interval = 7;

  static bool shouldShow(int detailOpenCount) =>
      detailOpenCount > 0 && detailOpenCount % interval == 0;
}
