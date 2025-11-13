/// Public holiday model
class Holiday {
  final DateTime date;
  final String name;
  final String localName;
  final String countryCode;
  final bool fixed;
  final HolidayType type;

  Holiday({
    required this.date,
    required this.name,
    required this.localName,
    required this.countryCode,
    required this.fixed,
    required this.type,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['date']),
      name: json['name'] as String,
      localName: json['localName'] as String,
      countryCode: json['countryCode'] as String? ?? 'LK',
      fixed: json['fixed'] as bool? ?? true,
      type: _parseType(json['types'] as List<dynamic>?),
    );
  }

  static HolidayType _parseType(List<dynamic>? types) {
    if (types == null || types.isEmpty) return HolidayType.publicHoliday;

    final typeStr = types.first.toString().toLowerCase();
    if (typeStr.contains('public')) return HolidayType.publicHoliday;
    if (typeStr.contains('bank')) return HolidayType.bankHoliday;
    if (typeStr.contains('religious')) return HolidayType.religious;
    if (typeStr.contains('observance')) return HolidayType.observance;

    return HolidayType.publicHoliday;
  }

  /// Check if holiday is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check if holiday is upcoming (within 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final diff = date.difference(now);
    return diff.inDays >= 0 && diff.inDays <= 30;
  }

  /// Get days until holiday
  int get daysUntil {
    return date.difference(DateTime.now()).inDays;
  }

  /// Get formatted date
  String get formattedDate {
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  /// Get icon based on holiday type
  String get icon {
    switch (type) {
      case HolidayType.religious:
        return '🕉️';
      case HolidayType.bankHoliday:
        return '🏦';
      case HolidayType.observance:
        return '📅';
      case HolidayType.publicHoliday:
      default:
        return '🎉';
    }
  }

  /// Get description
  String get description {
    if (name.contains('Poya')) {
      return 'Buddhist full moon observance day - Banks and government offices closed';
    } else if (name.contains('New Year')) {
      return 'Sinhala and Tamil New Year celebration - Major national holiday';
    } else if (name.contains('Independence')) {
      return 'Sri Lankan Independence Day - National celebration';
    } else if (name.contains('Christmas')) {
      return 'Christian celebration - Public holiday';
    } else if (name.contains('Id')) {
      return 'Islamic celebration - Public holiday';
    } else if (name.contains('Deepavali') || name.contains('Diwali')) {
      return 'Hindu festival of lights';
    }
    return 'Public holiday - Government offices and banks may be closed';
  }

  @override
  String toString() => '$name on $formattedDate';
}

/// Types of holidays
enum HolidayType {
  publicHoliday,
  bankHoliday,
  religious,
  observance,
}

extension HolidayTypeExtension on HolidayType {
  String get displayName {
    switch (this) {
      case HolidayType.publicHoliday:
        return 'Public Holiday';
      case HolidayType.bankHoliday:
        return 'Bank Holiday';
      case HolidayType.religious:
        return 'Religious Day';
      case HolidayType.observance:
        return 'Observance';
    }
  }
}

/// Sri Lankan holiday information
class SriLankanHolidays {
  static const String info = '''
Sri Lanka observes several types of holidays:

🌕 Poya Days (Full Moon Days)
Monthly Buddhist observance days. Alcohol sales prohibited, some businesses closed.

🎊 Cultural Festivals
- Sinhala & Tamil New Year (April)
- Vesak (May) - Buddha's birthday
- Esala Perahera (July/August)

🏖️ Best Times to Visit
- December to March: Dry season
- Avoid monsoon: May-September (southwest)

⚠️ Important Notes
- Book accommodations early during festivals
- Expect crowds at religious sites on Poya days
- Some restaurants may be closed on religious holidays
''';

  static List<String> get monthlyPoyaDays => [
    'January - Duruthu Poya',
    'February - Navam Poya',
    'March - Medin Poya',
    'April - Bak Poya',
    'May - Vesak Poya (most important)',
    'June - Poson Poya',
    'July - Esala Poya',
    'August - Nikini Poya',
    'September - Binara Poya',
    'October - Vap Poya',
    'November - Ill Poya',
    'December - Unduvap Poya',
  ];
}
