class ScoreCalculator {
  int _score = 0;
  int get score => _score;

  /// Adds score based on number of lines cleared and chain depth.
  /// [lines] number of rows/columns cleared in this cascade step.
  /// [chain] starts at 1 for first clear, increases with each cascade.
  void addClears({required int lines, required int chain}) {
    if (lines == 0) return;
    final int base = 10 * lines;
    _score += base * chain;
  }

  void reset() => _score = 0;
}