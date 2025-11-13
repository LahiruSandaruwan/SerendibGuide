import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holiday.dart';

/// Holiday service using Nager.Date API
/// 100% FREE - No API key required!
class HolidayService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  // Cache for holidays per year
  static final Map<int, List<Holiday>> _cache = {};

  /// Get all public holidays for Sri Lanka in a given year
  ///
  /// [year] - Year to get holidays for (defaults to current year)
  Future<List<Holiday>> getHolidays({int? year}) async {
    year ??= DateTime.now().year;

    // Check cache
    if (_cache.containsKey(year)) {
      print('📅 Using cached holidays for $year');
      return _cache[year]!;
    }

    try {
      final url = Uri.parse('$_baseUrl/PublicHolidays/$year/LK');

      print('🎉 Fetching public holidays for $year...');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch holidays: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      final holidays = data
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by date
      holidays.sort((a, b) => a.date.compareTo(b.date));

      // Cache the results
      _cache[year] = holidays;

      print('✅ Found ${holidays.length} holidays for $year');

      return holidays;
    } catch (e) {
      print('✗ Error fetching holidays: $e');
      rethrow;
    }
  }

  /// Get upcoming holidays (next 90 days)
  Future<List<Holiday>> getUpcomingHolidays() async {
    try {
      final now = DateTime.now();
      final currentYearHolidays = await getHolidays(year: now.year);
      final nextYearHolidays = now.month >= 10
          ? await getHolidays(year: now.year + 1)
          : <Holiday>[];

      final allHolidays = [...currentYearHolidays, ...nextYearHolidays];

      // Filter upcoming holidays (next 90 days)
      final upcoming = allHolidays.where((holiday) {
        final diff = holiday.date.difference(now);
        return diff.inDays >= 0 && diff.inDays <= 90;
      }).toList();

      upcoming.sort((a, b) => a.date.compareTo(b.date));

      return upcoming;
    } catch (e) {
      print('✗ Error fetching upcoming holidays: $e');
      rethrow;
    }
  }

  /// Get holidays for current month
  Future<List<Holiday>> getThisMonthHolidays() async {
    try {
      final now = DateTime.now();
      final holidays = await getHolidays(year: now.year);

      return holidays.where((holiday) {
        return holiday.date.year == now.year &&
               holiday.date.month == now.month;
      }).toList();
    } catch (e) {
      print('✗ Error fetching this month holidays: $e');
      rethrow;
    }
  }

  /// Check if a specific date is a holiday
  Future<Holiday?> isHoliday(DateTime date) async {
    try {
      final holidays = await getHolidays(year: date.year);

      return holidays.firstWhere(
        (holiday) =>
            holiday.date.year == date.year &&
            holiday.date.month == date.month &&
            holiday.date.day == date.day,
        orElse: () => throw Exception('Not a holiday'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get next holiday
  Future<Holiday?> getNextHoliday() async {
    try {
      final upcoming = await getUpcomingHolidays();
      return upcoming.isNotEmpty ? upcoming.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Get holidays by month
  Future<Map<int, List<Holiday>>> getHolidaysByMonth({int? year}) async {
    try {
      final holidays = await getHolidays(year: year);
      final byMonth = <int, List<Holiday>>{};

      for (final holiday in holidays) {
        final month = holiday.date.month;
        byMonth[month] = [...(byMonth[month] ?? []), holiday];
      }

      return byMonth;
    } catch (e) {
      print('✗ Error grouping holidays by month: $e');
      rethrow;
    }
  }

  /// Check if today is a holiday
  Future<Holiday?> isTodayHoliday() async {
    return isHoliday(DateTime.now());
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }
}
