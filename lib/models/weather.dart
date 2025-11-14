/// Weather data model for Open-Meteo API
class Weather {
  final DateTime timestamp;
  final double temperature;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final double precipitation;
  final double? uvIndex;
  final String description;
  final String icon;

  Weather({
    required this.timestamp,
    required this.temperature,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.precipitation,
    this.uvIndex,
    required this.description,
    required this.icon,
  });

  /// Create from Open-Meteo API response
  factory Weather.fromOpenMeteo(Map<String, dynamic> json, {bool isDaily = false}) {
    final weatherCode = json['weathercode'] ?? json['weather_code'] ?? 0;
    final desc = _getWeatherDescription(weatherCode);

    if (isDaily) {
      // Daily forecast
      return Weather(
        timestamp: DateTime.parse(json['time']),
        temperature: ((json['temperature_2m_max'] + json['temperature_2m_min']) / 2).toDouble(),
        temperatureMax: (json['temperature_2m_max'] as num).toDouble(),
        temperatureMin: (json['temperature_2m_min'] as num).toDouble(),
        weatherCode: weatherCode,
        windSpeed: (json['windspeed_10m_max'] ?? 0).toDouble(),
        humidity: 0,
        precipitation: (json['precipitation_sum'] ?? 0).toDouble(),
        uvIndex: (json['uv_index_max'] as num?)?.toDouble(),
        description: desc['description']!,
        icon: desc['icon']!,
      );
    } else {
      // Current weather
      return Weather(
        timestamp: DateTime.parse(json['time']),
        temperature: (json['temperature'] as num).toDouble(),
        temperatureMax: (json['temperature'] as num).toDouble(),
        temperatureMin: (json['temperature'] as num).toDouble(),
        weatherCode: weatherCode,
        windSpeed: (json['windspeed'] as num).toDouble(),
        humidity: json['relative_humidity'] ?? 0,
        precipitation: 0,
        uvIndex: (json['uv_index'] as num?)?.toDouble(),
        description: desc['description']!,
        icon: desc['icon']!,
      );
    }
  }

  /// Get weather description and icon from WMO weather code
  static Map<String, String> _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return {'description': 'Clear sky', 'icon': '☀️'};
      case 1:
      case 2:
      case 3:
        return {'description': 'Partly cloudy', 'icon': '⛅'};
      case 45:
      case 48:
        return {'description': 'Foggy', 'icon': '🌫️'};
      case 51:
      case 53:
      case 55:
        return {'description': 'Drizzle', 'icon': '🌦️'};
      case 61:
      case 63:
      case 65:
        return {'description': 'Rainy', 'icon': '🌧️'};
      case 71:
      case 73:
      case 75:
        return {'description': 'Snowy', 'icon': '🌨️'};
      case 80:
      case 81:
      case 82:
        return {'description': 'Rain showers', 'icon': '🌧️'};
      case 85:
      case 86:
        return {'description': 'Snow showers', 'icon': '🌨️'};
      case 95:
        return {'description': 'Thunderstorm', 'icon': '⛈️'};
      case 96:
      case 99:
        return {'description': 'Thunderstorm with hail', 'icon': '⛈️'};
      default:
        return {'description': 'Unknown', 'icon': '❓'};
    }
  }

  /// Get temperature display with unit
  String get temperatureDisplay => '${temperature.round()}°C';

  /// Get temperature range display
  String get temperatureRangeDisplay =>
      '${temperatureMin.round()}°C - ${temperatureMax.round()}°C';

  /// Check if it's good weather for visiting
  bool get isGoodWeather {
    // Good weather: no heavy rain, not too hot, clear or partly cloudy
    return weatherCode <= 3 && temperature <= 35 && precipitation < 5;
  }

  /// Get recommendation based on weather
  String get recommendation {
    if (weatherCode >= 61 && weatherCode <= 65) {
      return 'Expect rain - bring an umbrella!';
    } else if (weatherCode >= 95) {
      return 'Thunderstorm expected - plan indoor activities';
    } else if (temperature > 35) {
      return 'Very hot - stay hydrated and use sunscreen';
    } else if (weatherCode <= 3 && temperature >= 25 && temperature <= 32) {
      return 'Perfect weather for visiting!';
    } else if (weatherCode >= 51 && weatherCode <= 55) {
      return 'Light rain possible - carry a raincoat';
    } else {
      return 'Good weather for exploring';
    }
  }

  /// Get UV index category
  String get uvCategory {
    if (uvIndex == null) return 'Unknown';
    if (uvIndex! <= 2) return 'Low';
    if (uvIndex! <= 5) return 'Moderate';
    if (uvIndex! <= 7) return 'High';
    if (uvIndex! <= 10) return 'Very High';
    return 'Extreme';
  }

  /// Get UV index advice
  String get uvAdvice {
    if (uvIndex == null) return 'UV data unavailable';
    if (uvIndex! <= 2) {
      return 'Minimal sun protection needed';
    } else if (uvIndex! <= 5) {
      return 'Wear sunscreen (SPF 30+)';
    } else if (uvIndex! <= 7) {
      return 'Sunscreen essential. Seek shade during midday';
    } else if (uvIndex! <= 10) {
      return 'Extra protection needed. Avoid sun 10am-4pm';
    } else {
      return 'Take all precautions. Minimize sun exposure';
    }
  }

  /// Get UV index emoji
  String get uvEmoji {
    if (uvIndex == null) return '☀️';
    if (uvIndex! <= 2) return '🟢';
    if (uvIndex! <= 5) return '🟡';
    if (uvIndex! <= 7) return '🟠';
    if (uvIndex! <= 10) return '🔴';
    return '🟣';
  }

  /// Check if precipitation is likely
  bool get isPrecipitationLikely => precipitation > 1.0;

  /// Get precipitation display
  String get precipitationDisplay {
    if (precipitation == 0) return 'No rain';
    if (precipitation < 2.5) return 'Light rain (${precipitation.toStringAsFixed(1)}mm)';
    if (precipitation < 10) return 'Moderate rain (${precipitation.toStringAsFixed(1)}mm)';
    return 'Heavy rain (${precipitation.toStringAsFixed(1)}mm)';
  }

  @override
  String toString() {
    return 'Weather(temp: $temperatureDisplay, ${description})';
  }
}

/// Weather forecast containing current + daily forecasts
class WeatherForecast {
  final Weather current;
  final List<Weather> daily;
  final String locationName;

  WeatherForecast({
    required this.current,
    required this.daily,
    required this.locationName,
  });

  /// Get forecast for specific day (0 = today, 1 = tomorrow, etc.)
  Weather? getForecastForDay(int dayOffset) {
    if (dayOffset >= 0 && dayOffset < daily.length) {
      return daily[dayOffset];
    }
    return null;
  }

  /// Get today's forecast
  Weather get today => daily.isNotEmpty ? daily[0] : current;

  /// Get tomorrow's forecast
  Weather? get tomorrow => getForecastForDay(1);

  /// Count good weather days in forecast
  int get goodWeatherDaysCount {
    return daily.where((w) => w.isGoodWeather).length;
  }
}
