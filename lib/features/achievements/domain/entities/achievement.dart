import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final AchievementCategory category;
  final int requiredValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward;
  final AchievementRarity rarity;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.requiredValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpReward = 0,
    this.rarity = AchievementRarity.common,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    AchievementCategory? category,
    int? requiredValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
    AchievementRarity? rarity,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      category: category ?? this.category,
      requiredValue: requiredValue ?? this.requiredValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
      rarity: rarity ?? this.rarity,
    );
  }

  double get progress => currentValue / requiredValue;
  
  bool get isCompleted => currentValue >= requiredValue;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconPath,
        category,
        requiredValue,
        currentValue,
        isUnlocked,
        unlockedAt,
        xpReward,
        rarity,
      ];
}

enum AchievementCategory {
  gameplay('Gameplay'),
  learning('Learning'),
  social('Social'),
  progression('Progression'),
  special('Special');

  const AchievementCategory(this.displayName);
  final String displayName;
}

enum AchievementRarity {
  common('Common'),
  uncommon('Uncommon'),
  rare('Rare'),
  epic('Epic'),
  legendary('Legendary');

  const AchievementRarity(this.displayName);
  final String displayName;
}

class AchievementConstants {
  static const Map<AchievementRarity, Map<String, dynamic>> rarityConfig = {
    AchievementRarity.common: {
      'color': 0xFF9E9E9E, // Gray
      'xpMultiplier': 1.0,
    },
    AchievementRarity.uncommon: {
      'color': 0xFF4CAF50, // Green
      'xpMultiplier': 1.5,
    },
    AchievementRarity.rare: {
      'color': 0xFF2196F3, // Blue
      'xpMultiplier': 2.0,
    },
    AchievementRarity.epic: {
      'color': 0xFF9C27B0, // Purple
      'xpMultiplier': 3.0,
    },
    AchievementRarity.legendary: {
      'color': 0xFFFF9800, // Orange
      'xpMultiplier': 5.0,
    },
  };
}