import 'dart:math';
import 'package:intl/intl.dart';

/// Utility helper functions for Serendib Guide
class Helpers {
  /// Calculate Haversine distance between two coordinates in kilometers
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    return double.parse(distance.toStringAsFixed(2));
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Format distance for display (e.g., "5.3 km" or "350 m")
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final int meters = (distanceKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Format date in a readable format
  static String formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final DateTime date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  /// Format date with time
  static String formatDateTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final DateTime date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy • h:mm a').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  /// Format relative time (e.g., "2 days ago")
  static String formatRelativeTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final DateTime date = DateTime.parse(isoDate);
      final Duration difference = DateTime.now().difference(date);

      if (difference.inDays > 365) {
        final int years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        final int months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return isoDate;
    }
  }

  /// Parse comma-separated string to list
  static List<String> parseCommaSeparated(String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  /// Join list to comma-separated string
  static String joinCommaSeparated(List<String> values) {
    return values.join(',');
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate latitude
  static bool isValidLatitude(double? lat) {
    return lat != null && lat >= -90 && lat <= 90;
  }

  /// Validate longitude
  static bool isValidLongitude(double? lng) {
    return lng != null && lng >= -180 && lng <= 180;
  }

  /// Get file size from bytes
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Sanitize search query
  static String sanitizeSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Generate Google Maps URL for directions
  static String getDirectionsUrl(double lat, double lng) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }

  /// Generate share text for attraction
  static String getAttractionShareText(String name, double lat, double lng) {
    return 'Check out $name on Serendib Guide!\n\n'
        'Get directions: ${getDirectionsUrl(lat, lng)}\n\n'
        'Download Serendib Guide for more amazing places in Sri Lanka!';
  }

  /// Generate share text for trip
  static String getTripShareText(String tripName, List<String> attractionNames) {
    final String attractionsList = attractionNames.map((name) => '• $name').join('\n');
    return 'My $tripName itinerary:\n\n'
        '$attractionsList\n\n'
        'Created with Serendib Guide - Complete offline travel guide for Sri Lanka!';
  }

  /// Parse duration string (e.g., "3-4 hours", "Full day")
  static String formatDuration(String? duration) {
    if (duration == null || duration.isEmpty) return 'Not specified';
    return duration;
  }

  /// Get what to bring suggestions based on category
  static List<String> getWhatToBring(String category) {
    switch (category) {
      case 'Ancient Sites':
        return [
          'Comfortable walking shoes',
          'Sun hat and sunscreen',
          'Water bottle',
          'Camera',
          'Modest clothing (cover shoulders & knees)',
        ];
      case 'Beaches':
        return [
          'Swimwear',
          'Beach towel',
          'Sunscreen (reef-safe)',
          'Sunglasses',
          'Waterproof bag',
        ];
      case 'Nature & Wildlife':
        return [
          'Binoculars',
          'Insect repellent',
          'Comfortable hiking shoes',
          'Long pants and sleeves',
          'Camera with zoom lens',
        ];
      case 'Hill Country':
        return [
          'Warm jacket (mornings/evenings)',
          'Comfortable walking shoes',
          'Rain jacket',
          'Camera',
          'Reusable water bottle',
        ];
      case 'Religious Sites':
        return [
          'Modest clothing (white recommended for some)',
          'Remove shoes before entering',
          'Respectful attitude',
          'Small donation/offering',
          'Head covering (for some sites)',
        ];
      case 'Food Experiences':
        return [
          'Appetite!',
          'Hand sanitizer',
          'Small local currency',
          'Open mind for new flavors',
          'Camera for food photos',
        ];
      default:
        return [
          'Comfortable shoes',
          'Water bottle',
          'Sun protection',
          'Camera',
          'Local currency',
        ];
    }
  }

  /// Calculate estimated trip duration from individual durations
  static String calculateTripDuration(List<String> durations) {
    int totalHours = 0;
    for (final String duration in durations) {
      final String cleaned = duration.toLowerCase().replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isNotEmpty) {
        totalHours += int.tryParse(cleaned.substring(0, min(cleaned.length, 2))) ?? 0;
      }
    }

    if (totalHours == 0) return 'Not estimated';
    if (totalHours < 24) return '$totalHours hours';

    final int days = (totalHours / 8).ceil(); // Assuming 8 active hours per day
    return '$days ${days == 1 ? 'day' : 'days'}';
  }

  /// Calculate total trip distance
  static double calculateTripDistance(List<Map<String, double>> coordinates) {
    if (coordinates.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < coordinates.length - 1; i++) {
      final double distance = calculateDistance(
        coordinates[i]['lat']!,
        coordinates[i]['lng']!,
        coordinates[i + 1]['lat']!,
        coordinates[i + 1]['lng']!,
      );
      totalDistance += distance;
    }

    return double.parse(totalDistance.toStringAsFixed(2));
  }

  /// Format currency (LKR and USD)
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    if (currency == 'LKR') {
      return 'Rs ${amount.toStringAsFixed(0)}';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  /// Generate random placeholder for empty states
  static String getRandomTip() {
    final List<String> tips = [
      'Did you know? Sri Lanka has 8 UNESCO World Heritage Sites!',
      'Tip: Visit Sigiriya early morning to avoid heat and crowds.',
      'The train from Kandy to Ella is considered one of the most scenic in the world.',
      'Sri Lanka is home to the largest gathering of Asian elephants.',
      'Adam\'s Peak is sacred to four religions: Buddhism, Hinduism, Islam, and Christianity.',
      'Sri Lankan cuisine has been influenced by Indian, Dutch, Portuguese, and British cultures.',
    ];
    return tips[Random().nextInt(tips.length)];
  }
}
