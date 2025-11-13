import 'dart:math';
import '../models/moon_phase.dart';
import '../models/holiday.dart';
import '../services/holiday_service.dart';

/// Service for moon phase calculations
/// Uses astronomical calculations - completely free, no API required
class MoonPhaseService {
  final HolidayService _holidayService = HolidayService();

  /// Get current moon phase
  Future<MoonPhase> getCurrentMoonPhase() async {
    return getMoonPhaseForDate(DateTime.now());
  }

  /// Get moon phase for a specific date
  Future<MoonPhase> getMoonPhaseForDate(DateTime date) async {
    final phase = _calculateMoonPhase(date);
    final isPoya = await _isPoyaDay(date);

    return MoonPhase.fromPhaseValue(phase, date, isPoya: isPoya);
  }

  /// Calculate moon phase (0 = new moon, 0.5 = full moon, 1 = new moon)
  /// Based on astronomical formula
  double _calculateMoonPhase(DateTime date) {
    // Known new moon: January 6, 2000, 18:14 UTC
    final knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

    // Average lunar cycle is 29.53058770576 days
    const lunarCycle = 29.53058770576;

    // Calculate days since known new moon
    final daysSinceNewMoon = date.difference(knownNewMoon).inMilliseconds / (1000 * 60 * 60 * 24);

    // Calculate phase (0 to 1)
    final phase = (daysSinceNewMoon % lunarCycle) / lunarCycle;

    return phase;
  }

  /// Check if the date is a Poya (full moon) day in Sri Lanka
  Future<bool> _isPoyaDay(DateTime date) async {
    try {
      final holidays = await _holidayService.getHolidays(year: date.year);

      // Check if any holiday on this date is a Poya day
      return holidays.any((holiday) =>
          holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day &&
          holiday.name.toLowerCase().contains('poya'));
    } catch (e) {
      // If we can't fetch holidays, just check if it's a full moon
      final phase = _calculateMoonPhase(date);
      return (phase > 0.47 && phase < 0.53);
    }
  }

  /// Get upcoming moon phase events for the next 60 days
  Future<MoonPhaseCalendar> getUpcomingPhases() async {
    final today = DateTime.now();
    final upcomingEvents = <MoonPhaseEvent>[];

    // Calculate major phases for next 60 days
    for (int day = 0; day <= 60; day++) {
      final date = today.add(Duration(days: day));
      final phase = _calculateMoonPhase(date);

      // Check for major phase transitions
      String? phaseName;
      String? emoji;

      if (phase < 0.03 || phase > 0.97) {
        phaseName = 'New Moon';
        emoji = '🌑';
      } else if (phase >= 0.24 && phase <= 0.26) {
        phaseName = 'First Quarter';
        emoji = '🌓';
      } else if (phase >= 0.49 && phase <= 0.51) {
        final isPoya = await _isPoyaDay(date);
        phaseName = isPoya ? 'Full Moon (Poya)' : 'Full Moon';
        emoji = isPoya ? '🌕🙏' : '🌕';
      } else if (phase >= 0.74 && phase <= 0.76) {
        phaseName = 'Last Quarter';
        emoji = '🌗';
      }

      if (phaseName != null) {
        upcomingEvents.add(MoonPhaseEvent(
          phaseName: phaseName,
          emoji: emoji!,
          date: date,
          daysUntil: day,
        ));
      }
    }

    return MoonPhaseCalendar(
      date: today,
      upcomingPhases: upcomingEvents,
    );
  }

  /// Get next full moon
  Future<MoonPhaseEvent?> getNextFullMoon() async {
    final calendar = await getUpcomingPhases();
    return calendar.nextFullMoon;
  }

  /// Get next new moon
  Future<MoonPhaseEvent?> getNextNewMoon() async {
    final calendar = await getUpcomingPhases();
    return calendar.nextNewMoon;
  }

  /// Get moon illumination percentage for a specific date
  double getMoonIllumination(DateTime date) {
    final phase = _calculateMoonPhase(date);
    // Convert phase to illumination (0 and 1 are new moon, 0.5 is full moon)
    return phase > 0.5 ? 1.0 - (phase - 0.5) * 2 : phase * 2;
  }
}
