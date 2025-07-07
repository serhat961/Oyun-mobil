import 'package:shared_preferences/shared_preferences.dart';

class GameRepository {
  static const String _highScoreKey = 'high_score';
  static const String _totalPlayTimeKey = 'total_play_time';
  static const String _gamesPlayedKey = 'games_played';
  static const String _linesColoredKey = 'lines_cleared';
  static const String _currentLevelKey = 'current_level';
  static const String _experiencePointsKey = 'experience_points';
  static const String _achievementsKey = 'achievements';

  // High Score
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  // Player Level (1-100)
  Future<int> getPlayerLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentLevelKey) ?? 1;
  }

  Future<void> savePlayerLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentLevelKey, level);
  }

  // Experience Points
  Future<int> getExperiencePoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_experiencePointsKey) ?? 0;
  }

  Future<void> saveExperiencePoints(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_experiencePointsKey, xp);
  }

  // Add experience and level up
  Future<PlayerProgress> addExperience(int gainedXp) async {
    final currentXp = await getExperiencePoints();
    final currentLevel = await getPlayerLevel();
    
    final newXp = currentXp + gainedXp;
    final newLevel = calculateLevelFromXp(newXp);
    
    await saveExperiencePoints(newXp);
    await savePlayerLevel(newLevel);
    
    return PlayerProgress(
      level: newLevel,
      experiencePoints: newXp,
      experienceToNextLevel: getXpForLevel(newLevel + 1) - newXp,
      leveledUp: newLevel > currentLevel,
    );
  }

  // Calculate level from XP (1-100)
  int calculateLevelFromXp(int xp) {
    if (xp < 100) return 1;
    return (xp / 100).floor().clamp(1, 100);
  }

  // Get XP required for specific level
  int getXpForLevel(int level) {
    return level * 100;
  }

  // Game Statistics
  Future<int> getGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gamesPlayedKey) ?? 0;
  }

  Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_gamesPlayedKey) ?? 0;
    await prefs.setInt(_gamesPlayedKey, current + 1);
  }

  Future<int> getLinesCleared() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_linesColoredKey) ?? 0;
  }

  Future<void> addLinesCleared(int lines) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_linesColoredKey) ?? 0;
    await prefs.setInt(_linesColoredKey, current + lines);
  }

  Future<int> getTotalPlayTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalPlayTimeKey) ?? 0;
  }

  Future<void> addPlayTime(int secondsPlayed) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalPlayTimeKey) ?? 0;
    await prefs.setInt(_totalPlayTimeKey, current + secondsPlayed);
  }

  // Game Session Data
  Future<void> saveGameSession(GameSession session) async {
    final currentHigh = await getHighScore();
    if (session.score > currentHigh) {
      await saveHighScore(session.score);
    }
    
    await incrementGamesPlayed();
    await addLinesCleared(session.linesCleared);
    await addPlayTime(session.playTimeInSeconds);
    
    // Add XP based on performance
    final gainedXp = calculateXpGain(session);
    await addExperience(gainedXp);
  }

  int calculateXpGain(GameSession session) {
    // Base XP: 10 per game
    int xp = 10;
    
    // Bonus XP for score (1 XP per 100 points)
    xp += (session.score / 100).floor();
    
    // Bonus XP for lines cleared (5 XP per line)
    xp += session.linesCleared * 5;
    
    // Bonus XP for level reached (10 XP per level)
    xp += session.levelReached * 10;
    
    return xp;
  }

  // Get complete player stats
  Future<PlayerStats> getPlayerStats() async {
    return PlayerStats(
      highScore: await getHighScore(),
      level: await getPlayerLevel(),
      experiencePoints: await getExperiencePoints(),
      gamesPlayed: await getGamesPlayed(),
      linesCleared: await getLinesCleared(),
      totalPlayTimeInSeconds: await getTotalPlayTime(),
    );
  }
}

class PlayerProgress {
  final int level;
  final int experiencePoints;
  final int experienceToNextLevel;
  final bool leveledUp;

  PlayerProgress({
    required this.level,
    required this.experiencePoints,
    required this.experienceToNextLevel,
    required this.leveledUp,
  });
}

class PlayerStats {
  final int highScore;
  final int level;
  final int experiencePoints;
  final int gamesPlayed;
  final int linesCleared;
  final int totalPlayTimeInSeconds;

  PlayerStats({
    required this.highScore,
    required this.level,
    required this.experiencePoints,
    required this.gamesPlayed,
    required this.linesCleared,
    required this.totalPlayTimeInSeconds,
  });

  String get playTimeFormatted {
    final hours = totalPlayTimeInSeconds ~/ 3600;
    final minutes = (totalPlayTimeInSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
}

class GameSession {
  final int score;
  final int linesCleared;
  final int levelReached;
  final int playTimeInSeconds;

  GameSession({
    required this.score,
    required this.linesCleared,
    required this.levelReached,
    required this.playTimeInSeconds,
  });
}