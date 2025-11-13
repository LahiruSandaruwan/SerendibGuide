/// Sunrise and sunset times for a location
class SunTimes {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime solarNoon;
  final Duration dayLength;
  final DateTime civilTwilightBegin;
  final DateTime civilTwilightEnd;
  final DateTime nauticalTwilightBegin;
  final DateTime nauticalTwilightEnd;
  final DateTime astronomicalTwilightBegin;
  final DateTime astronomicalTwilightEnd;

  SunTimes({
    required this.sunrise,
    required this.sunset,
    required this.solarNoon,
    required this.dayLength,
    required this.civilTwilightBegin,
    required this.civilTwilightEnd,
    required this.nauticalTwilightBegin,
    required this.nauticalTwilightEnd,
    required this.astronomicalTwilightBegin,
    required this.astronomicalTwilightEnd,
  });

  /// Create from Sunrise-Sunset API response
  factory SunTimes.fromJson(Map<String, dynamic> json) {
    return SunTimes(
      sunrise: DateTime.parse(json['sunrise']).toLocal(),
      sunset: DateTime.parse(json['sunset']).toLocal(),
      solarNoon: DateTime.parse(json['solar_noon']).toLocal(),
      dayLength: Duration(seconds: json['day_length']),
      civilTwilightBegin: DateTime.parse(json['civil_twilight_begin']).toLocal(),
      civilTwilightEnd: DateTime.parse(json['civil_twilight_end']).toLocal(),
      nauticalTwilightBegin: DateTime.parse(json['nautical_twilight_begin']).toLocal(),
      nauticalTwilightEnd: DateTime.parse(json['nautical_twilight_end']).toLocal(),
      astronomicalTwilightBegin: DateTime.parse(json['astronomical_twilight_begin']).toLocal(),
      astronomicalTwilightEnd: DateTime.parse(json['astronomical_twilight_end']).toLocal(),
    );
  }

  /// Golden hour start (before sunset)
  DateTime get goldenHourStart {
    return sunset.subtract(const Duration(hours: 1));
  }

  /// Golden hour end (after sunrise)
  DateTime get goldenHourEnd {
    return sunrise.add(const Duration(hours: 1));
  }

  /// Blue hour start (after sunset)
  DateTime get blueHourStart {
    return civilTwilightEnd.subtract(const Duration(minutes: 20));
  }

  /// Blue hour end (after blue hour start)
  DateTime get blueHourEnd {
    return civilTwilightEnd.add(const Duration(minutes: 10));
  }

  /// Format time for display
  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get sunrise time display
  String get sunriseDisplay => '🌅 ${formatTime(sunrise)}';

  /// Get sunset time display
  String get sunsetDisplay => '🌇 ${formatTime(sunset)}';

  /// Get day length display
  String get dayLengthDisplay {
    final hours = dayLength.inHours;
    final minutes = dayLength.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Check if it's currently golden hour
  bool isGoldenHour(DateTime now) {
    return (now.isAfter(goldenHourStart) && now.isBefore(sunset)) ||
           (now.isAfter(sunrise) && now.isBefore(goldenHourEnd));
  }

  /// Check if it's currently blue hour
  bool isBlueHour(DateTime now) {
    return now.isAfter(blueHourStart) && now.isBefore(blueHourEnd);
  }

  /// Check if sun has risen
  bool hasSunRisen(DateTime now) {
    return now.isAfter(sunrise);
  }

  /// Check if sun has set
  bool hasSunSet(DateTime now) {
    return now.isAfter(sunset);
  }

  /// Get photography recommendations
  String get photographyRecommendation {
    final now = DateTime.now();

    if (isGoldenHour(now)) {
      return 'Perfect golden hour light right now! 📸';
    } else if (isBlueHour(now)) {
      return 'Beautiful blue hour - great for city lights! 📸';
    } else if (!hasSunRisen(now)) {
      final minutesUntilSunrise = sunrise.difference(now).inMinutes;
      if (minutesUntilSunrise < 60) {
        return 'Sunrise in $minutesUntilSunrise minutes - get ready! 🌅';
      }
      return 'Wait for sunrise at ${formatTime(sunrise)} 🌅';
    } else if (hasSunSet(now)) {
      return 'Sun has set - try night photography 🌙';
    } else {
      final minutesUntilGolden = goldenHourStart.difference(now).inMinutes;
      if (minutesUntilGolden < 120) {
        return 'Golden hour starts in ${(minutesUntilGolden / 60).ceil()}h 🌅';
      }
      return 'Best light: ${formatTime(goldenHourStart)} - ${formatTime(sunset)}';
    }
  }

  @override
  String toString() {
    return 'SunTimes(sunrise: ${formatTime(sunrise)}, sunset: ${formatTime(sunset)})';
  }
}
