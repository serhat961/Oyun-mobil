import 'package:flutter/material.dart';
import 'package:polyglot_puzzle/features/achievements/domain/entities/achievement.dart';
import 'package:polyglot_puzzle/core/themes/app_theme.dart';
import 'package:polyglot_puzzle/core/services/audio_service.dart';

class AchievementUnlockDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementUnlockDialog({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(AchievementConstants.rarityConfig[achievement.rarity]!['color']);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rarityColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Achievement unlocked header
            Text(
              '🏆 ACHIEVEMENT UNLOCKED!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: rarityColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Achievement icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Icon(
                Icons.emoji_events,
                size: 48,
                color: rarityColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Achievement name
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Achievement description
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Rarity and XP info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Rarity chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: rarityColor, width: 1),
                  ),
                  child: Text(
                    achievement.rarity.displayName,
                    style: TextStyle(
                      color: rarityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[900]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    '+${achievement.xpReward} XP',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: rarityColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, Achievement achievement) {
    // Play achievement unlock sound
    AudioService().playLevelUp(); // We can use level up sound for achievements
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
      ),
    );
  }
}

// Widget for showing multiple achievements sequentially
class AchievementSequenceDialog extends StatefulWidget {
  final List<Achievement> achievements;

  const AchievementSequenceDialog({
    Key? key,
    required this.achievements,
  }) : super(key: key);

  @override
  State<AchievementSequenceDialog> createState() => _AchievementSequenceDialogState();
}

class _AchievementSequenceDialogState extends State<AchievementSequenceDialog> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= widget.achievements.length) {
      return const SizedBox(); // All done
    }

    final achievement = widget.achievements[currentIndex];
    final rarityColor = Color(AchievementConstants.rarityConfig[achievement.rarity]!['color']);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rarityColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            if (widget.achievements.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < widget.achievements.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == currentIndex ? rarityColor : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            
            if (widget.achievements.length > 1) const SizedBox(height: 16),
            
            // Achievement unlocked header
            Text(
              '🏆 ACHIEVEMENT UNLOCKED!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: rarityColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Achievement icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Icon(
                Icons.emoji_events,
                size: 48,
                color: rarityColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Achievement name
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Achievement description
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Rarity and XP info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Rarity chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: rarityColor, width: 1),
                  ),
                  child: Text(
                    achievement.rarity.displayName,
                    style: TextStyle(
                      color: rarityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[900]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    '+${achievement.xpReward} XP',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Navigation buttons
            Row(
              children: [
                if (currentIndex < widget.achievements.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextAchievement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rarityColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Next (${currentIndex + 1}/${widget.achievements.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rarityColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _nextAchievement() {
    setState(() {
      currentIndex++;
    });
    
    // Play sound for next achievement
    AudioService().playLevelUp();
  }

  static void show(BuildContext context, List<Achievement> achievements) {
    if (achievements.isEmpty) return;
    
    // Play initial sound
    AudioService().playLevelUp();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementSequenceDialog(
        achievements: achievements,
      ),
    );
  }
}