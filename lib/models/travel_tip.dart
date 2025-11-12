/// Travel tip model for user-shared advice
class TravelTip {
  final int? id;
  final int? attractionId;
  final String? attractionName;
  final String userName;
  final String title;
  final String tipText;
  final DateTime postedDate;
  final int helpfulCount;
  final TipCategory category;
  final List<String> tags;

  TravelTip({
    this.id,
    this.attractionId,
    this.attractionName,
    required this.userName,
    required this.title,
    required this.tipText,
    required this.postedDate,
    this.helpfulCount = 0,
    required this.category,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attraction_id': attractionId,
      'attraction_name': attractionName,
      'user_name': userName,
      'title': title,
      'tip_text': tipText,
      'posted_date': postedDate.toIso8601String(),
      'helpful_count': helpfulCount,
      'category': category.name,
      'tags': tags.join(','),
    };
  }

  factory TravelTip.fromMap(Map<String, dynamic> map) {
    return TravelTip(
      id: map['id'] as int?,
      attractionId: map['attraction_id'] as int?,
      attractionName: map['attraction_name'] as String?,
      userName: map['user_name'] as String,
      title: map['title'] as String,
      tipText: map['tip_text'] as String,
      postedDate: DateTime.parse(map['posted_date'] as String),
      helpfulCount: map['helpful_count'] as int? ?? 0,
      category: TipCategory.values.firstWhere(
        (c) => c.name == (map['category'] as String? ?? 'general'),
        orElse: () => TipCategory.general,
      ),
      tags: (map['tags'] as String?)
              ?.split(',')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
    );
  }

  TravelTip copyWith({
    int? id,
    int? attractionId,
    String? attractionName,
    String? userName,
    String? title,
    String? tipText,
    DateTime? postedDate,
    int? helpfulCount,
    TipCategory? category,
    List<String>? tags,
  }) {
    return TravelTip(
      id: id ?? this.id,
      attractionId: attractionId ?? this.attractionId,
      attractionName: attractionName ?? this.attractionName,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      tipText: tipText ?? this.tipText,
      postedDate: postedDate ?? this.postedDate,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}

enum TipCategory {
  general,
  transportation,
  food,
  safety,
  money,
  photography,
  accommodation,
  timing,
}

extension TipCategoryExtension on TipCategory {
  String get displayName {
    switch (this) {
      case TipCategory.general:
        return 'General';
      case TipCategory.transportation:
        return 'Transportation';
      case TipCategory.food:
        return 'Food & Dining';
      case TipCategory.safety:
        return 'Safety';
      case TipCategory.money:
        return 'Money & Budget';
      case TipCategory.photography:
        return 'Photography';
      case TipCategory.accommodation:
        return 'Accommodation';
      case TipCategory.timing:
        return 'Best Time to Visit';
    }
  }

  String get icon {
    switch (this) {
      case TipCategory.general:
        return '💡';
      case TipCategory.transportation:
        return '🚗';
      case TipCategory.food:
        return '🍽️';
      case TipCategory.safety:
        return '🛡️';
      case TipCategory.money:
        return '💰';
      case TipCategory.photography:
        return '📸';
      case TipCategory.accommodation:
        return '🏨';
      case TipCategory.timing:
        return '⏰';
    }
  }
}
