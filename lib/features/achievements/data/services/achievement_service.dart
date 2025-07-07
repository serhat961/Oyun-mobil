import 'package:shared_preferences/shared_preferences.dart';
import 'package:polyglot_puzzle/features/achievements/domain/entities/achievement.dart';
import 'dart:convert';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  static const String _achievementsKey = 'achievements';
  static const String _unlockedAchievementsKey = 'unlocked_achievements';

  // Predefined achievements
  final List<Achievement> _allAchievements = [
    // Gameplay Achievements
    Achievement(
      id: 'first_game',
      name: 'First Steps',
      description: 'Play your first game',
      iconPath: 'assets/icons/first_game.png',
      category: AchievementCategory.gameplay,
      requiredValue: 1,
      xpReward: 50,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'games_10',
      name: 'Getting Started',
      description: 'Play 10 games',
      iconPath: 'assets/icons/games_10.png',
      category: AchievementCategory.gameplay,
      requiredValue: 10,
      xpReward: 100,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'games_100',
      name: 'Dedicated Player',
      description: 'Play 100 games',
      iconPath: 'assets/icons/games_100.png',
      category: AchievementCategory.gameplay,
      requiredValue: 100,
      xpReward: 500,
      rarity: AchievementRarity.uncommon,
    ),
    
    // Score Achievements
    Achievement(
      id: 'score_1000',
      name: 'Score Hunter',
      description: 'Reach 1,000 points in a single game',
      iconPath: 'assets/icons/score_1000.png',
      category: AchievementCategory.gameplay,
      requiredValue: 1000,
      xpReward: 100,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'score_10000',
      name: 'High Scorer',
      description: 'Reach 10,000 points in a single game',
      iconPath: 'assets/icons/score_10000.png',
      category: AchievementCategory.gameplay,
      requiredValue: 10000,
      xpReward: 300,
      rarity: AchievementRarity.uncommon,
    ),
    Achievement(
      id: 'score_100000',
      name: 'Score Master',
      description: 'Reach 100,000 points in a single game',
      iconPath: 'assets/icons/score_100000.png',
      category: AchievementCategory.gameplay,
      requiredValue: 100000,
      xpReward: 1000,
      rarity: AchievementRarity.rare,
    ),
    
    // Line Clear Achievements
    Achievement(
      id: 'lines_10',
      name: 'Line Clearer',
      description: 'Clear 10 lines',
      iconPath: 'assets/icons/lines_10.png',
      category: AchievementCategory.gameplay,
      requiredValue: 10,
      xpReward: 75,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'lines_100',
      name: 'Line Expert',
      description: 'Clear 100 lines',
      iconPath: 'assets/icons/lines_100.png',
      category: AchievementCategory.gameplay,
      requiredValue: 100,
      xpReward: 250,
      rarity: AchievementRarity.uncommon,
    ),
    Achievement(
      id: 'combo_5',
      name: 'Combo Master',
      description: 'Clear 5 lines in a single move',
      iconPath: 'assets/icons/combo_5.png',
      category: AchievementCategory.gameplay,
      requiredValue: 5,
      xpReward: 200,
      rarity: AchievementRarity.rare,
    ),
    
    // Learning Achievements
    Achievement(
      id: 'words_50',
      name: 'Vocabulary Builder',
      description: 'Learn 50 new words',
      iconPath: 'assets/icons/words_50.png',
      category: AchievementCategory.learning,
      requiredValue: 50,
      xpReward: 200,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'words_500',
      name: 'Word Master',
      description: 'Learn 500 new words',
      iconPath: 'assets/icons/words_500.png',
      category: AchievementCategory.learning,
      requiredValue: 500,
      xpReward: 1000,
      rarity: AchievementRarity.uncommon,
    ),
    Achievement(
      id: 'daily_streak_7',
      name: 'Week Warrior',
      description: 'Play for 7 consecutive days',
      iconPath: 'assets/icons/daily_streak_7.png',
      category: AchievementCategory.learning,
      requiredValue: 7,
      xpReward: 300,
      rarity: AchievementRarity.uncommon,
    ),
    Achievement(
      id: 'daily_streak_30',
      name: 'Month Master',
      description: 'Play for 30 consecutive days',
      iconPath: 'assets/icons/daily_streak_30.png',
      category: AchievementCategory.learning,
      requiredValue: 30,
      xpReward: 1500,
      rarity: AchievementRarity.rare,
    ),
    
    // Progression Achievements
    Achievement(
      id: 'level_10',
      name: 'Rising Star',
      description: 'Reach level 10',
      iconPath: 'assets/icons/level_10.png',
      category: AchievementCategory.progression,
      requiredValue: 10,
      xpReward: 200,
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'level_50',
      name: 'Experienced Player',
      description: 'Reach level 50',
      iconPath: 'assets/icons/level_50.png',
      category: AchievementCategory.progression,
      requiredValue: 50,
      xpReward: 1000,
      rarity: AchievementRarity.uncommon,
    ),
    Achievement(
      id: 'level_100',
      name: 'Max Level',
      description: 'Reach the maximum level 100',
      iconPath: 'assets/icons/level_100.png',
      category: AchievementCategory.progression,
      requiredValue: 100,
      xpReward: 5000,
      rarity: AchievementRarity.legendary,
    ),
    
    // Special Achievements
    Achievement(
      id: 'perfect_game',
      name: 'Perfect Game',
      description: 'Complete a game without any mistakes',
      iconPath: 'assets/icons/perfect_game.png',
      category: AchievementCategory.special,
      requiredValue: 1,
      xpReward: 500,
      rarity: AchievementRarity.epic,
    ),
    Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete a game in under 2 minutes',
      iconPath: 'assets/icons/speed_demon.png',
      category: AchievementCategory.special,
      requiredValue: 120, // seconds
      xpReward: 300,
      rarity: AchievementRarity.rare,
    ),
    Achievement(
      id: 'polyglot',
      name: 'True Polyglot',
      description: 'Play in 3 different languages',
      iconPath: 'assets/icons/polyglot.png',
      category: AchievementCategory.special,
      requiredValue: 3,
      xpReward: 1000,
      rarity: AchievementRarity.epic,
    ),
  ];

  // Get all achievements with current progress
  Future<List<Achievement>> getAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    
    if (achievementsJson == null) {
      // First time - initialize with default achievements
      await _initializeAchievements();
      return _allAchievements;
    }
    
    final Map<String, dynamic> achievementsData = json.decode(achievementsJson);
    
    return _allAchievements.map((achievement) {
      final data = achievementsData[achievement.id];
      if (data != null) {
        return achievement.copyWith(
          currentValue: data['currentValue'] ?? 0,
          isUnlocked: data['isUnlocked'] ?? false,
          unlockedAt: data['unlockedAt'] != null 
              ? DateTime.parse(data['unlockedAt'])
              : null,
        );
      }
      return achievement;
    }).toList();
  }

  // Get unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    final allAchievements = await getAllAchievements();
    return allAchievements.where((achievement) => achievement.isUnlocked).toList();
  }

  // Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(AchievementCategory category) async {
    final allAchievements = await getAllAchievements();
    return allAchievements.where((achievement) => achievement.category == category).toList();
  }

  // Update achievement progress
  Future<List<Achievement>> updateAchievementProgress(Map<String, int> progressUpdates) async {
    final achievements = await getAllAchievements();
    final newlyUnlocked = <Achievement>[];
    final updatedAchievements = <Achievement>[];
    
    for (final achievement in achievements) {
      final newProgress = progressUpdates[achievement.id];
      if (newProgress != null && newProgress > achievement.currentValue) {
        final updatedAchievement = achievement.copyWith(
          currentValue: newProgress,
          isUnlocked: achievement.isUnlocked || newProgress >= achievement.requiredValue,
          unlockedAt: achievement.isUnlocked 
              ? achievement.unlockedAt 
              : (newProgress >= achievement.requiredValue ? DateTime.now() : null),
        );
        
        if (!achievement.isUnlocked && updatedAchievement.isUnlocked) {
          newlyUnlocked.add(updatedAchievement);
        }
        
        updatedAchievements.add(updatedAchievement);
      } else {
        updatedAchievements.add(achievement);
      }
    }
    
    await _saveAchievements(updatedAchievements);
    return newlyUnlocked;
  }

  // Check specific achievement types
  Future<List<Achievement>> checkGameplayAchievements({
    int? score,
    int? linesCleared,
    int? gamesPlayed,
    int? gameTimeSeconds,
    int? comboCount,
  }) async {
    final updates = <String, int>{};
    
    if (score != null) {
      updates['score_1000'] = score >= 1000 ? 1000 : score;
      updates['score_10000'] = score >= 10000 ? 10000 : score;
      updates['score_100000'] = score >= 100000 ? 100000 : score;
    }
    
    if (linesCleared != null) {
      updates['lines_10'] = linesCleared;
      updates['lines_100'] = linesCleared;
    }
    
    if (gamesPlayed != null) {
      updates['first_game'] = gamesPlayed >= 1 ? 1 : gamesPlayed;
      updates['games_10'] = gamesPlayed;
      updates['games_100'] = gamesPlayed;
    }
    
    if (gameTimeSeconds != null && gameTimeSeconds <= 120) {
      updates['speed_demon'] = 120;
    }
    
    if (comboCount != null) {
      updates['combo_5'] = comboCount >= 5 ? 5 : comboCount;
    }
    
    return await updateAchievementProgress(updates);
  }

  Future<List<Achievement>> checkLearningAchievements({
    int? wordsLearned,
    int? dailyStreak,
    int? languagesUsed,
  }) async {
    final updates = <String, int>{};
    
    if (wordsLearned != null) {
      updates['words_50'] = wordsLearned;
      updates['words_500'] = wordsLearned;
    }
    
    if (dailyStreak != null) {
      updates['daily_streak_7'] = dailyStreak;
      updates['daily_streak_30'] = dailyStreak;
    }
    
    if (languagesUsed != null) {
      updates['polyglot'] = languagesUsed;
    }
    
    return await updateAchievementProgress(updates);
  }

  Future<List<Achievement>> checkProgressionAchievements({
    int? playerLevel,
  }) async {
    final updates = <String, int>{};
    
    if (playerLevel != null) {
      updates['level_10'] = playerLevel;
      updates['level_50'] = playerLevel;
      updates['level_100'] = playerLevel;
    }
    
    return await updateAchievementProgress(updates);
  }

  // Initialize achievements on first launch
  Future<void> _initializeAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsData = <String, dynamic>{};
    
    for (final achievement in _allAchievements) {
      achievementsData[achievement.id] = {
        'currentValue': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      };
    }
    
    await prefs.setString(_achievementsKey, json.encode(achievementsData));
  }

  // Save achievements to storage
  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsData = <String, dynamic>{};
    
    for (final achievement in achievements) {
      achievementsData[achievement.id] = {
        'currentValue': achievement.currentValue,
        'isUnlocked': achievement.isUnlocked,
        'unlockedAt': achievement.unlockedAt?.toIso8601String(),
      };
    }
    
    await prefs.setString(_achievementsKey, json.encode(achievementsData));
  }

  // Get achievement statistics
  Future<Map<String, int>> getAchievementStats() async {
    final achievements = await getAllAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalXpFromAchievements = achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.xpReward);
    
    return {
      'total': achievements.length,
      'unlocked': unlockedCount,
      'totalXp': totalXpFromAchievements,
      'completion': ((unlockedCount / achievements.length) * 100).round(),
    };
  }
}