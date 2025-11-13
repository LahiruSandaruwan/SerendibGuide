import 'package:flutter/material.dart';

/// Air quality index categories and data
class AirQuality {
  final double aqi;
  final String category;
  final String description;
  final String healthAdvice;
  final Color color;
  final String emoji;
  final DateTime timestamp;
  final String location;

  AirQuality({
    required this.aqi,
    required this.category,
    required this.description,
    required this.healthAdvice,
    required this.color,
    required this.emoji,
    required this.timestamp,
    required this.location,
  });

  factory AirQuality.fromAQI(double aqi, String location) {
    final info = _getAQIInfo(aqi);
    return AirQuality(
      aqi: aqi,
      category: info['category'] as String,
      description: info['description'] as String,
      healthAdvice: info['healthAdvice'] as String,
      color: info['color'] as Color,
      emoji: info['emoji'] as String,
      timestamp: DateTime.now(),
      location: location,
    );
  }

  factory AirQuality.fromJson(Map<String, dynamic> json, String location) {
    // OpenAQ API structure - simplified for free tier
    final aqi = (json['aqi'] as num?)?.toDouble() ??
                _estimateAQI(json['parameter'] as String?, (json['value'] as num?)?.toDouble());

    return AirQuality.fromAQI(aqi, location);
  }

  static double _estimateAQI(String? parameter, double? value) {
    if (value == null) return 50.0; // Default to moderate

    // Rough AQI estimation based on pollutant concentration
    switch (parameter) {
      case 'pm25':
        if (value <= 12) return 25;
        if (value <= 35.4) return 50;
        if (value <= 55.4) return 100;
        if (value <= 150.4) return 150;
        if (value <= 250.4) return 200;
        return 300;
      case 'pm10':
        if (value <= 54) return 25;
        if (value <= 154) return 50;
        if (value <= 254) return 100;
        if (value <= 354) return 150;
        if (value <= 424) return 200;
        return 300;
      default:
        return 50.0; // Default moderate
    }
  }

  static Map<String, dynamic> _getAQIInfo(double aqi) {
    if (aqi <= 50) {
      return {
        'category': 'Good',
        'description': 'Air quality is excellent',
        'healthAdvice': 'Perfect conditions for outdoor activities',
        'color': const Color(0xFF4CAF50), // Green
        'emoji': '😊',
      };
    } else if (aqi <= 100) {
      return {
        'category': 'Moderate',
        'description': 'Air quality is acceptable',
        'healthAdvice': 'Sensitive individuals should consider limiting prolonged outdoor exertion',
        'color': const Color(0xFFFFC107), // Amber
        'emoji': '😐',
      };
    } else if (aqi <= 150) {
      return {
        'category': 'Unhealthy for Sensitive',
        'description': 'Air quality may affect sensitive groups',
        'healthAdvice': 'People with respiratory conditions should reduce outdoor activities',
        'color': const Color(0xFFFF9800), // Orange
        'emoji': '😷',
      };
    } else if (aqi <= 200) {
      return {
        'category': 'Unhealthy',
        'description': 'Everyone may experience health effects',
        'healthAdvice': 'Limit outdoor activities, especially for children and elderly',
        'color': const Color(0xFFF44336), // Red
        'emoji': '😨',
      };
    } else if (aqi <= 300) {
      return {
        'category': 'Very Unhealthy',
        'description': 'Health alert: everyone may experience serious effects',
        'healthAdvice': 'Avoid outdoor activities. Stay indoors with air purification',
        'color': const Color(0xFF9C27B0), // Purple
        'emoji': '🤢',
      };
    } else {
      return {
        'category': 'Hazardous',
        'description': 'Health warnings of emergency conditions',
        'healthAdvice': 'Everyone should avoid all outdoor activities',
        'color': const Color(0xFF880E4F), // Maroon
        'emoji': '☠️',
      };
    }
  }

  bool get isGood => aqi <= 50;
  bool get isAcceptable => aqi <= 100;

  String get aqiDisplay => aqi.toStringAsFixed(0);

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Sri Lankan cities with air quality monitoring
class SriLankanCities {
  static const Map<String, Map<String, dynamic>> cities = {
    'Colombo': {
      'name': 'Colombo',
      'latitude': 6.9271,
      'longitude': 79.8612,
      'district': 'Colombo',
    },
    'Kandy': {
      'name': 'Kandy',
      'latitude': 7.2906,
      'longitude': 80.6337,
      'district': 'Kandy',
    },
    'Galle': {
      'name': 'Galle',
      'latitude': 6.0535,
      'longitude': 80.2210,
      'district': 'Galle',
    },
    'Jaffna': {
      'name': 'Jaffna',
      'latitude': 9.6615,
      'longitude': 80.0255,
      'district': 'Jaffna',
    },
  };

  static String getClosestCity(double latitude, double longitude) {
    String closestCity = 'Colombo';
    double minDistance = double.infinity;

    for (final entry in cities.entries) {
      final cityLat = entry.value['latitude'] as double;
      final cityLng = entry.value['longitude'] as double;

      final distance = _calculateDistance(latitude, longitude, cityLat, cityLng);

      if (distance < minDistance) {
        minDistance = distance;
        closestCity = entry.key;
      }
    }

    return closestCity;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple Euclidean distance for rough comparison
    final dx = lat2 - lat1;
    final dy = lon2 - lon1;
    return dx * dx + dy * dy;
  }
}
