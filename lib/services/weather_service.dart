import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

/// Weather service using Open-Meteo API
/// 100% FREE - No API key required!
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Get current weather and 7-day forecast
  ///
  /// [latitude] - Location latitude
  /// [longitude] - Location longitude
  /// [locationName] - Name of location (for display)
  Future<WeatherForecast> getWeatherForecast({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,weathercode,windspeed_10m'
        '&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,windspeed_10m_max'
        '&timezone=Asia/Colombo'
        '&forecast_days=7',
      );

      print('🌤️  Fetching weather from Open-Meteo...');
      print('📍 Location: $latitude, $longitude');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch weather: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Parse current weather
      final currentData = data['current'] as Map<String, dynamic>;
      final current = Weather.fromOpenMeteo(currentData, isDaily: false);

      // Parse daily forecast
      final dailyData = data['daily'] as Map<String, dynamic>;
      final timeList = dailyData['time'] as List<dynamic>;
      final daily = <Weather>[];

      for (int i = 0; i < timeList.length; i++) {
        final dayData = {
          'time': timeList[i],
          'weathercode': (dailyData['weathercode'] as List)[i],
          'temperature_2m_max': (dailyData['temperature_2m_max'] as List)[i],
          'temperature_2m_min': (dailyData['temperature_2m_min'] as List)[i],
          'precipitation_sum': (dailyData['precipitation_sum'] as List)[i],
          'windspeed_10m_max': (dailyData['windspeed_10m_max'] as List)[i],
        };
        daily.add(Weather.fromOpenMeteo(dayData, isDaily: true));
      }

      print('✅ Weather fetched: ${current.description}, ${current.temperatureDisplay}');
      print('📅 ${daily.length} days forecast loaded');

      return WeatherForecast(
        current: current,
        daily: daily,
        locationName: locationName,
      );
    } catch (e) {
      print('✗ Error fetching weather: $e');
      rethrow;
    }
  }

  /// Get simple current weather (lighter request)
  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,weathercode,windspeed_10m'
        '&timezone=Asia/Colombo',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch weather: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final currentData = data['current'] as Map<String, dynamic>;

      return Weather.fromOpenMeteo(currentData, isDaily: false);
    } catch (e) {
      print('✗ Error fetching current weather: $e');
      rethrow;
    }
  }

  /// Check if weather is good for visiting on specific date
  Future<bool> isGoodWeatherOn({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final forecast = await getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
      );

      final dayOffset = date.difference(DateTime.now()).inDays;
      if (dayOffset < 0 || dayOffset >= forecast.daily.length) {
        return false;
      }

      return forecast.daily[dayOffset].isGoodWeather;
    } catch (e) {
      return false;
    }
  }
}
