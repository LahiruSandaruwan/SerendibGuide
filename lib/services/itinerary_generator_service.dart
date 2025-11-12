import 'dart:math';
import '../models/attraction.dart';
import '../models/itinerary.dart';
import '../services/database_service.dart';

/// Service for generating intelligent itineraries
class ItineraryGeneratorService {
  final DatabaseService _databaseService = DatabaseService();

  /// Generate an itinerary based on preferences
  Future<GeneratedItinerary> generateItinerary(ItineraryPreferences prefs) async {
    // Get all attractions
    final allAttractions = await _databaseService.getAttractions();

    // Filter attractions based on preferences
    final filteredAttractions = _filterAttractionsByPreferences(allAttractions, prefs);

    // Score and rank attractions
    final rankedAttractions = _scoreAndRankAttractions(filteredAttractions, prefs);

    // Create day plans
    final dayPlans = _createDayPlans(rankedAttractions, prefs);

    return GeneratedItinerary(
      title: _generateTitle(prefs),
      numberOfDays: prefs.numberOfDays,
      dayPlans: dayPlans,
      budget: _getBudgetName(prefs.budgetLevel),
      interests: prefs.interests,
      pace: _getPaceName(prefs.pace),
      createdAt: DateTime.now(),
    );
  }

  /// Filter attractions based on user preferences
  List<Attraction> _filterAttractionsByPreferences(
    List<Attraction> attractions,
    ItineraryPreferences prefs,
  ) {
    return attractions.where((attraction) {
      // Filter by interests (categories)
      if (prefs.interests.isNotEmpty) {
        final hasMatchingCategory = prefs.interests.any((interest) =>
            attraction.category.toLowerCase().contains(interest.toLowerCase()));
        if (!hasMatchingCategory) return false;
      }

      // Filter by region preferences
      final province = attraction.province?.toLowerCase() ?? '';

      if (!prefs.includeBeaches && _isBeachArea(province, attraction.category)) {
        return false;
      }
      if (!prefs.includeHills && _isHillArea(province)) {
        return false;
      }
      if (!prefs.includeCulturalSites && _isCulturalSite(attraction.category)) {
        return false;
      }
      if (!prefs.includeWildlife && _isWildlifeSite(attraction.category)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Score attractions based on preferences and quality
  List<Attraction> _scoreAndRankAttractions(
    List<Attraction> attractions,
    ItineraryPreferences prefs,
  ) {
    final scored = attractions.map((attraction) {
      double score = 0.0;

      // Base score from rating (if available)
      score += 5.0; // Base score

      // Boost score for matching interests
      for (var interest in prefs.interests) {
        if (attraction.category.toLowerCase().contains(interest.toLowerCase())) {
          score += 10.0;
        }
      }

      // Boost UNESCO sites
      if (attraction.description.toLowerCase().contains('unesco')) {
        score += 15.0;
      }

      // Boost popular attractions (based on keywords)
      if (_isPopularAttraction(attraction)) {
        score += 8.0;
      }

      return MapEntry(attraction, score);
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.map((entry) => entry.key).toList();
  }

  /// Create day-by-day plans
  List<DayPlan> _createDayPlans(
    List<Attraction> rankedAttractions,
    ItineraryPreferences prefs,
  ) {
    final List<DayPlan> dayPlans = [];
    final attractionsPerDay = _getAttractionsPerDay(prefs.pace);

    // Group attractions by region for efficient routing
    final regionGroups = _groupByRegion(rankedAttractions);

    int attractionIndex = 0;

    for (int day = 1; day <= prefs.numberOfDays; day++) {
      // Get region for this day (rotate through regions)
      final regionKeys = regionGroups.keys.toList();
      if (regionKeys.isEmpty) break;

      final regionIndex = (day - 1) % regionKeys.length;
      final region = regionKeys[regionIndex];
      final regionAttractions = regionGroups[region] ?? [];

      // Select attractions for this day
      final dayAttractions = <Attraction>[];
      int count = 0;

      while (count < attractionsPerDay && attractionIndex < rankedAttractions.length) {
        final attraction = rankedAttractions[attractionIndex];
        if ((attraction.province ?? '').toLowerCase().contains(region.toLowerCase())) {
          dayAttractions.add(attraction);
          count++;
        }
        attractionIndex++;
      }

      // If not enough attractions in this region, add from other regions
      while (dayAttractions.length < attractionsPerDay && attractionIndex < rankedAttractions.length) {
        dayAttractions.add(rankedAttractions[attractionIndex]);
        attractionIndex++;
      }

      if (dayAttractions.isEmpty) continue;

      dayPlans.add(DayPlan(
        dayNumber: day,
        region: region,
        attractions: dayAttractions,
        estimatedCost: _calculateDayCost(dayAttractions, prefs.budgetLevel),
        travelTips: _generateTravelTips(region, dayAttractions),
        meals: _suggestMeals(region, prefs.budgetLevel),
      ));
    }

    return dayPlans;
  }

  /// Group attractions by region/province
  Map<String, List<Attraction>> _groupByRegion(List<Attraction> attractions) {
    final Map<String, List<Attraction>> groups = {};

    for (var attraction in attractions) {
      final province = attraction.province ?? 'Other';
      groups.putIfAbsent(province, () => []).add(attraction);
    }

    return groups;
  }

  /// Calculate estimated cost for a day
  double _calculateDayCost(List<Attraction> attractions, BudgetLevel budget) {
    double baseCost = 0;

    switch (budget) {
      case BudgetLevel.budget:
        baseCost = 3000; // Accommodation + food
        break;
      case BudgetLevel.moderate:
        baseCost = 8000;
        break;
      case BudgetLevel.luxury:
        baseCost = 20000;
        break;
    }

    // Add attraction entrance fees (estimated)
    final attractionCosts = attractions.length * 1500.0;

    // Add transport
    final transport = budget == BudgetLevel.budget ? 1000 : (budget == BudgetLevel.moderate ? 3000 : 8000);

    return baseCost + attractionCosts + transport;
  }

  /// Generate travel tips for the day
  String _generateTravelTips(String region, List<Attraction> attractions) {
    final tips = <String>[];

    if (region.toLowerCase().contains('kandy')) {
      tips.add('Dress modestly for temple visits');
    }
    if (region.toLowerCase().contains('western')) {
      tips.add('Traffic can be heavy in Colombo - plan accordingly');
    }
    if (region.toLowerCase().contains('uva') || region.toLowerCase().contains('central')) {
      tips.add('Bring warm clothing for hill country');
    }
    if (attractions.any((a) => a.category.toLowerCase().contains('wildlife'))) {
      tips.add('Book safari in advance');
    }

    if (tips.isEmpty) {
      tips.add('Start early to avoid crowds and heat');
    }

    return tips.join('. ');
  }

  /// Suggest meals based on region and budget
  List<String> _suggestMeals(String region, BudgetLevel budget) {
    final meals = <String>[];

    if (budget == BudgetLevel.budget) {
      meals.add('Breakfast: Local eatery (hoppers or string hoppers)');
      meals.add('Lunch: Rice and curry at local restaurant');
      meals.add('Dinner: Kottu roti or fried rice');
    } else if (budget == BudgetLevel.moderate) {
      meals.add('Breakfast: Hotel buffet or cafe');
      meals.add('Lunch: Mid-range restaurant with rice and curry');
      meals.add('Dinner: Restaurant with local or international cuisine');
    } else {
      meals.add('Breakfast: Hotel fine dining or specialty cafe');
      meals.add('Lunch: Premium restaurant or hotel');
      meals.add('Dinner: Fine dining with Sri Lankan or fusion cuisine');
    }

    return meals;
  }

  // Helper methods

  int _getAttractionsPerDay(PaceLevel pace) {
    switch (pace) {
      case PaceLevel.relaxed:
        return 2;
      case PaceLevel.moderate:
        return 3;
      case PaceLevel.packed:
        return 5;
    }
  }

  bool _isBeachArea(String province, String category) {
    return province.contains('southern') ||
           province.contains('western') ||
           category.toLowerCase().contains('beach');
  }

  bool _isHillArea(String province) {
    return province.toLowerCase().contains('central') ||
           province.toLowerCase().contains('uva');
  }

  bool _isCulturalSite(String category) {
    return category.toLowerCase().contains('cultural') ||
           category.toLowerCase().contains('historical') ||
           category.toLowerCase().contains('religious');
  }

  bool _isWildlifeSite(String category) {
    return category.toLowerCase().contains('wildlife') ||
           category.toLowerCase().contains('national park');
  }

  bool _isPopularAttraction(Attraction attraction) {
    final name = attraction.name.toLowerCase();
    final desc = attraction.description.toLowerCase();

    final popularKeywords = [
      'sigiriya', 'tooth', 'perahera', 'yala', 'ella', 'adams peak',
      'galle fort', 'temple of tooth', 'unesco', 'nine arch', 'world heritage'
    ];

    return popularKeywords.any((keyword) =>
      name.contains(keyword) || desc.contains(keyword));
  }

  String _generateTitle(ItineraryPreferences prefs) {
    final days = prefs.numberOfDays;
    if (prefs.interests.isEmpty) {
      return '$days-Day Sri Lanka Adventure';
    }

    final mainInterest = prefs.interests.first;
    return '$days-Day $mainInterest Tour';
  }

  String _getBudgetName(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return 'Budget';
      case BudgetLevel.moderate:
        return 'Moderate';
      case BudgetLevel.luxury:
        return 'Luxury';
    }
  }

  String _getPaceName(PaceLevel level) {
    switch (level) {
      case PaceLevel.relaxed:
        return 'Relaxed';
      case PaceLevel.moderate:
        return 'Moderate';
      case PaceLevel.packed:
        return 'Packed';
    }
  }
}
