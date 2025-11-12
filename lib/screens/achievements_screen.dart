import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/app_state_provider.dart';
import '../services/achievement_service.dart';
import '../utils/constants.dart';

/// Achievements screen showing all achievements with progress
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();

  late TabController _tabController;
  Map<String, UserAchievement> _userProgress = {};
  bool _isLoading = true;

  final Map<AchievementCategory, String> _categoryNames = {
    AchievementCategory.exploration: 'Exploration',
    AchievementCategory.cultural: 'Cultural',
    AchievementCategory.nature: 'Nature',
    AchievementCategory.adventure: 'Adventure',
    AchievementCategory.foodie: 'Foodie',
    AchievementCategory.social: 'Social',
    AchievementCategory.streak: 'Streaks',
    AchievementCategory.completionist: 'Completionist',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      await _achievementService.initializeAchievements();
      final progress = await _achievementService.getAllAchievementProgress();

      final Map<String, UserAchievement> progressMap = {};
      for (var p in progress) {
        progressMap[p.achievementId] = p;
      }

      if (mounted) {
        setState(() {
          _userProgress = progressMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading achievements: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppConstants.premiumGold,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unlocked'),
            Tab(text: 'Locked'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllAchievementsList(),
                _buildUnlockedAchievementsList(),
                _buildLockedAchievementsList(),
              ],
            ),
    );
  }

  Widget _buildAllAchievementsList() {
    final allAchievements = AchievementDefinitions.getAllAchievements();
    final appState = context.watch<AppStateProvider>();

    // Filter out premium achievements for free users
    final visibleAchievements = appState.isPremium
        ? allAchievements
        : allAchievements.where((a) => !a.isPremium).toList();

    // Group by category
    final Map<AchievementCategory, List<Achievement>> grouped = {};
    for (var achievement in visibleAchievements) {
      grouped.putIfAbsent(achievement.category, () => []).add(achievement);
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        // Summary card
        _buildSummaryCard(),

        const SizedBox(height: 16),

        // Achievements by category
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _categoryNames[entry.key] ?? entry.key.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entry.value.map((achievement) {
                final userProgress = _userProgress[achievement.id];
                return _buildAchievementCard(achievement, userProgress);
              }).toList(),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUnlockedAchievementsList() {
    final allAchievements = AchievementDefinitions.getAllAchievements();
    final unlocked = allAchievements.where((a) {
      final progress = _userProgress[a.id];
      return progress?.isUnlocked == true;
    }).toList();

    if (unlocked.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements unlocked yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring to earn your first achievement!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: unlocked.map((achievement) {
        final userProgress = _userProgress[achievement.id];
        return _buildAchievementCard(achievement, userProgress);
      }).toList(),
    );
  }

  Widget _buildLockedAchievementsList() {
    final allAchievements = AchievementDefinitions.getAllAchievements();
    final appState = context.watch<AppStateProvider>();

    final locked = allAchievements.where((a) {
      if (!appState.isPremium && a.isPremium) return false;
      final progress = _userProgress[a.id];
      return progress?.isUnlocked != true;
    }).toList();

    if (locked.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: AppConstants.premiumGold,
            ),
            SizedBox(height: 16),
            Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ve unlocked all achievements!',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: locked.map((achievement) {
        final userProgress = _userProgress[achievement.id];
        return _buildAchievementCard(achievement, userProgress);
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    final totalAchievements = AchievementDefinitions.getAllAchievements().length;
    final unlockedCount = _userProgress.values.where((p) => p.isUnlocked).length;
    final percentage = totalAchievements > 0
        ? (unlockedCount / totalAchievements * 100).toStringAsFixed(0)
        : '0';

    return Card(
      color: AppConstants.premiumGold.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.premiumGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 40,
                color: AppConstants.premiumGold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlockedCount / $totalAchievements Unlocked',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: unlockedCount / totalAchievements,
                    backgroundColor: Colors.grey[300],
                    color: AppConstants.premiumGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, UserAchievement? userProgress) {
    final isUnlocked = userProgress?.isUnlocked == true;
    final currentValue = userProgress?.currentValue ?? 0;
    final progress = currentValue / achievement.targetValue;
    final progressPercent = (progress * 100).clamp(0, 100).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnlocked
          ? AppConstants.premiumGold.withOpacity(0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppConstants.premiumGold.withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 30,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                  if (isUnlocked)
                    const Positioned(
                      top: 2,
                      right: 2,
                      child: Icon(
                        Icons.verified,
                        color: AppConstants.premiumGold,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppConstants.premiumGold : null,
                          ),
                        ),
                      ),
                      if (achievement.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.premiumGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.premiumGold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color: AppConstants.deepOceanBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$currentValue/${achievement.targetValue}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else if (userProgress?.unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Unlocked ${_formatDate(userProgress!.unlockedAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    }
  }
}
