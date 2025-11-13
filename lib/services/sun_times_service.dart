import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sun_times.dart';

/// Sun times service using Sunrise-Sunset API
/// 100% FREE - No API key required!
class SunTimesService {
  static const String _baseUrl = 'https://api.sunrise-sunset.org/json';

  // Cache for today's sun times per location
  static final Map<String, SunTimes> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheDuration = Duration(hours: 6);

  /// Get sun times for a location
  ///
  /// [latitude] - Location latitude
  /// [longitude] - Location longitude
  /// [date] - Date to get sun times for (defaults to today)
  Future<SunTimes> getSunTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      date ??= DateTime.now();
      final cacheKey = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)},${date.year}-${date.month}-${date.day}';

      // Check cache
      if (_cache.containsKey(cacheKey) &&
          _cacheTime.containsKey(cacheKey) &&
          DateTime.now().difference(_cacheTime[cacheKey]!) < _cacheDuration) {
        print('☀️ Using cached sun times');
        return _cache[cacheKey]!;
      }

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final url = Uri.parse(
        '$_baseUrl'
        '?lat=$latitude'
        '&lng=$longitude'
        '&date=$dateStr'
        '&formatted=0', // Get ISO 8601 format
      );

      print('🌅 Fetching sun times from Sunrise-Sunset API...');
      print('📍 Location: $latitude, $longitude');
      print('📅 Date: $dateStr');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch sun times: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        throw Exception('API returned error: ${data['status']}');
      }

      final results = data['results'] as Map<String, dynamic>;
      final sunTimes = SunTimes.fromJson(results);

      // Cache the result
      _cache[cacheKey] = sunTimes;
      _cacheTime[cacheKey] = DateTime.now();

      print('✅ Sun times fetched');
      print('   Sunrise: ${sunTimes.formatTime(sunTimes.sunrise)}');
      print('   Sunset: ${sunTimes.formatTime(sunTimes.sunset)}');

      return sunTimes;
    } catch (e) {
      print('✗ Error fetching sun times: $e');
      rethrow;
    }
  }

  /// Get sun times for today
  Future<SunTimes> getTodaySunTimes({
    required double latitude,
    required double longitude,
  }) async {
    return getSunTimes(
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
    );
  }

  /// Get sun times for tomorrow
  Future<SunTimes> getTomorrowSunTimes({
    required double latitude,
    required double longitude,
  }) async {
    return getSunTimes(
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// Check if it's good time for photography right now
  Future<bool> isGoodPhotographyTime({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final sunTimes = await getTodaySunTimes(
        latitude: latitude,
        longitude: longitude,
      );
      final now = DateTime.now();
      return sunTimes.isGoldenHour(now) || sunTimes.isBlueHour(now);
    } catch (e) {
      return false;
    }
  }

  /// Clear cache (useful for manual refresh)
  void clearCache() {
    _cache.clear();
    _cacheTime.clear();
  }
}
