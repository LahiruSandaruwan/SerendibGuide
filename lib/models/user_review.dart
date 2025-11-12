/// User review model for attractions
class UserReview {
  final int? id;
  final int attractionId;
  final String attractionName;
  final String userName;
  final int rating; // 1-5 stars
  final String reviewText;
  final DateTime visitDate;
  final DateTime postedDate;
  final int helpfulCount;
  final List<String> photoPaths;
  final String? userCountry;
  final ReviewCategory category;

  UserReview({
    this.id,
    required this.attractionId,
    required this.attractionName,
    required this.userName,
    required this.rating,
    required this.reviewText,
    required this.visitDate,
    required this.postedDate,
    this.helpfulCount = 0,
    this.photoPaths = const [],
    this.userCountry,
    this.category = ReviewCategory.general,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attraction_id': attractionId,
      'attraction_name': attractionName,
      'user_name': userName,
      'rating': rating,
      'review_text': reviewText,
      'visit_date': visitDate.toIso8601String(),
      'posted_date': postedDate.toIso8601String(),
      'helpful_count': helpfulCount,
      'photo_paths': photoPaths.join(','),
      'user_country': userCountry,
      'category': category.name,
    };
  }

  factory UserReview.fromMap(Map<String, dynamic> map) {
    return UserReview(
      id: map['id'] as int?,
      attractionId: map['attraction_id'] as int,
      attractionName: map['attraction_name'] as String,
      userName: map['user_name'] as String,
      rating: map['rating'] as int,
      reviewText: map['review_text'] as String,
      visitDate: DateTime.parse(map['visit_date'] as String),
      postedDate: DateTime.parse(map['posted_date'] as String),
      helpfulCount: map['helpful_count'] as int? ?? 0,
      photoPaths: (map['photo_paths'] as String?)
              ?.split(',')
              .where((p) => p.isNotEmpty)
              .toList() ??
          [],
      userCountry: map['user_country'] as String?,
      category: ReviewCategory.values.firstWhere(
        (c) => c.name == (map['category'] as String? ?? 'general'),
        orElse: () => ReviewCategory.general,
      ),
    );
  }

  UserReview copyWith({
    int? id,
    int? attractionId,
    String? attractionName,
    String? userName,
    int? rating,
    String? reviewText,
    DateTime? visitDate,
    DateTime? postedDate,
    int? helpfulCount,
    List<String>? photoPaths,
    String? userCountry,
    ReviewCategory? category,
  }) {
    return UserReview(
      id: id ?? this.id,
      attractionId: attractionId ?? this.attractionId,
      attractionName: attractionName ?? this.attractionName,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      visitDate: visitDate ?? this.visitDate,
      postedDate: postedDate ?? this.postedDate,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      photoPaths: photoPaths ?? this.photoPaths,
      userCountry: userCountry ?? this.userCountry,
      category: category ?? this.category,
    );
  }
}

enum ReviewCategory {
  general,
  family,
  solo,
  couple,
  business,
  adventure,
}

extension ReviewCategoryExtension on ReviewCategory {
  String get displayName {
    switch (this) {
      case ReviewCategory.general:
        return 'General';
      case ReviewCategory.family:
        return 'Family Trip';
      case ReviewCategory.solo:
        return 'Solo Travel';
      case ReviewCategory.couple:
        return 'Couple';
      case ReviewCategory.business:
        return 'Business';
      case ReviewCategory.adventure:
        return 'Adventure';
    }
  }

  String get emoji {
    switch (this) {
      case ReviewCategory.general:
        return '✈️';
      case ReviewCategory.family:
        return '👨‍👩‍👧‍👦';
      case ReviewCategory.solo:
        return '🎒';
      case ReviewCategory.couple:
        return '💑';
      case ReviewCategory.business:
        return '💼';
      case ReviewCategory.adventure:
        return '🏔️';
    }
  }
}
