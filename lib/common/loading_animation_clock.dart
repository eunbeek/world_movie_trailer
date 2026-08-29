/// Keeps full-page loading animations visually continuous when their widget
/// tree changes between application initialization stages.
class LoadingAnimationClock {
  LoadingAnimationClock._();

  static final Stopwatch _stopwatch = Stopwatch()..start();

  static double progress(Duration duration) {
    final durationMs = duration.inMilliseconds;
    if (durationMs <= 0) return 0;
    return (_stopwatch.elapsedMilliseconds % durationMs) / durationMs;
  }
}
