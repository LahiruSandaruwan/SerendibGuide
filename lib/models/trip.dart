import 'dart:convert';

/// Model for user-created trips/itineraries
class Trip {
  final int? id;
  final String name;
  final List<int> attractionIds;
  final String? createdAt;
  final String? updatedAt;

  const Trip({
    this.id,
    required this.name,
    required this.attractionIds,
    this.createdAt,
    this.updatedAt,
  }) : assert(name != '', 'Trip name cannot be empty');

  /// Get number of attractions in trip
  int get attractionCount => attractionIds.length;

  /// Check if trip is empty
  bool get isEmpty => attractionIds.isEmpty;

  /// Check if trip contains an attraction
  bool containsAttraction(int attractionId) {
    return attractionIds.contains(attractionId);
  }

  /// Factory constructor to create Trip from JSON/Map
  factory Trip.fromJson(Map<String, dynamic> json) {
    // Parse attraction_ids from JSON string to List<int>
    List<int> ids = [];
    final attractionIdsValue = json['attraction_ids'];

    if (attractionIdsValue is String) {
      try {
        final List<dynamic> decoded = jsonDecode(attractionIdsValue);
        ids = decoded.map((e) => e as int).toList();
      } catch (e) {
        // If JSON decode fails, try comma-separated format
        ids = attractionIdsValue
            .split(',')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => int.tryParse(s.trim()))
            .where((i) => i != null)
            .cast<int>()
            .toList();
      }
    } else if (attractionIdsValue is List) {
      ids = attractionIdsValue.map((e) => e as int).toList();
    }

    return Trip(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      attractionIds: ids,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convert Trip to JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'attraction_ids': jsonEncode(attractionIds),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create a copy with modified fields
  Trip copyWith({
    int? id,
    String? name,
    List<int>? attractionIds,
    String? createdAt,
    String? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      attractionIds: attractionIds ?? this.attractionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Add attraction to trip
  Trip addAttraction(int attractionId) {
    if (containsAttraction(attractionId)) return this;
    return copyWith(
      attractionIds: [...attractionIds, attractionId],
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Remove attraction from trip
  Trip removeAttraction(int attractionId) {
    return copyWith(
      attractionIds: attractionIds.where((id) => id != attractionId).toList(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Reorder attractions in trip
  Trip reorderAttractions(int oldIndex, int newIndex) {
    final List<int> newList = List.from(attractionIds);
    final int item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    return copyWith(
      attractionIds: newList,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trip && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Trip(id: $id, name: $name, attractions: ${attractionIds.length})';
  }
}
