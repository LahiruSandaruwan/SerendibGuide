import 'attraction.dart';

/// Generated itinerary model
class GeneratedItinerary {
  final String title;
  final int numberOfDays;
  final List<DayPlan> dayPlans;
  final String budget;
  final List<String> interests;
  final String pace;
  final DateTime createdAt;

  const GeneratedItinerary({
    required this.title,
    required this.numberOfDays,
    required this.dayPlans,
    required this.budget,
    required this.interests,
    required this.pace,
    required this.createdAt,
  });

  double getTotalEstimatedCost() {
    return dayPlans.fold(0.0, (sum, day) => sum + day.estimatedCost);
  }

  int getTotalAttractions() {
    return dayPlans.fold(0, (sum, day) => sum + day.attractions.length);
  }
}

/// Day plan within an itinerary
class DayPlan {
  final int dayNumber;
  final String region;
  final List<Attraction> attractions;
  final double estimatedCost;
  final String travelTips;
  final List<String> meals;

  const DayPlan({
    required this.dayNumber,
    required this.region,
    required this.attractions,
    required this.estimatedCost,
    required this.travelTips,
    required this.meals,
  });

  String getTitle() {
    return 'Day $dayNumber: $region';
  }
}

/// Itinerary generation preferences
class ItineraryPreferences {
  final int numberOfDays;
  final BudgetLevel budgetLevel;
  final List<String> interests; // Categories the user is interested in
  final PaceLevel pace;
  final bool includeBeaches;
  final bool includeHills;
  final bool includeCulturalSites;
  final bool includeWildlife;

  const ItineraryPreferences({
    required this.numberOfDays,
    required this.budgetLevel,
    required this.interests,
    required this.pace,
    this.includeBeaches = true,
    this.includeHills = true,
    this.includeCulturalSites = true,
    this.includeWildlife = true,
  });
}

enum BudgetLevel {
  budget, // Backpacker
  moderate, // Mid-range
  luxury, // High-end
}

enum PaceLevel {
  relaxed, // 2-3 attractions per day
  moderate, // 3-4 attractions per day
  packed, // 5+ attractions per day
}

/// Popular itinerary templates
class ItineraryTemplates {
  static const Map<String, String> templates = {
    'cultural_triangle': 'Cultural Triangle',
    'beach_relaxation': 'Beach & Relaxation',
    'hill_country': 'Hill Country Adventure',
    'wildlife_safari': 'Wildlife Safari',
    'complete_tour': 'Complete Sri Lanka Tour',
    'unesco_sites': 'UNESCO Heritage Sites',
  };

  static ItineraryPreferences getCulturalTriangleTemplate(int days) {
    return ItineraryPreferences(
      numberOfDays: days,
      budgetLevel: BudgetLevel.moderate,
      interests: ['Cultural', 'Historical'],
      pace: PaceLevel.moderate,
      includeCulturalSites: true,
      includeBeaches: false,
      includeHills: false,
      includeWildlife: false,
    );
  }

  static ItineraryPreferences getBeachRelaxationTemplate(int days) {
    return ItineraryPreferences(
      numberOfDays: days,
      budgetLevel: BudgetLevel.moderate,
      interests: ['Beach', 'Nature'],
      pace: PaceLevel.relaxed,
      includeBeaches: true,
      includeCulturalSites: false,
      includeHills: false,
      includeWildlife: false,
    );
  }

  static ItineraryPreferences getHillCountryTemplate(int days) {
    return ItineraryPreferences(
      numberOfDays: days,
      budgetLevel: BudgetLevel.moderate,
      interests: ['Nature', 'Adventure'],
      pace: PaceLevel.moderate,
      includeHills: true,
      includeBeaches: false,
      includeCulturalSites: true,
      includeWildlife: false,
    );
  }

  static ItineraryPreferences getWildlifeSafariTemplate(int days) {
    return ItineraryPreferences(
      numberOfDays: days,
      budgetLevel: BudgetLevel.moderate,
      interests: ['Wildlife', 'Nature'],
      pace: PaceLevel.relaxed,
      includeWildlife: true,
      includeBeaches: false,
      includeCulturalSites: false,
      includeHills: false,
    );
  }

  static ItineraryPreferences getCompleteTourTemplate(int days) {
    return ItineraryPreferences(
      numberOfDays: days,
      budgetLevel: BudgetLevel.moderate,
      interests: ['Cultural', 'Nature', 'Beach', 'Wildlife'],
      pace: PaceLevel.moderate,
      includeBeaches: true,
      includeHills: true,
      includeCulturalSites: true,
      includeWildlife: true,
    );
  }

  static ItineraryPreferences getUNESCOTemplate(int days) {
    return ItineraryPreferences(
      numberOfDays: days,
      budgetLevel: BudgetLevel.moderate,
      interests: ['Cultural', 'Historical'],
      pace: PaceLevel.moderate,
      includeCulturalSites: true,
      includeBeaches: false,
      includeHills: false,
      includeWildlife: false,
    );
  }
}
