import 'package:flutter/material.dart';
import 'package:polyglot_puzzle/core/themes/app_theme.dart';
import 'package:polyglot_puzzle/features/game/data/repositories/game_repository.dart';

class PlayerProfileWidget extends StatefulWidget {
  const PlayerProfileWidget({Key? key}) : super(key: key);

  @override
  State<PlayerProfileWidget> createState() => _PlayerProfileWidgetState();
}

class _PlayerProfileWidgetState extends State<PlayerProfileWidget> {
  final GameRepository _gameRepository = GameRepository();
  PlayerStats? _playerStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerStats();
  }

  Future<void> _loadPlayerStats() async {
    try {
      final stats = await _gameRepository.getPlayerStats();
      setState(() {
        _playerStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_playerStats == null) {
      return const Center(child: Text('Profil yüklenemedi'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  'L${_playerStats!.level}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oyuncu Seviyesi',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Level ${_playerStats!.level}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    _buildXpProgressBar(),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'En Yüksek Skor',
                _playerStats!.highScore.toString(),
                Icons.star,
                Colors.yellow,
              ),
              _buildStatCard(
                'Oynanan Oyun',
                _playerStats!.gamesPlayed.toString(),
                Icons.videogame_asset,
                Colors.blue,
              ),
              _buildStatCard(
                'Temizlenen Satır',
                _playerStats!.linesCleared.toString(),
                Icons.clear_all,
                Colors.green,
              ),
              _buildStatCard(
                'Oyun Süresi',
                _playerStats!.playTimeFormatted,
                Icons.access_time,
                Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Level Progress Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'XP: ${_playerStats!.experiencePoints}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Sonraki seviye: ${_getXpToNextLevel()} XP',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpProgressBar() {
    final currentXp = _playerStats!.experiencePoints;
    final currentLevelXp = _gameRepository.getXpForLevel(_playerStats!.level);
    final nextLevelXp = _gameRepository.getXpForLevel(_playerStats!.level + 1);
    
    final progress = (currentXp - currentLevelXp) / (nextLevelXp - currentLevelXp);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[700],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% sonraki seviyeye',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getXpToNextLevel() {
    final currentXp = _playerStats!.experiencePoints;
    final nextLevelXp = _gameRepository.getXpForLevel(_playerStats!.level + 1);
    return nextLevelXp - currentXp;
  }
}

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final int gainedXp;

  const LevelUpDialog({
    Key? key,
    required this.newLevel,
    required this.gainedXp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level up icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                size: 48,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Congrats text
            Text(
              'TEBRİKLER!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Seviye ${newLevel}\'e yükseldiniz!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            // XP gained
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${gainedXp} XP kazandınız',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Devam Et'),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, int newLevel, int gainedXp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(
        newLevel: newLevel,
        gainedXp: gainedXp,
      ),
    );
  }
}