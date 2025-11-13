import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../utils/helpers.dart';

/// Service for finding nearby places using OpenStreetMap (Overpass API)
/// Completely free, no API key required!
class NearbyPlacesService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Get nearby places of specific types
  ///
  /// [latitude] - Center latitude
  /// [longitude] - Center longitude
  /// [radiusMeters] - Search radius in meters (default: 5000m = 5km)
  /// [types] - Types of places to search (restaurants, cafes, hotels, etc.)
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    List<PlaceType> types = const [PlaceType.restaurant, PlaceType.hotel],
  }) async {
    try {
      // Build amenity filter for query
      final amenities = types.map((t) => t.amenityTag).where((t) => t.isNotEmpty).toList();

      // Add related amenities
      final amenityFilters = <String>[];
      for (final type in types) {
        switch (type) {
          case PlaceType.restaurant:
            amenityFilters.add('node["amenity"="restaurant"](around:$radiusMeters,$latitude,$longitude);');
            amenityFilters.add('node["amenity"="fast_food"](around:$radiusMeters,$latitude,$longitude);');
            break;
          case PlaceType.cafe:
            amenityFilters.add('node["amenity"="cafe"](around:$radiusMeters,$latitude,$longitude);');
            break;
          case PlaceType.hotel:
            amenityFilters.add('node["tourism"="hotel"](around:$radiusMeters,$latitude,$longitude);');
            amenityFilters.add('node["tourism"="guest_house"](around:$radiusMeters,$latitude,$longitude);');
            amenityFilters.add('node["tourism"="hostel"](around:$radiusMeters,$latitude,$longitude);');
            break;
          case PlaceType.bar:
            amenityFilters.add('node["amenity"="bar"](around:$radiusMeters,$latitude,$longitude);');
            amenityFilters.add('node["amenity"="pub"](around:$radiusMeters,$latitude,$longitude);');
            break;
          case PlaceType.other:
            break;
        }
      }

      // Build Overpass QL query
      final query = '''
[out:json][timeout:25];
(
  ${amenityFilters.join('\n  ')}
);
out body;
>;
out skel qt;
      ''';

      print('📡 Fetching nearby places from OpenStreetMap...');
      print('📍 Location: $latitude, $longitude');
      print('📏 Radius: ${radiusMeters}m');

      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: {'data': query},
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch places: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];

      print('✅ Found ${elements.length} places');

      // Parse places and calculate distances
      final places = <Place>[];
      for (final element in elements) {
        if (element is Map<String, dynamic>) {
          try {
            final place = Place.fromOSM(element);

            // Calculate distance from origin
            place.distance = Helpers.calculateDistance(
              latitude,
              longitude,
              place.latitude,
              place.longitude,
            );

            places.add(place);
          } catch (e) {
            print('⚠️ Error parsing place: $e');
          }
        }
      }

      // Sort by distance
      places.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

      return places;
    } catch (e) {
      print('✗ Error fetching nearby places: $e');
      rethrow;
    }
  }

  /// Get restaurants only
  Future<List<Place>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    return getNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      types: [PlaceType.restaurant, PlaceType.cafe],
    );
  }

  /// Get hotels only
  Future<List<Place>> getNearbyHotels({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    return getNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      types: [PlaceType.hotel],
    );
  }

  /// Get all types of places
  Future<List<Place>> getAllNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    return getNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      types: [
        PlaceType.restaurant,
        PlaceType.cafe,
        PlaceType.hotel,
        PlaceType.bar,
      ],
    );
  }
}
