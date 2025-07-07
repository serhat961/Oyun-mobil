class LevelManager {
  int _xp = 0;
  int _level = 1;

  int get xp => _xp;
  int get level => _level;
  int get nextThreshold => _level * 100;
  double get progress => _xp / nextThreshold;

  void addXp(int amount) {
    _xp += amount;
    while (_xp >= nextThreshold) {
      _xp -= nextThreshold;
      _level += 1;
    }
  }

  void reset() {
    _xp = 0;
    _level = 1;
  }
}