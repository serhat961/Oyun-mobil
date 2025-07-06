class ScoreCalculator {
  int _score = 0;
  int get score => _score;

  void updateScore(List<int> clearedLines) {
    if (clearedLines.isEmpty) return;
    int base = 10 * clearedLines.length;
    int multiplier = clearedLines.length > 1 ? clearedLines.length : 1;
    _score += base * multiplier;
  }

  void reset() => _score = 0;
}