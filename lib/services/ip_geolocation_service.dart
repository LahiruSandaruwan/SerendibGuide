import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_location.dart';

/// Service for IP-based geolocation
/// Uses ipapi.co (free tier: 1000 requests/day, no key required)
class IpGeolocationService {
  static const String _baseUrl = 'https://ipapi.co';

  UserLocation? _cachedLocation;
  DateTime? _cacheTime;
  final Duration _cacheDuration = const Duration(hours: 24);

  /// Get user's location from IP address
  Future<UserLocation?> getUserLocation() async {
    // Check cache first
    if (_cachedLocation != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedLocation;
    }

    try {
      // Get location from IP (free tier, no key required)
      final response = await http.get(
        Uri.parse('$_baseUrl/json/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if there's an error
        if (data.containsKey('error') && data['error'] == true) {
          return null;
        }

        final location = UserLocation.fromJson(data);

        // Cache the result
        _cachedLocation = location;
        _cacheTime = DateTime.now();

        return location;
      }
    } catch (e) {
      // Return null on error (offline, rate limit, etc.)
      return null;
    }

    return null;
  }

  /// Get location for a specific IP address
  Future<UserLocation?> getLocationForIp(String ipAddress) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$ipAddress/json/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if there's an error
        if (data.containsKey('error') && data['error'] == true) {
          return null;
        }

        return UserLocation.fromJson(data);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Check if user is in Sri Lanka
  Future<bool> isUserInSriLanka() async {
    final location = await getUserLocation();
    return location?.isInSriLanka ?? false;
  }

  /// Get user's recommended currency
  Future<String?> getRecommendedCurrency() async {
    final location = await getUserLocation();
    return location?.recommendedCurrency;
  }

  /// Get localized greeting for user
  Future<String> getLocalizedGreeting() async {
    final location = await getUserLocation();
    return location?.localizedGreeting ?? 'Welcome to Serendib Guide!';
  }

  /// Clear cache
  void clearCache() {
    _cachedLocation = null;
    _cacheTime = null;
  }
}
