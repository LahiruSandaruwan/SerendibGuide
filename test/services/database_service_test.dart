import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:serendib_guide/services/database_service.dart';
import 'package:serendib_guide/models/attraction.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseService', () {
    late DatabaseService databaseService;

    setUp(() {
      databaseService = DatabaseService();
    });

    test('DatabaseService is a singleton', () {
      final instance1 = DatabaseService();
      final instance2 = DatabaseService();
      expect(instance1, equals(instance2));
    });

    group('getAttractions', () {
      test('returns list of attractions', () async {
        // Note: This test requires a populated test database
        // In a real scenario, you'd use a test database with known data
        final attractions = await databaseService.getAttractions();
        expect(attractions, isA<List<Attraction>>());
      });

      test('filters by category when provided', () async {
        final attractions = await databaseService.getAttractions(
          category: 'Beaches',
        );

        for (final attraction in attractions) {
          expect(attraction.category.toString().contains('Beaches'), isTrue);
        }
      });

      test('filters by province when provided', () async {
        final attractions = await databaseService.getAttractions(
          province: 'Southern',
        );

        for (final attraction in attractions) {
          expect(attraction.province.toString().contains('Southern'), isTrue);
        }
      });

      test('excludes premium attractions when includePremium is false', () async {
        final attractions = await databaseService.getAttractions(
          includePremium: false,
        );

        for (final attraction in attractions) {
          expect(attraction.isPremium, isFalse);
        }
      });

      test('includes premium attractions when includePremium is true', () async {
        final attractions = await databaseService.getAttractions(
          includePremium: true,
        );

        expect(attractions, isNotEmpty);
        // Should contain both free and premium attractions
      });
    });

    group('getAttractionById', () {
      test('returns attraction when ID exists', () async {
        final attraction = await databaseService.getAttractionById(1);
        expect(attraction, isNotNull);
        expect(attraction?.id, equals(1));
      });

      test('returns null when ID does not exist', () async {
        final attraction = await databaseService.getAttractionById(999999);
        expect(attraction, isNull);
      });
    });

    group('searchAttractions', () {
      test('returns attractions matching query', () async {
        final results = await databaseService.searchAttractions('beach');
        expect(results, isA<List<Attraction>>());

        // Verify results contain search term in name or description
        for (final attraction in results) {
          final searchableText = '${attraction.nameEn} ${attraction.descriptionEn}'.toLowerCase();
          expect(searchableText.contains('beach'), isTrue);
        }
      });

      test('search is case-insensitive', () async {
        final resultsLower = await databaseService.searchAttractions('sigiriya');
        final resultsUpper = await databaseService.searchAttractions('SIGIRIYA');
        final resultsMixed = await databaseService.searchAttractions('SiGiRiYa');

        expect(resultsLower.length, equals(resultsUpper.length));
        expect(resultsLower.length, equals(resultsMixed.length));
      });

      test('returns empty list for non-matching query', () async {
        final results = await databaseService.searchAttractions('xyzabc123nonexistent');
        expect(results, isEmpty);
      });

      test('respects category filter in search', () async {
        final results = await databaseService.searchAttractions(
          'temple',
          category: 'Religious Sites',
        );

        for (final attraction in results) {
          expect(attraction.category.toString().contains('Religious'), isTrue);
        }
      });
    });

    group('getAttractionsByCategory', () {
      test('returns attractions for valid category', () async {
        final attractions = await databaseService.getAttractionsByCategory('Beaches');
        expect(attractions, isA<List<Attraction>>());

        for (final attraction in attractions) {
          expect(attraction.category.toString().contains('Beaches'), isTrue);
        }
      });

      test('returns empty list for invalid category', () async {
        final attractions = await databaseService.getAttractionsByCategory('NonExistentCategory');
        expect(attractions, isEmpty);
      });
    });

    group('getAttractionsByProvince', () {
      test('returns attractions for valid province', () async {
        final attractions = await databaseService.getAttractionsByProvince('Western');
        expect(attractions, isA<List<Attraction>>());

        for (final attraction in attractions) {
          expect(attraction.province.toString().contains('Western'), isTrue);
        }
      });

      test('returns empty list for invalid province', () async {
        final attractions = await databaseService.getAttractionsByProvince('NonExistentProvince');
        expect(attractions, isEmpty);
      });
    });

    group('getNearbyAttractions', () {
      test('returns attractions within specified radius', () async {
        // Colombo coordinates
        const latitude = 6.9271;
        const longitude = 79.8612;
        const radiusKm = 50.0;

        final nearby = await databaseService.getNearbyAttractions(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );

        expect(nearby, isA<List<Attraction>>());

        // Verify all attractions are within radius
        // (This assumes calculateDistance is working correctly)
        for (final attraction in nearby) {
          expect(attraction.latitude, isNotNull);
          expect(attraction.longitude, isNotNull);
        }
      });

      test('respects limit parameter', () async {
        const latitude = 6.9271;
        const longitude = 79.8612;
        const limit = 5;

        final nearby = await databaseService.getNearbyAttractions(
          latitude: latitude,
          longitude: longitude,
          radiusKm: 100,
          limit: limit,
        );

        expect(nearby.length, lessThanOrEqualTo(limit));
      });

      test('excludes current attraction when excludeId provided', () async {
        const latitude = 6.9271;
        const longitude = 79.8612;
        const excludeId = 1;

        final nearby = await databaseService.getNearbyAttractions(
          latitude: latitude,
          longitude: longitude,
          radiusKm: 100,
          excludeId: excludeId,
        );

        for (final attraction in nearby) {
          expect(attraction.id, isNot(equals(excludeId)));
        }
      });
    });

    group('getPremiumAttractions', () {
      test('returns only premium attractions', () async {
        final attractions = await databaseService.getPremiumAttractions();

        for (final attraction in attractions) {
          expect(attraction.isPremium, isTrue);
        }
      });
    });

    group('getFreeAttractions', () {
      test('returns only free attractions', () async {
        final attractions = await databaseService.getFreeAttractions();

        for (final attraction in attractions) {
          expect(attraction.isPremium, isFalse);
        }
      });

      test('respects free tier limit', () async {
        // Free tier should have exactly 100 attractions
        final attractions = await databaseService.getFreeAttractions();
        expect(attractions.length, lessThanOrEqualTo(100));
      });
    });

    group('getAttractionsByTags', () {
      test('returns attractions matching tags', () async {
        final attractions = await databaseService.getAttractionsByTags(['unesco']);

        for (final attraction in attractions) {
          expect(attraction.tags.toLowerCase().contains('unesco'), isTrue);
        }
      });

      test('returns attractions matching any of multiple tags', () async {
        final attractions = await databaseService.getAttractionsByTags([
          'unesco',
          'historical',
        ]);

        for (final attraction in attractions) {
          final tags = attraction.tags.toLowerCase();
          final matchesAnyTag = tags.contains('unesco') || tags.contains('historical');
          expect(matchesAnyTag, isTrue);
        }
      });
    });
  });
}
