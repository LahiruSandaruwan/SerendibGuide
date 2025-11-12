import 'package:sqflite/sqflite.dart';
import '../models/achievement.dart';
import '../services/user_data_service.dart';

/// Service for managing achievements and gamification
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final UserDataService _userDataService = UserDataService();

  /// Initialize achievements table
  Future<void> initializeAchievements() async {
    final Database db = await _userDataService.database;

    // Create user_achievements table
    await db.execute('''\n      CREATE TABLE IF NOT EXISTS user_achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        achievement_id TEXT NOT NULL UNIQUE,
        current_value INTEGER NOT NULL DEFAULT 0,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT
      )
    ''');

    // Create stats table for tracking various metrics
    await db.execute('''\n      CREATE TABLE IF NOT EXISTS user_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stat_key TEXT NOT NULL UNIQUE,
        stat_value INTEGER NOT NULL DEFAULT 0,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create visited attractions table
    await db.execute('''\n      CREATE TABLE IF NOT EXISTS visited_attractions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attraction_id INTEGER NOT NULL UNIQUE,
        visited_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''\n      CREATE INDEX IF NOT EXISTS idx_achievement_id ON user_achievements(achievement_id)
    ''');

    print('✓ Achievement service initialized');
  }

  // ==================== ACHIEVEMENT PROGRESS ====================

  /// Get user's progress for an achievement
  Future<UserAchievement?> getAchievementProgress(String achievementId) async {
    try {
      final Database db = await _userDataService.database;
      final List<Map<String, dynamic>> result = await db.query(
        'user_achievements',
        where: 'achievement_id = ?',
        whereArgs: [achievementId],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return UserAchievement.fromJson(result.first);
    } catch (e) {
      print('✗ Error getting achievement progress: $e');
      return null;
    }
  }

  /// Get all user achievements with progress
  Future<List<UserAchievement>> getAllAchievementProgress() async {
    try {
      final Database db = await _userDataService.database;
      final List<Map<String, dynamic>> result = await db.query(
        'user_achievements',
        orderBy: 'unlocked_at DESC',
      );

      return result.map((map) => UserAchievement.fromJson(map)).toList();
    } catch (e) {
      print('✗ Error getting all achievements: $e');
      return [];
    }
  }

  /// Get unlocked achievements only
  Future<List<UserAchievement>> getUnlockedAchievements() async {
    try {
      final Database db = await _userDataService.database;
      final List<Map<String, dynamic>> result = await db.query(
        'user_achievements',
        where: 'is_unlocked = 1',
        orderBy: 'unlocked_at DESC',
      );

      return result.map((map) => UserAchievement.fromJson(map)).toList();
    } catch (e) {
      print('✗ Error getting unlocked achievements: $e');
      return [];
    }
  }

  /// Update achievement progress
  Future<bool> updateAchievementProgress(
    String achievementId,
    int newValue, {
    bool forceUnlock = false,
  }) async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;

      final achievement = AchievementDefinitions.getById(achievementId);
      if (achievement == null) {
        print('✗ Achievement not found: $achievementId');
        return false;
      }

      // Get current progress
      final current = await getAchievementProgress(achievementId);

      final bool shouldUnlock = forceUnlock || newValue >= achievement.targetValue;
      final DateTime? unlockedAt = shouldUnlock && (current?.isUnlocked != true)
          ? DateTime.now()
          : current?.unlockedAt;

      // Insert or update
      await db.insert(
        'user_achievements',
        {
          'achievement_id': achievementId,
          'current_value': newValue,
          'is_unlocked': shouldUnlock ? 1 : 0,
          'unlocked_at': unlockedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // If newly unlocked, print success
      if (shouldUnlock && current?.isUnlocked != true) {
        print('🏆 Achievement unlocked: ${achievement.name}');
        return true; // Return true if newly unlocked
      }

      return false;
    } catch (e) {
      print('✗ Error updating achievement: $e');
      return false;
    }
  }

  /// Increment achievement progress
  Future<bool> incrementAchievement(String achievementId, {int by = 1}) async {
    final current = await getAchievementProgress(achievementId);
    final newValue = (current?.currentValue ?? 0) + by;
    return await updateAchievementProgress(achievementId, newValue);
  }

  // ==================== VISIT TRACKING ====================

  /// Mark attraction as visited
  Future<void> markAttractionVisited(int attractionId) async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;

      await db.insert(
        'visited_attractions',
        {
          'attraction_id': attractionId,
          'visited_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      // Update visit count achievements
      final visitCount = await getVisitedCount();
      await updateAchievementProgress('first_visit', visitCount);
      await updateAchievementProgress('explorer_5', visitCount);
      await updateAchievementProgress('wanderer_10', visitCount);
      await updateAchievementProgress('adventurer_25', visitCount);
      await updateAchievementProgress('master_explorer_50', visitCount);

      print('✓ Marked attraction $attractionId as visited');
    } catch (e) {
      print('✗ Error marking attraction visited: $e');
    }
  }

  /// Get count of visited attractions
  Future<int> getVisitedCount() async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM visited_attractions',
      );
      return result.first['count'] as int;
    } catch (e) {
      print('✗ Error getting visited count: $e');
      return 0;
    }
  }

  /// Get all visited attraction IDs
  Future<List<int>> getVisitedAttractionIds() async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;
      final result = await db.query('visited_attractions');
      return result.map((row) => row['attraction_id'] as int).toList();
    } catch (e) {
      print('✗ Error getting visited attractions: $e');
      return [];
    }
  }

  /// Check if attraction has been visited
  Future<bool> isAttractionVisited(int attractionId) async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;
      final result = await db.query(
        'visited_attractions',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('✗ Error checking visited status: $e');
      return false;
    }
  }

  // ==================== STATS TRACKING ====================

  /// Get stat value
  Future<int> getStat(String key) async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;
      final result = await db.query(
        'user_stats',
        where: 'stat_key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isEmpty) return 0;
      return result.first['stat_value'] as int;
    } catch (e) {
      print('✗ Error getting stat: $e');
      return 0;
    }
  }

  /// Set stat value
  Future<void> setStat(String key, int value) async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;

      await db.insert(
        'user_stats',
        {
          'stat_key': key,
          'stat_value': value,
          'last_updated': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('✗ Error setting stat: $e');
    }
  }

  /// Increment stat
  Future<void> incrementStat(String key, {int by = 1}) async {
    final current = await getStat(key);
    await setStat(key, current + by);
  }

  /// Get all stats
  Future<Map<String, int>> getAllStats() async {
    try {
      await initializeAchievements();
      final Database db = await _userDataService.database;
      final result = await db.query('user_stats');

      return Map.fromEntries(
        result.map((row) => MapEntry(
              row['stat_key'] as String,
              row['stat_value'] as int,
            )),
      );
    } catch (e) {
      print('✗ Error getting all stats: $e');
      return {};
    }
  }

  // ==================== STREAK TRACKING ====================

  /// Update daily streak
  Future<void> updateDailyStreak() async {
    try {
      final lastVisit = await getStat('last_visit_date');
      final currentStreak = await getStat('current_streak');

      final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000; // Days since epoch
      final yesterday = today - 1;

      if (lastVisit == today) {
        // Already visited today
        return;
      } else if (lastVisit == yesterday) {
        // Consecutive day
        await setStat('current_streak', currentStreak + 1);
      } else {
        // Streak broken
        await setStat('current_streak', 1);
      }

      await setStat('last_visit_date', today);

      // Update longest streak
      final newStreak = await getStat('current_streak');
      final longestStreak = await getStat('longest_streak');
      if (newStreak > longestStreak) {
        await setStat('longest_streak', newStreak);
      }

      // Update streak achievements
      await updateAchievementProgress('week_warrior', newStreak);
      await updateAchievementProgress('month_master', newStreak);

      print('✓ Streak updated: $newStreak days');
    } catch (e) {
      print('✗ Error updating streak: $e');
    }
  }

  /// Get current streak
  Future<int> getCurrentStreak() async {
    return await getStat('current_streak');
  }

  /// Get longest streak
  Future<int> getLongestStreak() async {
    return await getStat('longest_streak');
  }

  // ==================== UTILITY ====================

  /// Get achievement completion percentage
  Future<double> getCompletionPercentage() async {
    final allAchievements = AchievementDefinitions.getAllAchievements();
    final unlocked = await getUnlockedAchievements();

    if (allAchievements.isEmpty) return 0.0;
    return (unlocked.length / allAchievements.length) * 100;
  }

  /// Get recently unlocked achievements (last 7 days)
  Future<List<UserAchievement>> getRecentlyUnlocked({int days = 7}) async {
    try {
      final Database db = await _userDataService.database;
      final cutoff = DateTime.now().subtract(Duration(days: days));

      final result = await db.query(
        'user_achievements',
        where: 'is_unlocked = 1 AND unlocked_at > ?',
        whereArgs: [cutoff.toIso8601String()],
        orderBy: 'unlocked_at DESC',
      );

      return result.map((map) => UserAchievement.fromJson(map)).toList();
    } catch (e) {
      print('✗ Error getting recent achievements: $e');
      return [];
    }
  }

  /// Clear all achievement data (for testing)
  Future<void> resetAllAchievements() async {
    try {
      final Database db = await _userDataService.database;
      await db.delete('user_achievements');
      await db.delete('user_stats');
      await db.delete('visited_attractions');
      print('✓ All achievements reset');
    } catch (e) {
      print('✗ Error resetting achievements: $e');
    }
  }
}
