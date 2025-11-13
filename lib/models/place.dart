/// Model for nearby places (hotels, restaurants, cafes, etc.)
class Place {
  final int id;
  final String name;
  final PlaceType type;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? website;
  final String? cuisine;
  final String? openingHours;
  final int? stars; // for hotels
  final String? description;
  final Map<String, dynamic> tags;
  double? distance; // Distance from user/attraction in km

  Place({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.website,
    this.cuisine,
    this.openingHours,
    this.stars,
    this.description,
    required this.tags,
    this.distance,
  });

  /// Create Place from OpenStreetMap data
  factory Place.fromOSM(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    final lat = (json['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (json['lon'] as num?)?.toDouble() ?? 0.0;

    // Determine place type from amenity tag
    final amenity = tags['amenity'] as String?;
    PlaceType type = PlaceType.other;
    if (amenity == 'restaurant' || amenity == 'fast_food') {
      type = PlaceType.restaurant;
    } else if (amenity == 'cafe') {
      type = PlaceType.cafe;
    } else if (amenity == 'hotel' || amenity == 'guest_house' || amenity == 'hostel') {
      type = PlaceType.hotel;
    } else if (amenity == 'bar' || amenity == 'pub') {
      type = PlaceType.bar;
    }

    // Extract stars for hotels
    int? stars;
    if (tags['stars'] != null) {
      stars = int.tryParse(tags['stars'].toString());
    }

    // Build address from tags
    String? address;
    final street = tags['addr:street'];
    final houseNumber = tags['addr:housenumber'];
    final city = tags['addr:city'];

    if (street != null || city != null) {
      final parts = <String>[];
      if (houseNumber != null) parts.add(houseNumber.toString());
      if (street != null) parts.add(street.toString());
      if (city != null) parts.add(city.toString());
      address = parts.join(', ');
    }

    return Place(
      id: json['id'] as int? ?? 0,
      name: tags['name'] as String? ?? 'Unnamed Place',
      type: type,
      latitude: lat,
      longitude: lon,
      address: address,
      phone: tags['phone'] as String? ?? tags['contact:phone'] as String?,
      website: tags['website'] as String? ?? tags['contact:website'] as String?,
      cuisine: tags['cuisine'] as String?,
      openingHours: tags['opening_hours'] as String?,
      stars: stars,
      description: tags['description'] as String?,
      tags: tags,
    );
  }

  /// Get icon based on place type
  String get icon {
    switch (type) {
      case PlaceType.restaurant:
        return '🍽️';
      case PlaceType.cafe:
        return '☕';
      case PlaceType.hotel:
        return '🏨';
      case PlaceType.bar:
        return '🍺';
      case PlaceType.other:
        return '📍';
    }
  }

  /// Get display distance
  String get displayDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }

  /// Get star rating display (for hotels)
  String get starRating {
    if (stars == null) return '';
    return '⭐' * stars!;
  }

  @override
  String toString() {
    return 'Place(id: $id, name: $name, type: $type, distance: ${displayDistance})';
  }
}

/// Types of places
enum PlaceType {
  restaurant,
  cafe,
  hotel,
  bar,
  other,
}

extension PlaceTypeExtension on PlaceType {
  String get displayName {
    switch (this) {
      case PlaceType.restaurant:
        return 'Restaurants';
      case PlaceType.cafe:
        return 'Cafes';
      case PlaceType.hotel:
        return 'Hotels';
      case PlaceType.bar:
        return 'Bars';
      case PlaceType.other:
        return 'Other';
    }
  }

  String get amenityTag {
    switch (this) {
      case PlaceType.restaurant:
        return 'restaurant';
      case PlaceType.cafe:
        return 'cafe';
      case PlaceType.hotel:
        return 'hotel';
      case PlaceType.bar:
        return 'bar';
      case PlaceType.other:
        return '';
    }
  }
}
