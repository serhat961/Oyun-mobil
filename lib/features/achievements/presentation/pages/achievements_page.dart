import 'package:flutter/material.dart';
import 'package:polyglot_puzzle/features/achievements/domain/entities/achievement.dart';
import 'package:polyglot_puzzle/features/achievements/data/services/achievement_service.dart';
import 'package:polyglot_puzzle/core/themes/app_theme.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> with SingleTickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
  
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  
  late TabController _tabController;
  AchievementCategory _selectedCategory = AchievementCategory.gameplay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AchievementCategory.values.length, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    try {
      final achievements = await _achievementService.getAllAchievements();
      final stats = await _achievementService.getAchievementStats();
      
      setState(() {
        _achievements = achievements;
        _stats = stats;
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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        elevation: 0,
        bottom: _isLoading ? null : _buildTabBar(),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsHeader(),
                Expanded(
                  child: _buildTabBarView(),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: AchievementCategory.values.map((category) {
        final categoryAchievements = _achievements.where((a) => a.category == category).toList();
        final unlockedCount = categoryAchievements.where((a) => a.isUnlocked).length;
        
        return Tab(
          child: Column(
            children: [
              Text(
                category.displayName,
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '$unlockedCount/${categoryAchievements.length}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      labelColor: AppTheme.primaryBlue,
      unselectedLabelColor: Colors.grey[400],
      indicatorColor: AppTheme.primaryBlue,
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Progress',
              '${_stats['completion'] ?? 0}%',
              Icons.trending_up,
              AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Unlocked',
              '${_stats['unlocked'] ?? 0}/${_stats['total'] ?? 0}',
              Icons.emoji_events,
              Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total XP',
              '${_stats['totalXp'] ?? 0}',
              Icons.star,
              AppTheme.successGreen,
            ),
          ),
        ],
      ),
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
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: AchievementCategory.values.map((category) {
        final categoryAchievements = _achievements
            .where((a) => a.category == category)
            .toList()
          ..sort((a, b) {
            // Sort by unlocked status, then by rarity, then by name
            if (a.isUnlocked && !b.isUnlocked) return -1;
            if (!a.isUnlocked && b.isUnlocked) return 1;
            
            final rarityComparison = b.rarity.index.compareTo(a.rarity.index);
            if (rarityComparison != 0) return rarityComparison;
            
            return a.name.compareTo(b.name);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categoryAchievements.length,
          itemBuilder: (context, index) {
            return _buildAchievementCard(categoryAchievements[index]);
          },
        );
      }).toList(),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final rarityColor = Color(AchievementConstants.rarityConfig[achievement.rarity]!['color']);
    final isLocked = !achievement.isUnlocked;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLocked ? Colors.grey[700]! : rarityColor,
          width: isLocked ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showAchievementDetails(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Achievement icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isLocked ? Colors.grey[700] : rarityColor)?.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked ? Colors.grey[600]! : rarityColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isLocked ? Icons.lock : Icons.emoji_events,
                  color: isLocked ? Colors.grey[600] : rarityColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Achievement info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and rarity
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isLocked ? Colors.grey[400] : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildRarityChip(achievement.rarity, isLocked),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isLocked ? Colors.grey[500] : Colors.grey[300],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Progress bar (for incomplete achievements)
                    if (!achievement.isUnlocked) _buildProgressBar(achievement),
                    
                    // Unlock date (for completed achievements)
                    if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // XP reward
              Column(
                children: [
                  Text(
                    '+${achievement.xpReward}',
                    style: TextStyle(
                      color: isLocked ? Colors.grey[600] : AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'XP',
                    style: TextStyle(
                      color: isLocked ? Colors.grey[600] : AppTheme.successGreen,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRarityChip(AchievementRarity rarity, bool isLocked) {
    final color = isLocked ? Colors.grey[600]! : Color(AchievementConstants.rarityConfig[rarity]!['color']);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        rarity.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar(Achievement achievement) {
    final progress = achievement.progress.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            Text(
              '${achievement.currentValue}/${achievement.requiredValue}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[700],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      ],
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AchievementConstants.rarityConfig[achievement.rarity]!['color']).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(AchievementConstants.rarityConfig[achievement.rarity]!['color']),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
                    color: Color(AchievementConstants.rarityConfig[achievement.rarity]!['color']),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRarityChip(achievement.rarity, false),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[300],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress or completion info
            if (achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successGreen),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievement Unlocked!',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (achievement.unlockedAt != null)
                            Text(
                              'Completed on ${_formatDate(achievement.unlockedAt!)}',
                              style: TextStyle(
                                color: AppTheme.successGreen,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildProgressBar(achievement),
              const SizedBox(height: 8),
              Text(
                '${((achievement.progress * 100).clamp(0, 100)).toInt()}% Complete',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}