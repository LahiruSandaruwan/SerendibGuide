import 'package:flutter/material.dart';

/// App-wide constants for Serendib Guide
class AppConstants {
  // App Identity
  static const String appName = 'Serendib Guide';
  static const String appTagline = 'Discover the Island of Serendipity 🌴';
  static const String packageName = 'com.serendibguide.srilanka';

  // Brand Colors
  static const Color deepOceanBlue = Color(0xFF1565C0); // Primary - Indian Ocean
  static const Color tropicalGreen = Color(0xFF2E7D32); // Secondary - Tea plantations
  static const Color sunsetOrange = Color(0xFFF57C00); // Accent - Sri Lankan sunsets
  static const Color cleanWhite = Color(0xFAFAFA); // Background
  static const Color darkGrey = Color(0xFF212121); // Text

  // Additional UI Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningAmber = Color(0xFFFFA000);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color ancientBrown = Color(0xFF5D4037);
  static const Color mountainGreen = Color(0xFF388E3C);
  static const Color spiceYellow = Color(0xFFFDD835);
  static const Color skyBlue = Color(0xFF0288D1);

  // Spacing & Dimensions
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;
  static const double borderRadius24 = 24.0;

  static const double attractionCardHeight = 200.0;
  static const double attractionCardImageHeight = 120.0;
  static const double categoryChipHeight = 40.0;
  static const double bannerAdHeight = 50.0;

  // Font Weights
  static const FontWeight fontLight = FontWeight.w300;
  static const FontWeight fontRegular = FontWeight.w400;
  static const FontWeight fontMedium = FontWeight.w500;
  static const FontWeight fontBold = FontWeight.w700;

  // AdMob Ad Unit IDs (TEST IDs - MUST REPLACE IN PRODUCTION)
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  // In-App Purchase Product IDs
  static const String premiumProductId = 'premium_unlock';
  static const double premiumPriceUSD = 14.99;

  // Database Constants
  static const String attractionsDbName = 'attractions.db';
  static const String userDataDbName = 'user_data.db';
  static const int databaseVersion = 1;

  // Free Tier Limits
  static const int freeAttractionLimit = 100;
  static const int freeFavoritesLimit = 20;
  static const int freeTripsLimit = 3;

  // Ad Display Configuration
  static const int interstitialAdFrequency = 5; // Show interstitial every 5 attraction views
  static const int interstitialAdMaxAttempts = 3;

  // Map Configuration
  static const double sriLankaDefaultLat = 7.8731;
  static const double sriLankaDefaultLng = 80.7718;
  static const double defaultZoom = 8.0;
  static const double minZoom = 7.0;
  static const double maxZoom = 15.0;

  // Map Bounds (Sri Lanka)
  static const double boundsNorth = 9.9;
  static const double boundsSouth = 5.9;
  static const double boundsEast = 82.0;
  static const double boundsWest = 79.5;

  // Search Configuration
  static const int minSearchLength = 2;
  static const int maxRecentSearches = 10;
  static const int searchDebounceMs = 300;

  // Nearby Attractions Configuration
  static const double nearbyRadiusKm = 10.0;
  static const int maxNearbyResults = 10;

  // Image Configuration
  static const int imageQuality = 85;
  static const double maxImageWidth = 1200;
  static const double maxImageHeight = 800;

  // Categories
  static const List<String> categories = [
    'Ancient Sites',
    'Beaches',
    'Nature & Wildlife',
    'Hill Country',
    'Cities',
    'Religious Sites',
    'Food Experiences',
    'Culture & Museums',
    'Scenic Experiences',
  ];

  // Provinces
  static const List<String> provinces = [
    'Western',
    'Central',
    'Southern',
    'Northern',
    'Eastern',
    'North Western',
    'North Central',
    'Uva',
    'Sabaragamuwa',
  ];

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Easy',
    'Moderate',
    'Challenging',
  ];

  // Supported Languages
  static const List<String> supportedLanguageCodes = ['en', 'si', 'ta'];
  static const Map<String, String> languageNames = {
    'en': 'English',
    'si': 'සිංහල',
    'ta': 'தமிழ்',
  };

  // SharedPreferences Keys
  static const String keyLanguageCode = 'language_code';
  static const String keyIsPremium = 'is_premium';
  static const String keyAdImpressionCount = 'ad_impression_count';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyUseOfflineMaps = 'use_offline_maps';
  static const String keyRecentSearches = 'recent_searches';
  static const String keyFirstLaunch = 'first_launch';

  // URLs
  static const String supportEmail = 'support@serendibguide.com';
  static const String websiteUrl = 'https://serendibguide.com';
  static const String privacyPolicyUrl = 'https://serendibguide.com/privacy';
  static const String termsOfServiceUrl = 'https://serendibguide.com/terms';
  static const String playStoreUrl = 'market://details?id=$packageName';

  // Contact Info
  static const String touristPolice = '1912';
  static const String ambulance = '1990';
  static const String fire = '110';

  // Attribution
  static const String mapAttribution = '© OpenStreetMap contributors';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Helper class for category-specific configurations
class CategoryConfig {
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Ancient Sites':
        return const Color(0xFF1976D2); // Blue
      case 'Beaches':
        return AppConstants.sunsetOrange; // Orange
      case 'Nature & Wildlife':
        return AppConstants.tropicalGreen; // Green
      case 'Hill Country':
        return const Color(0xFF7B1FA2); // Purple
      case 'Cities':
        return const Color(0xFF455A64); // Blue Grey
      case 'Religious Sites':
        return const Color(0xFFD32F2F); // Red
      case 'Food Experiences':
        return const Color(0xFFE64A19); // Deep Orange
      case 'Culture & Museums':
        return const Color(0xFF5D4037); // Brown
      case 'Scenic Experiences':
        return const Color(0xFF0097A7); // Cyan
      default:
        return AppConstants.deepOceanBlue;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Ancient Sites':
        return Icons.account_balance;
      case 'Beaches':
        return Icons.beach_access;
      case 'Nature & Wildlife':
        return Icons.nature;
      case 'Hill Country':
        return Icons.terrain;
      case 'Cities':
        return Icons.location_city;
      case 'Religious Sites':
        return Icons.temple_hindu;
      case 'Food Experiences':
        return Icons.restaurant;
      case 'Culture & Museums':
        return Icons.museum;
      case 'Scenic Experiences':
        return Icons.landscape;
      default:
        return Icons.place;
    }
  }
}

/// Helper class for difficulty-specific configurations
class DifficultyConfig {
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppConstants.successGreen;
      case 'Moderate':
        return AppConstants.sunsetOrange;
      case 'Challenging':
        return AppConstants.errorRed;
      default:
        return Colors.grey;
    }
  }

  static IconData getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Icons.sentiment_satisfied;
      case 'Moderate':
        return Icons.sentiment_neutral;
      case 'Challenging':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}
