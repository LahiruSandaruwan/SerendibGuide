/// Community photo model for shared attraction photos
class CommunityPhoto {
  final int? id;
  final int attractionId;
  final String attractionName;
  final String userName;
  final String photoPath;
  final String? caption;
  final DateTime uploadDate;
  final DateTime? takenDate;
  final int likesCount;
  final List<String> tags;
  final String? location;

  CommunityPhoto({
    this.id,
    required this.attractionId,
    required this.attractionName,
    required this.userName,
    required this.photoPath,
    this.caption,
    required this.uploadDate,
    this.takenDate,
    this.likesCount = 0,
    this.tags = const [],
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attraction_id': attractionId,
      'attraction_name': attractionName,
      'user_name': userName,
      'photo_path': photoPath,
      'caption': caption,
      'upload_date': uploadDate.toIso8601String(),
      'taken_date': takenDate?.toIso8601String(),
      'likes_count': likesCount,
      'tags': tags.join(','),
      'location': location,
    };
  }

  factory CommunityPhoto.fromMap(Map<String, dynamic> map) {
    return CommunityPhoto(
      id: map['id'] as int?,
      attractionId: map['attraction_id'] as int,
      attractionName: map['attraction_name'] as String,
      userName: map['user_name'] as String,
      photoPath: map['photo_path'] as String,
      caption: map['caption'] as String?,
      uploadDate: DateTime.parse(map['upload_date'] as String),
      takenDate: map['taken_date'] != null
          ? DateTime.parse(map['taken_date'] as String)
          : null,
      likesCount: map['likes_count'] as int? ?? 0,
      tags: (map['tags'] as String?)
              ?.split(',')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
      location: map['location'] as String?,
    );
  }

  CommunityPhoto copyWith({
    int? id,
    int? attractionId,
    String? attractionName,
    String? userName,
    String? photoPath,
    String? caption,
    DateTime? uploadDate,
    DateTime? takenDate,
    int? likesCount,
    List<String>? tags,
    String? location,
  }) {
    return CommunityPhoto(
      id: id ?? this.id,
      attractionId: attractionId ?? this.attractionId,
      attractionName: attractionName ?? this.attractionName,
      userName: userName ?? this.userName,
      photoPath: photoPath ?? this.photoPath,
      caption: caption ?? this.caption,
      uploadDate: uploadDate ?? this.uploadDate,
      takenDate: takenDate ?? this.takenDate,
      likesCount: likesCount ?? this.likesCount,
      tags: tags ?? this.tags,
      location: location ?? this.location,
    );
  }
}
