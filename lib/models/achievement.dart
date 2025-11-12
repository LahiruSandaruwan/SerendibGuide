/// Achievement/Badge model for gamification
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji or icon name
  final AchievementCategory category;
  final int targetValue;
  final String? reward; // Description of what you get
  final bool isPremium; // Premium-only achievements

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    this.reward,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.toString(),
      'targetValue': targetValue,
      'reward': reward,
      'isPremium': isPremium ? 1 : 0,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => AchievementCategory.exploration,
      ),
      targetValue: json['targetValue'] as int,
      reward: json['reward'] as String?,
      isPremium: (json['isPremium'] as int? ?? 0) == 1,
    );
  }
}

/// User's achievement progress
class UserAchievement {
  final int? id;
  final String achievementId;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const UserAchievement({
    this.id,
    required this.achievementId,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double getProgress(int targetValue) {
    if (isUnlocked) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'achievement_id': achievementId,
      'current_value': currentValue,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as int?,
      achievementId: json['achievement_id'] as String,
      currentValue: json['current_value'] as int,
      isUnlocked: (json['is_unlocked'] as int) == 1,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }

  UserAchievement copyWith({
    int? id,
    String? achievementId,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

enum AchievementCategory {
  exploration, // Visiting attractions
  cultural, // UNESCO sites, temples
  nature, // National parks, beaches
  adventure, // Hiking, challenging activities
  foodie, // Food experiences
  social, // Sharing, reviewing
  streak, // Daily usage
  completionist, // 100% completion
}

/// Predefined achievements
class AchievementDefinitions {
  static List<Achievement> getAllAchievements() {
    return [
      // Exploration achievements
      const Achievement(
        id: 'first_visit',
        name: 'First Steps',
        description: 'Visit your first attraction',
        icon: '🎯',
        category: AchievementCategory.exploration,
        targetValue: 1,
      ),
      const Achievement(
        id: 'explorer_5',
        name: 'Explorer',
        description: 'Visit 5 different attractions',
        icon: '🗺️',
        category: AchievementCategory.exploration,
        targetValue: 5,
      ),
      const Achievement(
        id: 'wanderer_10',
        name: 'Wanderer',
        description: 'Visit 10 different attractions',
        icon: '🧭',
        category: AchievementCategory.exploration,
        targetValue: 10,
      ),
      const Achievement(
        id: 'adventurer_25',
        name: 'Adventurer',
        description: 'Visit 25 different attractions',
        icon: '⛰️',
        category: AchievementCategory.exploration,
        targetValue: 25,
      ),
      const Achievement(
        id: 'master_explorer_50',
        name: 'Master Explorer',
        description: 'Visit 50 different attractions',
        icon: '🏆',
        category: AchievementCategory.exploration,
        targetValue: 50,
        isPremium: true,
      ),

      // Cultural achievements
      const Achievement(
        id: 'unesco_collector',
        name: 'UNESCO Collector',
        description: 'Visit all 8 UNESCO World Heritage Sites',
        icon: '🏛️',
        category: AchievementCategory.cultural,
        targetValue: 8,
      ),
      const Achievement(
        id: 'temple_explorer',
        name: 'Temple Explorer',
        description: 'Visit 10 religious sites',
        icon: '🛕',
        category: AchievementCategory.cultural,
        targetValue: 10,
      ),
      const Achievement(
        id: 'ancient_historian',
        name: 'Ancient Historian',
        description: 'Visit all ancient city sites',
        icon: '📜',
        category: AchievementCategory.cultural,
        targetValue: 3,
      ),

      // Nature achievements
      const Achievement(
        id: 'wildlife_watcher',
        name: 'Wildlife Watcher',
        description: 'Visit 5 national parks',
        icon: '🦁',
        category: AchievementCategory.nature,
        targetValue: 5,
      ),
      const Achievement(
        id: 'beach_bum',
        name: 'Beach Bum',
        description: 'Visit 8 different beaches',
        icon: '🏖️',
        category: AchievementCategory.nature,
        targetValue: 8,
      ),
      const Achievement(
        id: 'mountain_climber',
        name: 'Peak Conqueror',
        description: 'Visit 3 mountain peaks',
        icon: '⛰️',
        category: AchievementCategory.nature,
        targetValue: 3,
      ),

      // Province achievements
      const Achievement(
        id: 'province_hopper_3',
        name: 'Province Hopper',
        description: 'Visit attractions in 3 provinces',
        icon: '🗾',
        category: AchievementCategory.exploration,
        targetValue: 3,
      ),
      const Achievement(
        id: 'island_explorer_5',
        name: 'Island Explorer',
        description: 'Visit attractions in 5 provinces',
        icon: '🏝️',
        category: AchievementCategory.exploration,
        targetValue: 5,
      ),
      const Achievement(
        id: 'sri_lanka_master',
        name: 'Sri Lanka Master',
        description: 'Visit attractions in all 9 provinces',
        icon: '🇱🇰',
        category: AchievementCategory.exploration,
        targetValue: 9,
        reward: 'Unlock special Sri Lanka badge',
        isPremium: true,
      ),

      // Foodie achievements
      const Achievement(
        id: 'taste_tester',
        name: 'Taste Tester',
        description: 'Try 3 food experiences',
        icon: '🍛',
        category: AchievementCategory.foodie,
        targetValue: 3,
      ),
      const Achievement(
        id: 'food_critic',
        name: 'Food Critic',
        description: 'Complete 5 food tours',
        icon: '👨‍🍳',
        category: AchievementCategory.foodie,
        targetValue: 5,
        isPremium: true,
      ),

      // Adventure achievements
      const Achievement(
        id: 'thrill_seeker',
        name: 'Thrill Seeker',
        description: 'Complete 5 challenging activities',
        icon: '🎢',
        category: AchievementCategory.adventure,
        targetValue: 5,
      ),
      const Achievement(
        id: 'summit_master',
        name: 'Summit Master',
        description: 'Climb Adam\'s Peak and World\'s End',
        icon: '🏔️',
        category: AchievementCategory.adventure,
        targetValue: 2,
      ),

      // Streak achievements
      const Achievement(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Use app for 7 consecutive days',
        icon: '📅',
        category: AchievementCategory.streak,
        targetValue: 7,
      ),
      const Achievement(
        id: 'month_master',
        name: 'Month Master',
        description: 'Use app for 30 consecutive days',
        icon: '📆',
        category: AchievementCategory.streak,
        targetValue: 30,
        isPremium: true,
      ),

      // Completionist achievements
      const Achievement(
        id: 'favorites_collector',
        name: 'Favorites Collector',
        description: 'Save 20 favorites',
        icon: '❤️',
        category: AchievementCategory.completionist,
        targetValue: 20,
      ),
      const Achievement(
        id: 'trip_planner',
        name: 'Trip Planner',
        description: 'Create 5 trip plans',
        icon: '📝',
        category: AchievementCategory.completionist,
        targetValue: 5,
      ),
      const Achievement(
        id: 'budget_master',
        name: 'Budget Master',
        description: 'Use budget calculator 10 times',
        icon: '💰',
        category: AchievementCategory.completionist,
        targetValue: 10,
      ),
    ];
  }

  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return getAllAchievements().where((a) => a.category == category).toList();
  }
}
