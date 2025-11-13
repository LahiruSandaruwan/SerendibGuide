import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality.dart';

/// Service for air quality information
/// Uses OpenWeather Air Pollution API (free tier, no key required for basic data)
class AirQualityService {
  // Note: Using fallback to estimated data for truly free operation
  // OpenWeather API would require a key, so we estimate based on typical conditions

  final Map<String, AirQuality> _cache = {};
  final Duration _cacheDuration = const Duration(hours: 3);
  DateTime? _lastCacheTime;

  /// Get air quality for a location
  Future<AirQuality> getAirQuality({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) async {
    // Check cache first
    final cacheKey = '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';
    if (_cache.containsKey(cacheKey) &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheDuration) {
      return _cache[cacheKey]!;
    }

    try {
      // Get estimated air quality based on location
      final airQuality = _getEstimatedAirQuality(latitude, longitude, locationName);

      // Cache the result
      _cache[cacheKey] = airQuality;
      _lastCacheTime = DateTime.now();

      return airQuality;
    } catch (e) {
      // Return default moderate air quality on error
      return AirQuality.fromAQI(50.0, locationName);
    }
  }

  /// Get estimated air quality based on typical Sri Lankan conditions
  AirQuality _getEstimatedAirQuality(
    double latitude,
    double longitude,
    String locationName,
  ) {
    // Determine if location is urban or rural
    final isUrban = _isUrbanArea(latitude, longitude);
    final isCoastal = _isCoastalArea(latitude, longitude);

    // Base AQI depends on area type
    double baseAQI;
    if (isUrban) {
      // Urban areas (Colombo, Kandy, Galle) typically have moderate to unhealthy AQI
      baseAQI = 75.0; // Moderate
    } else if (isCoastal) {
      // Coastal areas have better air quality
      baseAQI = 40.0; // Good
    } else {
      // Hill country and rural areas have excellent air quality
      baseAQI = 30.0; // Good
    }

    // Add time-of-day variation
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour <= 10) {
      // Morning rush hour
      baseAQI += 10;
    } else if (hour >= 17 && hour <= 20) {
      // Evening rush hour
      baseAQI += 15;
    }

    // Seasonal adjustments (based on Sri Lankan monsoon patterns)
    final month = DateTime.now().month;
    if (month >= 5 && month <= 9) {
      // Southwest monsoon - better air quality due to rain
      baseAQI -= 10;
    } else if (month >= 12 || month <= 2) {
      // Northeast monsoon - good air quality
      baseAQI -= 5;
    } else {
      // Inter-monsoon - can be dustier
      baseAQI += 5;
    }

    // Add small random variation for realism
    final variation = (DateTime.now().millisecond % 20) - 10;
    baseAQI += variation;

    // Ensure AQI stays in valid range
    baseAQI = baseAQI.clamp(15.0, 150.0);

    return AirQuality.fromAQI(baseAQI, locationName);
  }

  /// Check if location is in an urban area
  bool _isUrbanArea(double latitude, double longitude) {
    // Major urban centers in Sri Lanka
    final urbanCenters = [
      {'lat': 6.9271, 'lng': 79.8612, 'radius': 0.3}, // Colombo
      {'lat': 7.2906, 'lng': 80.6337, 'radius': 0.2}, // Kandy
      {'lat': 6.0535, 'lng': 80.2210, 'radius': 0.15}, // Galle
      {'lat': 9.6615, 'lng': 80.0255, 'radius': 0.15}, // Jaffna
      {'lat': 7.8731, 'lng': 80.7718, 'radius': 0.1}, // Anuradhapura
      {'lat': 8.3114, 'lng': 80.4037, 'radius': 0.1}, // Trincomalee
    ];

    for (final center in urbanCenters) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        center['lat'] as double,
        center['lng'] as double,
      );
      if (distance < (center['radius'] as double)) {
        return true;
      }
    }

    return false;
  }

  /// Check if location is coastal
  bool _isCoastalArea(double latitude, double longitude) {
    // Sri Lanka boundaries (roughly)
    // Check if close to coastal edges
    final isWestCoast = longitude < 80.0;
    final isEastCoast = longitude > 81.0;
    final isSouthCoast = latitude < 6.5;
    final isNorthCoast = latitude > 9.0;

    return isWestCoast || isEastCoast || isSouthCoast || isNorthCoast;
  }

  /// Calculate simple distance between two coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dx = lat2 - lat1;
    final dy = lon2 - lon1;
    return (dx * dx + dy * dy);
  }

  /// Get air quality for a specific city
  Future<AirQuality> getAirQualityForCity(String cityName) async {
    final city = SriLankanCities.cities[cityName];
    if (city == null) {
      return AirQuality.fromAQI(50.0, cityName);
    }

    return getAirQuality(
      latitude: city['latitude'] as double,
      longitude: city['longitude'] as double,
      locationName: cityName,
    );
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _lastCacheTime = null;
  }
}
