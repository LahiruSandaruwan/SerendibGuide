import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';

/// Stats dashboard showing user progress and achievements
class StatsDashboardScreen extends StatefulWidget {
  const StatsDashboardScreen({super.key});

  @override
  State<StatsDashboardScreen> createState() => _StatsDashboardScreenState();
}

class _StatsDashboardScreenState extends State<StatsDashboardScreen> {
  final AchievementService _achievementService = AchievementService();
  final UserDataService _userDataService = UserDataService();

  bool _isLoading = true;
  int _visitedCount = 0;
  int _favoritesCount = 0;
  int _tripsCount = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _unlockedAchievements = 0;
  double _completionPercentage = 0.0;
  List<UserAchievement> _recentAchievements = [];
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      // Initialize achievements service
      await _achievementService.initializeAchievements();

      // Load all stats
      final visitedCount = await _achievementService.getVisitedCount();
      final favoritesCount = await _userDataService.getFavoritesCount();
      final tripsCount = await _userDataService.getTripsCount();
      final currentStreak = await _achievementService.getCurrentStreak();
      final longestStreak = await _achievementService.getLongestStreak();
      final unlocked = await _achievementService.getUnlockedAchievements();
      final completion = await _achievementService.getCompletionPercentage();
      final recent = await _achievementService.getRecentlyUnlocked(days: 30);
      final allStats = await _achievementService.getAllStats();

      if (mounted) {
        setState(() {
          _visitedCount = visitedCount;
          _favoritesCount = favoritesCount;
          _tripsCount = tripsCount;
          _currentStreak = currentStreak;
          _longestStreak = longestStreak;
          _unlockedAchievements = unlocked.length;
          _completionPercentage = completion;
          _recentAchievements = recent;
          _stats = allStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stats'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card with overall progress
                    _buildOverviewCard(),

                    const SizedBox(height: 24),

                    // Streak section
                    _buildStreakCard(),

                    const SizedBox(height: 24),

                    // Quick stats grid
                    const Text(
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildStatsGrid(),

                    const SizedBox(height: 24),

                    // Recent achievements
                    if (_recentAchievements.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Achievements',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/achievements');
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ..._recentAchievements.take(5).map((userAchievement) {
                        final achievement =
                            AchievementDefinitions.getById(userAchievement.achievementId);
                        if (achievement == null) return const SizedBox.shrink();

                        return _buildRecentAchievementCard(achievement, userAchievement);
                      }).toList(),
                    ],

                    const SizedBox(height: 24),

                    // Motivational message
                    _buildMotivationalCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    final totalAchievements = AchievementDefinitions.getAllAchievements().length;

    return Card(
      color: AppConstants.deepOceanBlue,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_completionPercentage.toStringAsFixed(0)}% Complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_unlockedAchievements of $totalAchievements achievements',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: AppConstants.premiumGold,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Card(
      color: AppConstants.sunsetOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.sunsetOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 40,
                color: AppConstants.sunsetOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_currentStreak days',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.sunsetOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Best: $_longestStreak days',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (_currentStreak >= 7)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.premiumGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppConstants.premiumGold,
                    width: 2,
                  ),
                ),
                child: const Text(
                  '🔥 On Fire!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.premiumGold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Visited',
          _visitedCount.toString(),
          Icons.location_on,
          AppConstants.tropicalGreen,
          'attractions',
        ),
        _buildStatCard(
          'Favorites',
          _favoritesCount.toString(),
          Icons.favorite,
          Colors.red,
          'saved',
        ),
        _buildStatCard(
          'Trips',
          _tripsCount.toString(),
          Icons.route,
          AppConstants.deepOceanBlue,
          'planned',
        ),
        _buildStatCard(
          'Achievements',
          _unlockedAchievements.toString(),
          Icons.emoji_events,
          AppConstants.premiumGold,
          'unlocked',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievementCard(
    Achievement achievement,
    UserAchievement userAchievement,
  ) {
    final daysAgo = userAchievement.unlockedAt != null
        ? DateTime.now().difference(userAchievement.unlockedAt!).inDays
        : 0;

    final timeText = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? 'Yesterday'
            : '$daysAgo days ago';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppConstants.premiumGold.withOpacity(0.1),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppConstants.premiumGold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          achievement.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          achievement.description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.verified, color: AppConstants.premiumGold, size: 20),
            const SizedBox(height: 2),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalCard() {
    String message;
    String icon;

    if (_completionPercentage >= 80) {
      message = "Almost there! You're a true Sri Lanka explorer!";
      icon = '🎉';
    } else if (_completionPercentage >= 50) {
      message = 'Great progress! Keep exploring the beauty of Sri Lanka!';
      icon = '🌟';
    } else if (_visitedCount >= 10) {
      message = 'You\'re doing amazing! More adventures await!';
      icon = '🚀';
    } else if (_visitedCount >= 5) {
      message = 'Nice start! Sri Lanka has so much more to offer!';
      icon = '👏';
    } else {
      message = 'Start your journey! Discover the wonders of Sri Lanka!';
      icon = '🗺️';
    }

    return Card(
      color: AppConstants.tropicalGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
