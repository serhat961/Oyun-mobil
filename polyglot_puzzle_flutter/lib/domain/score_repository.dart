import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepository {
  static const _bestKey = 'best_score';
  static const _lastKey = 'last_score';

  static final ScoreRepository instance = ScoreRepository._internal();
  ScoreRepository._internal();

  Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestKey) ?? 0;
  }

  Future<int> getLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastKey) ?? 0;
  }

  Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastKey, score);
    final best = prefs.getInt(_bestKey) ?? 0;
    if (score > best) {
      await prefs.setInt(_bestKey, score);
    }
  }
}