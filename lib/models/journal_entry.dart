/// Travel journal entry model
class JournalEntry {
  final int? id;
  final int? attractionId;
  final String attractionName;
  final String title;
  final String content;
  final DateTime visitDate;
  final DateTime createdAt;
  final int rating; // 1-5 stars
  final String? photoPath; // Optional photo
  final List<String> tags;

  const JournalEntry({
    this.id,
    this.attractionId,
    required this.attractionName,
    required this.title,
    required this.content,
    required this.visitDate,
    required this.createdAt,
    this.rating = 0,
    this.photoPath,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attraction_id': attractionId,
      'attraction_name': attractionName,
      'title': title,
      'content': content,
      'visit_date': visitDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'photo_path': photoPath,
      'tags': tags.join(','),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      attractionId: map['attraction_id'] as int?,
      attractionName: map['attraction_name'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      visitDate: DateTime.parse(map['visit_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      rating: map['rating'] as int? ?? 0,
      photoPath: map['photo_path'] as String?,
      tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
    );
  }

  JournalEntry copyWith({
    int? id,
    int? attractionId,
    String? attractionName,
    String? title,
    String? content,
    DateTime? visitDate,
    DateTime? createdAt,
    int? rating,
    String? photoPath,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      attractionId: attractionId ?? this.attractionId,
      attractionName: attractionName ?? this.attractionName,
      title: title ?? this.title,
      content: content ?? this.content,
      visitDate: visitDate ?? this.visitDate,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      photoPath: photoPath ?? this.photoPath,
      tags: tags ?? this.tags,
    );
  }
}
