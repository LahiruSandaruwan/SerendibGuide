import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/world_time.dart';

/// Service for world time information
/// Uses worldtimeapi.org (completely free, no key required)
class WorldTimeService {
  static const String _baseUrl = 'https://worldtimeapi.org/api';

  final Map<String, WorldTime> _cache = {};
  final Map<String, DateTime> _cacheTime = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  /// Get time for Sri Lanka
  Future<WorldTime?> getSriLankaTime() async {
    return getTimeForTimezone('Asia/Colombo');
  }

  /// Get time for a specific timezone
  Future<WorldTime?> getTimeForTimezone(String timezone) async {
    // Check cache first
    if (_cache.containsKey(timezone) &&
        _cacheTime.containsKey(timezone) &&
        DateTime.now().difference(_cacheTime[timezone]!) < _cacheDuration) {
      return _cache[timezone];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/timezone/$timezone'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final worldTime = WorldTime.fromJson(data);

        // Cache the result
        _cache[timezone] = worldTime;
        _cacheTime[timezone] = DateTime.now();

        return worldTime;
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// Get time for user's IP-based timezone
  Future<WorldTime?> getUserTime() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ip'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WorldTime.fromJson(data);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Compare Sri Lanka time with user's time
  Future<TimeComparison?> compareWithSriLanka() async {
    try {
      final sriLankaTime = await getSriLankaTime();
      final userTime = await getUserTime();

      if (sriLankaTime != null && userTime != null) {
        return TimeComparison(
          sriLankaTime: sriLankaTime,
          userTime: userTime,
        );
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Get time for multiple timezones
  Future<Map<String, WorldTime>> getMultipleTimezones(
      List<String> timezones) async {
    final results = <String, WorldTime>{};

    for (final timezone in timezones) {
      final time = await getTimeForTimezone(timezone);
      if (time != null) {
        results[timezone] = time;
      }
    }

    return results;
  }

  /// Get all available timezones
  Future<List<String>> getAllTimezones() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/timezone'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<String>();
      }
    } catch (e) {
      return [];
    }

    return [];
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTime.clear();
  }
}
