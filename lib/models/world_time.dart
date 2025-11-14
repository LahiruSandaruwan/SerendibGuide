/// World time information
class WorldTime {
  final String timezone;
  final DateTime datetime;
  final int utcOffset;
  final String abbreviation;
  final bool isDaylightSaving;

  WorldTime({
    required this.timezone,
    required this.datetime,
    required this.utcOffset,
    required this.abbreviation,
    required this.isDaylightSaving,
  });

  factory WorldTime.fromJson(Map<String, dynamic> json) {
    // Parse datetime string
    final datetimeStr = json['datetime'] as String;
    final datetime = DateTime.parse(datetimeStr);

    // Parse UTC offset (format: +05:30 or -04:00)
    final utcOffsetStr = json['utc_offset'] as String;
    final utcOffset = _parseUtcOffset(utcOffsetStr);

    return WorldTime(
      timezone: json['timezone'] as String,
      datetime: datetime,
      utcOffset: utcOffset,
      abbreviation: json['abbreviation'] as String? ?? '',
      isDaylightSaving: json['dst'] as bool? ?? false,
    );
  }

  static int _parseUtcOffset(String offset) {
    // Parse offset like "+05:30" or "-04:00" to minutes
    final sign = offset.startsWith('-') ? -1 : 1;
    final parts = offset.substring(1).split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return sign * (hours * 60 + minutes);
  }

  String get formattedTime {
    final hour = datetime.hour.toString().padLeft(2, '0');
    final minute = datetime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDateTime {
    return '${_formatDate(datetime)} at $formattedTime';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get utcOffsetFormatted {
    final sign = utcOffset >= 0 ? '+' : '-';
    final hours = (utcOffset.abs() / 60).floor();
    final minutes = utcOffset.abs() % 60;
    return 'UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String get timeWithTimezone {
    return '$formattedTime $abbreviation ($utcOffsetFormatted)';
  }
}

/// Time comparison between two timezones
class TimeComparison {
  final WorldTime sriLankaTime;
  final WorldTime userTime;

  TimeComparison({
    required this.sriLankaTime,
    required this.userTime,
  });

  int get timeDifferenceMinutes {
    return sriLankaTime.utcOffset - userTime.utcOffset;
  }

  String get timeDifferenceFormatted {
    final diff = timeDifferenceMinutes;
    if (diff == 0) return 'Same time';

    final sign = diff > 0 ? '+' : '';
    final hours = (diff.abs() / 60).floor();
    final minutes = diff.abs() % 60;

    if (minutes == 0) {
      return '$sign$hours hour${hours.abs() != 1 ? 's' : ''}';
    } else if (minutes == 30) {
      return '$sign$hours.5 hours';
    } else {
      return '$sign$hours hours $minutes minutes';
    }
  }

  String get comparisonText {
    final diff = timeDifferenceMinutes;
    if (diff == 0) {
      return 'Sri Lanka is in the same timezone as you!';
    } else if (diff > 0) {
      return 'Sri Lanka is $timeDifferenceFormatted ahead of you';
    } else {
      return 'Sri Lanka is ${timeDifferenceFormatted.substring(1)} behind you';
    }
  }

  bool get isDifferentDay {
    return sriLankaTime.datetime.day != userTime.datetime.day;
  }
}

/// Popular timezones for travelers
class PopularTimezones {
  static const Map<String, String> timezones = {
    'Sri Lanka': 'Asia/Colombo',
    'India': 'Asia/Kolkata',
    'UK': 'Europe/London',
    'USA (New York)': 'America/New_York',
    'USA (Los Angeles)': 'America/Los_Angeles',
    'Australia (Sydney)': 'Australia/Sydney',
    'Japan': 'Asia/Tokyo',
    'China': 'Asia/Shanghai',
    'UAE (Dubai)': 'Asia/Dubai',
    'Singapore': 'Asia/Singapore',
  };

  static List<String> get locationNames => timezones.keys.toList();

  static String? getTimezone(String location) {
    return timezones[location];
  }
}
