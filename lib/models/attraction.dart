import 'dart:convert';
import 'dart:math';
import '../utils/helpers.dart';

/// Immutable data model for Sri Lankan attractions
class Attraction {
  final int? id;
  final String nameEn;
  final String? nameSi;
  final String? nameTa;
  final String category;
  final String province;
  final String? district;
  final String descriptionEn;
  final String? descriptionSi;
  final String? descriptionTa;
  final double latitude;
  final double longitude;
  final String? entryFee;
  final String? openingHours;
  final String? bestTime;
  final String? duration;
  final String? difficulty;
  final List<String> tags;
  final List<String> images;
  final bool isPremium;
  final String? createdAt;
  final String? updatedAt;

  const Attraction({
    this.id,
    required this.nameEn,
    this.nameSi,
    this.nameTa,
    required this.category,
    required this.province,
    this.district,
    required this.descriptionEn,
    this.descriptionSi,
    this.descriptionTa,
    required this.latitude,
    required this.longitude,
    this.entryFee,
    this.openingHours,
    this.bestTime,
    this.duration,
    this.difficulty,
    required this.tags,
    required this.images,
    this.isPremium = false,
    this.createdAt,
    this.updatedAt,
  })  : assert(nameEn != '', 'Name in English cannot be empty'),
        assert(latitude >= -90 && latitude <= 90, 'Invalid latitude'),
        assert(longitude >= -180 && longitude <= 180, 'Invalid longitude');

  /// Get name based on current locale
  String getName(String locale) {
    switch (locale) {
      case 'si':
        return nameSi ?? nameEn;
      case 'ta':
        return nameTa ?? nameEn;
      case 'en':
      default:
        return nameEn;
    }
  }

  /// Get description based on current locale
  String getDescription(String locale) {
    switch (locale) {
      case 'si':
        return descriptionSi ?? descriptionEn;
      case 'ta':
        return descriptionTa ?? descriptionEn;
      case 'en':
      default:
        return descriptionEn;
    }
  }

  /// Get complete location (district + province)
  String get fullLocation {
    if (district != null && district!.isNotEmpty) {
      return '$district, $province';
    }
    return province;
  }

  /// Get location with coordinates
  String get locationWithCoords {
    return '$fullLocation (${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°)';
  }

  /// Calculate distance from this attraction to given coordinates using Haversine formula
  double distanceFrom(double lat, double lng) {
    return Helpers.calculateDistance(latitude, longitude, lat, lng);
  }

  /// Convenience getter for English name (for backwards compatibility)
  String get name => nameEn;

  /// Convenience getter for English description (for backwards compatibility)
  String get description => descriptionEn;

  /// Convenience getter for images list (for backwards compatibility)
  List<String> get imageUrls => images;

  /// Get first image path
  String get firstImage => images.isNotEmpty ? images[0] : '';

  /// Get full image path - handles both remote URLs and local assets
  String getImagePath(int index) {
    if (index >= 0 && index < images.length) {
      final String image = images[index];
      // Check if it's a remote URL (starts with http or https)
      if (image.startsWith('http://') || image.startsWith('https://')) {
        return image;
      }
      // Otherwise treat as local asset
      return 'assets/images/attractions/$image';
    }
    return 'assets/images/illustrations/placeholder.png';
  }

  /// Get all image paths - handles both remote URLs and local assets
  List<String> get imagePaths {
    return images.map((img) {
      if (img.startsWith('http://') || img.startsWith('https://')) {
        return img;
      }
      return 'assets/images/attractions/$img';
    }).toList();
  }

  /// Check if attraction has valid coordinates
  bool get hasValidCoordinates {
    return Helpers.isValidLatitude(latitude) && Helpers.isValidLongitude(longitude);
  }

  /// Check if entry is free
  bool get isFree {
    return entryFee?.toLowerCase().contains('free') ?? false;
  }

  /// Helper method to parse images from either JSON array string or comma-separated string
  static List<String> _parseImages(String? imagesData) {
    if (imagesData == null || imagesData.isEmpty || imagesData == '[]') {
      return [];
    }

    try {
      // Try parsing as JSON array first
      if (imagesData.trim().startsWith('[')) {
        final dynamic decoded = jsonDecode(imagesData);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (e) {
      // If JSON parsing fails, fall through to comma-separated parsing
    }

    // Fall back to comma-separated parsing
    return Helpers.parseCommaSeparated(imagesData);
  }

  /// Factory constructor to create Attraction from JSON/Map
  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] as int?,
      nameEn: json['name_en'] as String? ?? '',
      nameSi: json['name_si'] as String?,
      nameTa: json['name_ta'] as String?,
      category: json['category'] as String? ?? '',
      province: json['province'] as String? ?? '',
      district: json['district'] as String?,
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionSi: json['description_si'] as String?,
      descriptionTa: json['description_ta'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      entryFee: json['entry_fee'] as String?,
      openingHours: json['opening_hours'] as String?,
      bestTime: json['best_time'] as String?,
      duration: json['duration'] as String?,
      difficulty: json['difficulty'] as String?,
      tags: Helpers.parseCommaSeparated(json['tags'] as String?),
      images: _parseImages(json['images'] as String?),
      isPremium: (json['is_premium'] as int?) == 1,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convert Attraction to JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_si': nameSi,
      'name_ta': nameTa,
      'category': category,
      'province': province,
      'district': district,
      'description_en': descriptionEn,
      'description_si': descriptionSi,
      'description_ta': descriptionTa,
      'latitude': latitude,
      'longitude': longitude,
      'entry_fee': entryFee,
      'opening_hours': openingHours,
      'best_time': bestTime,
      'duration': duration,
      'difficulty': difficulty,
      'tags': Helpers.joinCommaSeparated(tags),
      'images': Helpers.joinCommaSeparated(images),
      'is_premium': isPremium ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create a copy with modified fields
  Attraction copyWith({
    int? id,
    String? nameEn,
    String? nameSi,
    String? nameTa,
    String? category,
    String? province,
    String? district,
    String? descriptionEn,
    String? descriptionSi,
    String? descriptionTa,
    double? latitude,
    double? longitude,
    String? entryFee,
    String? openingHours,
    String? bestTime,
    String? duration,
    String? difficulty,
    List<String>? tags,
    List<String>? images,
    bool? isPremium,
    String? createdAt,
    String? updatedAt,
  }) {
    return Attraction(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameSi: nameSi ?? this.nameSi,
      nameTa: nameTa ?? this.nameTa,
      category: category ?? this.category,
      province: province ?? this.province,
      district: district ?? this.district,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionSi: descriptionSi ?? this.descriptionSi,
      descriptionTa: descriptionTa ?? this.descriptionTa,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      entryFee: entryFee ?? this.entryFee,
      openingHours: openingHours ?? this.openingHours,
      bestTime: bestTime ?? this.bestTime,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attraction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Attraction(id: $id, nameEn: $nameEn, category: $category, province: $province, isPremium: $isPremium)';
  }
}
