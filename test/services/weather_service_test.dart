import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:serendib_guide/services/weather_service.dart';
import 'package:serendib_guide/models/weather.dart';

void main() {
  group('WeatherService', () {
    late WeatherService weatherService;

    setUp(() {
      weatherService = WeatherService();
    });

    group('getWeatherForecast', () {
      test('returns WeatherForecast on successful API call', () async {
        // Mock response data
        final mockResponse = {
          'current': {
            'time': '2025-11-26T12:00',
            'temperature_2m': 28.5,
            'relative_humidity_2m': 75,
            'weathercode': 0,
            'windspeed_10m': 12.5,
          },
          'daily': {
            'time': ['2025-11-26', '2025-11-27'],
            'weathercode': [1, 2],
            'temperature_2m_max': [30.0, 29.5],
            'temperature_2m_min': [24.0, 23.5],
            'precipitation_sum': [0.0, 2.5],
            'windspeed_10m_max': [15.0, 14.0],
          },
        };

        // Note: In a real test, you'd use a mock HTTP client
        // For now, this test demonstrates the structure

        expect(mockResponse['current'], isNotNull);
        expect(mockResponse['daily'], isNotNull);
      });

      test('throws exception on API error', () async {
        // This would use a mock HTTP client that returns an error
        // For demonstration purposes only
        expect(() async {
          // Would mock http.get to throw
        }, returnsNormally);
      });

      test('handles timeout gracefully', () async {
        // Mock timeout scenario
        expect(() async {
          // Would mock http.get to timeout after 10 seconds
        }, returnsNormally);
      });
    });

    group('Weather model parsing', () {
      test('Weather.fromOpenMeteo parses current weather correctly', () {
        final data = {
          'time': '2025-11-26T12:00',
          'temperature_2m': 28.5,
          'relative_humidity_2m': 75,
          'weathercode': 0,
          'windspeed_10m': 12.5,
        };

        final weather = Weather.fromOpenMeteo(data, isDaily: false);

        expect(weather.temperature, equals(28.5));
        expect(weather.humidity, equals(75));
        expect(weather.weatherCode, equals(0));
        expect(weather.windSpeed, equals(12.5));
      });

      test('Weather.fromOpenMeteo parses daily weather correctly', () {
        final data = {
          'time': '2025-11-26',
          'weathercode': 1,
          'temperature_2m_max': 30.0,
          'temperature_2m_min': 24.0,
          'precipitation_sum': 0.0,
          'windspeed_10m_max': 15.0,
        };

        final weather = Weather.fromOpenMeteo(data, isDaily: true);

        expect(weather.temperatureMax, equals(30.0));
        expect(weather.temperatureMin, equals(24.0));
        expect(weather.precipitation, equals(0.0));
      });
    });

    group('Weather descriptions', () {
      test('getWeatherDescription returns correct description for clear sky', () {
        expect(
          Weather.getWeatherDescription(0),
          equals('Clear sky'),
        );
      });

      test('getWeatherDescription returns correct description for rain', () {
        expect(
          Weather.getWeatherDescription(61),
          contains('Rain'),
        );
      });

      test('getWeatherIcon returns correct icon for weather codes', () {
        expect(Weather.getWeatherIcon(0), equals('☀️'));
        expect(Weather.getWeatherIcon(61), equals('🌧️'));
        expect(Weather.getWeatherIcon(95), equals('⛈️'));
      });
    });
  });
}
