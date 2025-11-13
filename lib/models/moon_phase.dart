/// Moon phase information
class MoonPhase {
  final String phaseName;
  final String emoji;
  final double illumination; // 0.0 to 1.0
  final DateTime date;
  final String description;
  final List<String> photographyTips;
  final List<String> beachActivities;
  final bool isPoyaDay; // Full moon Poya day

  MoonPhase({
    required this.phaseName,
    required this.emoji,
    required this.illumination,
    required this.date,
    required this.description,
    required this.photographyTips,
    required this.beachActivities,
    this.isPoyaDay = false,
  });

  factory MoonPhase.fromPhaseValue(double phase, DateTime date, {bool isPoya = false}) {
    // Phase is 0-1, where 0/1 = new moon, 0.5 = full moon
    final normalized = phase % 1.0;

    String phaseName;
    String emoji;
    String description;
    List<String> photoTips;
    List<String> beachTips;

    if (normalized < 0.03 || normalized > 0.97) {
      // New Moon
      phaseName = 'New Moon';
      emoji = '🌑';
      description = 'The moon is not visible. Perfect for stargazing!';
      photoTips = [
        'Excellent for astrophotography and Milky Way shots',
        'Capture star trails with long exposures',
        'Night landscapes with minimal moon interference',
      ];
      beachTips = [
        'Ideal for watching bioluminescence',
        'Lower tides, good for tide pool exploration',
        'Perfect for stargazing from the beach',
      ];
    } else if (normalized < 0.22) {
      // Waxing Crescent
      phaseName = 'Waxing Crescent';
      emoji = '🌒';
      description = 'A sliver of moon is visible in the evening sky';
      photoTips = [
        'Capture the crescent moon at sunset',
        'Good balance between stars and moonlight',
        'Silhouette photography opportunities',
      ];
      beachTips = [
        'Evening beach walks with moonlight',
        'Lower tides suitable for beach activities',
        'Moderate conditions for water sports',
      ];
    } else if (normalized < 0.28) {
      // First Quarter
      phaseName = 'First Quarter';
      emoji = '🌓';
      description = 'Half of the moon is illuminated';
      photoTips = [
        'Half-lit moon creates dramatic shadows',
        'Great for moon surface detail photography',
        'Balance of light for landscape shots',
      ];
      beachTips = [
        'Moderate tides',
        'Good visibility for evening activities',
        'Safe swimming conditions',
      ];
    } else if (normalized < 0.47) {
      // Waxing Gibbous
      phaseName = 'Waxing Gibbous';
      emoji = '🌔';
      description = 'More than half illuminated, approaching full moon';
      photoTips = [
        'Bright moon for night photography',
        'Moonlit landscape opportunities',
        'Good for capturing moon details',
      ];
      beachTips = [
        'Increasing tides',
        'Bright nights for beach activities',
        'Romantic moonlit beach walks',
      ];
    } else if (normalized < 0.53) {
      // Full Moon
      phaseName = isPoya ? 'Full Moon (Poya Day)' : 'Full Moon';
      emoji = isPoya ? '🌕🙏' : '🌕';
      description = isPoya
          ? 'Full moon - Buddhist Poya observance day in Sri Lanka'
          : 'The moon is fully illuminated';
      photoTips = [
        'Photograph the moon rising over landscapes',
        'Capture moon reflections on water',
        'Silhouette photography with moon backdrop',
        if (isPoya) 'Visit temples for Poya celebrations',
      ];
      beachTips = [
        'Highest tides of the month',
        'Spectacular moonlit beach views',
        'Popular time for beach gatherings',
        if (isPoya) 'Note: Alcohol sales prohibited on Poya days',
      ];
    } else if (normalized < 0.72) {
      // Waning Gibbous
      phaseName = 'Waning Gibbous';
      emoji = '🌖';
      description = 'More than half illuminated, after full moon';
      photoTips = [
        'Late-night moon photography',
        'Moon rises later in evening',
        'Atmospheric moonset shots in morning',
      ];
      beachTips = [
        'Decreasing tides',
        'Late moonrise for evening activities',
        'Beautiful moonset at dawn',
      ];
    } else if (normalized < 0.78) {
      // Last Quarter
      phaseName = 'Last Quarter';
      emoji = '🌗';
      description = 'Half illuminated, visible in morning sky';
      photoTips = [
        'Morning moon photography',
        'Moon and sunrise combinations',
        'Last quarter moon at dawn',
      ];
      beachTips = [
        'Moderate tides',
        'Morning beach activities',
        'Good for early morning surfing',
      ];
    } else {
      // Waning Crescent
      phaseName = 'Waning Crescent';
      emoji = '🌘';
      description = 'Thin crescent visible before sunrise';
      photoTips = [
        'Pre-dawn crescent moon shots',
        'Increasing darkness for stars',
        'Prepare for new moon astrophotography',
      ];
      beachTips = [
        'Lower tides approaching',
        'Excellent for sunrise beach visits',
        'Good for calm water activities',
      ];
    }

    return MoonPhase(
      phaseName: phaseName,
      emoji: emoji,
      illumination: normalized > 0.5 ? 1.0 - (normalized - 0.5) * 2 : normalized * 2,
      date: date,
      description: description,
      photographyTips: photoTips,
      beachActivities: beachTips,
      isPoyaDay: isPoya,
    );
  }

  String get illuminationPercentage => '${(illumination * 100).toInt()}%';

  bool get isFullMoon => illumination > 0.95;
  bool get isNewMoon => illumination < 0.05;

  String get tideInfo {
    if (isFullMoon || isNewMoon) {
      return 'Spring tides (highest high and lowest low tides)';
    } else if (illumination > 0.4 && illumination < 0.6) {
      return 'Neap tides (moderate tidal range)';
    } else {
      return 'Moderate tides';
    }
  }
}

/// Upcoming moon phases
class MoonPhaseCalendar {
  final DateTime date;
  final List<MoonPhaseEvent> upcomingPhases;

  MoonPhaseCalendar({
    required this.date,
    required this.upcomingPhases,
  });

  MoonPhaseEvent? get nextFullMoon {
    return upcomingPhases
        .where((p) => p.phaseName == 'Full Moon')
        .isNotEmpty
        ? upcomingPhases.firstWhere((p) => p.phaseName == 'Full Moon')
        : null;
  }

  MoonPhaseEvent? get nextNewMoon {
    return upcomingPhases
        .where((p) => p.phaseName == 'New Moon')
        .isNotEmpty
        ? upcomingPhases.firstWhere((p) => p.phaseName == 'New Moon')
        : null;
  }
}

/// Individual moon phase event
class MoonPhaseEvent {
  final String phaseName;
  final String emoji;
  final DateTime date;
  final int daysUntil;

  MoonPhaseEvent({
    required this.phaseName,
    required this.emoji,
    required this.date,
    required this.daysUntil,
  });

  bool get isToday => daysUntil == 0;
  bool get isPoya => phaseName.contains('Poya');
}
